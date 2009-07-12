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

#import "NSWorkspace+Additions.h"

#include <sys/sysctl.h>
#include <sys/types.h>

@implementation NSWorkspace (Additions)

- (BOOL) processIsRunning:(pid_t)aPID
{
	int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
	
	size_t length = 0;
	
	if (sysctl(name, 4, NULL, &length, NULL, 0) != noErr)
		return NO;
	
	struct kinfo_proc *result = malloc(length);
	
	if (sysctl(name, 4, result, &length, NULL, 0) != noErr)
		return NO;
	
	struct kinfo_proc *tmpInfoProc;
	int i, procCount = length / sizeof(struct kinfo_proc);
	
	for (i=0; i<procCount; i++)
	{
		tmpInfoProc = &result[i];
		
		if (tmpInfoProc->kp_proc.p_pid == aPID)
		{
			free(result);
			return YES;
		}
	}
	
	free(result);
	
	return NO;
}

- (BOOL) portIsUsed:(uint)port
{
	NSTask* bash = [[NSTask new] autorelease];
	NSString* argument;
	
	argument = [NSString stringWithFormat:@"netstat -an | egrep -q \"[.:]%i .*LISTEN\"", port];
	
	[bash setLaunchPath:@"/bin/bash"];
	[bash setArguments:[NSArray arrayWithObjects:@"-c", argument, Nil]];
	
	[bash launch];
	[bash waitUntilExit];
	
	if ([bash terminationStatus] == 0) // egrep returns success == one programm is using port 80
		return YES;
	else
		return NO;
}

@end
