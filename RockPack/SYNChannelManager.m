//
//  SYNChannelManager.m
//  rockpack
//
//  Created by Michael Michailidis on 23/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "MKNetworkOperation.h"
#import "SYNAppDelegate.h"
#import "SYNChannelManager.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "VideoInstance.h"
#import "SYNMasterViewController.h"

@interface SYNChannelManager ()

@property (nonatomic, weak) SYNAppDelegate *appDelegate;
@property (nonatomic, weak) MKNetworkOperation *channelUpdateOperation;
@property (nonatomic, weak) MKNetworkOperation *channelOwnerUpdateOperation;

@end


@implementation SYNChannelManager

@synthesize appDelegate;

#pragma mark - Object lifecycle

+ (id) manager
{
    return [[self alloc] init];
}


- (id) init
{
    if ((self = [super init]))
    {
        self.appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelSubscribeRequest:)
                                                     name: kChannelSubscribeRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelUpdateRequest:)
                                                     name: kChannelUpdateRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelOwnerUpdateRequest:)
                                                     name: kChannelOwnerUpdateRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelDeleteRequest:)
                                                     name: kChannelDeleteRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(userSubscribeRequest:)
                                                     name: kChannelOwnerSubscribeToUserRequest
                                                   object: nil];

    }
    
    return self;
}


- (void) dealloc
{
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - Notification Handlers

- (void) channelSubscribeRequest: (NSNotification *) notification
{
    Channel *channelToSubscribe = (Channel *) [notification userInfo][kChannel];
    
    if (!channelToSubscribe)
    {
        return;
    }
    
    // toggle subscription from/to channel //
    if (channelToSubscribe.subscribedByUserValue == YES)
    {
        [self unsubscribeFromChannel: channelToSubscribe];
    }
    else
    {
        [self subscribeToChannel: channelToSubscribe];
    }
    
}

- (void) userSubscribeRequest: (NSNotification *) notification
{
    
    
    ChannelOwner *channelOwnerToSubscribe = (ChannelOwner *) [notification userInfo][kChannelOwner];
    
    if (!channelOwnerToSubscribe)
    {
        return;
    }
    
    if (!channelOwnerToSubscribe.subscribedByUser) {
        [self subscribeToUser: (ChannelOwner*) channelOwnerToSubscribe ];

    }
    else
    {
        [self unsubscribeToUser: (ChannelOwner*) channelOwnerToSubscribe ];

        
    }
    
}



// update another user's profile channels //

- (void) channelOwnerUpdateRequest: (NSNotification *) notification
{
    
    ChannelOwner *channelOwner = (ChannelOwner *) [notification userInfo][kChannelOwner];
    
    if (!channelOwner)
    {
        return;
    }
    
    [self updateChannelsForChannelOwner: channelOwner];
}

- (void) channelUpdateRequest: (NSNotification *) notification
{
    Channel *channelToUpdate = (Channel *) [notification userInfo][kChannel];
    
    if (!channelToUpdate)
    {
        if (self.channelUpdateOperation)
        {
            [self.channelUpdateOperation cancel];
        }
        
        return;
    }
    
    // If the channel to be updated is not yet created then update it based on the videoQueue objects, else make a network call
    Channel *currentlyCreatingChannel = appDelegate.videoQueue.currentlyCreatingChannel;
    
    if ([channelToUpdate.uniqueId isEqualToString: currentlyCreatingChannel.uniqueId])
    {
        [channelToUpdate.videoInstancesSet enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
             [((VideoInstance *) obj).managedObjectContext deleteObject : obj];
         }];
        
        for (VideoInstance *vi in currentlyCreatingChannel.videoInstances)
        {
            VideoInstance *copyOfVideoInstance = [VideoInstance instanceFromVideoInstance: vi
                                                                usingManagedObjectContext: channelToUpdate.managedObjectContext
                                                                      ignoringObjectTypes: kIgnoreChannelObjects];
            
            [channelToUpdate.videoInstancesSet addObject: copyOfVideoInstance];
        }
        
        NSError *error;
        [channelToUpdate.managedObjectContext save: &error];
        
        return;
    }
    else
    {
        [self  updateChannel: channelToUpdate
            withForceRefresh: channelToUpdate.hasChangedSubscribeValue];
    }
}


- (void) channelDeleteRequest: (NSNotification *) notification
{
    Channel *channelToUpdate = (Channel *) [notification userInfo][kChannel];
    
    if (!channelToUpdate)
    {
        return;
    }
    
    [self deleteChannel: channelToUpdate];
}


#pragma mark - Implementation Methods

