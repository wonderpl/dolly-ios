//
//  SYNChannelDetailsViewController.m
//  dolly
//
//  Created by Cong on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelDetailsViewController.h"
#import "Appirater.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "CoverArt.h"
#import "GAI.h"
#import "Genre.h"
#import "SSTextView.h"
#import "SYNAppDelegate.h"
#import "SYNCaution.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNExistingChannelCreateNewCell.h"
#import "SYNCoverChooserController.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNDeviceManager.h"
#import "SYNExistingCollectionsViewController.h"
#import "SYNImagePickerController.h"
#import "SYNMasterViewController.h"
#import "SYNModalSubscribersController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOnBoardingPopoverQueueController.h"
#import "SYNProfileRootViewController.h"
#import "SYNReportConcernTableViewController.h"
#import "SYNSubscribersViewController.h"
#import "SYNCollectionVideoCell.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNAvatarButton.h"

static NSString* CollectionVideoCellName = @"SYNCollectionVideoCell";

@import AVFoundation;
@import CoreImage;
@import QuartzCore;

@interface SYNChannelDetailsViewController () <UITextViewDelegate,
SYNImagePickerControllerDelegate,
UIPopoverControllerDelegate,

SYNChannelCoverImageSelectorDelegate>

@property (nonatomic, assign)  CGPoint originalContentOffset;
@property (nonatomic, assign)  CGRect originalSubscribersLabelRect;
@property (nonatomic, assign) BOOL hasAppeared;
@property (nonatomic, assign) BOOL isIPhone;
@property (nonatomic, assign, getter = isImageSelectorOpen) BOOL imageSelectorOpen;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) CIImage *backgroundCIImage;
@property (nonatomic, strong) IBOutlet SSTextView *channelTitleTextView;
@property (nonatomic, strong) IBOutlet UIButton *addCoverButton;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *createChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *playChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *profileImageButton;
@property (nonatomic, strong) IBOutlet UIButton *reportConcernButton;
@property (nonatomic, strong) IBOutlet UIButton *saveChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *selectCategoryButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelCoverImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;
@property (nonatomic, strong) IBOutlet UILabel *subscribersLabel;
@property (nonatomic, strong) IBOutlet UIView *avatarBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *channelTitleTextBackgroundView;
@property (nonatomic, strong) IBOutlet UIView *displayControlsView;
@property (nonatomic, strong) IBOutlet UIView *editControlsView;
@property (nonatomic, strong) IBOutlet UIView *masterControlsView;
@property (nonatomic, strong) NSIndexPath *indexPathToDelete;
@property (nonatomic, strong) NSString *selectedCategoryId;
@property (nonatomic, strong) NSString *selectedCoverId;
@property (nonatomic, strong) SYNCoverChooserController *coverChooserController;
@property (nonatomic, strong) SYNImagePickerController *imagePicker;
@property (nonatomic, strong) SYNModalSubscribersController *modalSubscriptionsContainer;
@property (nonatomic, strong) SYNReportConcernTableViewController *reportConcernController;
@property (nonatomic, strong) UIActivityIndicatorView *subscribingIndicator;
@property (nonatomic, strong) UIImage *originalBackgroundImage;
@property (nonatomic, strong) UIImageView *blurredBGImageView;
@property (nonatomic, strong) UIPopoverController *subscribersPopover;
@property (nonatomic, strong) UIView *coverChooserMasterView;
@property (nonatomic, strong) UIView *noVideosMessageView;
@property (nonatomic, weak) Channel *originalChannel;
@property (nonatomic, weak) IBOutlet UIButton *cancelEditButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UILabel *byLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *shareActivityIndicator;
@property (nonatomic, strong) UIAlertView *deleteChannelAlertView;

//iPhone specific

@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) SYNChannelCoverImageSelectorViewController *coverImageSelector;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelTextInputButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *textBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *subscribersButton;

@property (nonatomic) BOOL editedVideos;


@property (strong, nonatomic) IBOutlet SYNAvatarButton *btnAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblFullName;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblChannelTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblFollowersCount;
@property (strong, nonatomic) IBOutlet UILabel *lblVideosCount;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnFollow;
@property (strong, nonatomic) IBOutlet SYNSocialButton *btnShare;

@property (strong, nonatomic) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *btnFollowers;
@property (strong, nonatomic) IBOutlet UIButton *btnVideos;

@property (strong, nonatomic) IBOutlet UIView *viewIPhoneContainer;

@end


