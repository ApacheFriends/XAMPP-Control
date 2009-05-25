/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "XPRootTask.h"
#import "NSWorkspace (Process).h"
#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#include <unistd.h>

static AuthorizationRef authRef = NULL;
static NSLock *authLock = Nil;

@implementation XPRootTask

+ (AuthorizationRef) authorizationRef
{
	OSStatus status;
	AuthorizationFlags flags = kAuthorizationFlagDefaults;
	
	if (!authLock)
		authLock = [[NSLock alloc] init];
	
	[authLock lock];
	
	if (authRef == NULL) {
		status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, flags, &authRef);
		
		if (status != errAuthorizationSuccess) {
			[authLock unlock];
			return false;
		}
	}
	
	AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights rights = {1, &items};
	
	flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
		
	status = AuthorizationCopyRights(authRef, &rights, NULL, flags, NULL);
	
	[authLock unlock];
	
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
	
	authorizationRef = [XPRootTask authorizationRef];
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
