//
//  NSFileHandle+OpenAsRoot.h
//  XAMPP Control
//
//  Created by Christian Speich on 26.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileHandle (OpenAsRoot)

+ (id)fileHandleWithRootPrivilegesForUpdatingAtPath:(NSString *)path;

@end
