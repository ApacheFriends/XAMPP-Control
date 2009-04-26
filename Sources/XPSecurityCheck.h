//
//  XPSecurityCheck.h
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	XPSecuritySecure = 1,
	XPSecurityUnsecure = 2,
	XPSecurityUnknown = 3,
} XPSecurityStatus;

@interface XPSecurityCheck : NSObject {
	NSView	*formView;
}

// Check the Security
- (void) check;

// Status of the security
- (XPSecurityStatus) status;

- (NSView*) formView;
- (void) setFormView:(NSView*)anView;

// Validate the SecurityCheck Form(View)
- (BOOL) validateError:(NSError**)anError;

// Secure this with the data out of the form
- (BOOL) secureError:(NSError**)anError;

@end
