//
//  SYNOAuthNetworkEngine.h
//  oauth2demo-iOS
//
//  Created by Nick Banks on 21/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "SYNAbstractNetworkEngine.h"
#import "AbstractCommon.h"
#import "Friend.h"
#import <FacebookSDK/FacebookSDK.h>

typedef void (^SYNOAuth2CompletionBlock)(NSError *error);
typedef void (^SYNOAuth2RefreshCompletionBlock)(NSError *error);

@interface SYNOAuthNetworkEngine : SYNAbstractNetworkEngine

- (void) enqueueSignedOperation: (MKNetworkOperation *) request;
- (void) enqueueSignedOperation: (MKNetworkOperation *) request withForceReload:(BOOL) relaod;

- (void) registerUserWithData: (NSDictionary *) userData
            completionHandler: (MKNKLoginCompleteBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doSimpleLoginForUsername: (NSString *) username
                      forPassword: (NSString *) password
                completionHandler: (MKNKLoginCompleteBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doFacebookLoginWithAccessToken: (NSString *) facebookAccessToken
                                expires: (NSDate *) expirationDate
                            permissions: (NSArray *) permissions
                      completionHandler: (MKNKLoginCompleteBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doTwitterLoginWithAccessToken: (NSString *) twitterAccessToken
                     completionHandler: (MKNKLoginCompleteBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) doRequestPasswordResetForUsername: (NSString *) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock;

- (void) doRequestUsernameAvailabilityForUsername: (NSString *) username
                                completionHandler: (MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKErrorBlock) errorBlock;
// User information

- (void) retrieveAndRegisterUserFromCredentials: (SYNOAuth2Credential *) credentials
                              completionHandler: (MKNKUserSuccessBlock) completionBlock
                                   errorHandler: (MKNKUserErrorBlock) errorBlock;

// Avatars

- (void) updateAvatarForUserId: (NSString *) userId
                         image: (UIImage *) image
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock;

//Profile Cover

- (void) updateProfileCoverForUserId: (NSString *) userId
                               image: (UIImage *) image
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock;


// Channel creation


- (void) channelCreatedForUserId: (NSString *) userId
                       channelId: (NSString *) channelId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) channelDataForUserId: (NSString *) userId
                    channelId: (NSString *) channelId
                      inRange: (NSRange) range
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) createChannelForUserId: (NSString *) userId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updatePrivacyForChannelForUserId: (NSString *) userId
                                channelId: (NSString *) channelId
                                 isPublic: (BOOL) isPublic
                        completionHandler: (MKNKUserSuccessBlock) completionBlock
                             errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) deleteChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

- (MKNetworkOperation *) updateRecommendedChannelsScreenForUserId: (NSString *) userId
                                                         forRange: (NSRange) range
                                                    ignoringCache: (BOOL) ignore
                                                     onCompletion: (MKNKJSONCompleteBlock) completeBlock
                                                          onError: (MKNKJSONErrorBlock) errorBlock;

- (void) channelsForUserId: (NSString *) userId
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

- (void) updateVideosForUserId: (NSString *) userId
                               forChannelID: (NSString *) channelId
                        videoInstanceSet: (NSOrderedSet *) videoInstanceSet
                           clearPrevious: (BOOL) clearPrevious
                       completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) userDataForUser: (User *) user
                 inRange: (NSRange) range
            onCompletion: (MKNKUserSuccessBlock) completionBlock
                 onError: (MKNKUserErrorBlock) errorBlock;

- (void) userSubscriptionsForUser: (User *) user
                     onCompletion: (MKNKUserSuccessBlock) completionBlock
                          onError: (MKNKUserErrorBlock) errorBlock;

- (void)updateVideosForUserId:(NSString *)userId
				 forChannelId:(NSString *)channelId
			 videoInstanceIds:(NSArray *)videoInstanceIds
				clearPrevious:(BOOL)clearPrevious
			completionHandler:(MKNKUserSuccessBlock)completionBlock
				 errorHandler:(MKNKUserErrorBlock)errorBlock;

// User activity

- (void) recordActivityForUserId: (NSString *) userId
                          action: (NSString *) action
                 videoInstanceId: (NSString *) videoInstanceId
                    trackingCode: (NSString *) trackingCode
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) recordActivityForUserId: (NSString *) userId
                          action: (NSString *) action
               channelInstanceId: (NSString *) channelInstanceId
                    trackingCode: (NSString *) trackingCode
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) activityForUserId: (NSString *) userId
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) notificationsFromUserId: (NSString *) userId
               completionHandler: (MKNKUserErrorBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) markAsReadForNotificationIndexes: (NSArray *) indexes
                               fromUserId: (NSString *) userId
                        completionHandler: (MKNKUserErrorBlock) completionBlock
                             errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) changeUserField: (NSString *) userField
                 forUser: (User *) user
            withNewValue: (id) newValue
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) changeUserPasswordWithOldValue: (NSString *) oldPassword
                            andNewValue: (NSString *) newValue
                              forUserId: (NSString *) userid
                      completionHandler: (MKNKUserSuccessBlock) successBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) feedUpdatesForUserId: (NSString *) userId
                        start: (NSUInteger) start
                         size: (NSUInteger) size
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

