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
#import "SYNOAuthNetworkEngine.h"
#import "SYNSocialActionsDelegate.h"
#import "SYNPopupMessageView.h"

@import CoreData;
@import UIKit;

@class VideoInstance, Channel, ChannelOwner, Genre, SubGenre;

@interface SYNAbstractViewController : UIViewController <NSFetchedResultsControllerDelegate,
                                                         UICollectionViewDataSource,
                                                         UICollectionViewDelegate,
                                                         SYNSocialActionsDelegate>
{
@protected
    SYNAppDelegate *appDelegate;
    NSString *viewId;
    NSString *abstractTitle;
}

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) NSInteger dataItemsAvailable;
@property (nonatomic) NSRange dataRequestRange;
@property (nonatomic, assign, getter = isLoadingMoreContent) BOOL loadingMoreContent;
@property (nonatomic, readonly) NSString *viewId;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) SYNChannelFooterMoreView *footerView;
@property (readonly) NSManagedObjectContext *mainManagedObjectContext;

- (void) performAction: (NSString *) action withObject: (id) object;

- (void) displayVideoViewerFromCell: (UICollectionViewCell *) cell
                         andSubCell: (UICollectionViewCell *) subCell
                     atSubCellIndex: (NSInteger) subCellIndex;

- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                 andSelectedIndex: (int) selectedIndex
                                           center: (CGPoint) center;


- (id) initWithViewId: (NSString *) vid;

- (void) resetDataRequestRange;

- (void) incrementRangeForNextRequest;
- (BOOL) moreItemsToLoad;

// Share
- (void) requestShareLinkWithObjectType: (NSString *) objectType
                               objectId: (NSString *) objectId;

- (void) shareVideoInstance: (VideoInstance *) videoInstance;

- (void) shareChannel: (Channel *) channel
              isOwner: (NSNumber *) isOwner
           usingImage: (UIImage *) image;


- (SYNPopupMessageView*) displayPopupMessage: (NSString*) messageKey
                                  withLoader: (BOOL) isLoader;

- (void) removePopupMessage;

- (void)viewProfileDetails:(ChannelOwner *)channelOwner;
- (void)viewChannelDetails:(Channel *)channel;


// Purchase
- (void) applicationWillEnterForeground: (UIApplication *) application;

- (CGSize) footerSize;

- (void) checkForOnBoarding;

@end
