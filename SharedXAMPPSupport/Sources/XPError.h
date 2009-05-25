/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

extern NSString *XAMPPControlErrorDomain;
extern NSString* XPErrorLogFileKey;
extern NSString* XPErrorModuleNameKey;

typedef enum _XPError {
	XPNoError,
	XPDidNotStart,
	XPDidNotStop,
	XPDidNotReload,
	XPUnknownError
} XPError;