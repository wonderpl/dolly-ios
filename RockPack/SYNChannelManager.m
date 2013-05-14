//
//  SYNSubscriptionsManager.m
//  rockpack
//
//  Created by Michael Michailidis on 23/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelManager.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNNetworkEngine.h"
#import "AppConstants.h"


@interface SYNChannelManager()

@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNChannelManager

@synthesize appDelegate;


-(id)init
{
    if (self = [super init])
    {
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelSubscribeRequest:)
                                                     name:kChannelSubscribeRequest
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelUpdateRequest:)
                                                     name:kChannelUpdateRequest
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelOwnerUpdateRequest:)
                                                     name:kChannelOwnerUpdateRequest
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(channelDeleteRequest:)
                                                     name:kChannelDeleteRequest
                                                   object:nil];
        
        
        
    }
    return self;
}


+(id)manager
{
    return [[self alloc] init];
}

#pragma mark - Notification Handlers

-(void)channelSubscribeRequest:(NSNotification*)notification
{
    Channel* channelToSubscribe = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channelToSubscribe)
        return;
    
    [self toggleSubscriptionToChannel:channelToSubscribe];
}


-(void)channelOwnerUpdateRequest:(NSNotification*)notification
{
    ChannelOwner* channelOwner = (ChannelOwner*)[[notification userInfo] objectForKey:kChannelOwner];
    if(!channelOwner)
        return;
    
    [self updateChannelsForChannelOwner:channelOwner];
}

-(void)channelUpdateRequest:(NSNotification*)notification
{
    Channel* channelToUpdate = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channelToUpdate)
        return;
    
    [self updateChannel:channelToUpdate];
}

-(void)channelDeleteRequest:(NSNotification*)notification
{
    Channel* channelToUpdate = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channelToUpdate)
        return;
    
    [self deleteChannel:channelToUpdate];
}


#pragma mark - Implementation Methods

-(void)toggleSubscriptionToChannel:(Channel*)channel
{
    
    if (channel.subscribedByUserValue == YES)
    {
        [self unsubscribeFromChannel:channel];
    }
    else
    {
        [self subscribeToChannel:channel];
    }
    
    
    
    
    
}
-(void)subscribeToChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                   channelURL: channel.resourceURL
                                            completionHandler: ^(NSDictionary *responseDictionary) {
                                                
                                                
                                                DebugLog(@"Subscribe action successful");
                                                
                                                channel.subscribedByUserValue = TRUE;
                                                channel.subscribersCountValue += 1;
                                                
                                                [channel addSubscribersObject:appDelegate.currentUser];
                                                
                                                [appDelegate saveContext:YES];
                                                
                                            } errorHandler: ^(NSDictionary* errorDictionary) {
                                                
                                                
                                                DebugLog(@"Subscribe action failed");
                                            }];
    
    
    
    
}
-(void)unsubscribeFromChannel:(Channel*)channel
{
    
    
    [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      channelId: channel.uniqueId
                                              completionHandler: ^(NSDictionary *responseDictionary) {
                                                  
                                                  DebugLog(@"Unsubscribe action successful");
                                                  
                                                  channel.subscribedByUserValue = NO;
                                                  channel.subscribersCountValue -= 1;
                                                  
                                                  [channel removeSubscribersObject:appDelegate.currentUser];
                                                  
                                                  [appDelegate saveContext:YES];
                                                  
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                                       DebugLog(@"Unsubscribe action failed");
                                                    
                                                    
                                                }];
    
    
}

-(void)deleteChannel:(Channel*)channel
{
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId:appDelegate.currentUser.uniqueId
                                                 channelId:channel.uniqueId
                                         completionHandler:^(id response) {
                                             
                                             NSMutableOrderedSet *channelsSet = [NSMutableOrderedSet orderedSetWithOrderedSet:appDelegate.currentUser.channels];
                                             
                                             
                                             [channelsSet removeObject:channel];
                                             
                                             [appDelegate.currentUser setChannels:channelsSet];
                                             
                                             [appDelegate saveContext:YES];
                                             
                                             DebugLog(@"Delete channel succeed");
                
                                         } errorHandler:^(id error) {
                                             
                                             DebugLog(@"Delete channel NOT succeed");
        
                                         }];
}

-(void)updateChannel:(Channel*)channel
{
    if (channel.resourceURL != nil && ![channel.resourceURL isEqualToString: @""])
    {
        if ([channel.resourceURL hasPrefix: @"https"])
        {
            [appDelegate.oAuthNetworkEngine updateChannel: channel.resourceURL
                                        completionHandler: ^(NSDictionary *responseDictionary) {
                                            // Save the position for back-patching in later
                                            NSNumber *savedPosition = channel.position;
                                            
                                            [channel setAttributesFromDictionary: responseDictionary
                                                                          withId: channel.uniqueId
                                                             ignoringObjectTypes: kIgnoreNothing
                                                                       andViewId: kChannelDetailsViewId];
                                            
                                           
                                            channel.position = savedPosition;
                                            channel.viewId = kChannelsViewId;
                                            
                                            
                                            if([channel.managedObjectContext hasChanges])
                                            {
                                                NSError* error;
                                                [channel.managedObjectContext save:&error];
                                                
                                            }
                                            
                                            
                                            
                                        } errorHandler: ^(NSDictionary* errorDictionary) {
                                                 DebugLog(@"Update action failed");
                                             }];
            
        }
        else
        {
            [appDelegate.networkEngine updateChannel: channel.resourceURL
                                   completionHandler: ^(NSDictionary *responseDictionary) {
                                       // Save the position for back-patching in later
                                       NSNumber *savedPosition = channel.position;
                                       
                                       [channel setAttributesFromDictionary: responseDictionary
                                                                     withId: channel.uniqueId
                                                        ignoringObjectTypes: kIgnoreNothing
                                                                  andViewId: kChannelDetailsViewId];
                                       
             
                                       channel.position = savedPosition;
                                       channel.viewId = kChannelsViewId;
                                       
                                       if([channel.managedObjectContext hasChanges])
                                       {
                                           NSError* error;
                                           [channel.managedObjectContext save:&error];
                                           
                                       }
                                       
                                        } errorHandler: ^(NSDictionary* errorDictionary) {
                                            DebugLog(@"Update action failed");
                                        }];
        }
    }
}

-(void)updateChannelsForChannelOwner:(ChannelOwner*)channelOwner
{
    [appDelegate.networkEngine channelOwnerDataForChannelOwner:channelOwner onComplete:^(id dictionary) {
        
        
        
        [appDelegate.mainRegistry registerChannelsFromDictionary:dictionary
                                                 forChannelOwner:channelOwner
                                                     byAppending:NO];
        
    } onError:^(id error) {
        
    }];
}



@end
