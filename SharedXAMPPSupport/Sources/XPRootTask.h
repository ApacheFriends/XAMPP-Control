/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>


@interface XPRootTask : NSObject {
	NSArray			*arguments;
	NSDictionary	*environment;
	NSString		*launchPath;
	NSFileHandle	*communicationsPipe;
	int				terminationStatus;
	pid_t			taskPid;
}

- (NSArray*) arguments;
- (void) setArguments:(NSArray*) arguments;

- (NSDictionary*) environment;
- (void) setEnvironment:(NSDictionary*)enviroment;

- (NSString*) launchPath;
- (void) setLaunchPath:(NSString*)launchPath;

- (NSFileHandle*) communicationsPipe;

- (void) launch;
- (void) waitUntilExit;
- (bool) isRunning;
- (int)  terminationStatus;

@end
