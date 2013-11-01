//
//  SYNActivityManager.m
//  rockpack
//
//  Created by Nick Banks on 25/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Channel.h"
#import "SYNActivityManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "Video.h"
#import "SYNAppDelegate.h"

@interface SYNActivityManager ()

@property (nonatomic, strong) NSSet *recentlyStarred;
@property (nonatomic, strong) NSSet *recentlyViewed;
@property (nonatomic, strong) NSSet *subscribed;
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
        activityManager.appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    });
    
    return activityManager;
}

- (void) updateActivityForCurrentUser
{
    [self.appDelegate.oAuthNetworkEngine activityForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                         completionHandler: ^(NSDictionary *responseDictionary) {
                                             NSArray *starredArray = responseDictionary[@"recently_starred"];
                                             NSArray *viewedArray = responseDictionary[@"recently_viewed"];
                                             NSArray *subscribedArray = responseDictionary[@"subscribed"];

                                             if (starredArray)
                                             {
                                                 self.recentlyStarred = [NSSet setWithArray: starredArray];
                                             }
                                             else
                                             {
                                                 self.recentlyStarred = [NSSet setWithArray: @[]];
                                             }
                                             
                                             if (viewedArray)
                                             {
                                                 self.recentlyViewed = [NSSet setWithArray: viewedArray];
                                             }
                                             else
                                             {
                                                 self.recentlyStarred = [NSSet setWithArray: @[]];
                                             }
                                             
                                             if (subscribedArray)
                                             {
                                                 self.subscribed = [NSSet setWithArray: subscribedArray];
                                             }
                                             else
                                             {
                                                 self.recentlyStarred = [NSSet setWithArray: @[]];
                                             }
                                         } errorHandler: ^(NSDictionary* error) {
                                             DebugLog(@"Activity updates failed");
                                         }];
}


- (void) updateActivityForVideo: (Video *) video
{
    // Cache the uniqueId (slight optimisation)
    NSString *uniqueId = video.uniqueId;
    
    [self.recentlyStarred enumerateObjectsWithOptions: NSEnumerationConcurrent
                                           usingBlock: ^(id obj, BOOL *stop)
    {
        if ([uniqueId isEqualToString: obj])
        {
            video.starredByUserValue = YES;
            *stop = YES;
        }
    }];
    
    [self.recentlyViewed enumerateObjectsWithOptions: NSEnumerationConcurrent
                                          usingBlock: ^(id obj, BOOL *stop)
     {
         if ([uniqueId isEqualToString: obj])
         {
             video.viewedByUserValue = TRUE;
             *stop = YES;
         }
     }];
}


- (void) updateSubscriptionsForChannel: (Channel *) channel
{
    // Cache the uniqueId (slight optimisation)
    NSString *uniqueId = channel.uniqueId;
    
    [self.subscribed enumerateObjectsWithOptions: NSEnumerationConcurrent
                                      usingBlock: ^(id obj, BOOL *stop)
     {
         if ([uniqueId isEqualToString: obj])
         {
             channel.subscribedByUserValue = YES;
             *stop = YES;
         }
     }];
}

@end
