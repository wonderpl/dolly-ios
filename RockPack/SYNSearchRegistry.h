//
//  SYNSearchRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNRegistry.h"

@interface SYNSearchRegistry : SYNRegistry

- (BOOL) registerVideoInstancesFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerUsersFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerSubscribersFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerFriendsFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerRecommendationsFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerVideoInstancesFromDictionary: (NSDictionary *) dictionary withViewId:(NSString*)viewId;


- (NSMutableDictionary *) registerFriendsFromAddressBookArray: (NSArray *) abArray;

@end
