//
//  PlugIn.h
//  XAMPP Control
//
//  Created by Christian Speich on 21.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <PlugIn/PlugInManager.h>
#import <PlugIn/PlugInRegistry.h>

@interface PlugIn : NSObject {

}

- (BOOL) setupError:(NSError**)anError;
- (NSDictionary*) registryInfo;

@end
