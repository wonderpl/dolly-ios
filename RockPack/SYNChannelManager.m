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
                                                 selector: @selector(channelUpdateRequest:)
                                                     name: kChannelUpdateRequest
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(channelOwnerUpdateRequest:)
                                                     name: kChannelOwnerUpdateRequest
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
                                     ignoringObjectTypes: kIgnoreNothing];
                
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
                                                inRange: NSMakeRange(0, STANDARD_REQUEST_LENGTH)
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