- (void) subscribeToChannel: (Channel *) channel
{
    // To prevent crashes that would occur when faulting object that have disappeared
//    NSManagedObjectID *channelObjectId = channel.objectID;
//    NSManagedObjectContext *channelObjectMOC = channel.managedObjectContext;
//    
//    [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
//                                                   channelURL: channel.resourceURL
//                                            completionHandler: ^(NSDictionary *responseDictionary) {
//												
//                                                NSError *error = nil;
//                                                Channel *channelFromId = (Channel *)[channelObjectMOC existingObjectWithID: channelObjectId
//                                                                                                                          error: &error];
//                                                
//                                                if (channelFromId)
//                                                {
//                                                    // This notifies the ChannelDetails through KVO
//                                                    channelFromId.hasChangedSubscribeValue = YES;
//                                                    channelFromId.subscribedByUserValue = YES;
//                                                    channelFromId.subscribersCountValue += 1;
//                                                    
//                                                    // the channel that got updated was a copy inside the ChannelDetails, so we must copy it to user
//                                                    IgnoringObjects copyFlags = kIgnoreVideoInstanceObjects;
//                                                    
//                                                    Channel *subscription = [Channel instanceFromChannel: channelFromId
//                                                                                               andViewId: kProfileViewId
//                                                                               usingManagedObjectContext: appDelegate.currentUser.managedObjectContext
//                                                                                     ignoringObjectTypes: copyFlags];
//
//                                                    subscription.hasChangedSubscribeValue = YES;
//                                                    
//                                                    [appDelegate.currentUser addSubscriptionsObject: subscription];
//                                                    
//                                                    // might be in search context
//                                                    [channelFromId.managedObjectContext save: &error];
//                                                    
//                                                    if (error)
//                                                    {
//                                                        [[NSNotificationCenter defaultCenter] postNotificationName: kUpdateFailed
//                                                                                                            object: self];
//                                                    }
//                                                    else
//                                                    {
//                                                        [appDelegate saveContext: YES];
//                                                    }
//                                                }
//                                                else
//                                                {
//                                                    DebugLog (@"Channel disappeared from underneath us");
//                                                }
//                                                
//                                            } errorHandler: ^(NSDictionary *errorDictionary) {
//                                                [[NSNotificationCenter defaultCenter] postNotificationName: kUpdateFailed
//                                                                                                    object: self];
//                                            }];
}


- (void) unsubscribeFromChannel: (Channel *) channel
{
    // To prevent crashes that would occur when faulting object that have disappeared
    NSManagedObjectID *channelOwnerObjectId = channel.objectID;
    NSManagedObjectContext *channelOwnerObjectMOC = channel.managedObjectContext;
    
    [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      channelId: channel.uniqueId
                                              completionHandler: ^(NSDictionary *responseDictionary) {
                                                  // Find our object from it's ID
                                                  NSError *error = nil;
                                                  Channel *channelFromId = (Channel *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
                                                                                                                            error: &error];
                                                  if (channelFromId)
                                                  {
                                                      // This notifies the ChannelDetails through KVO
                                                      channelFromId.hasChangedSubscribeValue = YES;
                                                      channelFromId.subscribedByUserValue = NO;
                                                      channelFromId.subscribersCountValue -= 1;
                                                      
                                                      // the channel that got updated was a copy inside the ChannelDetails, so we must find the original and update it.
                                                      for (Channel * subscription in appDelegate.currentUser.subscriptions)
                                                      {
                                                          if ([subscription.uniqueId isEqualToString: channelFromId.uniqueId])
                                                          {
                                                              [appDelegate.currentUser removeSubscriptionsObject: subscription];
                                                              
                                                              break;
                                                          }
                                                      }
                                                      
                                                      [channelFromId.managedObjectContext save: &error];
                                                      
                                                      if (error)
                                                      {
                                                          [[NSNotificationCenter defaultCenter] postNotificationName: kUpdateFailed
                                                                                                              object: self];
                                                      }
                                                      else
                                                      {
                                                          [appDelegate saveContext: YES];
                                                      }
                                                  }
                                                  else
                                                  {
                                                      DebugLog (@"Channel disappeared from underneath us");
                                                  }
                                              } errorHandler: ^(NSDictionary *errorDictionary) {
                                                  [[NSNotificationCenter defaultCenter]  postNotificationName: kUpdateFailed
                                                                                                       object: self];
                                              }];
}


- (void) deleteChannel: (Channel *) channel
{
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                 channelId: channel.uniqueId
                                         completionHandler: ^(id response) {
                                             // this is done through the profile view so no need to copy the channel over.
                                             
                                             [appDelegate.currentUser.channelsSet removeObject: channel];
                                             
                                             [appDelegate saveContext: YES];
                                         }
                                              errorHandler: ^(id error) {
                                              }];
}


