/*
 *  PlugInPriorityProtocol.h
 *  XAMPP Control
 *
 *  Created by Christian Speich on 23.05.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@protocol PlugInPriorityProtocol

/*
  This sets the priority of these Object. High
  values means an _low_ priority. (Just like the
  values for 'nice')
 */
- (int) priority;

/*
  After the priority comparison results equalniss
  the two objects get ordered based on this string
 */
- (NSString*) comparisonString;

@end
