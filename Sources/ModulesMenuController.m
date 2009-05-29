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

#import "ModulesMenuController.h"
#import <PlugIn/PlugInManager.h>
#import <PlugIn/PlugInRegistry.h>
#import <SharedXAMPPSupport/XPPlugInCategories.h>
#import <SharedXAMPPSupport/XPModule.h>
#import <SharedXAMPPSupport/XPModuleAlertController.h>

@interface ModulesMenuController (PRIVAT)

- (void) removeAllStatusObserver;
- (void) updateModules;

@end

NSString *ModulesMenuControllerContext = @"ModulesMenuControllerContext";

@implementation ModulesMenuController

- (id) initWithMenu:(NSMenu*)anMenu
{
	self = [super init];
	if (self != nil) {
		menu = [anMenu retain];
		
		[[[PlugInManager sharedPlugInManager] registry] addObserver:self 
														 forKeyPath:[NSString stringWithFormat:@"plugInCategories.%@", XPModulesPlugInCategorie]
															options:NSKeyValueObservingOptionNew 
															context:ModulesMenuControllerContext];
		
		[self updateModules];
	}
	return self;
}

- (void) dealloc
{
	[self removeAllStatusObserver];
	[menu release];
	
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context != ModulesMenuControllerContext)
		return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	if ([keyPath isEqualToString:[NSString stringWithFormat:@"plugInCategories.%@", XPModulesPlugInCategorie]]) {
		[self updateModules];
	}
	else if ([keyPath isEqualToString:@"status"]) {
		[menu update];
	}
}

- (void) updateModules
{
	NSArray* modules;
	NSEnumerator *modulesEnumerator;
	XPModule *module;

	[self removeAllStatusObserver];
	
	// Clear the old menu
	
	while ([menu numberOfItems])
		[menu removeItemAtIndex:0];
	
	modules = [[[PlugInManager sharedPlugInManager] registry] objectsForCategorie:XPModulesPlugInCategorie];
	modulesEnumerator = [modules objectEnumerator];
	
	while ((module = [modulesEnumerator nextObject])) {
		NSMenuItem* startItem;
		NSMenuItem* stopItem;
		NSMenuItem* reloadItem;
		
		startItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Start %@", @"Start the Module %@"), [module name]]
											   action:@selector(start:) 
										keyEquivalent:@""];
		stopItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Stop %@", @"Stop the Module %@"), [module name]]
											  action:@selector(stop:) 
									   keyEquivalent:@""];
		reloadItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Reload %@", @"Reload the Module %@"), [module name]]
												action:@selector(reload:) 
										 keyEquivalent:@""];
		
		[startItem setTarget:self];
		[startItem setRepresentedObject:module];
		[stopItem setTarget:self];
		[stopItem setRepresentedObject:module];
		[reloadItem setTarget:self];
		[reloadItem setRepresentedObject:module];
		
		[menu addItem:startItem];
		[menu addItem:stopItem];
		[menu addItem:reloadItem];
		
		if (![module isEqual:[modules lastObject]])
			[menu addItem:[NSMenuItem separatorItem]];
		
		[startItem release];
		[stopItem release];
		[reloadItem release];
		
		[module addObserver:self 
				 forKeyPath:@"status" 
					options:NSKeyValueObservingOptionNew 
					context:ModulesMenuControllerContext];
	}
}

- (void) removeAllStatusObserver
{
	NSEnumerator *enumerator = [[menu itemArray] objectEnumerator];
	NSMenuItem *item;
	
	while ((item = [enumerator nextObject])) {
		XPModule *module = [item representedObject];
		
		if ([module isKindOfClass:[XPModule class]])
			[module removeObserver:self forKeyPath:@"status"];
	}
}

#pragma mark Action Methods

- (void) start:(NSMenuItem*)sender
{
	XPModule *module = [sender representedObject];
	
	if (![module isKindOfClass:[XPModule class]]) // Not an module
		return;
	
	[NSThread detachNewThreadSelector:@selector(doStart:) 
							 toTarget:self 
						   withObject:module];
}

- (void) doStart:(XPModule*)module
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	error = [module start];
	
	if (error)
		[XPModuleAlertController presentError:error];
	
	[pool release];
}

- (void) stop:(NSMenuItem*)sender
{
	XPModule *module = [sender representedObject];
	
	if (![module isKindOfClass:[XPModule class]]) // Not an module
		return;
	
	[NSThread detachNewThreadSelector:@selector(doStop:) 
							 toTarget:self 
						   withObject:module];
}

- (void) doStop:(XPModule*)module
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	error = [module stop];
	
	if (error)
		[XPModuleAlertController presentError:error];
	
	[pool release];
}

- (void) reload:(NSMenuItem*)sender
{
	XPModule *module = [sender representedObject];
	
	if (![module isKindOfClass:[XPModule class]]) // Not an module
		return;
	
	[NSThread detachNewThreadSelector:@selector(doReload:) 
							 toTarget:self 
						   withObject:module];
}

- (void) doReload:(XPModule*)module
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	error = [module reload];
	
	if (error)
		[XPModuleAlertController presentError:error];
	
	[pool release];
}

- (BOOL)validateUserInterfaceItem:(NSMenuItem*)anItem
{
	SEL action = [anItem action];
	XPModule *module;
	
	if (![anItem isKindOfClass:[NSMenuItem class]])
		return YES;
	
	module = [anItem representedObject];
	
	if (![module isKindOfClass:[XPModule class]]) // Not an module
		return YES;
	
	if (action == @selector(start:))
		return ([module status] == XPNotRunning);
	else if (action == @selector(stop:))
		return  ([module status] == XPRunning);
	else if (action == @selector(reload:))
		return ([module status] == XPRunning);
	
	return YES;
}

@end