@implementation SYNChannelDetailsViewController

#pragma mark - Object lifecyle

- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode
{
    if ((self = [super initWithViewId: kChannelDetailsViewId]))
    {
        self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
        
        // mode must be set first because setChannel relies on it...
        self.mode = mode;
        self.channel = channel;
    }
    
    return self;
}

    
- (void) dealloc
{
    
}

#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPHONE) {
        [self.lblFullName setFont:[UIFont regularCustomFontOfSize:13]];
        [self.lblChannelTitle setFont:[UIFont regularCustomFontOfSize:24]];
        [self.lblDescription setFont:[UIFont lightCustomFontOfSize:13]];
        [self.lblFollowersCount setFont:[UIFont regularCustomFontOfSize:14]];
        [self.lblVideosCount setFont:[UIFont regularCustomFontOfSize:14]];
    }
    
    
    [self.videoThumbnailCollectionView registerNib: [UINib nibWithNibName: CollectionVideoCellName bundle: nil]
                        forCellWithReuseIdentifier: CollectionVideoCellName];
    
    // == Footer View == //
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: footerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                               withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    

    self.lblFullName.text = self.channel.channelOwner.displayName;
    
    
    self.lblChannelTitle.text = self.channel.title;
    //No cms yet
    self.lblDescription.text = @"Test Description";
    
    
    [self.btnFollowers setTitle:[NSString stringWithFormat: @"%lld %@", self.channel.subscribersCountValue, NSLocalizedString(@"SUBSCRIBERS", nil)] forState:UIControlStateNormal ];
    
    self.btnFollowers.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [self.btnVideos setTitle:[NSString stringWithFormat: @"%lu %@", (unsigned long)self.channel.videoInstances.count, NSLocalizedString(@"VIDEOS", nil)] forState:UIControlStateNormal ];
    
    
    self.btnVideos.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    

    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (self.mode == kChannelDetailsModeDisplay)
    {
        [tracker set: kGAIScreenName
               value: @"Channel details"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        
    }
    
    
    if (IS_IPAD)
    {
        
    }
    else
    {
    }
    
    
    [self performSelector: @selector(checkForOnBoarding)
               withObject: nil
               afterDelay: 1.0f];
    
    

}


- (void) viewWillAppear: (BOOL) animated
{
    
    
    [super viewWillAppear: animated];
    
    self.editedVideos = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coverImageChangedHandler:)
                                                 name: kCoverArtChanged
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(videoQueueCleared)
                                                 name: kVideoQueueClear
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateFailed:)
                                                 name: kUpdateFailed
                                               object: nil];
    
    if (self.channel.channelOwner.uniqueId == appDelegate.currentUser.uniqueId)
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reloadUserImage:)
                                                     name: kUserDataChanged
                                                   object: nil];
    }
    
    //if it user is following already
    self.btnFollow.selected = self.channel.subscribedByUserValue;
    
    // We set up assets depending on whether we are in display or edit mode
    [self setDisplayControlsVisibility: (self.mode == kChannelDetailsModeDisplay)];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    if (self.channel.videoInstances.count == 0 && ![self.channel.uniqueId isEqualToString: kNewChannelPlaceholderId])
    {
//        [self showNoVideosMessage: NSLocalizedString(@"channel_screen_loading_videos", nil)
//                       withLoader: YES];
    }
    
    [self displayChannelDetails];
    
    if (self.hasAppeared)
    {
        AssertOrLog(@"Detail View controller had viewWillAppear called twice!!!!");
    }
    
    if (self.mode == kChannelDetailsModeDisplay && !self.hasAppeared)
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                            object: self
                                                          userInfo: @{kChannel: self.channel}];
    }
    
    self.hasAppeared = YES;
    self.navigationController.navigationBarHidden = NO;
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteHideAllCautions
                                                        object: self];
    
    
    // Remove notifications individually
    // Do this rather than plain RemoveObserver call as low memory handling is based on NSNotifications.
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kCoverArtChanged
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kVideoQueueClear
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kUpdateFailed
                                                  object: nil];
    
    if (self.channel.channelOwner.uniqueId == appDelegate.currentUser.uniqueId)
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: kUserDataChanged
                                                      object: nil];
    }
    
    if (!self.isIPhone)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                            object: self
                                                          userInfo: nil];
    }
    
    [self.subscribersPopover dismissPopoverAnimated: NO];
    
    self.subscribersPopover = nil;
    
    if (self.subscribingIndicator)
    {
        [self.subscribingIndicator removeFromSuperview];
        self.subscribingIndicator = nil;
    }
    
    // cancel the existing request if there is one
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                        object: self
                                                      userInfo: nil];
    
    if (!self.hasAppeared)
    {
        AssertOrLog(@"Detail View controller had viewWillDisappear called twice!!!!");
    }
    
    
    self.hasAppeared = NO;
    self.navigationController.navigationBarHidden = YES;
}


