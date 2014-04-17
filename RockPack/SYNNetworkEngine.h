//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//



#import "AppConstants.h"
#import "SYNAbstractNetworkEngine.h"
#import "SYNNetworkOperationJsonObject.h"
#import "ChannelOwner.h"
#import "SYNNetworkOperationJsonObjectParse.h"

@interface SYNNetworkEngine : SYNAbstractNetworkEngine

#pragma mark - Search

- (MKNetworkOperation *) searchVideosForTerm: (NSString *) searchTerm
                                     inRange: (NSRange) range
                                  onComplete: (MKNKSearchSuccessBlock) completeBlock;


- (MKNetworkOperation *) searchUsersForTerm: (NSString *) searchTerm
                                   andRange: (NSRange) range
                                 onComplete: (MKNKSearchSuccessBlock) completeBlock;

- (MKNetworkOperation *) getAutocompleteForHint: (NSString *) hint
                                    forResource: (EntityType) entityType
                                   withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                                       andError: (MKNKErrorBlock) errorBlock;

#pragma mark - Channel owner

- (void) channelOwnerDataForChannelOwner: (ChannelOwner *) channelOwner
                              onComplete: (MKNKUserSuccessBlock) completeBlock
                                 onError: (MKNKUserErrorBlock) errorBlock;

- (void) channelOwnerSubscriptionsForOwner: (ChannelOwner *) channelOwner
                                  forRange: (NSRange) range
                         completionHandler: (MKNKUserSuccessBlock) completionBlock
                              errorHandler: (MKNKUserErrorBlock) errorBlock;

#pragma mark - Subscriber

- (void) subscribersForUserId: (NSString *) userId
                    channelId: (NSString *) channelId
                     forRange: (NSRange) range
                  byAppending: (BOOL) append
            completionHandler: (MKNKSearchSuccessBlock) completionBlock
                 errorHandler: (MKNKBasicFailureBlock) errorBlock;

- (void) channelDataForUserId: (NSString *) userId
                    channelId: (NSString *) channelId
                      inRange: (NSRange) range
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) videosForChannelForUserId: (NSString *) userId
                         channelId: (NSString *) channelId
                           inRange: (NSRange) range
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) videoForChannelForUserId: (NSString *) userId
                        channelId: (NSString *) channelId
                       instanceId: (NSString *) instanceId
                completionHandler: (MKNKUserSuccessBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) channelsForUserId: (NSString *) userId
                   inRange: (NSRange) range
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;


- (MKNetworkOperation *) videosForGenreId: (NSString *) genreId
                                 forRange: (NSRange) range
                        completionHandler: (MKNKSearchSuccessBlock) completionBlock;

- (MKNetworkOperation *) usersForGenreId: (NSString *) genreId
                                forRange: (NSRange) range
                       completionHandler: (MKNKSearchSuccessBlock) completionBlock;


#pragma mark - Video player HTML update

- (void) updatePlayerSourceWithCompletionHandler: (MKNKUserSuccessBlock) completionBlock
                                    errorHandler: (MKNKUserErrorBlock) errorBlock;

#pragma mark - Search video player info

- (void)likesForVideoId:(NSString *)videoId
				inRange:(NSRange)range
	  completionHandler:(MKNKUserSuccessBlock)completionBlock
		   errorHandler:(MKNKErrorBlock)errorBlock;

- (void)channelsForVideoId:(NSString *)videoId
				   inRange:(NSRange)range
		 completionHandler:(MKNKUserSuccessBlock)completionBlock
			  errorHandler:(MKNKErrorBlock)errorBlock;

#pragma mark - Facebook deep linking

- (void) resolveFacebookLink: (NSString *) facebookLink
           completionHandler: (MKNKUserSuccessBlock) completionBlock
                errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) getMoodsWithCompletionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void)exampleUsersWithCompletionHandler:(MKNKUserSuccessBlock)completionBlock
							 errorHandler:(MKNKUserErrorBlock)errorBlock;



// post comments method is in the oAuthNetworkEngine

- (void) subscriptionsForUserId: (NSString *) userId
						inRange: (NSRange) range
			  completionHandler: (MKNKUserSuccessBlock) completionBlock
				   errorHandler: (MKNKUserErrorBlock) errorBlock;



@end