// == follow all
- (void) subscribeToUser: (ChannelOwner *) channelToSubscribeTo
{
    
    [appDelegate.oAuthNetworkEngine subscribeAllForUserId:appDelegate.currentUser.uniqueId subUserId:channelToSubscribeTo.uniqueId completionHandler:^(id response) {
        
        channelToSubscribeTo.subscribedByUserValue = YES;
        [appDelegate saveContext: YES];
        
    } errorHandler:^(id response) {
        
    }
     ];
    
    
}

- (void) unsubscribeToUser: (ChannelOwner *) channelToSubscribeTo
{
    
    [appDelegate.oAuthNetworkEngine unsubscribeAllForUserId:appDelegate.currentUser.uniqueId subUserId:channelToSubscribeTo.uniqueId completionHandler:^(id response) {
        channelToSubscribeTo.subscribedByUserValue = NO;
        
        [appDelegate saveContext: YES];
        
    } errorHandler:^(id response) {
        
    }];
}

#pragma mark - Updating

- (void) updateChannel: (Channel *) channel
      withForceRefresh: (BOOL) refresh
{
    if (!channel.resourceURL || [channel.resourceURL isEqualToString: @""])
    {
        return;
    }
    
    // define success block //
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *channelDictionary) {

        NSNumber *savedPosition = channel.position;
        
        [channel setAttributesFromDictionary: channelDictionary
                         ignoringObjectTypes: kIgnoreNothing];
        
        // the channel that got updated was a copy inside the ChannelDetails, so we must find the original and update it.
        for (Channel *userChannel in appDelegate.currentUser.channels)
        {
            if ([userChannel.uniqueId isEqualToString: channel.uniqueId])
            {
                [userChannel setAttributesFromDictionary: channelDictionary
                                     ignoringObjectTypes: kIgnoreChannelOwnerObject];
                
                //channel.channelOwner = appDelegate.currentUser;
                
                break;
            }
        }
        
        channel.position = savedPosition;
        
        
        NSError *error = nil;
        
        if (![channel.managedObjectContext save: &error])
        {
            AssertOrLog(@"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    };
    
    // define success block //
    
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        DebugLog(@"Update action failed");
    };
    
    BOOL isUser = [channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
    
    
    if (refresh == YES || [channel.resourceURL hasPrefix: @"https"] || isUser) // https does not cache so it is fresh
    {
        self.channelUpdateOperation = [appDelegate.oAuthNetworkEngine updateChannel: channel.resourceURL
                                                                    forVideosLength: isUser ? MAXIMUM_REQUEST_LENGTH : STANDARD_REQUEST_LENGTH
                                                                  completionHandler: successBlock
                                                                       errorHandler: errorBlock];
    }
    else
    {
        self.channelUpdateOperation = [appDelegate.networkEngine updateChannel: channel.resourceURL
                                                               forVideosLength: STANDARD_REQUEST_LENGTH
                                                             completionHandler: successBlock
                                                                  errorHandler: errorBlock];
    }
}


// From Profile Page only

- (void) updateChannelsForChannelOwner: (ChannelOwner *) channelOwner
{
    
    // To prevent crashes that would occur when faulting object that have disappeared
    NSManagedObjectID *channelOwnerObjectId = channelOwner.objectID;
    NSManagedObjectContext *channelOwnerObjectMOC = channelOwner.managedObjectContext;
    
    MKNKUserErrorBlock errorBlock = ^(id error) {
        
    };
    
    if ([channelOwner isMemberOfClass: [User class]]) // the user uses the oAuthEngine to avoid caching
    {
        [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) channelOwner)
                                           onCompletion: ^(id dictionary) {
             NSError *error = nil;
             ChannelOwner * channelOwnerFromId = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
                                                                                                       error: &error];
             if (channelOwnerFromId)
             {
                 [channelOwnerFromId setAttributesFromDictionary: dictionary
                                             ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
             }
             else
             {
                 DebugLog (@"Channel disappeared from underneath us");
             }
             
          
         } onError: errorBlock];
    }
    else // common channel owners user the public API
    {
        [appDelegate.networkEngine channelOwnerDataForChannelOwner: channelOwner
                                                        onComplete: ^(id dictionary)
         {
             
             [channelOwner setAttributesFromDictionary: dictionary
                                   ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
             
             [appDelegate.networkEngine
              channelOwnerSubscriptionsForOwner: channelOwner
              forRange: NSMakeRange(0, 48)                           // set to max for the moment
              completionHandler: ^(id dictionary) {
                  [channelOwner setSubscriptionsDictionary: dictionary];
                  
                  NSError *error = nil;
                  [channelOwner.managedObjectContext
                   save: &error];
                  
                  if (error)
                  {
                      NSString *errorString = [NSString stringWithFormat: @"%@ %@", [error localizedDescription], [error userInfo]];
                      DebugLog(@"%@", errorString);
                      errorBlock(@{@"saving_error": errorString});
                  }
              }
              errorHandler: errorBlock];
         } onError: errorBlock];
    }
}

@end