- (BOOL) isFavouritesChannel
{
    return [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId] && self.channel.favouritesValue;
}

- (void) refreshFavouritesChannel
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                        object: self
                                                      userInfo: @{kChannel: self.channel}];
}



- (IBAction)followControlPressed:(id)sender
{
  //  [self.delegate followControlPressed:sender];
    
    // Update google analytics
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"channelSubscribeButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    self.btnFollow.enabled = NO;
    self.btnFollow.selected = FALSE;
    
    [self addSubscribeActivityIndicator];
    
    // Defensive programming
    if (self.channel != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                            object: self
                                                          userInfo: @{kChannel : self.channel}];
    }

}

- (void) addSubscribeActivityIndicator
{
    self.subscribingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    self.subscribingIndicator.center = self.btnFollow.center;
    [self.subscribingIndicator startAnimating];
    [self.view addSubview: self.subscribingIndicator];
}

- (IBAction)shareControlPressed:(id)sender
{
    [self.delegate shareControlPressed: sender];

}


#pragma mark - ScrollView Delegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    // TODO: Implement rest if needed
    
    
    CGFloat offset = scrollView.contentOffset.y;
    
    if (IS_IPHONE) {
        
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, -offset);
        
        self.viewIPhoneContainer.transform = move;
        
        
    }
}

#pragma mark - Tab View Methods

