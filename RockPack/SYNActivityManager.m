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
        
        activityManager.recentlyStarred = [NSSet setWithArray: @[]];
        activityManager.recentlyStarred = [NSSet setWithArray: @[]];
        activityManager.recentlyStarred = [NSSet setWithArray: @[]];
    });
    
    return activityManager;
}

-(void)registerActivityFromDictionary:(NSDictionary*)dictionary
{
    if (dictionary)
    {
        
        if (dictionary[@"recently_starred"])
            self.recentlyStarred = [NSSet setWithArray: dictionary[@"recently_starred"]];
        
        
//        if (dictionary[@"recently_viewed"])
//            self.recentlyViewed = [NSSet setWithArray: dictionary[@"recently_viewed"]];
        
        
        if (dictionary[@"subscribed"])
            self.subscribed = [NSSet setWithArray: dictionary[@"subscribed"]];
        
    }
    else
    {
        AssertOrLog(@"SYNActivityManager:updateActivityForCurrentUser response is nil");
    }
}


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

- (BOOL) isSubscribed:(NSString*)channelId
{
    if(!channelId)
        return nil;
    
    return [self.subscribed containsObject:channelId];
}

@end
