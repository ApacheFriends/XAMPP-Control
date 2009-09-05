/*
 
  The PlugIn Framework
  Copyright (C) 2009 by Christian Speich <kleinweby@kleinweby.de>
 
  This file is part of the PlugIn Framework.
 
  The PlugIn Framework is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
 
  The PlugIn Framework is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Lesser General Public License for more details.
 
  You should have received a copy of the GNU Lesser General Public License
  along with the PlugIn Framework.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import <Foundation/Foundation.h>

#import <PlugIn/PlugInManager.h>
#import <PlugIn/PlugInRegistry.h>
#import <PlugIn/PlugInPriorityProtocol.h>

@interface PlugIn : NSObject {
	NSDictionary *_registryInfo;
}

- (BOOL) setupError:(NSError**)anError;
- (NSDictionary*) registryInfo;
- (void) setRegistryInfo:(NSDictionary*)registryInfo;

@end
