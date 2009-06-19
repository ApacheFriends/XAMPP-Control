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

#import <Cocoa/Cocoa.h>

/*
 !
 ! In this file are all public hooks and hook parameters for 
 ! XAMPP Control listed. Please be prepared that parameters
 ! can be [NSNull null] and handle this probbably.
 !
 ! Be warned that undocumented Hooks and parameters can be
 ! changed or removed at any time!
 !
 */

/*

 Is invoked when the Contols Window is loaded and
 configured.
 
 The following parameters are avaiable: 
   - HookWindowKey (NSWindow*)
 
 */
extern NSString* const ControlsWindowDidLoadHook;

/*
 
 Is invoked when the About Window is beeing configured.
 
 The following parameters are avaiable: 
 - HookWindowKey (NSWindow*)
 - HookVersionsStringKey (NSMutableAttributedString*)
 - HookCreditsHTMLKey (NSMutableString*)
 - HookXAMPPLabelKey (NSMutableAttributedString*)
 
 */
extern NSString* const AboutWindowSetupHook;
	extern NSString* const HookVersionsStringKey;
	extern NSString* const HookCreditsHTMLKey;
	extern NSString* const HookXAMPPLabelKey;

/*
 
 Global Hook Keys that are used in many Hooks
 
 */

extern NSString* const HookWindowKey;
