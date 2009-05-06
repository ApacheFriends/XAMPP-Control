/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "XPModuleViewController.h"
#import "StatusView.h"
#import "XPModule.h"

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
		
		startItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Start %@", [module name]]
											   action:@selector(start:)
										keyEquivalent:@""];
		[startItem setTarget:self];
		
		stopItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Stop %@", [module name]]
											  action:@selector(stop:)
									   keyEquivalent:@""];
		[stopItem setTarget:self];
		
		reloadItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Reload %@", [module name]]
												action:@selector(reload:)
										 keyEquivalent:@""];
		[reloadItem setTarget:self];
	}
	return self;
}

- (void) dealloc
{
	[module release];
	
	[super dealloc];
}

- (NSArray*) menuItems
{
	return [NSArray arrayWithObjects:startItem, stopItem, reloadItem, Nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (module == object && [keyPath isEqualToString:@"status"]) {
		// Update status
		[statusView setStatus:[module status]];
		
		switch ([module status]) {
			case XPNotRunning:
				[actionButton setTitle:NSLocalizedString(@"Start", @"Start a Module")];
				[actionButton setEnabled:YES];
				break;
			case XPRunning:
				[actionButton setTitle:NSLocalizedString(@"Stop", @"Stop a Module")];
				[actionButton setEnabled:YES];
				break;
			default:
				[actionButton setEnabled:NO];
				break;
		}
		
		// Update the modules menu
		// we asume thats all the items are in the same menu
		[[startItem menu] update];
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

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	SEL action = [anItem action];
	
	if (action == @selector(start:))
		return ([module status] == XPNotRunning);
	else if (action == @selector(stop:))
		return  ([module status] == XPRunning);
	else if (action == @selector(reload:))
		return ([module status] == XPRunning);
	
	return YES;
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
		[NSApp presentError:error];
	
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
		[NSApp presentError:error];
	
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
		[NSApp presentError:error];
	
	[pool release];
}

@end
