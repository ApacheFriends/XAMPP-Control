/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends>
 
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
