//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//



#import "AppConstants.h"
#import "SYNAbstractNetworkEngine.h"
#import "SYNNetworkOperationJsonObject.h"
#import "ChannelOwner.h"

@interface SYNNetworkEngine : SYNAbstractNetworkEngine

- (void) updateCategoriesOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;

- (void) updateVideosScreenForCategory: (NSString*) categoryId;
- (void) updateChannel: (NSString *) resourceURL;

- (void) updateChannelsScreenForCategory:(NSString*)categoryId
                                forRange:(NSRange)range
                            onCompletion:(MKNKJSONCompleteBlock)completeBlock
                                 onError:(MKNKJSONErrorBlock)errorBlock;

- (void) searchVideosForTerm: (NSString*) searchTerm;
- (void) searchChannelsForTerm: (NSString*) searchTerm;

- (void) getAutocompleteForHint: (NSString*)hint
                    forResource: (EntityType)entityType
                   withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                       andError: (MKNKErrorBlock) errorBlock;

-(void)userPublicChannelsByOwner:(ChannelOwner*)channelOwner;

@end
