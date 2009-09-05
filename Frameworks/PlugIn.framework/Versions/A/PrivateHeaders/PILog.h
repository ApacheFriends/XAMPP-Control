/*
 
 The PlugIn Framework
 Copyright (C) 2009 by Christian Speich <kleinweby@kleinweby.de>
 
 This file is part of the PlugIn Framework.
 
 The PlugIn Framework is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 The PlugIn Framework is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with the PlugIn Framework.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import <Cocoa/Cocoa.h>

enum _PILogLevel {
	PIErrorLogLevel = 1,
	PIWarnLogLevel,
	PINoticeLogLevel,
	PIDebugLogLevel,
	PIMaxLogLevel = 200
};

typedef enum _PILogLevel PILogLevel;

void PILog(PILogLevel level, NSString* format, ...);
void PILogv(PILogLevel level, NSString* format, va_list args);

void PIDebugLog(NSString* format, ...);
void PIWarnLog(NSString* format, ...);
void PINoticeLog(NSString* format, ...);
void PIErrorLog(NSString* format, ...);

void PISetMaxShownLogLevel(PILogLevel level);
void PISetMessageDriver(void (*driver)(PILogLevel, NSString*));
