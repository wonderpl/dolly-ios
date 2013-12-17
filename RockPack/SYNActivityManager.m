//
//  SYNActivityManager.m
//  rockpack
//
//  Created by Nick Banks on 25/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Channel.h"
#import "SYNActivityManager.h"
#import "Video.h"
#import "SYNAppDelegate.h"
@interface SYNActivityManager ()


@property (nonatomic, strong) NSMutableSet *recentlyStarred;
@property (nonatomic, strong) NSMutableSet *recentlyViewed;
@property (nonatomic, strong) NSMutableSet *channelSubscriptions;
@property (nonatomic, strong) NSMutableSet *userSubscriptons;

@property (nonatomic, weak) SYNAppDelegate *appDelegate;




@end


@implementation SYNActivityManager

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceQueue;
    static SYNActivityManager *activityManager = nil;
    
    dispatch_once(&onceQueue, ^
    {
        activityManager = [[self alloc] init];

    });
    
    return activityManager;
}

-(id)init
{
    self.appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.recentlyStarred = [[NSMutableSet alloc]init];
    self.recentlyViewed = [[NSMutableSet alloc]init];
    self.channelSubscriptions = [[NSMutableSet alloc]init];
    self.userSubscriptons = [[NSMutableSet alloc]init];
    
    return self;
}

-(void)reset
{
    self.recentlyStarred = [[NSMutableSet alloc]init];
    self.recentlyViewed = [[NSMutableSet alloc]init];
    self.channelSubscriptions = [[NSMutableSet alloc]init];
    self.userSubscriptons = [[NSMutableSet alloc]init];
}

-(void)registerActivityFromDictionary:(NSDictionary*)dictionary
{
    if (dictionary)
    {
        //Union in the case that the activity manager or the activity service is out of sync
        
        if (dictionary[@"recently_starred"]){
            [self.recentlyStarred unionSet:[NSMutableSet setWithArray:dictionary[@"recently_starred"]]];
        }
        //cant union as unfollow all users cells wont ever be removed
        if (dictionary[@"subscribed"]){
//            [self.channelSubscriptions unionSet:[NSMutableSet setWithArray: dictionary[@"subscribed"]]];
            
            [self.channelSubscriptions setSet:[NSMutableSet setWithArray: dictionary[@"subscribed"]]];
        }
        
        if (dictionary[@"user_subscribed"]){
//            [self.userSubscriptons unionSet:[NSMutableSet setWithArray:dictionary[@"user_subscribed"]]];
            
            [self.userSubscriptons setSet:[NSMutableSet setWithArray:dictionary[@"user_subscribed"]]];
            
        }
    }
    else
    {
        AssertOrLog(@"SYNActivityManager:updateActivityForCurrentUser response is nil");
    }
}

#pragma mark - update activity manager
- (void) updateActivityForCurrentUser
{
    // Don't do this if we don't yet have a user
    NSString *userId =self.appDelegate.currentOAuth2Credentials.userId;
    if (userId)
    {
        [self.appDelegate.oAuthNetworkEngine activityForUserId: userId
                                             completionHandler: ^(NSDictionary *responseDictionary) {

                                                 [self registerActivityFromDictionary:responseDictionary];
                                                 
                                             } errorHandler: ^(NSDictionary* error) {
                                                 DebugLog(@"Activity updates failed");
                                             }];
    }
}

#pragma mark - channel subscriptions
//
//- (void) subscriptionRequestToChannel: (Channel *) channel
//          completionHandler: (MKNKUserSuccessBlock) completionBlock
//               errorHandler: (MKNKUserErrorBlock) errorBlock
//{
// 
//    if (channel.subscribedByUserValue)
//    {
//        //Unsubscribe
//        [self.appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId:self.appDelegate.currentUser.uniqueId channelId:channel.uniqueId completionHandler:^(NSDictionary *responseDictionary) {
//            
//            [self.channelSubscriptions removeObject:channel];
//            channel.subscribedByUserValue = NO;
//            
//            if (completionBlock)
//            {
//                completionBlock(responseDictionary);
//            }
//            
//        } errorHandler:^(NSDictionary *error) {
//            if (errorBlock)
//            {
//                errorBlock(error);
//            }
//        }];
//    }
//    else
//    {
//        //Subscribe
//        [self.appDelegate.oAuthNetworkEngine channelSubscribeForUserId:self.appDelegate.currentUser.uniqueId channelURL:channel.resourceURL completionHandler:^(NSDictionary *responseDictionary) {
//            [self.channelSubscriptions addObject:channel.uniqueId];
//            channel.subscribedByUserValue = YES;
//            //channel.subscribedByUserValue = [self.subscribed containsObject:channel];
//            if (completionBlock)
//            {
//                completionBlock(responseDictionary);
//            }
//        } errorHandler:^(NSDictionary *error) {
//            
//            if (errorBlock)
//            {
//                errorBlock(error);
//            }
//        }];
//    }
//}
//
//

