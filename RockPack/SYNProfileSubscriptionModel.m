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

        
		BOOL isInitalPage = (range.location == 0);
		if (isInitalPage) {
			[sself.channelOwner setSubscriptionsDictionary:dictionary];
		} else {
			[sself.channelOwner addSubscriptionsFromDictionary: dictionary];
		}
		
		sself.totalItemCount = [dictionary[@"channels"][@"total"] intValue];

		NSMutableArray *arr = [NSMutableArray arrayWithArray:[sself.channelOwner.subscriptionsSet array]];
		sself.loadedItems = arr;
        [sself handleDataUpdatedForRange:range];
    };
    
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        DebugLog(@"Update action failed");
    };

	[appDelegate.oAuthNetworkEngine subscriptionsForUserId: wself.channelOwner.uniqueId
												   inRange: range
										 completionHandler: successBlock
											  errorHandler: errorBlock];
}



@end
