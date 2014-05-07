//
//  SYNSearchVideoChannelsModel.m
//  dolly
//
//  Created by Sherman Lo on 17/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchVideoChannelsModel.h"
#import "SYNPagingModel+Protected.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"

@interface SYNSearchVideoChannelsModel ()

@property (nonatomic, copy) NSString *videoId;

@end

@implementation SYNSearchVideoChannelsModel

#pragma mark - Public class

+ (instancetype)modelWithVideoId:(NSString *)videoId {
	return [[self alloc] initWithVideoId:videoId];
}

#pragma mark - Init / Dealloc

- (instancetype)initWithVideoId:(NSString *)videoId {
	if (self = [super init]) {
		self.videoId = videoId;
	}
	return self;
}

#pragma mark - Overridden

- (void)loadItemsForRange:(NSRange)range successBlock:(SYNPagingModelResultsBlock)successBlock errorBlock:(SYNPagingModelErrorBlock)errorBlock {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	[appDelegate.networkEngine channelsForVideoId:self.videoId
										  inRange:range
								completionHandler:^(NSDictionary *response) {
									
									NSMutableArray *channels = [NSMutableArray array];
									for (NSDictionary *dictionary in response[@"channels"][@"items"]) {
										Channel *channel = [Channel instanceFromDictionary:dictionary
																 usingManagedObjectContext:appDelegate.mainManagedObjectContext];
										[channels addObject:channel];
									}
									
									successBlock(channels, [response[@"channels"][@"total"] integerValue]);
								} errorHandler:^(NSError *error) {
									errorBlock();
								}];
}

@end
