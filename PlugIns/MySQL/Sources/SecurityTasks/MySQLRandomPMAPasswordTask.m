//
//  MySQLRandomPMAPasswordTask.m
//  XAMPP Control
//
//  Created by Christian Speich on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MySQLRandomPMAPasswordTask.h"
#import "MySQLPlugIn.h"
#import "MySQLModule.h"

#include <mysql/mysql.h>

#define PASSWORD_LENGTH (20)

@interface MySQLRandomPMAPasswordTask(PRIVAT)

- (BOOL) createRandomPassword;
- (BOOL) changePasswordInMySQL;
- (BOOL) updatePMAConfig;

@end


@implementation MySQLRandomPMAPasswordTask

- (void) dealloc
{
	[self setPassword:Nil];
	
	[super dealloc];
}


- (NSString*) password
{
	return _password;
}

- (void) setPassword:(NSString*)password
{
	[_password release];
	_password = [password retain];
}

- (NSString*) localizedTitle
{
	return NSLocalizedString(@"SetRandomMySQLPMAPassword", 
							 @"Taskdrscription for the set a random mysql's pma password task.");
}

- (BOOL) run
{
	MySQLPlugIn* plugIn;
	MySQLModule* module;
	NSBundle* bundle;
	NSError* error;
	BOOL shouldStop = NO;
	BOOL success = YES;
	
	
		
	bundle = [NSBundle bundleForClass:[self class]];
	
	plugIn = [[[[PlugInManager sharedPlugInManager] plugInInformations]
			   objectForKey:[bundle bundleIdentifier]]
			  objectForKey:@"instance"];
	module = [plugIn module];
	
	if ([module status] == XPNotRunning) {
		shouldStop = YES;
		error = [module start];
		if (error) {
			[XPAlert presentError:error];
			return NO;
		}
	}
	
	if (![self createRandomPassword]) {
		if (shouldStop)
			[module stop];
		return NO;
	}
	
	if (![self changePasswordInMySQL]) {
		if (shouldStop)
			[module stop];
		return NO;
	}
	
	
	if (shouldStop) {
		// TODO: Missing error check
		[module stop];
	}
	
	return success;
}

@end

@implementation MySQLRandomPMAPasswordTask(PRIVAT)

- (BOOL) createRandomPassword
{
	NSMutableString* password;
	char possibleChars[] = "!#$%&()*+,-./0123456789:;<=>?0@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_abcdefghijklmnopqrstuvwxyz{|}~";
	
	password = [NSMutableString string];
	
	srand ( time(NULL) );
	
	for (int i = 0; i < PASSWORD_LENGTH; i++) {
		[password appendFormat:@"%c", possibleChars[rand()%(sizeof(possibleChars)/sizeof(char))]];
	}
	
	[self setPassword:password];
	
	return YES;
}

- (BOOL) changePasswordInMySQL
{
	MYSQL mysql;
	const char* sql;
	
	mysql_init(&mysql);
	
	if (!mysql_real_connect(&mysql, NULL, "root", "", 
							"mysql", 0, "/Applications/XAMPP/xamppfiles/var/mysql/mysql.sock", 0)) {
		
		NSLog(@"mysql: %s", mysql_error(&mysql));
		
		mysql_close(&mysql);
		return NO;
	}
	
	sql = [[NSString stringWithFormat:@"UPDATE user set Password=password('%@') where User = 'pma';", [self password]] cString];
	
	NSLog(@"%s", sql);
	
	if (mysql_real_query(&mysql, sql, strlen(sql))) {
		NSLog(@"mysql: %s", mysql_error(&mysql));
		
		mysql_close(&mysql);
		return NO;
	}
	
	mysql_close(&mysql);
	return YES;
}

- (BOOL) updatePMAConfig
{
	
}

@end
