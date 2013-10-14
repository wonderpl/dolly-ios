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

- (BOOL) registerVideosFromDictionary: (NSDictionary *) dictionary;
- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerUsersFromDictionary: (NSDictionary *) dictionary
                         byAppending: (BOOL) append;

- (BOOL) registerSubscribersFromDictionary: (NSDictionary *) dictionary
                               byAppending: (BOOL) append;

- (BOOL) registerFriendsFromDictionary: (NSDictionary *) dictionary;

- (NSCache *) registerFriendsFromAddressBookArray: (NSArray *) abArray;

@end
