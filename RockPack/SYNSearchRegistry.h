//
//  SYNSearchRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"
#import "ChannelOwner.h"

@interface SYNSearchRegistry : SYNRegistry

-(BOOL)registerVideosFromDictionary:(NSDictionary *)dictionary;
-(BOOL)registerChannelFromDictionary:(NSDictionary *)dictionary;

-(BOOL)registerChannelFromDictionary:(NSDictionary *)dictionary withViewId:(NSString*)viewId;
-(BOOL)registerChannelFromDictionary:(NSDictionary *)dictionary withViewId:(NSString*)viewId andOwner:(ChannelOwner*)owner;

@end
