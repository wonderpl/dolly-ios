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

@property (nonatomic, strong) NSMutableSet *recentlyStarred;
@property (nonatomic, strong) NSMutableSet *recentlyViewed;
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
        activityManager.recentlyStarred = [[NSMutableSet alloc] initWithCapacity: 100];
        activityManager.recentlyViewed = [[NSMutableSet alloc] initWithCapacity: 100];
        activityManager.appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];

    });
    
    return activityManager;
}

- (void) updateActivityForCurrentUser
{
    [self.appDelegate.oAuthNetworkEngine activityForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                         completionHandler: ^(NSDictionary *responseDictionary) {
//                                             DebugLog(@"Activity updates successful");
                                         } errorHandler: ^(NSDictionary* error) {
//                                             DebugLog(@"Activity updates failed");
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




@end
