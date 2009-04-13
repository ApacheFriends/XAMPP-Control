/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "NSWorkspace (Process).h"

#include <sys/sysctl.h>
#include <sys/types.h>

@implementation NSWorkspace (Process)

- (bool) processIsRunning:(pid_t)aPID
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

@end
