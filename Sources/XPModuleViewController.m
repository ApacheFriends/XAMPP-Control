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

#import "XPModuleViewController.h"
#import "StatusIndicatorView.h"
#import "XPModule.h"
#import "XPAlert.h"

@interface XPModuleViewController (PRIVATE)

- (void) updateActionButton;

@end


@implementation XPModuleViewController

- (id) initWithModule:(XPModule*) aModule
{
	NSParameterAssert(aModule != Nil);
	
	self = [self init];
	if (self != nil) {
		module = [aModule retain];
		
		if (![NSBundle loadNibNamed:@"ModuleView" owner:self]) {
			[self release];
			return nil;
		}
		
		[module addObserver:self forKeyPath:@"status" options:Nil context:NULL];
		[self observeValueForKeyPath:@"status" ofObject:module change:Nil context:NULL];
		[nameField setStringValue:[module name]];
	}
	return self;
}

- (void) dealloc
{
	[module release];
	
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (module == object && [keyPath isEqualToString:@"status"]) {
		// Update status
		
		switch ([module status]) {
			case XPNotRunning:
				[actionButton setTitle:NSLocalizedString(@"Start", @"Start a Module")];
				[actionButton setEnabled:YES];
				[statusIndicator setStatus:RedStatus];
				[statusIndicator setToolTip:@"Not Running"];
				break;
			case XPRunning:
				[actionButton setTitle:NSLocalizedString(@"Stop", @"Stop a Module")];
				[actionButton setEnabled:YES];
				[statusIndicator setStatus:GreenStatus];
				[statusIndicator setToolTip:NSLocalizedString(@"Running", @"Module is Running ToolTip")];
				break;
			case XPStarting:
				[actionButton setEnabled:NO];
				[statusIndicator setStatus:WorkingStatus];
				[statusIndicator setToolTip:NSLocalizedString(@"Starting", @"Module is Starting ToolTip")];
				break;
			case XPStopping:
				[actionButton setEnabled:NO];
				[statusIndicator setStatus:WorkingStatus];
				[statusIndicator setToolTip:NSLocalizedString(@"Stopping", @"Module is Stopping ToolTip")];
				break;
			default:
				[actionButton setEnabled:NO];
				[statusIndicator setStatus:UnknownStatus];
				[statusIndicator setToolTip:NSLocalizedString(@"Unknown", @"Module is in a Unknown Stat ToolTip")];
				break;
		}
	}
}

- (IBAction) action:(id)sender
{
	switch ([module status]) {
		case XPNotRunning:
			[self start:sender];
			break;
		case XPRunning:
			[self stop:sender];
			break;
		default:
			break;
	}
}

- (IBAction) reload:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(doReload) 
							 toTarget:self 
						   withObject:Nil];
}

- (void) doReload
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	error = [module reload];
	
	if (error)
		[XPAlert presentError:error];
	
	[pool release];
}

- (IBAction) start:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(doStart) 
							 toTarget:self 
						   withObject:Nil];
}

- (void) doStart
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	error = [module start];
	
	if (error)
		[XPAlert presentError:error];
	
	[pool release];
}

- (IBAction) stop:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(doStop) 
							 toTarget:self 
						   withObject:Nil];
}

- (void) doStop
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	error = [module stop];
	
	if (error)
		[XPAlert presentError:error];
	
	[pool release];
}

@end

