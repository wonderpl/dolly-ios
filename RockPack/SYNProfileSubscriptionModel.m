//
//  SYNProfileModel.m
//  dolly
//
//  Created by Cong Le on 17/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileSubscriptionModel.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import	"SYNPagingModel+Protected.h"
#import "SYNActivityManager.h"

@interface SYNProfileSubscriptionModel ()

@property (nonatomic, strong) ChannelOwner *channelOwner;

@end

@implementation SYNProfileSubscriptionModel


#pragma mark - Public class

+ (instancetype)modelWithChannelOwner:(ChannelOwner *)channelOwner {
	return [[self alloc] initWithChannelOwner:channelOwner];
}

- (instancetype)initWithChannelOwner:(ChannelOwner *)channelOwner {
	if (self = [super initWithItems:[channelOwner.subscriptionsSet array] totalItemCount:channelOwner.totalVideosValueSubscriptionsValue]) {
		_channelOwner = channelOwner;
	}
	return self;
}


- (void)loadItemsForRange:(NSRange)range {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    __weak typeof(self) wself = self;

    MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
        __strong typeof(self) sself = wself;

        NSError *error = nil;
        
        [wself.channelOwner addSubscriptionsFromDictionary: dictionary];
        //#warning cache all the channels to activity manager?
        // is there a better way?
        // can use the range object, this should be poosible
        if (wself.channelOwner.uniqueId == appDelegate.currentUser.uniqueId) {
            for (Channel *tmpChannel in wself.channelOwner.subscriptions) {
                [SYNActivityManager.sharedInstance addChannelSubscriptionsObject:tmpChannel];
            }
        }
        [wself.channelOwner.managedObjectContext save: &error];

        sself.loadedItems = [sself.channelOwner.subscriptionsSet array];
		sself.totalItemCount = [dictionary[@"channels"][@"total"] intValue];
        

        [sself handleDataUpdatedForRange:range];
    };
    
    // define success block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
//        weakSelf.loadingMoreContent = NO;
        DebugLog(@"Update action failed");
    };
    //    Working load more videos for user channels
    
//    NSRange range = NSMakeRange(0, 100);
    
        [appDelegate.oAuthNetworkEngine subscriptionsForUserId: wself.channelOwner.uniqueId
                                                       inRange: range
                                             completionHandler: successBlock
                                                  errorHandler: errorBlock];
}

- (void)loadFirstPage {
    
    SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSRange range = NSMakeRange(0, self.batchSize);
    
    __weak typeof(self) wself = self;
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
        __strong typeof(self) sself = wself;
        
        NSError *error = nil;
        
        [wself.channelOwner setSubscriptionsDictionary: dictionary];
        //#warning cache all the channels to activity manager?
        // is there a better way?
        // can use the range object, this should be poosible
        if (wself.channelOwner.uniqueId == appDelegate.currentUser.uniqueId) {
            for (Channel *tmpChannel in wself.channelOwner.subscriptions) {
                [SYNActivityManager.sharedInstance addChannelSubscriptionsObject:tmpChannel];
            }
        }
        [wself.channelOwner.managedObjectContext save: &error];
        
        sself.loadedItems = [sself.channelOwner.subscriptionsSet array];
		sself.totalItemCount = [dictionary[@"channels"][@"total"] intValue];
        
        
        [sself handleDataUpdatedForRange:range];
    };
    
    // define success block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        //        weakSelf.loadingMoreContent = NO;
        DebugLog(@"Update action failed");
    };
    //    Working load more videos for user channels
    
    //    NSRange range = NSMakeRange(0, 100);
    
    [appDelegate.oAuthNetworkEngine subscriptionsForUserId: wself.channelOwner.uniqueId
                                                   inRange: range
                                         completionHandler: successBlock
                                              errorHandler: errorBlock];
    
}



@end
