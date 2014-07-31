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
#import "SYNMasterViewController.h"
#import "SYNChannelDetailsViewController.h"
#import "SYNActivityViewController.h"

@interface SYNActivityManager ()

@property (nonatomic, strong) NSMutableSet *recentlyStarred;
@property (nonatomic, strong) NSMutableSet *recentlyViewed;
@property (nonatomic, strong) NSMutableSet *channelSubscriptions;
@property (nonatomic, strong) NSMutableSet *userSubscriptons;
@property (nonatomic, strong) NSMutableDictionary *trackingDictionary;
@property (nonatomic, strong) NSMutableDictionary *trackingDictionaryNoPosition;

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
        self.trackingDictionary = [NSMutableDictionary new];
        self.trackingDictionaryNoPosition = [NSMutableDictionary new];
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
    [self.appDelegate.oAuthNetworkEngine channelSubscribeForUserId:self.appDelegate.currentUser.uniqueId channelId:channel.uniqueId withTrackingCode:[self trackingCodeForChannel:channel] completionHandler:^(NSDictionary *responseDictionary) {
        
        if (responseDictionary && [responseDictionary isKindOfClass:[NSDictionary class]]) {
            [self registerActivityFromDictionary:responseDictionary];
        }
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
    [self.appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId:self.appDelegate.currentUser.uniqueId channelId:channel.uniqueId withTrackingCode:[self trackingCodeForChannel:channel] completionHandler:^(NSDictionary *responseDictionary) {
        
        if (responseDictionary && [responseDictionary isKindOfClass:[NSDictionary class]]) {
            [self registerActivityFromDictionary:responseDictionary];
        }
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


- (NSString*)trackingCodeForUser :(ChannelOwner*) user withVideoInstance:(VideoInstance*) videoInstance{
    
    
    if ([[self.appDelegate.masterViewController.viewControllers firstObject] isKindOfClass:[SYNActivityViewController class]]) {
        return [self trackingCodeForVideoInstance:videoInstance];
    }

    SYNAbstractViewController *viewController = [self.appDelegate.masterViewController.viewControllers lastObject];
    
    NSLog(@"AllVCs%@", self.appDelegate.masterViewController.viewControllers);
    NSLog(@"ChossenVC %@", [viewController class]);
    if ([viewController isKindOfClass:[SYNChannelDetailsViewController class]]) {
        return self.trackingDictionaryNoPosition[[NSString stringWithFormat:@"%@%@", videoInstance.channel.uniqueId, [self classNameForTracking]]];
    }
    
    
    NSString *videoInstanceKey = [NSString stringWithFormat:@"%@%lld%@", videoInstance.uniqueId, videoInstance.positionValue, [self classNameForTracking]];
    NSLog(@"videoInstanceKey : %@", videoInstanceKey);
    
    if (self.trackingDictionary[videoInstanceKey]) {
        return self.trackingDictionary[videoInstanceKey];
    } else {
        NSLog(@"self.trackingDictionary : %@", self.trackingDictionary);
    }

    NSString* key = [NSString stringWithFormat:@"%@%lld%@", user.uniqueId, user.positionValue, [self classNameForTracking]];
    if (!self.trackingDictionary[key]) {
        NSLog(@"No Key %@", self.trackingDictionary[key]);
        NSLog(@"Key for user %@", self.trackingDictionary[key]);
        NSLog(@"%@", self.trackingDictionary);
        return self.trackingDictionaryNoPosition[[NSString stringWithFormat:@"%@%@", user.uniqueId, [self classNameForTracking]]];
    }
    
    NSLog(@"Key for user %@", self.trackingDictionary[key]);
    return self.trackingDictionary[key];
}


- (NSString*)trackingCodeForUser :(ChannelOwner*) user{

    NSString* key = [NSString stringWithFormat:@"%@%lld%@", user.uniqueId, user.positionValue, [self classNameForTracking]];
    
    
    if (!self.trackingDictionary[key]) {
        NSLog(@"No Key %@", self.trackingDictionary[key]);

        NSLog(@"Key for user %@", self.trackingDictionary[key]);
        
        NSLog(@"%@", self.trackingDictionary);
        

        return self.trackingDictionaryNoPosition[[NSString stringWithFormat:@"%@%@", user.uniqueId, [self classNameForTracking]]];
    }
    
    NSLog(@"Key for user %@", self.trackingDictionary[key]);
    
    return self.trackingDictionary[key];
}


- (NSString*) classNameForTracking {
    if ([self.appDelegate.window.rootViewController isKindOfClass:[SYNMasterViewController class]]) {
        return NSStringFromClass([self.appDelegate.masterViewController.rootViewController class]);
    } else {
        return NSStringFromClass([self.appDelegate.window.rootViewController class]);
    }
}

- (NSString*)trackingCodeForChannel :(Channel*) channel videoInstance :(VideoInstance*)videoInstance {

    
    if ([[self.appDelegate.masterViewController.viewControllers firstObject] isKindOfClass:[SYNActivityViewController class]]) {
        return [self trackingCodeForVideoInstance:videoInstance];
    }
    
    SYNAbstractViewController *viewController = [self.appDelegate.masterViewController.viewControllers lastObject];
    
    NSLog(@"AllVCs%@", self.appDelegate.masterViewController.viewControllers);
    NSLog(@"ChossenVC %@", [viewController class]);
    if ([viewController isKindOfClass:[SYNChannelDetailsViewController class]]) {
        NSLog(@"CHANELL DETAILS TRACKING");
        return [self trackingCodeForChannel:channel];
    }
    
    return [self trackingCodeForVideoInstance:videoInstance];
}



- (NSString*)trackingCodeForChannel :(Channel*) channel {
    NSString* key = [NSString stringWithFormat:@"%@%lld%@", channel.uniqueId, channel.positionValue, [self classNameForTracking]];

    if (!self.trackingDictionary[key]) {
        if (!self.trackingDictionaryNoPosition[[NSString stringWithFormat:@"%@%@", channel.uniqueId, [self classNameForTracking]]]) {
            NSLog(@"nothing Found for key: %@  ------- : %@",[NSString stringWithFormat:@"%@%@", channel.uniqueId, [self classNameForTracking]], self.trackingDictionary);
        }
        return self.trackingDictionaryNoPosition[[NSString stringWithFormat:@"%@%@", channel.uniqueId, [self classNameForTracking]]];
    }
    return self.trackingDictionary[key];
}

- (NSString*)trackingCodeForVideoInstance :(VideoInstance*) videoInstance {
    
    NSLog(@"videoInstance : %@", videoInstance);
    
    SYNAbstractViewController *viewController = [self.appDelegate.masterViewController.viewControllers lastObject];
    
    NSLog(@"AllVCs%@", self.appDelegate.masterViewController.viewControllers);
    NSLog(@"ChossenVC %@", [viewController class]);
    if ([viewController isKindOfClass:[SYNChannelDetailsViewController class]]) {
        
        
        NSLog(@"%@",  [self trackingCodeForChannel:videoInstance.channel]);
		return [self trackingCodeForChannel:videoInstance.channel];
    }
    
    NSLog(@"%@", videoInstance.uniqueId);
    NSString* key = [NSString stringWithFormat:@"%@%lld%@", videoInstance.uniqueId, videoInstance.positionValue, [self classNameForTracking]];
    
    if (!self.trackingDictionary[key]) {
    	return self.trackingDictionaryNoPosition[[NSString stringWithFormat:@"%@%@", videoInstance.uniqueId, [self classNameForTracking]]];
    }
    
    return self.trackingDictionary[key];
}

- (void) subscribeToUser: (ChannelOwner *) channelOwner
           videoInstance: (VideoInstance*) videoInstance
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    [self.appDelegate.oAuthNetworkEngine subscribeAllForUserId: self.appDelegate.currentUser.uniqueId
                                                     subUserId: channelOwner.uniqueId
                                              withTrackingCode:[self trackingCodeForUser:channelOwner withVideoInstance:videoInstance]
                                             completionHandler:^(NSDictionary *responseDictionary) {
                                                 
                                                 if (responseDictionary && [responseDictionary isKindOfClass:[NSDictionary class]]) {
                                                     [self registerActivityFromDictionary:responseDictionary];
                                                 }
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



- (void) unsubscribeToUser: (ChannelOwner *) channelOwner
             videoInstance: (VideoInstance*) videoInstance
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    [self.appDelegate.oAuthNetworkEngine unsubscribeAllForUserId: self.appDelegate.currentUser.uniqueId
                                                       subUserId: channelOwner.uniqueId
                                                withTrackingCode:[self trackingCodeForUser:channelOwner withVideoInstance:videoInstance]
                                               completionHandler:^(NSDictionary *responseDictionary) {
                                                   
                                                   if (responseDictionary && [responseDictionary isKindOfClass:[NSDictionary class]]) {
                                                       [self registerActivityFromDictionary:responseDictionary];
                                                   }
                                                   if (completionBlock) {
                                                       completionBlock(responseDictionary);
                                                   }
                                                   
                                               } errorHandler:^(NSDictionary *error) {
                                                   
                                                   if (errorBlock)
                                                   {
                                                       errorBlock(error);
                                                   }
                                               }];
}


- (void)addObjectFromNotifications :(NSDictionary*) dict {

    NSString* classString = @"";
    
    if ([self.appDelegate.window.rootViewController isKindOfClass:[SYNMasterViewController class]]) {
        classString = NSStringFromClass([self.appDelegate.masterViewController.rootViewController class]);
    } else {
        classString = NSStringFromClass([self.appDelegate.window.rootViewController class]);
    }
    
    NSString* key = [NSString stringWithFormat:@"%@%@%@", dict[@"id"], dict[@"position"], classString];
    [self.trackingDictionary setValue:dict[@"tracking_code"] forKey:key];
    [self.trackingDictionaryNoPosition setValue:dict[@"tracking_code"] forKey:[NSString stringWithFormat:@"%@%@", dict[@"id"],  classString]];

}



- (void)addObjectFromDict :(NSDictionary*) dict {
    NSString* classString = @"";
    
    if ([self.appDelegate.window.rootViewController isKindOfClass:[SYNMasterViewController class]]) {
        classString = NSStringFromClass([self.appDelegate.masterViewController.rootViewController class]);
    } else {
        classString = NSStringFromClass([self.appDelegate.window.rootViewController class]);
    }

    NSString* key = [NSString stringWithFormat:@"%@%@%@", dict[@"id"], dict[@"position"], classString];    
    [self.trackingDictionary setValue:dict[@"tracking_code"] forKey:key];
    [self.trackingDictionaryNoPosition setValue:dict[@"tracking_code"] forKey:[NSString stringWithFormat:@"%@%@", dict[@"id"],  classString]];
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

-(NSUInteger) userFollowingCount {
    return [self.userSubscriptons count];
}


- (void) viewVideo: (VideoInstance *) videoInstance
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock {
}

@end
