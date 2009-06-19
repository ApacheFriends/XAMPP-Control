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

/* PlugIn Stuff */
#import <XAMPP Control/XPPlugInCategories.h>
#import <XAMPP Control/XPPlugInHooks.h>

/* Status und Error (Handling) */
#import <XAMPP Control/XPStatus.h>
#import <XAMPP Control/XPError.h>
#import <XAMPP Control/XPAlert.h>

/* Module */
#import <XAMPP Control/XPModuleViewController.h>
#import <XAMPP Control/XPModule.h>

/* Assistant */
#import <XAMPP Control/AssistantPage.h>
#import <XAMPP Control/AssistantController.h>

/* Security Check */
#import <XAMPP Control/SecurityCheckProtocol.h>
#import <XAMPP Control/SecurityTaskProtocol.h>

/* Utilitys */
#import <XAMPP Control/XPRootTask.h>
#import <XAMPP Control/XPConfiguration.h>
#import <XAMPP Control/XPViewController.h>
#import <XAMPP Control/XPProcessWatcher.h>

/* Additions */
#import <XAMPP Control/NSObject (MainThread).h>
#import <XAMPP Control/NSObject+unproxy.h>
#import <XAMPP Control/NSWorkspace (Process).h>

/* I18N */
#import <XAMPP Control/XPLocalization.h>
