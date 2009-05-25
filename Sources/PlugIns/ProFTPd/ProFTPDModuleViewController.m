//
//  ProFTPDModuleViewController.m
//  XAMPP Control
//
//  Created by Christian Speich on 23.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProFTPDModuleViewController.h"


@implementation ProFTPDModuleViewController

#pragma mark -
#pragma mark Priority Protocol

- (int) priority
{
	return -1000;
}

- (NSString*) comparisonString
{
	return @"ProFTPD";
}

@end
