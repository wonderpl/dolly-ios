//
//  SYNCommentsModel.m
//  dolly
//
//  Created by Sherman Lo on 31/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNCommentsModel.h"
#import	"SYNPagingModel+Protected.h"
#import "SYNAbstractNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNNetworkEngine.h"
#import "VideoInstance.h"

static const NSInteger MinutesCacheLength = 1;

@interface SYNCommentsModel	()

@property (nonatomic, strong) VideoInstance *videoInstance;

@end

@implementation SYNCommentsModel

+ (instancetype)modelWithVideoInstance:(VideoInstance *)videoInstance {
	return [[self alloc] initWithVideoInstance:videoInstance];
}

- (instancetype)initWithVideoInstance:(VideoInstance *)videoInstance {
	if (self = [super init]) {
		self.videoInstance = videoInstance;
	}
	return self;
}

- (void)loadItemsForRange:(NSRange)range {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	/* NOTE: Comments are CACHED so we need to save on the fly comments carefuly */
    
    SYNAbstractNetworkEngine* networkEngineToUse;
    NSDate* lastInteractedWithCommenting = [[NSUserDefaults standardUserDefaults] objectForKey: kUserDefaultsCommentingLastInteracted];
    
    
    if(!lastInteractedWithCommenting) // first time we launched this section
        lastInteractedWithCommenting = [NSDate distantPast];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSMinuteCalendarUnit
                                               fromDate:lastInteractedWithCommenting
                                                 toDate:[NSDate date]
                                                options:0];
    
    
    
    if (components.minute <= MinutesCacheLength) {
        networkEngineToUse = appDelegate.oAuthNetworkEngine;
    } else {
        networkEngineToUse = appDelegate.networkEngine;
    }
    
//    if(self.comments.count == 0)
//    {
//        self.generalLoader.hidden = NO;
//        [self.generalLoader startAnimating];
//    }
    
    [networkEngineToUse getCommentsForUsedId:appDelegate.currentUser.uniqueId
                                   channelId:self.videoInstance.channel.uniqueId
                                  andVideoId:self.videoInstance.uniqueId
                                     inRange:range
                           completionHandler:^(NSDictionary	*dictionary) {
							   
							   NSArray *comments = dictionary[@"comments"][@"items"];
							   
							   self.loadedItems = comments;
							   self.totalItemCount = [dictionary[@"comments"][@"total"] integerValue];
							   
							   [self handleDataUpdatedForRange:range];
							   
//							   if(![dictionary isKindOfClass:[NSDictionary class]])
//								   return;
//							   
//							   
//
//							   if(![appDelegate.mainRegistry registerCommentsFromDictionary:dictionary
//																			   withExisting:self.comments
//																		 forVideoInstanceId:self.videoInstance.uniqueId])
//							   {
//								   self.comments = @[].mutableCopy;
//								   
//								   
//							   }
//                               
//                               self.generalLoader.hidden = YES;
//                               
//							   
//                               [self refreshCollectionView];
//							   
						   } errorHandler:^(id error) {
							   
							   
						   }];
}

@end