// Flags

- (void) getFlagsforUseId: (NSString *) userId
        completionHandler: (MKNKUserSuccessBlock) completionBlock
             errorHandler: (MKNKUserSuccessBlock) errorBlock;

- (void)	  setFlag: (NSString *) flag
         withValue: (BOOL) value
          forUseId: (NSString *) userId
 completionHandler: (MKNKUserSuccessBlock) completionBlock
      errorHandler: (MKNKUserSuccessBlock) errorBlock;

- (void) subscriptionsForUserId: (NSString *) userId
                               inRange: (NSRange) start
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;


// Subscriptions

- (void) channelSubscriptionsForUserId: (NSString *) userId
                            credential: (SYNOAuth2Credential *) credential
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) channelSubscribeForUserId: (NSString *) userId
                         channelId: (NSString *) channelId
                  withTrackingCode: (NSString *) trackingCode
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) channelUnsubscribeForUserId: (NSString *) userId
                           channelId: (NSString *) channelId
                	withTrackingCode: (NSString *) trackingCode
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) subscriptionsUpdatesForUserId: (NSString *) userId
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) shareLinkWithObjectType: (NSString *) objectType
                        objectId: (NSString *) objectId
					trackingCode: (NSString *) trackingCode
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) emailShareWithObjectType: (NSString *) shareType
                         objectId: (NSString *) objectId
                       withFriend: (Friend *) friendToShare
                completionHandler: (MKNKUserSuccessBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock;

- (MKNetworkOperation *) updateChannel: (NSString *) resourceURL
                       forVideosLength: (NSInteger) length
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) reportConcernForUserId: (NSString *) userId
                     objectType: (NSString *) objectType
                       objectId: (NSString *) objectId
                         reason: (NSString *) reason
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) reportPlayerErrorForVideoInstanceId: (NSString *) videoInstanceId
                            errorDescription: (NSString *) errorDescription
                           completionHandler: (MKNKUserSuccessBlock) completionBlock
                                errorHandler: (MKNKUserErrorBlock) errorBlock;

- (SYNNetworkOperationJsonObject *) friendsForUser: (User *) user
                                        onlyRecent: (BOOL) recent
                                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                                      errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) subscribeAllForUserId: (NSString *) userId
                     subUserId: (NSString *) subUserId
              withTrackingCode: (NSString *) trackingCode
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) unsubscribeAllForUserId: (NSString *) userId
                       subUserId: (NSString *) subUserId
                withTrackingCode: (NSString *) trackingCode
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

#pragma mark - External Accounts

- (void) updateApplePushNotificationForUserId: (NSString *) userId
                                        token: (NSString *) token
                            completionHandler: (MKNKUserSuccessBlock) completionBlock
                                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) connectFacebookAccountForUserId: (NSString *) userId
                      andAccessTokenData: (FBAccessTokenData *) data
                       completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) connectExternalAccoundForUserId: (NSString *) userId
                             accountData: (NSDictionary *) accountData
                       completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) getExternalAccountForUserId: (NSString *) userId
                           accountId: (NSString *) accountId
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) getExternalAccountForUrl: (NSString *) urlString
                completionHandler: (MKNKUserSuccessBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock;

#pragma mark - Feedback Form

- (void) sendFeedbackForMessage: (NSString *) userId
                       andScore: (NSNumber*)score
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

#pragma mark - Recommendations Form

- (void) getRecommendationsForUserId: (NSString*) userId
                       andEntityName: (NSString*) entityName
                              params: (NSDictionary*) params // aplies to the mood
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock;

// getting comments is in the NetworkEngine

- (void) postCommentForUserId:(NSString*)userId
                    channelId:(NSString*)channelId
                   andVideoId:(NSString*)videoId
                  withComment:(NSString*)comment
            completionHandler:(MKNKUserSuccessBlock) completionBlock
                 errorHandler:(MKNKUserErrorBlock) errorBlock;

- (void) deleteCommentForUserId:(NSString*)userId
                      channelId:(NSString*)channelId
                        videoId:(NSString*)videoId
                   andCommentId:(NSString*)commentId
              completionHandler:(MKNKUserSuccessBlock) completionBlock
                   errorHandler:(MKNKUserErrorBlock) errorBlock;



@end
