//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"

#import "AppConstants.h"
#import "SYNNetworkOperationJsonObject.h"

@interface SYNNetworkEngine : MKNetworkEngine

- (id) initWithDefaultSettings;

- (void) updateHomeScreenOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;

- (void) updateCategoriesOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;

- (void) updateVideosScreenForCategory:(NSString*)categoryId;
- (void) updateChannel: (NSString *) resourceURL;
- (void) updateChannelsScreenForCategory:(NSString*)category;

- (void) searchVideosForTerm:(NSString*)searchTerm;
- (void) searchChannelsForTerm:(NSString*)searchTerm;

- (void) getAutocompleteForHint:(NSString*)hint
                    forResource:(EntityType)entityType
                   withComplete: (MKNKFurtherProcessBlock) completionBlock
                       andError: (MKNKErrorBlock) errorBlock;


@end
