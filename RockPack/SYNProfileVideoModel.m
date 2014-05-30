//
//  SYNProfileVideoModel.m
//  dolly
//
//  Created by Cong on 30/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileVideoModel.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import	"SYNPagingModel+Protected.h"


@interface SYNProfileVideoModel ()

@property (nonatomic, strong) ChannelOwner *channelOwner;

@end

@implementation SYNProfileVideoModel



#pragma mark - Public class

+ (instancetype)modelWithChannelOwner:(ChannelOwner *)channelOwner {
	return [[self alloc] initWithChannelOwner:channelOwner];
}

- (instancetype)initWithChannelOwner:(ChannelOwner *)channelOwner {
	if (self = [super initWithItems:[channelOwner.subscriptionsSet array] totalItemCount:100]) {
		_channelOwner = channelOwner;
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
			[sself.channelOwner setVideoInstancesFromDictionary:dictionary];
		} else {
            
			[sself.channelOwner addVideoInstancesFromDictionary: dictionary];
		}
		
		sself.channelOwner.totalVideosValue = [dictionary[@"videos"][@"total"] intValue];
		successBlock([sself.channelOwner.videoInstances array], [dictionary[@"videos"][@"total"] integerValue]);
        
        
    };
    
    MKNKUserErrorBlock internalErrorBlock = ^(NSDictionary *errorDictionary) {
		errorBlock();
        DebugLog(@"Update action failed");
    };
    
	
	BOOL isUserProfile = [self.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId];
	
//	if (isUserProfile) {
//		[appDelegate.oAuthNetworkEngine videosForUserId: wself.channelOwner.uniqueId
//													   inRange: range
//											 completionHandler: internalSuccessBlock
//												  errorHandler: internalErrorBlock];
//	} else {
		[appDelegate.networkEngine videosForUserId: wself.channelOwner.uniqueId
                                                inRange: range
                                      completionHandler: internalSuccessBlock
                                           errorHandler: internalErrorBlock];
//	}
}


@end
