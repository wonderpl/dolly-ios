//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "ChannelOwner.h"
#import "Genre.h"
#import "SYNRegistry.h"
@import Foundation;

@interface SYNMainRegistry : SYNRegistry

- (BOOL) registerIPBasedLocation:(NSString*)locationString;


- (BOOL) registerUserFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerSubscriptionsForCurrentUserFromDictionary: (NSDictionary *) dictionary;

-(BOOL)registerExternalAccountWithCurrentUserFromDictionary:(NSDictionary*)dictionary;

-(BOOL)registerMoodsFromDictionary:(NSDictionary*)dictionary
                 withExistingMoods:(NSArray*)moods;

- (BOOL) registerCommentsFromDictionary: (NSDictionary*) dictionary
                           withExisting: (NSArray*)existingComments
                     forVideoInstanceId: (NSString*)vid;


@end
