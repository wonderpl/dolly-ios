//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers


#import "MKNetworkOperation.h"
#import "SYNAppDelegate.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNNetworkEngine.h"
#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOnBoardingPopoverView.h"
#import "SYNSocialActionsDelegate.h"
#import "SYNPopupMessageView.h"

@import CoreData;
@import UIKit;

typedef void (^SYNShareCompletionBlock)(void);

@class VideoInstance, Channel, ChannelOwner, Genre, SubGenre;

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate,
                                                         UICollectionViewDataSource,
                                                         UICollectionViewDelegate,
                                                         SYNSocialActionsDelegate>
{
@protected
    SYNAppDelegate *appDelegate;
    BOOL tabExpanded;
    NSString *viewId;
    NSFetchedResultsController *fetchedResultsController;
    NSString *abstractTitle;
}

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) NSInteger dataItemsAvailable;
@property (nonatomic) NSRange dataRequestRange;
@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) CGPoint initialDragCenter;
@property (nonatomic, assign, getter = isLoadingMoreContent) BOOL loadingMoreContent;
@property (nonatomic, readonly) NSString *viewId;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) SYNChannelFooterMoreView *footerView;
@property (nonatomic, strong) UIImageView *draggedView;
@property (nonatomic, weak) MKNetworkOperation *runningNetworkOperation;
@property (readonly) BOOL alwaysDisplaysSearchBox;
@property (readonly) NSManagedObjectContext *mainManagedObjectContext;
@property (readonly, getter = isVideoQueueVisible) BOOL videoQueueVisible;

- (void) performAction: (NSString *) action withObject: (id) object;


- (void) videoOverlayDidDissapear;

- (void) displayVideoViewerFromCell: (UICollectionViewCell *) cell
                         andSubCell: (UICollectionViewCell *) subCell
                     atSubCellIndex: (NSInteger) subCellIndex;

- (NSIndexPath *) indexPathFromVideoInstanceButton: (UIButton *) button;

- (void) reloadCollectionViews;

- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath;

- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                 andSelectedIndex: (int) selectedIndex
                                           center: (CGPoint) center;
- (void) refresh;

- (id) initWithViewId: (NSString *) vid;

- (void) resetDataRequestRange;

- (void) incrementRangeForNextRequest;
- (BOOL) moreItemsToLoad;

- (void) headerTapped;

- (IBAction) toggleStarAtIndexPath: (NSIndexPath *) indexPath;

// Share
- (void) requestShareLinkWithObjectType: (NSString *) objectType
                               objectId: (NSString *) objectId;

- (void) shareVideoInstance: (VideoInstance *) videoInstance;


- (void) addVideoAtIndexPath: (NSIndexPath *) indexPath
               withOperation: (NSString *) operation;

- (SYNPopupMessageView*) displayPopupMessage: (NSString*) messageKey
                                  withLoader: (BOOL) isLoader;

- (void) removePopupMessage;

- (void)viewProfileDetails:(ChannelOwner *)channelOwner;


// Purchase
- (void) initiatePurchaseAtURL: (NSURL *) purchaseURL;

- (void) applicationWillEnterForeground: (UIApplication *) application;

- (CGSize) footerSize;



- (void) createAndDisplayNewChannel;

- (EntityType) associatedEntity;

- (void) checkForOnBoarding;

@end
