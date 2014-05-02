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
#import "VideoInstance.h"

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

-(id)init {
	if (self = [super init]) {
		self.appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self initAllValues];
    }
    return self;
}

-(void) initAllValues {
    self.recentlyStarred = [[NSMutableSet alloc] init];
    self.recentlyViewed = [[NSMutableSet alloc] init];
    self.channelSubscriptions = [[NSMutableSet alloc] init];
    self.userSubscriptons = [[NSMutableSet alloc] init];
    
}

-(void)registerActivityFromDictionary:(NSDictionary*)dictionary
{
    if (dictionary)
    {
        
		// == Recently Starred are all videos that a user has liked/stared/favorited
        if (dictionary[@"recently_starred"]){
            self.recentlyStarred = [NSMutableSet setWithArray:dictionary[@"recently_starred"]];
			
			// Need to update existing video instances with the fact they've been starred
			NSManagedObjectContext *managedObjectContext = self.appDelegate.mainManagedObjectContext;
			NSDictionary *videoInstances = [VideoInstance existingVideoInstancesWithIds:[self.recentlyStarred allObjects]
																 inManagedObjectContext:managedObjectContext];
			[videoInstances enumerateKeysAndObjectsUsingBlock:^(NSString *videoInstanceId, VideoInstance *videoInstance, BOOL *stop) {
				videoInstance.starredByUserValue = YES;
			}];
        }

        if (dictionary[@"subscribed"]){
			self.channelSubscriptions = [NSMutableSet setWithArray:dictionary[@"subscribed"]];
        }
        
        if (dictionary[@"user_subscribed"]){
			self.userSubscriptons = [NSMutableSet setWithArray:dictionary[@"user_subscribed"]];
        }
    }
    else
    {
        AssertOrLog(@"SYNActivityManager:updateActivityForCurrentUser response is nil");
    }
}

#pragma mark - update activity manager
- (void) updateActivityForCurrentUserWithReset:(BOOL)reset
{
    // Don't do this if we don't yet have a user
    NSString *userId =self.appDelegate.currentOAuth2Credentials.userId;
    if (userId)
    {
        [self.appDelegate.oAuthNetworkEngine activityForUserId: userId
                                             completionHandler: ^(NSDictionary *responseDictionary) {

                                                 if (reset) {
                                                     [self initAllValues];                                                 
                                                 }
                                                 
                                                 [self registerActivityFromDictionary:responseDictionary];
                                                 
                                             } errorHandler: ^(NSDictionary* error) {
                                                 DebugLog(@"Activity updates failed");
                                             }];
    }
}




- (void) subscribeToChannel: (Channel *) channel
          completionHandler: (MKNKUserSuccessBlock) completionBlock
               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    [self.appDelegate.oAuthNetworkEngine channelSubscribeForUserId:self.appDelegate.currentUser.uniqueId channelURL:channel.resourceURL completionHandler:^(NSDictionary *responseDictionary) {
		channel.subscribedByUserValue = YES;
		[self.channelSubscriptions addObject:channel.uniqueId];
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

- (void) unsubscribeToChannel: (Channel *) channel
          completionHandler: (MKNKUserSuccessBlock) completionBlock
               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId:self.appDelegate.currentUser.uniqueId channelId:channel.uniqueId completionHandler:^(NSDictionary *responseDictionary) {
		channel.subscribedByUserValue = NO;
        [self.channelSubscriptions removeObject:channel.uniqueId];
        
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
