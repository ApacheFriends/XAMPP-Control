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

#import <Cocoa/Cocoa.h>
#import <XAMPP Control/XAMPP Control.h>

typedef enum {
	AssistantNormalPage = 1,
	AssistantSummaryPage = 2,
	AssistantWoringkPage = 3,
	AssistantConclusionPage = 4,
	AssistantUnknownPage = 5
} AssistantPageType;

@class AssistantController;

@interface AssistantPage : XPViewController {
	AssistantPageType	type;
	AssistantController*assistantController;
	NSString*			title;
	NSString*			stepTitle;
}

- (AssistantPageType) type;
- (void) setType:(AssistantPageType)anType;

- (NSString*) title;
- (void) setTitle:(NSString*)anTitle;

- (NSString*) stepTitle;
- (void) setStepTitle:(NSString*)anStepTitle;

- (AssistantController*) assistantController;
- (void) setAssistantController:(AssistantController*)anController;

- (void) pageWillAppear;
- (void) pageDidAppear;
- (void) pageWillDisappear;
- (void) pageDidDisappear;

// Is the pagecontent valid so that the page can disappear and show the next page
// The error presentation is the task of the assistant page
- (BOOL) valid;

@end
