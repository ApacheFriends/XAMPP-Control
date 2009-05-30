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

#import "AssistantPage.h"


@implementation AssistantPage

- (void) dealloc
{
	[self setTitle:Nil];
	[self setStepTitle:Nil];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Getter and Setter

- (AssistantPageType) type
{
	return type;
}

- (void) setType:(AssistantPageType)anType
{	
	type = anType;
}

- (NSString*) title
{
	return title;
}

- (void) setTitle:(NSString*)anTitle
{	
	if ([anTitle isEqualToString:title])
		return;
	
	[title release];
	title = [anTitle retain];
}

- (NSString*) stepTitle;
{
	return stepTitle;
}

- (void) setStepTitle:(NSString*)anStepTitle
{
	if ([anStepTitle isEqualToString:stepTitle])
		return;
	
	[stepTitle release];
	stepTitle = [anStepTitle retain];
}

- (AssistantController*) assistantController
{
	return assistantController;
}

- (void) setAssistantController:(AssistantController*)anController
{
	assistantController = anController;
}

#pragma mark -

- (void) pageWillAppear
{ 
}

- (void) pageDidAppear
{
}

- (void) pageWillDisappear
{
}

- (void) pageDidDisappear
{
}

- (BOOL) valid
{
	return YES;
}

@end
