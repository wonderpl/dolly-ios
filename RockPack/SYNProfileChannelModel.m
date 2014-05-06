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


- (void)loadItemsForRange:(NSRange)range successBlock:(SYNPagingModelResultsBlock)successBlock errorBlock:(SYNPagingModelErrorBlock)errorBlock {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
    __weak typeof(self) wself = self;

    MKNKUserSuccessBlock internalSuccessBlock = ^(NSDictionary *dictionary) {
		__strong typeof(self) sself = wself;
		
		BOOL isInitalPage = (range.location == 0);
		if (isInitalPage) {
            [sself.channelOwner setSubscriptionsDictionary: dictionary];
		} else {
			
			// This is bad, need to fix. getting doubles because of the double server call
			// also assuming that total item count is correct
			if (sself.channelOwner.channelsSet.count < sself.totalItemCount) {
				[sself.channelOwner addChannelsFromDictionary: dictionary];
			}
		}
		
		successBlock([sself.channelOwner.channelsSet array], [dictionary[@"channels"][@"total"] integerValue]);
    };
    
    // define error block //
    MKNKUserErrorBlock internalErrorBlock = ^(NSDictionary *errorDictionary) {
		errorBlock();
    };
    
	if ([self.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]) {
		[appDelegate.oAuthNetworkEngine channelsForUserId: self.channelOwner.uniqueId
												  inRange: range
										completionHandler: internalSuccessBlock
											 errorHandler: internalErrorBlock];
	} else {
		[appDelegate.networkEngine channelsForUserId: self.channelOwner.uniqueId
												  inRange: range
										completionHandler: internalSuccessBlock
											 errorHandler: internalErrorBlock];
	}
}


@end
