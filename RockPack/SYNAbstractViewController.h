//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "SYNTabViewDelegate.h"
#import "SYNTabViewController.h"
#import "SYNAppDelegate.h"
#import "SYNVideoQueueDelegate.h"

//#import "Channel.h"
#import "SYNNetworkEngine.h"


@class VideoInstance, Channel, ChannelOwner;

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource,                                                            UICollectionViewDelegate, SYNTabViewDelegate> {
@protected
    SYNAppDelegate* appDelegate;
    BOOL tabExpanded;
    SYNTabViewController* tabViewController;
    NSString* viewId;
    NSFetchedResultsController* fetchedResultsController;
    CGFloat startAnimationDelay;
}

@property (readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) CGPoint initialDragCenter;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) UIImageView *draggedView;

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, strong) SYNTabViewController* tabViewController;

- (void) highlightTab: (int) tabIndex;
-(void)handleNewTabSelectionWithId:(NSString*)selectionId;


-(void) reloadCollectionViews;

// Persist the current state of CoreData to the mySQL DB
- (void) saveDB;

// Animation support

// Push new view controller onto UINavigationController stack using a custom animation
// Fade old VC out, fade new VC in (as opposed to regular push animation)
- (void) animatedPushViewController: (UIViewController *) vc;
- (IBAction) animatedPopViewController;

- (void) toggleVideoStarAtIndex: (NSIndexPath *) indexPath;
- (void) toggleChannelSubscribeAtIndex: (NSIndexPath *) indexPath;

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath;

- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath;


// Video Queue

- (BOOL) hasTabBar;
- (BOOL) isVideoQueueVisibleOnStart;


- (void) highlightVideoQueue: (BOOL) showHighlight;
- (BOOL) pointInVideoQueue: (CGPoint) point;

- (void) animateVideoAdditionToVideoQueue: (VideoInstance *) videoInstance;

- (void) displayVideoViewerWithSelectedIndexPath: (NSIndexPath *) indexPath;
- (void) displayCategoryChooser;


- (void) createChannel:(Channel*)channel;
- (void) addToChannel:(Channel*)channel;

- (void) viewChannelDetails: (Channel *) channel;
- (void) viewProfileDetails: (ChannelOwner *) channelOwner;


-(id)initWithViewId:(NSString*)vid;
-(void)viewCameToScrollFront;

@end
