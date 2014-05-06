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

//- (void)loadItemsForRange:(NSRange)range {
//	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//	
//	/* NOTE: Comments are CACHED so we need to save on the fly comments carefuly */
//    
//    SYNAbstractNetworkEngine* networkEngineToUse;
//    NSDate* lastInteractedWithCommenting = [[NSUserDefaults standardUserDefaults] objectForKey: kUserDefaultsCommentingLastInteracted];
//    
//    
//    if(!lastInteractedWithCommenting) // first time we launched this section
//        lastInteractedWithCommenting = [NSDate distantPast];
//    
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *components = [calendar components:NSMinuteCalendarUnit
//                                               fromDate:lastInteractedWithCommenting
//                                                 toDate:[NSDate date]
//                                                options:0];
//    
//        
//    if (components.minute <= MinutesCacheLength) {
//        networkEngineToUse = appDelegate.oAuthNetworkEngine;
//    } else {
//        networkEngineToUse = appDelegate.networkEngine;
//    }
//    
//    [networkEngineToUse getCommentsForUsedId:appDelegate.currentUser.uniqueId
//                                   channelId:self.videoInstance.channel.uniqueId
//                                  andVideoId:self.videoInstance.uniqueId
//                                     inRange:range
//                                  withForceReload: NO
//                           completionHandler:^(NSDictionary	*dictionary) {
//							   
//
//							   NSMutableArray *comments = [NSMutableArray arrayWithArray:dictionary[@"comments"][@"items"]];
//							                        
//                               // There is a double server call bug
//                               // Using a set to ensure only 1 copy of a comment exists
//                               
//                               NSMutableDictionary* tmpDictionary = [[NSMutableDictionary alloc]init];
//                               
//                               for (NSDictionary* comment in self.loadedItems) {
//                                   [tmpDictionary setObject:comment forKey:comment[@"id"]];
//                               }
//                               
//                               for (int i=0; i<comments.count;i++) {
//                                   if (tmpDictionary[[comments objectAtIndex:i][@"id"]]) {
//                                       [comments removeObjectAtIndex:i];
//                                       i--;
//                                   }
//                               }
//                               
//                               //Put the current commets into a set
//                               NSMutableOrderedSet * tmpOrderedSet = [[NSMutableOrderedSet alloc]initWithArray:self.loadedItems];
//                               
//                               //add the items in reverse order as we are displaying them with the most recent at the bottom
//                               
//                               for (NSDictionary *commentDictionary in comments) {
//                                   if (![tmpOrderedSet containsObject:commentDictionary]) {
//                                       [tmpOrderedSet insertObject:commentDictionary atIndex:0];
//                                   }
//                               }
//                               
//                               NSSortDescriptor *idSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date_added" ascending:YES];
//                               
//                               
//                               self.loadedItems =  [NSArray arrayWithArray:[[tmpOrderedSet array] sortedArrayUsingDescriptors:@[idSortDescriptor]]];
//
//                               self.totalItemCount = [dictionary[@"comments"][@"total"] integerValue];
//                               
////							   [self handleDataUpdatedForRange:range];
//							   
//						   } errorHandler:^(id error) {
//							   
//							   
//						   }];
//    
//}

//- (void)loadNewComments{
//	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    [appDelegate.oAuthNetworkEngine getCommentsForUsedId:appDelegate.currentUser.uniqueId
//                                               channelId:self.videoInstance.channel.uniqueId
//                                              andVideoId:self.videoInstance.uniqueId
//                                                 inRange:NSMakeRange(0, 40)
//                                         withForceReload:YES
//                                       completionHandler:^(NSDictionary	*dictionary) {
//                                           
//                                           NSMutableArray *comments = [NSMutableArray arrayWithArray:dictionary[@"comments"][@"items"]];
//                                           
//                                           // There is a double server call bug
//                                           // Using a set to ensure only 1 copy of a comment exists
//                                           
//                                           NSMutableDictionary* tmpDictionary = [[NSMutableDictionary alloc]init];
//                                           
//                                           for (NSDictionary* comment in self.loadedItems) {
//                                               [tmpDictionary setObject:comment forKey:comment[@"id"]];
//                                           }
//                                           
//                                           
//                                           for (int i=0; i<comments.count;i++) {
//                                               if (tmpDictionary[[comments objectAtIndex:i][@"id"]]) {
//                                                   [comments removeObjectAtIndex:i];
//                                                   i--;
//                                               }
//                                           }
//                                           
//                                           //Put the current commets into a set
//                                           NSMutableOrderedSet * tmpOrderedSet = [[NSMutableOrderedSet alloc]initWithArray:self.loadedItems];
//                                           
//                                           //add the items in reverse order as we are displaying them with the most recent at the bottom
//                                           
//                                           for (NSDictionary *commentDictionary in comments) {
//                                               
//                                               if (![tmpOrderedSet containsObject:commentDictionary]) {
//                                                   [tmpOrderedSet insertObject:commentDictionary atIndex:0];
//                                               }
//                                           }
//                                           
//                                           
//                                           NSSortDescriptor *idSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date_added" ascending:YES];
//
//                                           
//                                           self.loadedItems =  [NSArray arrayWithArray:[[tmpOrderedSet array] sortedArrayUsingDescriptors:@[idSortDescriptor]]];
//                                           
//                                           self.totalItemCount = [dictionary[@"comments"][@"total"] integerValue];
//                                           
//                                           [self.delegate pagingModelDataUpdated:self];
//
//                                       } errorHandler:^(id error) {
//                                           
//                                           
//                                       }];
//}
//
//
//- (void)removeObjectAtIndex:(NSInteger)index {
//    
//    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.loadedItems];
//    [tmpArray removeObjectAtIndex:index];
//    self.loadedItems = tmpArray;
//	self.totalItemCount = [tmpArray count];
//}


- (void)resetLoadedData {

}


@end
