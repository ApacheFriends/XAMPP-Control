//
//  NSFileHandle+OpenAsRoot.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSFileHandle+OpenAsRoot.h"
#import "XPRootTask.h"
#include <sys/socket.h>
#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#include <unistd.h>

/* ---- Thanks to apple for the fd receiving code ---- */

// When we pass a descriptor, we have to pass at least one byte
// of data along with it, otherwise the recvmsg call will not
// block if the descriptor hasn't been written to the other end
// of the socket yet.

static const char kDummyData = 'D';

// Due to a kernel bug in Mac OS X 10.4.x and earlier
// <rdar://problem/4650646>, you will run into problems if you write
// data to a socket while a process is trying to receive a descriptor
// from that socket.  A common symptom of this problem is that, if
// you write two descriptors back-to-back, the second one just
// disappears.
//
// To avoid this problem, we explicitly ACK all descriptor transfers.
// After writing a descriptor, the sender reads an ACK byte from the
// socket.  After reading a descriptor, the receiver sends an ACK byte
// (kACKData) to unblock the sender.

static const char kACKData   = 'A';

static bool kWorkaround4650646 = true;

static int ReadDescriptor(int fd, int *fdRead)
// Read a descriptor from fd and place it in *fdRead.
//
// On success, the caller is responsible for closing *fdRead.
{
    int                 err;
    int                 junk;
    struct msghdr       msg;
    struct iovec        iov;
    struct {
        struct cmsghdr  hdr;
        int             fd;
    }                   control;
    char                dummyData;
    ssize_t             bytesReceived;
	
    // Pre-conditions
	
    assert(fd >= 0);
    assert( fdRead != NULL);
    assert(*fdRead == -1);
	
    // Read a single byte of data from the socket, with the assumption
    // that this byte has piggybacked on to it a single descriptor that
    // we're trying to receive.  This is pretty much standard boilerplate
    // code for reading descriptors; see <x-man-page://2/recv> for details.
	
    iov.iov_base = (char *) &dummyData;
    iov.iov_len  = sizeof(dummyData);
	
    msg.msg_name       = NULL;
    msg.msg_namelen    = 0;
    msg.msg_iov        = &iov;
    msg.msg_iovlen     = 1;
    msg.msg_control    = &control;
    msg.msg_controllen = sizeof(control);
    msg.msg_flags      = MSG_WAITALL;
	
    do {
        bytesReceived = recvmsg(fd, &msg, 0);
        if (bytesReceived == sizeof(dummyData)) {
            if (   (dummyData != kDummyData)
                || (msg.msg_flags != 0)
                || (msg.msg_control == NULL)
                || (msg.msg_controllen != sizeof(control))
                || (control.hdr.cmsg_len != sizeof(control))
                || (control.hdr.cmsg_level != SOL_SOCKET)
                || (control.hdr.cmsg_type  != SCM_RIGHTS)
                || (control.fd < 0) ) {
                err = EINVAL;
            } else {
                *fdRead = control.fd;
                err = 0;
            }
        } else if (bytesReceived == 0) {
            err = EPIPE;
        } else {
            assert(bytesReceived == -1);
			
            err = errno;
            assert(err != 0);
        }
    } while (err == EINTR);
	
    // Send the ACK.  If that fails, we have to act like we never got the
    // descriptor in our to ensure consistent results for our caller.
	
    if ( (err == 0) && kWorkaround4650646) {
        do {
            if ( write(fd, &kACKData, sizeof(kACKData)) == -1 ) {
                err = errno;
            }
        } while (err == EINTR);
		
        if (err != 0) {
            junk = close(*fdRead);
            assert(junk == 0);
            *fdRead = -1;
        }
    }
	
    // Post condition
	
    assert( (err == 0) == (*fdRead >= 0) );
	
    return err;
}

@implementation NSFileHandle (OpenAsRoot)

+ (id)fileHandleWithRootPrivilegesForUpdatingAtPath:(NSString *)path
{
	AuthorizationRef authorizationRef;
	FILE *pipe;
	OSStatus status;
	const char *helperPath;
	const char *args[] = {
		[path fileSystemRepresentation]
	};
	NSFileHandle* handle =  Nil;
	
	[XPRootTask authorize];
	
	authorizationRef = [XPRootTask authorizationRef];
	helperPath = [[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"open-helper-tool"] fileSystemRepresentation];
	status = AuthorizationExecuteWithPrivileges(authorizationRef, helperPath, kAuthorizationFlagDefaults, (char**) args, &pipe);
	if (status == errAuthorizationSuccess) {
		// Ok our helper process is running, it sends us the file descriptor
		int fd = -1;
		
		ReadDescriptor(fileno(pipe), &fd);
		
		if (fd >= 0)
			handle = [[[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES] autorelease];
		
		fclose(pipe);
	}
	
	return handle;
}

@end