- (void) setChannel: (Channel *) channel
{
    self.originalChannel = channel;
    
    
    NSError *error = nil;
    
    if (!appDelegate)
    {
        appDelegate = UIApplication.sharedApplication.delegate;
    }
    
    if (self.channel)
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: NSManagedObjectContextDidSaveNotification
                                                      object: self.channel.managedObjectContext];
    }
    
    _channel = channel;
    
    if (!self.channel)
    {
        return;
    }
    
    // create a copy that belongs to this viewId (@"ChannelDetails")
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: channel.managedObjectContext]];
    
    [channelFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", channel.uniqueId, self.viewId]];
    
    
    NSArray *matchingChannelEntries = [channel.managedObjectContext
                                       executeFetchRequest: channelFetchRequest
                                       error: &error];
    
    if (matchingChannelEntries.count > 0)
    {
        _channel = (Channel *) matchingChannelEntries[0];
        _channel.markedForDeletionValue = NO;
        
        if (matchingChannelEntries.count > 1) // housekeeping, there can be only one!
        {
            for (int i = 1; i < matchingChannelEntries.count; i++)
            {
                [channel.managedObjectContext
                 deleteObject: (matchingChannelEntries[i])];
            }
        }
    }
    else
    {
        // the User will be copyed over, but as a ChannelOwner, so "current" will not be set to YES
        _channel = [Channel	 instanceFromChannel: channel
                                       andViewId: self.viewId
                       usingManagedObjectContext: channel.managedObjectContext
                             ignoringObjectTypes: kIgnoreNothing];
        
        if (_channel)
        {
            [_channel.managedObjectContext
             save: &error];
            
            if (error)
            {
                _channel = nil; // further error code
            }
        }
    }
    
    if (self.channel)
    {
        // check for subscribed
        self.channel.subscribedByUserValue = NO;
        
        for (Channel *subscription in appDelegate.currentUser.subscriptions)
        {
            if ([subscription.uniqueId
                 isEqualToString: self.channel.uniqueId])
            {
                self.channel.subscribedByUserValue = YES;
            }
        }
        
        if ([self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
        {
            [self updateChannelOwnerWithUser];
            
            // set the request to maximum
            
            self.dataRequestRange = NSMakeRange(0, MAXIMUM_REQUEST_LENGTH);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channel.managedObjectContext];
        
//        if (self.mode == kChannelDetailsModeDisplay && self.hasAppeared)
//        {
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
//                                                                object: self
//                                                              userInfo: @{kChannel: self.channel}];
//        }
    }
}



- (void) updateChannelOwnerWithUser
{
    BOOL dateDirty = NO;
    
    if (![self.channel.channelOwner.displayName isEqualToString: appDelegate.currentUser.displayName])
    {
        self.channel.channelOwner.displayName = appDelegate.currentUser.displayName;
        dateDirty = YES;
    }
    
    if (![self.channel.channelOwner.thumbnailURL isEqualToString: appDelegate.currentUser.thumbnailURL])
    {
        self.channel.channelOwner.thumbnailURL = appDelegate.currentUser.thumbnailURL;
        dateDirty = YES;
    }
    
    if (dateDirty) // save
    {
        NSError *error;
        [self.channel.channelOwner.managedObjectContext
         save: &error];
        
        if (!error)
        {
            [self displayChannelDetails];
        }
        else
        {
            DebugLog(@"%@", [error description]);
        }
    }
}

- (void) displayChannelDetails
{
    self.channelOwnerLabel.text = self.channel.channelOwner.displayName;
    
    NSString *detailsString;
    
    if (self.channel.publicValue)
    {
        detailsString = [NSString stringWithFormat: @"%lld %@", self.channel.subscribersCountValue, NSLocalizedString(@"SUBSCRIBERS", nil)];
        self.shareButton.hidden = FALSE;
        self.subscribersButton.hidden = FALSE;
    }
    else
    {
        detailsString = @"Private";
        self.shareButton.hidden = TRUE;
        self.subscribersButton.hidden = TRUE;
    }
    
    self.subscribersLabel.text = detailsString;
    
    
    // Set title //
    if (self.channel.title)
    {
        self.channelTitleTextView.text = self.channel.title;
    }
    else
    {
        self.channelTitleTextView.text = @"";
    }
    
    [self adjustTextView];
    
    UIImage *placeholderImage = [UIImage imageNamed: @"PlaceholderAvatarProfile.png"];
    
    NSArray *thumbnailURLItems = [self.channel.channelOwner.thumbnailURL componentsSeparatedByString: @"/"];
    
    if (thumbnailURLItems.count >= 6) // there is a url string with the proper format
    {
        // whatever is set to be the default size by the server (ex. 'thumbnail_small') //
        NSString *thumbnailSizeString = thumbnailURLItems[5];
        
        
        NSString *thumbnailUrlString = [self.channel.channelOwner.thumbnailURL stringByReplacingOccurrencesOfString: thumbnailSizeString
                                                                                                         withString: @"thumbnail_large"];
        
        [self.avatarImageView setImageWithURL: [NSURL URLWithString: thumbnailUrlString]
                             placeholderImage: placeholderImage
                                      options: SDWebImageRetryFailed];
    }
    else
    {
        self.avatarImageView.image = placeholderImage;
    }
}

- (void) adjustTextView
{
    CGFloat topCorrect = ([self.channelTitleTextView bounds].size.height - [self.channelTitleTextView contentSize].height);
    
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
    
    [self.channelTitleTextView setContentOffset: (CGPoint) { .x = 0, .y = -topCorrect}
                                       animated: NO];
}


#pragma mark - Data Model Change

- (void) handleDataModelChange: (NSNotification *) notification
{
    NSArray *updatedObjects = [notification userInfo][NSUpdatedObjectsKey];
    
    NSArray *deletedObjects = [notification userInfo][NSDeletedObjectsKey]; // our channel has been deleted
    
    if ([deletedObjects containsObject: self.channel])
    {
        return;
    }
    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (obj == self.channel)
        {
            self.dataItemsAvailable = self.channel.totalVideosValue;
            
            
            self.btnFollow.selected = self.channel.subscribedByUserValue;
            self.btnFollow.enabled = YES;
            
            if (self.subscribingIndicator)
            {
                [self.subscribingIndicator removeFromSuperview];
                self.subscribingIndicator = nil;
            }
            
            [self reloadCollectionViews];
            
            if (self.channel.videoInstances.count == 0)
            {
//                [self showNoVideosMessage: NSLocalizedString(@"channel_screen_no_videos", nil)
//                               withLoader: NO];
            }
            else
            {
//                [self showNoVideosMessage: nil
//                               withLoader: NO];
            }
            
            return;
        }
        else if ([obj isKindOfClass: [User class]] && [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
        {
            [self updateChannelOwnerWithUser];
        }
    }];
    
    
    
    if ((self.channel.channelOwner.displayName !=  nil) && (self.channelOwnerLabel.text == nil))
    {
        [self displayChannelDetails];
    }
    
    BOOL visible = (self.mode == kChannelDetailsModeDisplay);
    
    self.editButton.hidden = (visible && ![self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]);
    
    if (self.channel.favouritesValue && [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
    {
        self.editButton.hidden = TRUE;
    }
}



- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    [self displayChannelDetails];
    
    
    
}



#pragma mark - Collection Delegate/Data Source Methods

- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.channel.videoInstances.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    SYNCollectionVideoCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: CollectionVideoCellName
                                                                                           forIndexPath: indexPath];
    
    
    VideoInstance *videoInstance = self.channel.videoInstances [indexPath.item];
    
    
    [videoThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                 placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]
                                          options: SDWebImageRetryFailed];
    
    videoThumbnailCell.titleLabel.text = videoInstance.title;
    videoThumbnailCell.delegate = self;
    
    
    
    return videoThumbnailCell;
}


//- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
//            viewForSupplementaryElementOfKind: (NSString *) kind
//                                  atIndexPath: (NSIndexPath *) indexPath
//{
//    UICollectionReusableView *supplementaryView;
//
//    if (kind == UICollectionElementKindSectionFooter)
//    {
//        self.footerView = [self.videoThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
//                                                                                withReuseIdentifier: @"SYNChannelFooterMoreView"
//                                                                                       forIndexPath: indexPath];
//
//        supplementaryView = self.footerView;
//
//        if (self.channel.videoInstances.count > 0 && self.moreItemsToLoad)
//        {
//            self.footerView.showsLoading = self.isLoadingMoreContent;
//        }
//    }
//
//    return supplementaryView;
//}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout *) collectionViewLayout
referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize;
    
    if (collectionView == self.videoThumbnailCollectionView &&
        self.channel.videoInstances.count != 0)
    {
        footerSize = [self footerSize];
        
        
        if (self.moreItemsToLoad)
        {
            footerSize = CGSizeMake(1.0f, 5.0f);
        }
    }
    else
    {
        footerSize = CGSizeZero;
    }
    
    return footerSize;
}


- (void) loadMoreVideos
{
    if(!self.moreItemsToLoad)
        return;
    
    
    self.loadingMoreContent = YES;
    
    
    [self incrementRangeForNextRequest];
    
    __weak typeof(self) weakSelf = self;
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
        weakSelf.loadingMoreContent = NO;
        
        [weakSelf.channel addVideoInstancesFromDictionary: dictionary];
        
        NSError *error;
        [weakSelf.channel.managedObjectContext
         save: &error];
    };
    
    // define success block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        weakSelf.loadingMoreContent = NO;
        DebugLog(@"Update action failed");
    };
    
    if ([self.channel.resourceURL hasPrefix: @"https"]) // https does not cache so it is fresh
    {
        [appDelegate.oAuthNetworkEngine videosForChannelForUserId: appDelegate.currentUser.uniqueId
                                                        channelId: self.channel.uniqueId
                                                          inRange: self.dataRequestRange
                                                completionHandler: successBlock
                                                     errorHandler: errorBlock];
    }
    else
    {
        [appDelegate.networkEngine videosForChannelForUserId: appDelegate.currentUser.uniqueId
                                                   channelId: self.channel.uniqueId
                                                     inRange: self.dataRequestRange
                                           completionHandler: successBlock
                                                errorHandler: errorBlock];
    }
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // the method is being replaced by the 'videoButtonPressed' because other elements on the cell migth be interactive as well
}


- (void) videoButtonPressed: (UIButton *) videoButton
{
    UIView *candidateCell = videoButton;
    
    while (![candidateCell isKindOfClass: [SYNCollectionVideoCell class]])
    {
        candidateCell = candidateCell.superview;
    }
    
    SYNCollectionVideoCell *selectedCell = (SYNCollectionVideoCell *) candidateCell;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: selectedCell.center];
    
    SYNMasterViewController *masterViewController = (SYNMasterViewController *) appDelegate.masterViewController;
    
    NSArray *videoInstancesToPlayArray = self.channel.videoInstances.array;
    
    [masterViewController addVideoOverlayToViewController: self
                                   withVideoInstanceArray: videoInstancesToPlayArray
                                         andSelectedIndex: indexPath.item
                                               fromCenter: self.view.center];
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void) collectionView: (UICollectionView *) collectionView
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    VideoInstance *viToSwap = (self.channel.videoInstancesSet)[fromIndexPath.item];
    
    [self.channel.videoInstancesSet removeObjectAtIndex: fromIndexPath.item];
    
    [self.channel.videoInstancesSet insertObject: viToSwap
                                         atIndex: toIndexPath.item];
    
    self.editedVideos = YES;
    
    // set the new positions
    [self.channel.videoInstances enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL *stop) {
        [(VideoInstance *) obj setPositionValue : index];
    }];
}


