//
//  SYNProfileModel.m
//  dolly
//
//  Created by Cong Le on 17/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileChannelModel.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import	"SYNPagingModel+Protected.h"

@interface SYNProfileChannelModel ()

@property (nonatomic, strong) ChannelOwner *channelOwner;

@end

@implementation SYNProfileChannelModel


#pragma mark - Public class

+ (instancetype)modelWithChannelOwner:(ChannelOwner *)channelOwner {
	return [[self alloc] initWithChannelOwner:channelOwner];
}

- (instancetype)initWithChannelOwner:(ChannelOwner *)channelOwner {
	if (self = [super initWithItems:[channelOwner.channelsSet array] totalItemCount:channelOwner.totalVideosValueChannelValue]) {
		self.channelOwner = channelOwner;
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
            [sself.channelOwner setSubscriptionsDictionary: dictionary];
		} else {
			[sself.channelOwner addChannelsFromDictionary: dictionary];
		}
				
		sself.loadedItems = [sself.channelOwner.channelsSet array];
		sself.totalItemCount = sself.channelOwner.totalVideosValueChannelValue;
        
        [sself handleDataUpdatedForRange:range];

    };
    
    // define error block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        DebugLog(@"Update action failed");
    };
    
	[appDelegate.oAuthNetworkEngine channelsForUserId: self.channelOwner.uniqueId
											  inRange: range
									completionHandler: successBlock
										 errorHandler: errorBlock];
}


@end