- (void) subscribeToChannel: (Channel *) channel
          completionHandler: (MKNKUserSuccessBlock) completionBlock
               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    [self.appDelegate.oAuthNetworkEngine channelSubscribeForUserId:self.appDelegate.currentUser.uniqueId channelURL:channel.resourceURL completionHandler:^(NSDictionary *responseDictionary) {
        [self addChannelSubscriptionsObject:channel];

        if (completionBlock)
        {
            completionBlock(responseDictionary);
        }
        
    } errorHandler:^(NSDictionary *error) {
        
        if (errorBlock)
        {
            errorBlock(error);
        }
    }];
}
//
//-(void) subscribetoChannel :(Channel*) channel{
//    [self.appDelegate.oAuthNetworkEngine channelSubscribeForUserId:self.appDelegate.currentUser.uniqueId channelURL:channel.resourceURL completionHandler:^(NSDictionary *responseDictionary) {
//        [self.channelSubscriptions addObject:channel.uniqueId];
//        channel.subscribedByUserValue = [self.channelSubscriptions containsObject:channel];
//    } errorHandler:^(NSDictionary *error) {
//        
//    }];
//}

- (void) unsubscribeToChannel: (Channel *) channel
          completionHandler: (MKNKUserSuccessBlock) completionBlock
               errorHandler: (MKNKUserErrorBlock) errorBlock
{
//    NSLog(@"before");
//    [self subscribedList];
//
    [self.appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId:self.appDelegate.currentUser.uniqueId channelId:channel.uniqueId completionHandler:^(NSDictionary *responseDictionary) {
   
        [self.channelSubscriptions removeObject:channel.uniqueId];
        channel.subscribedByUserValue = NO;
        
//        
//        NSLog(@"unsubscribe");
//        NSLog(@"%@, %hhd", channel.title, channel.subscribedByUserValue);
//        
//        NSLog(@"after");
//        [self subscribedList];
        
        
        if (completionBlock)
        {
            completionBlock(responseDictionary);
        }
        
    } errorHandler:^(NSDictionary *error) {
        if (errorBlock)
        {
            errorBlock(error);
        }
    }];
    
}

//-(void) unsubscribetoChannel :(Channel*) channel{
//    [self.appDelegate.oAuthNetworkEngine channelSubscribeForUserId:self.appDelegate.currentUser.uniqueId channelURL:channel.resourceURL completionHandler:^(NSDictionary *responseDictionary) {
//        
//        [self.channelSubscriptions removeObject:channel];
//        
//    } errorHandler:^(NSDictionary *error) {
//        
//        
//    }];
//}

#pragma mark - user subscriptions


- (void) subscribeToUser: (ChannelOwner *) channelOwner
          completionHandler: (MKNKUserSuccessBlock) completionBlock
               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine subscribeAllForUserId: self.appDelegate.currentUser.uniqueId
                                                subUserId: channelOwner.uniqueId
 completionHandler:^(NSDictionary *responseDictionary) {
     
        if (completionBlock)
        {
            [self addUserSubscriptonsObject:channelOwner];

            for (Channel *tmpChannel in channelOwner.channels) {
                [self addChannelSubscriptionsObject:tmpChannel];
            }
            
            completionBlock(responseDictionary);
        }
        
    } errorHandler:^(NSDictionary *error) {
        
        if (errorBlock)
        {
            errorBlock(error);
        }
    }];
}


- (void) unsubscribeToUser: (ChannelOwner *) channelOwner
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock
{

    
    [self.appDelegate.oAuthNetworkEngine unsubscribeAllForUserId: self.appDelegate.currentUser.uniqueId
                                                     subUserId: channelOwner.uniqueId
                                             completionHandler:^(NSDictionary *responseDictionary) {

                                                 if (completionBlock)
                                                 {
                                                     for (Channel *tmpChannel in channelOwner.channels) {
                                                         [self.channelSubscriptions removeObject:tmpChannel.uniqueId];
                                                         tmpChannel.subscribedByUserValue = NO;
                                                     }
                                                     
                                                     [self.userSubscriptons removeObject:channelOwner.uniqueId];
                                                     channelOwner.subscribedByUserValue = NO;


                                                     completionBlock(responseDictionary);
                                                 }
                                                 
                                             } errorHandler:^(NSDictionary *error) {
                                                 
                                                 if (errorBlock)
                                                 {
                                                     errorBlock(error);
                                                 }
                                             }];
}

#pragma mark - helper methods
- (BOOL) isRecentlyStarred:(NSString*)videoId
{
    if(!videoId)
        return NO;
    
    return [self.recentlyStarred containsObject:videoId];

}

- (BOOL) isRecentlyViewed:(NSString*)videoId
{
    if(!videoId)
        return NO;
    
    return [self.recentlyViewed containsObject:videoId];
    
}

- (BOOL)isSubscribedToChannelId:(NSString*)channelId {
	return [self.channelSubscriptions containsObject:channelId];
}

- (BOOL)isSubscribedToUserId:(NSString*)userId {
	return [self.userSubscriptons containsObject:userId];
}

-(void) addChannelSubscriptionsObject:(Channel *)channel
{
    channel.subscribedByUserValue = YES;
    [self.channelSubscriptions addObject:channel.uniqueId];
}

-(void) addUserSubscriptonsObject:(ChannelOwner*)channelOwner{
    channelOwner.subscribedByUserValue = YES;
    [self.userSubscriptons addObject:channelOwner.uniqueId];
}

-(void) subscribedList
{
    NSLog(@"%@", self.channelSubscriptions);
}

@end