- (void) setDisplayControlsVisibility: (BOOL) visible
{
    // Support for different appearances / functionality of textview
    self.channelTitleTextView.textColor = (visible) ? [UIColor whiteColor] : [UIColor blackColor];
    self.channelTitleTextView.userInteractionEnabled = (visible) ? NO : YES;
    self.channelTitleTextBackgroundView.backgroundColor = (visible) ? [UIColor clearColor] : [UIColor whiteColor];
    self.displayControlsView.alpha = (visible) ? 1.0f : 0.0f;
    self.editControlsView.alpha = (visible) ? 0.0f : 1.0f;
    self.coverChooserMasterView.hidden = (visible) ? TRUE : FALSE;
    self.profileImageButton.enabled = visible;
    
    self.editButton.hidden = (visible && ![self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]);
    
    self.logoImageView.hidden = !visible;
    
    // If the current user's favourites channel, hide edit button and move subscribers
    if (self.channel.favouritesValue &&
        [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
    {
        self.editButton.hidden = TRUE;
        
        CGFloat offset = IS_IPAD ? 80.0f : 125.0f;
        
        CGRect frame = self.subscribersLabel.frame;
        
        frame.origin.x = 144.0f - offset;
        
        self.subscribersLabel.frame = frame;
        
        self.originalSubscribersLabelRect = frame;
        
        self.subscribersButton.center = self.subscribersLabel.center;
    }
    
    
//    [(LXReorderableCollectionViewFlowLayout *) self.videoThumbnailCollectionView.collectionViewLayout longPressGestureRecognizer].enabled = (visible) ? FALSE : TRUE;
    
    if (visible == NO)
    {
        // If we are in edit mode, then hide navigation controls
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsHide
                                                            object: self
                                                          userInfo: nil];
    }
}


// For edit controls just do the inverse of details control
- (void) setEditControlsVisibility: (BOOL) visible
{
    _mode = visible;
    
    [self setDisplayControlsVisibility: !visible];
    
    [self.videoThumbnailCollectionView reloadData];
}


- (void) enterEditMode
{
    self.coverChooserController.selectedImageURL = self.channel.channelCover.imageUrl;
    
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         [self setEditControlsVisibility: TRUE];
                     }
                     completion: nil];
}


- (void) leaveEditMode
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         [self setDisplayControlsVisibility: TRUE];
                     }
                     completion: nil];
}


#pragma mark - KVO support

// We fade out all controls/information views when the user starts scrolling the videos collection view
// by monitoring the collectionview content offset using KVO
- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if ([keyPath isEqualToString: kTextViewContentSizeKey]){
        UITextView *tv = object;
        
        // Bottom vertical alignment
        CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
        
        // topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
        
        [tv setContentOffset: (CGPoint) { .x = 0, .y = -topCorrect}
                    animated: NO];
    }
}


