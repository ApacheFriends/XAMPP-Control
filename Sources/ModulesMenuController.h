//
//  ModulesMenuController.h
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ModulesMenuController : NSObject {
	NSMenu		*menu;
}

- (id) initWithMenu:(NSMenu*)menu;

@end
