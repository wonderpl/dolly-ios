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
- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerUsersFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerSubscribersFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerFriendsFromDictionary: (NSDictionary *) dictionary;

- (NSCache *) registerFriendsFromAddressBookArray: (NSArray *) abArray;

@end