- (void) fetchAndStoreUpdatedChannelForId: (NSString *) channelId
                                 isUpdate: (BOOL) isUpdate
{
    [appDelegate.oAuthNetworkEngine channelCreatedForUserId: appDelegate.currentOAuth2Credentials.userId
                                                  channelId: channelId
                                          completionHandler: ^(id dictionary) {
                                              
                                              Channel *createdChannel;
                                              
                                              if (!isUpdate) // its a new creation
                                              {
                                                  
                                                  createdChannel = [Channel instanceFromDictionary: dictionary
                                                                         usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                                               ignoringObjectTypes: kIgnoreChannelOwnerObject];
                                                  
                                                  // this will automatically add the channel to the set of channels of the User
                                                  [appDelegate.currentUser.channelsSet
                                                   addObject: createdChannel];
                                                  
                                                  if ([createdChannel.categoryId isEqualToString: @""])
                                                  {
                                                      createdChannel.publicValue = NO;
                                                  }
                                                  
                                                  Channel * oldChannel = self.channel;
                                                  
                                                  self.channel = createdChannel;
                                                  
                                                  self.originalChannel = self.channel;
                                                  
                                                  [oldChannel.managedObjectContext deleteObject: oldChannel];
                                                  
                                                  NSError *error;
                                                  
                                                  [oldChannel.managedObjectContext save: &error];
                                              }
                                              else
                                              {
                                                  [Appirater userDidSignificantEvent: FALSE];
                                                  
                                                  [self.channel setAttributesFromDictionary: dictionary
                                                                        ignoringObjectTypes: kIgnoreChannelOwnerObject];
                                                  
                                                  // if editing the user's channel we must update the original
                                                  
                                                  [self.originalChannel setAttributesFromDictionary: dictionary
                                                                                ignoringObjectTypes: kIgnoreChannelOwnerObject];
                                              }
                                              
                                              [appDelegate saveContext: YES];
                                              
                                              // Complete Channel Creation //
                                              self.channelOwnerLabel.text = [appDelegate.currentUser.displayName uppercaseString];
                                              
                                              [self displayChannelDetails];
                                              
//                                              [self reloadUserImage: nil];
                                              
                                              [self setDisplayControlsVisibility: YES];
                                              
                                              self.mode = kChannelDetailsModeDisplay;
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kNoteAllNavControlsShow
                                                                                                   object: self
                                                                                                 userInfo: nil];
                                              
                                              [self finaliseViewStatusAfterCreateOrUpdate: !self.isIPhone];
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                   object: nil];
                                              
                                              [self notifyForChannelCreation: self.channel];
                                              
                                              self.isLocked = NO;
                                          } errorHandler: ^(id err) {
                                              self.isLocked = NO;
                                              
                                              DebugLog(@"Error @ getNewlyCreatedChannelForId:");
                                              [self	  showError: NSLocalizedString(@"Could not retrieve the uploaded channel data. Please try accessing it from your profile later.", nil)
                                                 showErrorTitle: @"Error"];
                                              self.channelOwnerLabel.text = [appDelegate.currentUser.displayName uppercaseString];
                                              
                                              [self displayChannelDetails];
                                              
                                              [self setDisplayControlsVisibility: YES];
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kNoteAllNavControlsShow
                                                                                                   object: self
                                                                                                 userInfo: nil];
                                              
                                              [self finaliseViewStatusAfterCreateOrUpdate: !self.isIPhone];
                                              
                                              
                                              [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                   object: nil];
                                          }];
}


- (void) notifyForChannelCreation: (Channel *) channelCreated
{
    // == Decide on the success message type shown == //
    NSNotification *successNotification = [NSNotification notificationWithName: kNoteChannelSaved
                                                                        object: self];
    
    
    SYNCaution *caution;
    CautionCallbackBlock actionBlock;
    NSMutableArray *conditionsArray = [NSMutableArray arrayWithCapacity: 3];
    NSString *buttonString;
    int numberOfConditions = 0;
    __weak SYNChannelDetailsViewController *wself = self;
    
    if (channelCreated) // channelCreated will always be true in this implementation, change from self.channels to show message only on creation and not on update
    {
        if (self.channel.title.length > 8 && [[self.channel.title substringToIndex: 8] isEqualToString: @"UNTITLED"])                  // no title
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_title", nil)];
            buttonString = NSLocalizedString(@"enter_title", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
              //  [wself editButtonTapped: wself.editButton];
                [wself.channelTitleTextView becomeFirstResponder];
            };
            numberOfConditions++;
        }
        
        if ([self.channel.categoryId isEqualToString: @""])
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_category", nil)];
            buttonString = NSLocalizedString(@"select_category", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
//                [wself editButtonTapped: wself.editButton];
//                [wself selectCategoryButtonTapped: wself.selectCategoryButton];
            };
            numberOfConditions++;
        }
        
        if ([self.channel.channelCover.imageUrl isEqualToString: @""])
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_cover", nil)];
            buttonString = NSLocalizedString(@"select_cover", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
//                [wself editButtonTapped: wself.editButton];
//                [wself addCoverButtonTapped: wself.addCoverButton];
            };
            numberOfConditions++;
        }
        
        NSMutableString *conditionString;
        switch (numberOfConditions)
        {
            case 0 :
                
                break;
                
            case 1 :
                conditionString = [NSMutableString stringWithString: NSLocalizedString(@"channel_will_remain_private_until", nil)];
                [conditionString appendString: conditionsArray[0]];
                break;
                
            case 2:
                conditionString = [NSMutableString stringWithString: NSLocalizedString(@"channel_will_remain_private_until", nil)];
                [conditionString appendString: conditionsArray[0]];
                [conditionString appendString: @" AND "];
                [conditionString appendString: conditionsArray[1]];
                break;
                
            case 3:
                conditionString = [NSMutableString stringWithString: NSLocalizedString(@"channel_will_remain_private_until", nil)];
                [conditionString appendString: conditionsArray[0]];
                [conditionString appendString: @", "];
                [conditionString appendString: conditionsArray[1]];
                [conditionString appendString: @" AND "];
                [conditionString appendString: conditionsArray[2]];
                break;
        }
        
        if (numberOfConditions > 0)
        {
            if (numberOfConditions > 1)
            {
                buttonString = @"EDIT";
                actionBlock = ^{
//                    [wself setMode: kChannelDetailsModeEdit];
//                    [wself editButtonTapped: wself.editButton];
                };
            }
            
            caution = [SYNCaution withMessage: (NSString *) conditionString
                                  actionTitle: buttonString
                                  andCallback: actionBlock];
            
            successNotification = [NSNotification notificationWithName: kNoteSavingCaution
                                                                object: self
                                                              userInfo: @{kCaution: caution}];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotification: successNotification];
}


