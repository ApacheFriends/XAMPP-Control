/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends.org>
 
 This file is part of XAMPP.
 
 XAMPP is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 XAMPP is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with XAMPP.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <assert.h>

/* ---- Thanks to apple for the fd sending code ---- */

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

static _Bool kWorkaround4650646 = 1;

static int WriteDescriptor(int fd, int fdToWrite)
// Write the descriptor fdToWrite to fd.
{
    int                 err;
    struct msghdr       msg;
    struct iovec        iov;
    struct {
        struct cmsghdr  hdr;
        int             fd;
    }                   control;
    ssize_t             bytesSent;
    char                ack;
	
    // Pre-conditions
	
    assert(fd >= 0);
    assert(fdToWrite >= 0);
	
    control.hdr.cmsg_len   = sizeof(control);
    control.hdr.cmsg_level = SOL_SOCKET;
    control.hdr.cmsg_type  = SCM_RIGHTS;
    control.fd             = fdToWrite;
	
    iov.iov_base = (char *) &kDummyData;
    iov.iov_len  = sizeof(kDummyData);
	
    msg.msg_name       = NULL;
    msg.msg_namelen    = 0;
    msg.msg_iov        = &iov;
    msg.msg_iovlen     = 1;
    msg.msg_control    = &control;
    msg.msg_controllen = control.hdr.cmsg_len;
    msg.msg_flags      = 0;
    do {
        bytesSent = sendmsg(fd, &msg, 0);
        if (bytesSent == sizeof(kDummyData)) {
            err = 0;
        } else {
            assert(bytesSent == -1);
			
            err = errno;
            assert(err != 0);
        }
    } while (err == EINTR);
	
    // After writing the descriptor, try to read an ACK back from the
    // recipient.  If that fails, or we get the wrong ACK, we've failed.
	
    if ( (err == 0) && kWorkaround4650646 ) {
        do {
            ssize_t     bytesRead;
			
            bytesRead = read(fd, &ack, sizeof(ack));
            if (bytesRead == 0) {
                err = EPIPE;
            } else if (bytesRead == -1) {
                err = errno;
            }
        } while (err == EINTR);
		
        if ( (err == 0) && (ack != kACKData) ) {
            err = EINVAL;
        }
    }
	
    return err;
}

int main(int argc, char **argv) {
	int fd;
	
	if (argc != 2) {
		int result[1] = { 500+argc };
		write(STDOUT_FILENO, result, sizeof(result));
		return 1;
	}
	
	fd = open(argv[1], O_CREAT | O_RDWR);
	
	if (fd < 0) {
		int result[1] = { 2 };
		write(STDOUT_FILENO, result, sizeof(result));
		return 2;
	}
	
	int result[1] = { 0 };
	write(STDOUT_FILENO, result, sizeof(result));
	
	WriteDescriptor(STDOUT_FILENO, fd);
	
	//close(fd);
	
	return 0;
}
