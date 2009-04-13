/*
 *  xproottask-helper-tool.c
 *  XAMPP Control
 *
 *  Created by Christian Speich on 08.02.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include <unistd.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	setuid(0);
	pid_t pid[1];
	pid[0] = getpid();
	
	// Make stderr and stdout the same
	dup2(STDOUT_FILENO, STDERR_FILENO);
	
	write(STDOUT_FILENO, pid, sizeof(pid));
	
	// Remove the first element in the argv array an execute the task
	for (int i = 1; i < argc; i++) {
		argv[i-1] = argv[i];
	}
	argv[argc-1] = NULL;
	
	execv(argv[0], argv);
	
	exit(-1);
}