- (void) finaliseViewStatusAfterCreateOrUpdate: (BOOL) isIPad
{
    if (isIPad)
    {
        self.createChannelButton.hidden = YES;
    }
    else
    {
        SYNMasterViewController *master = (SYNMasterViewController *) self.presentingViewController;
        
        if (master)
        {
            //This scenario happens on channel creation only and means this channel is presented modally.
            //After creation want to show it as if it is part of the master view hierarchy.
            //Thus we move the view there.
            
            //Check for precense of existing channels view controller.
            UIViewController *lastController = [[master childViewControllers] lastObject];
            
            if ([lastController isKindOfClass: [SYNExistingCollectionsViewController class]])
            {
                //This removes the "existing channels view controller"
                [lastController.view removeFromSuperview];
                [lastController removeFromParentViewController];
            }
            
            //Now dimiss self modally (not animated)
            [master dismissViewControllerAnimated: NO
                                       completion: nil];
            
            //Change to display mode
            self.mode = kChannelDetailsModeDisplay;
            
            //Don't really like this, but send notification to hide title and dots for a seamless transition.
            [[NSNotificationCenter defaultCenter] postNotificationName: kNoteHideTitleAndDots
                                                                object: self
                                                              userInfo: nil];
            
            //And show as if displayed from the normal master view hierarchy
            [appDelegate.viewStackManager pushController: self];
        }
        
        [self setDisplayControlsVisibility: YES];
        [self.activityIndicator stopAnimating];
    }
}


- (void) showError: (NSString *) errorMessage showErrorTitle: (NSString *) errorTitle
{
    self.createChannelButton.hidden = NO;
    [self.activityIndicator stopAnimating];
    
    [[[UIAlertView alloc] initWithTitle: errorTitle
                                message: errorMessage
                               delegate: nil
                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}

- (IBAction)avatarTapped:(id)sender {
    
    SYNProfileRootViewController *profileVC = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId WithMode:OtherUsersProfile];
    
    
    profileVC.channelOwner = self.channel.channelOwner;
    
    [self.navigationController pushViewController:profileVC animated:NO];
    

}



- (IBAction) followersLabelPressed: (id) sender
{
   // [self releasedSubscribersLabel: sender];
    
    if (self.subscribersPopover)
    {
        return;
    }
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Subscribers List"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    SYNSubscribersViewController *subscribersViewController = [[SYNSubscribersViewController alloc] initWithChannel: self.channel];
    
    if (IS_IPAD)
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: subscribersViewController];
        navigationController.view.backgroundColor = [UIColor clearColor];
        
        
        self.subscribersPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
        
        self.subscribersPopover.popoverBackgroundViewClass = [SYNAccountSettingsPopoverBackgroundView class];
        
        self.subscribersPopover.popoverContentSize = CGSizeMake(514, 626);
        self.subscribersPopover.delegate = self;
        
        
        CGRect rect = CGRectMake([SYNDeviceManager.sharedInstance currentScreenWidth] * 0.5,
                                 480.0f, 1, 1);
        
        
        [self.subscribersPopover presentPopoverFromRect: rect
                                                 inView: self.view
                               permittedArrowDirections: 0
                                               animated: YES];
    }
    else
    {
        self.modalSubscriptionsContainer = [[SYNModalSubscribersController alloc] initWithContentViewController: subscribersViewController];
        
        [appDelegate.viewStackManager presentModallyController: self.modalSubscriptionsContainer];
    }
}




@end
