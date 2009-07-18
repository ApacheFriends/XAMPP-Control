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

#import "XPRootTask.h"
#import "NSWorkspace+Additions.h"
#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#include <unistd.h>

static AuthorizationRef authRef = NULL;
static NSLock *authLock = Nil;

@implementation XPRootTask

+ (NSError*) authorize
{
	OSStatus status;
	NSError* error = Nil;
	AuthorizationFlags flags = kAuthorizationFlagDefaults;
	
	if (!authLock)
		authLock = [[NSLock alloc] init];
	
	[authLock lock];
	
	if (authRef == NULL) {
		status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, flags, &authRef);
		
		if (status != errAuthorizationSuccess) {
			[authLock unlock];
			
			if (status == errAuthorizationCanceled) {
				error = [NSError errorWithDomain:NSCocoaErrorDomain 
											code:NSUserCancelledError 
										userInfo:Nil];
			}
			else {
				error = [NSError errorWithDomain:NSOSStatusErrorDomain 
											code:status 
										userInfo:Nil];
			}
			return error;
		}
	}
	
	AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights rights = {1, &items};
	
	flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
	
	status = AuthorizationCopyRights(authRef, &rights, NULL, flags, NULL);
	
	[authLock unlock];
	
	if (status == errAuthorizationCanceled) {
		error = [NSError errorWithDomain:NSCocoaErrorDomain 
									code:NSUserCancelledError 
								userInfo:Nil];
	}
	else if (status != errAuthorizationSuccess) {
		error = [NSError errorWithDomain:NSOSStatusErrorDomain 
									code:status 
								userInfo:Nil];
	}
	
	return error;
}

- (NSError*) authorize
{
	return [[self class] authorize];
}

+ (AuthorizationRef) authorizationRef
{	
	return authRef;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		arguments = Nil;
		environment = Nil;
		launchPath = Nil;
		
		communicationsPipe = Nil;
		terminationStatus = INT_MAX;
		taskPid = -1;
	}
	return self;
}

- (void) dealloc
{
	[arguments release];
	[environment release];
	[launchPath release];
	[communicationsPipe release];
	
	[super dealloc];
}


- (NSArray*) arguments
{
	return arguments;
}

- (void) setArguments:(NSArray*) aArgumentArray
{
	if ([aArgumentArray isEqualToArray:arguments])
		return;
	
	[arguments release];
	arguments = aArgumentArray;
	[arguments retain];
}

- (NSDictionary*) environment
{
	return environment;
}

- (void) setEnvironment:(NSDictionary*) anEnvironmentArray
{
	[environment release];
	environment = anEnvironmentArray;
	[environment retain];
}

- (NSString*) launchPath
{
	return launchPath;
}

- (void) setLaunchPath:(NSString*) aPath
{
	if ([aPath isEqualToString:launchPath])
		return;
	
	[launchPath release];
	launchPath = aPath;
	[launchPath retain];
}

- (NSFileHandle*) communicationsPipe
{
	return communicationsPipe;
}

- (void) launch
{
	AuthorizationRef authorizationRef;
	FILE *pipe;
	OSStatus status;
	const char *helperPath;
	const char **args;
	
	[self authorize];
	
	authorizationRef = [[self class] authorizationRef];
	helperPath = [[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"xproottask-helper-tool"] fileSystemRepresentation];
	
	// Allocate [arguments count] + 2(launchPath, Null) pointers
	args = malloc(sizeof(char*) * ([arguments count]+2));
	args[0] = [launchPath fileSystemRepresentation];
	for(int i = 0; i < [arguments count]; i++)
		args[i+1] = [[arguments objectAtIndex:i] fileSystemRepresentation];
	args[[arguments count]+1] = NULL;

	status = AuthorizationExecuteWithPrivileges(authorizationRef, helperPath, kAuthorizationFlagDefaults, (char**) args, &pipe);
	if (status == errAuthorizationSuccess) {
		// Ok our helper process is running, it sends first his pid
		pid_t pid[1];
		read(fileno(pipe), pid, sizeof(pid));
		taskPid = pid[0];
		
		communicationsPipe = [[NSFileHandle alloc] initWithFileDescriptor:fileno(pipe) closeOnDealloc:YES];
	}
	
	free(args);
}

- (int) terminationStatus
{
	return terminationStatus;
}

- (bool) isRunning
{
	return [[NSWorkspace sharedWorkspace] processIsRunning:taskPid];
}

- (void) waitUntilExit
{
	int status;
	
	waitpid(taskPid, &status, 0);
	
	if (WIFEXITED(status))
		terminationStatus = WEXITSTATUS(status);
}

@end
