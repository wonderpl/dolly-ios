//
//  SYNAbstractChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

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
#import "SYNChannelCreateNewCell.h"
#import "SYNCollectionDetailsViewController.h"
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

static NSString* CollectionVideoCellName = @"SYNCollectionVideoCell";

@import AVFoundation;
@import CoreImage;
@import QuartzCore;

@interface SYNCollectionDetailsViewController () <UITextViewDelegate,
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
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *createChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *playChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *profileImageButton;
@property (nonatomic, strong) IBOutlet UIButton *reportConcernButton;
@property (nonatomic, strong) IBOutlet UIButton *saveChannelButton;
@property (nonatomic, strong) IBOutlet UIButton *selectCategoryButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *subscribeButton;
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

@end


@implementation SYNCollectionDetailsViewController

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
    // Defensive programming
    self.channelTitleTextView.delegate = nil;
    self.imagePicker.delegate = nil;
    
    // This will remove the observer (in the setter)
    self.channelTitleTextView = nil;
}


#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.isIPhone = IS_IPHONE;
    
    self.channelOwnerLabel.font = [UIFont regularCustomFontOfSize: self.channelOwnerLabel.font.pointSize];
    self.subscribersLabel.font = [UIFont regularCustomFontOfSize: self.subscribersLabel.font.pointSize];
    self.byLabel.font = [UIFont lightCustomFontOfSize: self.byLabel.font.pointSize];
    self.channelTitleTextView.font = [UIFont lightCustomFontOfSize: self.channelTitleTextView.font.pointSize];
    
    // Display 'Done' instead of 'Return' on Keyboard
    self.channelTitleTextView.returnKeyType = UIReturnKeyDone;
    
    self.channelTitleTextView.backgroundColor = [UIColor clearColor];
    
    self.channelTitleTextView.placeholder = NSLocalizedString(@"channel_creation_screen_field_channeltitle_placeholder", nil);
    
    self.channelTitleTextView.placeholderTextColor = [UIColor colorWithRed: 0.909
                                                                     green: 0.909
                                                                      blue: 0.909
                                                                     alpha: 1.0f];
    // Set delegate so that we can respond to events
    self.channelTitleTextView.delegate = self;
    
    
    
    
    // == Video Cells == //
    
    [self.videoThumbnailCollectionView registerNib: [UINib nibWithNibName: CollectionVideoCellName bundle: nil]
                        forCellWithReuseIdentifier: CollectionVideoCellName];
    
    // == Footer View == //
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: footerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                               withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    
    
    // == Avatar Image == //
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
    
   
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (self.mode == kChannelDetailsModeDisplay)
    {
        [tracker set: kGAIScreenName
               value: @"Channel details"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        
        self.createChannelButton.hidden = YES;
    }
    else if (self.mode)
    {
        [tracker set: kGAIScreenName
               value: @"Add to channel"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        
        self.createChannelButton.hidden = NO;
        self.backButton.hidden = YES;
        self.cancelEditButton.hidden = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsHide
                                                            object: self
                                                          userInfo: nil];
    }
    
    //Remove the save button. It is added back again if the edit button is tapped.
    [self.saveChannelButton removeFromSuperview];
    
    if (IS_IPAD)
    {
        // Set text on add cover and select category buttons
        NSString *coverString = NSLocalizedString(@"channel_creation_screen_button_selectcover_label", nil);
        
        NSMutableAttributedString *attributedCoverString = [[NSMutableAttributedString alloc] initWithString: coverString
                                                                                                  attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed: 40.0f / 255.0f
                                                                                                                                                                green: 45.0f / 255.0f
                                                                                                                                                                 blue: 51.0f / 255.0f
                                                                                                                                                                alpha: 1.0f],
                                                                                         NSFontAttributeName: [UIFont regularCustomFontOfSize: 18.0f]}];
        
        [self.addCoverButton setAttributedTitle: attributedCoverString
                                       forState: UIControlStateNormal];
        
        // Now do fancy attributed string
        NSString *categoryString = NSLocalizedString(@"channel_creation_screen_button_selectcat_label", nil);
        
        
        NSMutableAttributedString *attributedCategoryString = [[NSMutableAttributedString alloc] initWithString: categoryString
                                                                                                     attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed: 40.0f / 255.0f
                                                                                                                                                                   green: 45.0f / 255.0f
                                                                                                                                                                    blue: 51.0f / 255.0f
                                                                                                                                                                   alpha: 1.0f],
                                                                                            NSFontAttributeName: [UIFont regularCustomFontOfSize: 18.0f]}];
        
        // Set text on add cover and select category buttons
        [self.selectCategoryButton setAttributedTitle: attributedCategoryString
                                             forState: UIControlStateNormal];
        
        self.coverChooserController = [[SYNCoverChooserController alloc] initWithSelectedImageURL: self.channel.channelCover.imageUrl];
        [self addChildViewController: self.coverChooserController];
        self.coverChooserMasterView = self.coverChooserController.view;
        
        
    }
    else
    {
        self.textBackgroundImageView.image = [[UIImage imageNamed: @"FieldChannelTitle"] resizableImageWithCapInsets: UIEdgeInsetsMake(5, 5, 6, 6)];
        
        self.addCoverButton.titleLabel.font = [UIFont regularCustomFontOfSize: self.addCoverButton.titleLabel.font.pointSize];
        self.addCoverButton.titleLabel.numberOfLines = 2;
        self.addCoverButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.addCoverButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.selectCategoryButton.titleLabel.font = [UIFont regularCustomFontOfSize: self.selectCategoryButton.titleLabel.font.pointSize];
        self.selectCategoryButton.titleLabel.numberOfLines = 2;
        self.selectCategoryButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.selectCategoryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if (self.mode != kChannelDetailsModeDisplay)
        {
            self.view.backgroundColor = [UIColor colorWithWhite: 0.92f
                                                          alpha: 1.0f];
        }
        
        // button text alignement iOS7
        
        if(IS_IOS_7_OR_GREATER)
        {
            UIEdgeInsets eInsets;
            
            eInsets = self.addCoverButton.contentEdgeInsets;
            eInsets.top = 4.0f;
            self.addCoverButton.contentEdgeInsets = eInsets;
            
            
            eInsets = self.selectCategoryButton.contentEdgeInsets;
            eInsets.top = 4.0f;
            self.selectCategoryButton.contentEdgeInsets = eInsets;
            
            CGRect vFrame;
            for (UIView* viewToMove in @[self.saveChannelButton, self.createChannelButton,
                                         self.cancelEditButton, self.deleteChannelButton, self.cancelTextInputButton, self.activityIndicator]) {
                vFrame = viewToMove.frame;
                vFrame.origin.y += 6.0f;
                viewToMove.frame = vFrame;
            }
        }
        
        if(self.mode == kChannelDetailsModeCreate)
            self.deleteChannelButton.hidden = YES;
    }
    
    self.selectedCategoryId = self.channel.categoryId;
    self.selectedCoverId = @"";
    
    CGRect correctRect = self.coverChooserMasterView.frame;
    correctRect.origin.y = 404.0;
    self.coverChooserMasterView.frame = correctRect;
    
    [self.editControlsView addSubview: self.coverChooserMasterView];
    
    self.cameraButton = self.coverChooserController.cameraButton;
    
    [self.cameraButton addTarget: self
                          action: @selector(userTouchedCameraButton:)
                forControlEvents: UIControlEventTouchUpInside];

    
    self.originalContentOffset = self.videoThumbnailCollectionView.contentOffset;
    
    // iOS 7 header shift
    if (IS_IOS_7_OR_GREATER)
    {
        self.createChannelButton.center = CGPointMake(self.createChannelButton.center.x, self.createChannelButton.center.y + kiOS7PlusHeaderYOffset);
        self.deleteChannelButton.center = CGPointMake(self.deleteChannelButton.center.x, self.deleteChannelButton.center.y + kiOS7PlusHeaderYOffset);
        self.saveChannelButton.center = CGPointMake(self.saveChannelButton.center.x, self.saveChannelButton.center.y + kiOS7PlusHeaderYOffset);
        self.cancelEditButton.center = CGPointMake(self.cancelEditButton.center.x, self.cancelEditButton.center.y + kiOS7PlusHeaderYOffset);
        self.logoImageView.center = CGPointMake(self.logoImageView.center.x, self.logoImageView.center.y + kiOS7PlusHeaderYOffset - 2.0f);
        self.activityIndicator.center = CGPointMake(self.activityIndicator.center.x, self.activityIndicator.center.y + kiOS7PlusHeaderYOffset);
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
    
    self.subscribeButton.enabled = YES;
    self.subscribeButton.selected = self.channel.subscribedByUserValue;
    
    // We set up assets depending on whether we are in display or edit mode
    [self setDisplayControlsVisibility: (self.mode == kChannelDetailsModeDisplay)];

    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    if (self.channel.videoInstances.count == 0 && ![self.channel.uniqueId isEqualToString: kNewChannelPlaceholderId])
    {
        [self showNoVideosMessage: NSLocalizedString(@"channel_screen_loading_videos", nil)
                       withLoader: YES];
    }
    
    [self displayChannelDetails];
    
    if (self.hasAppeared)
    {
        AssertOrLog(@"Detail View controller had viewWillAppear called twice!!!!");
    }
    
    if (self.mode == kChannelDetailsModeDisplay && !self.hasAppeared)
    {
        [self clearBackground];
        
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


- (IBAction) playChannelsButtonTouched: (id) sender
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"playAll"
                                                            label: nil
                                                            value: nil] build]];
    
    [self displayVideoViewerWithVideoInstanceArray: self.channel.videoInstances.array
                                  andSelectedIndex: 0
                                            center: self.view.center];
}


- (IBAction) touchedSubscribersLabel: (id) sender
{
    self.subscribersLabel.textColor = [UIColor colorWithRed: 38.0f / 255.0f
                                                      green: 41.0f / 255.0f
                                                       blue: 43.0f / 255.0f
                                                      alpha: 1.0f];
}


- (IBAction) releasedSubscribersLabel: (id) sender
{
    self.subscribersLabel.textColor = [UIColor whiteColor];
}


- (IBAction) followersLabelPressed: (id) sender
{
    [self releasedSubscribersLabel: sender];
    
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


- (void) videoQueueCleared
{
    [self.videoThumbnailCollectionView reloadData];
}


- (void) updateFailed: (NSNotification *) notification
{
    self.subscribeButton.selected = self.channel.subscribedByUserValue;
    self.subscribeButton.enabled = YES;
    
    if (self.subscribingIndicator)
    {
        [self.subscribingIndicator removeFromSuperview];
        self.subscribingIndicator = nil;
    }
    
    self.subscribersLabel.text = [NSString stringWithFormat:
                                  NSLocalizedString(@"channel_screen_error_subscribe", nil)];
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
            
            
            self.subscribeButton.selected = self.channel.subscribedByUserValue;
            self.subscribeButton.enabled = YES;
            
            if (self.subscribingIndicator)
            {
                [self.subscribingIndicator removeFromSuperview];
                self.subscribingIndicator = nil;
            }
            
            [self reloadCollectionViews];
            
            if (self.channel.videoInstances.count == 0)
            {
                [self showNoVideosMessage: NSLocalizedString(@"channel_screen_no_videos", nil)
                               withLoader: NO];
            }
            else
            {
                [self showNoVideosMessage: nil
                               withLoader: NO];
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
    
    self.subscribeButton.hidden = (visible && [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]);
    self.editButton.hidden = (visible && ![self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]);
    
    if (self.channel.favouritesValue && [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
    {
        self.editButton.hidden = TRUE;
    }
}


- (void) showNoVideosMessage: (NSString *) message withLoader: (BOOL) withLoader
{
    if (self.noVideosMessageView)
    {
        [self.noVideosMessageView removeFromSuperview];
        self.noVideosMessageView = nil;
    }
    
    if (!message)
    {
        return;
    }
    
    CGSize viewFrameSize = self.isIPhone ? CGSizeMake(300.0, 50.0) : CGSizeMake(360.0, 50.0);
    
    if (withLoader && !self.isIPhone)
    {
        viewFrameSize.width = 380.0;
    }
    
    self.noVideosMessageView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 640.0, viewFrameSize.width, viewFrameSize.height)];
    self.noVideosMessageView.center = self.isIPhone ? CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height - 70.0f) : CGPointMake(self.view.frame.size.width * 0.5, self.noVideosMessageView.center.y);
    self.noVideosMessageView.frame = CGRectIntegral(self.noVideosMessageView.frame);
    self.noVideosMessageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UIView *noVideosBGView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, viewFrameSize.width, viewFrameSize.height)];
    noVideosBGView.backgroundColor = [UIColor blackColor];
    noVideosBGView.alpha = 0.3;
    
    [self.noVideosMessageView addSubview: noVideosBGView];
    
    UILabel *noVideosLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    noVideosLabel.text = message;
    noVideosLabel.textAlignment = NSTextAlignmentCenter;
    noVideosLabel.font = [UIFont lightCustomFontOfSize: self.isIPhone ? 12.0f: 16.0f];
    noVideosLabel.textColor = [UIColor whiteColor];
    [noVideosLabel sizeToFit];
    noVideosLabel.backgroundColor = [UIColor clearColor];
    noVideosLabel.center = CGPointMake(viewFrameSize.width * 0.5, viewFrameSize.height * 0.5 + 4.0);
    noVideosLabel.frame = CGRectIntegral(noVideosLabel.frame);
    
    if (withLoader && !self.isIPhone)
    {
        UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        CGRect loaderRect = loader.frame;
        loaderRect.origin.x = noVideosLabel.frame.origin.x + noVideosLabel.frame.size.width + 8.0;
        loaderRect.origin.y = 16.0;
        loader.frame = loaderRect;
        [self.noVideosMessageView addSubview: loader];
        [loader startAnimating];
    }
    
    [self.noVideosMessageView addSubview: noVideosLabel];
    
    [self.view addSubview: self.noVideosMessageView];
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    [self displayChannelDetails];
    
    
    
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
    
    // If we have a valid ecommerce URL, then display the button
    if (self.channel.eCommerceURL != nil && ![self.channel.eCommerceURL isEqualToString: @""])
    {
        self.buyButton.hidden = FALSE;
    }
    
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


- (void) setChannelTitleTextView: (SSTextView *) channelTitleTextView
{
    if (_channelTitleTextView)
    {
        [_channelTitleTextView removeObserver: self
                                   forKeyPath: kTextViewContentSizeKey];
    }
    
    _channelTitleTextView = channelTitleTextView;
    
    [_channelTitleTextView addObserver: self
                            forKeyPath: kTextViewContentSizeKey
                               options: NSKeyValueObservingOptionNew
                               context: NULL];
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


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView;
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        self.footerView = [self.videoThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                       forIndexPath: indexPath];
        
        supplementaryView = self.footerView;
        
        if (self.channel.videoInstances.count > 0 && self.moreItemsToLoad)
        {
            self.footerView.showsLoading = self.isLoadingMoreContent;
        }
    }
    
    return supplementaryView;
}


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


#pragma mark - Helper methods

- (void) autoplayVideoIfAvailable
{
    __block NSArray *videoSubset = [[self.channel.videoInstances array] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@", self.autoplayVideoId]];

    
    if ([videoSubset count] == 1)
    {
        [self displayVideoViewerWithVideoInstanceArray: self.channel.videoInstances.array
                                      andSelectedIndex: [self.channel.videoInstances indexOfObject: videoSubset[0]]
                                                center: self.view.center];
        self.autoplayVideoId = nil;
    }
    else
    {
        __weak typeof(self) weakSelf = self;

        MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
            [weakSelf.channel addVideoInstanceFromDictionary: dictionary];
            
            NSError *error;
            [weakSelf.channel.managedObjectContext save: &error];
            
            videoSubset = [[self.channel.videoInstances array] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@", self.autoplayVideoId]];
            
            if ([videoSubset count] >= 1)
            {
                [self displayVideoViewerWithVideoInstanceArray: self.channel.videoInstances.array
                                              andSelectedIndex: [self.channel.videoInstances indexOfObject: videoSubset[0]]
                                                        center: self.view.center];
                self.autoplayVideoId = nil;
            }
        };
        
        // define success block //
        MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        };
        
        if ([self.channel.resourceURL hasPrefix: @"https"])                          // https does not cache so it is fresh
        {
            [appDelegate.oAuthNetworkEngine videoForChannelForUserId: appDelegate.currentUser.uniqueId
                                                           channelId: self.channel.uniqueId
                                                          instanceId: self.autoplayVideoId
                                                   completionHandler: successBlock
                                                        errorHandler: errorBlock];
        }
        else
        {
            [appDelegate.networkEngine videoForChannelForUserId: appDelegate.currentUser.uniqueId
                                                      channelId: self.channel.uniqueId
                                                     instanceId: self.autoplayVideoId
                                              completionHandler: successBlock
                                                   errorHandler: errorBlock];
        }
    }
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
    
    self.subscribeButton.hidden = (visible && [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]);
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
    
    if (self.channel.eCommerceURL && ![self.channel.eCommerceURL isEqualToString: @""] && self.mode == kChannelDetailsModeDisplay)
    {
        self.buyButton.hidden = NO;
    }
    else
    {
        self.buyButton.hidden = YES;
    }
    
    [(LXReorderableCollectionViewFlowLayout *) self.videoThumbnailCollectionView.collectionViewLayout longPressGestureRecognizer].enabled = (visible) ? FALSE : TRUE;
    
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





// If the buy button is visible, then (hopefully) we have a valid URL
// But check to see that it should open anyway
- (IBAction) buyButtonTapped: (id) sender
{
    [self initiatePurchaseAtURL: [NSURL URLWithString: self.channel.eCommerceURL]];
}


- (IBAction) subscribeButtonTapped: (id) sender
{
    // Update google analytics
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"channelSubscribeButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    self.subscribeButton.enabled = NO;
    self.subscribeButton.selected = FALSE;
    
    [self addSubscribeActivityIndicator];
    
    // Defensive programming
    if (self.channel != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                            object: self
                                                          userInfo: @{kChannel : self.channel}];
    }
}


- (IBAction) profileImagePressed: (UIButton *) sender
{
    if ([self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
    {
        [appDelegate.navigationManager navigateToPageByName:kProfileViewId];
        return;
    }
    
    [appDelegate.viewStackManager viewProfileDetails: self.channel.channelOwner];
}


- (void) videoAddButtonTapped: (UIButton *) addButton
{
    NSString *noteName;
    
    if (!addButton.selected || self.isIPhone) // There is only ever one video in the queue on iPhone. Always fire the add action.
    {
        noteName = kVideoQueueAdd;
    }
    else
    {
        noteName = kVideoQueueRemove;
    }
    
    UIView *v = addButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];

    [self addVideoAtIndexPath: indexPath
                withOperation: noteName];
    
    addButton.selected = !addButton.selected;
}


- (VideoInstance *) videoInstanceForIndexPath: (NSIndexPath *) indexPath
{
    return  self.channel.videoInstances [indexPath.row];
}


#pragma mark - Deleting Video Instances

- (void) videoDeleteButtonTapped: (UIButton *) deleteButton
{
    UIView *v = deleteButton.superview.superview;
    
    self.indexPathToDelete = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    VideoInstance *videoInstanceToDelete = (VideoInstance *) self.channel.videoInstances[self.indexPathToDelete.item];
    
    if (!videoInstanceToDelete)
    {
        return;
    }
    
    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"channel_creation_screen_channel_delete_dialog_title", nil)
                                message: NSLocalizedString(@"channel_creation_screen_video_delete_dialog_description", nil)
                               delegate: self
                      cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles: NSLocalizedString(@"Delete", nil), nil] show];
}


- (void) deleteVideoInstance
{
    VideoInstance *videoInstanceToDelete = (VideoInstance *) self.channel.videoInstances[self.indexPathToDelete.item];
    
    if (!videoInstanceToDelete)
    {
        return;
    }
    
    self.editedVideos = YES;
    
    UICollectionViewCell *cell = [self.videoThumbnailCollectionView cellForItemAtIndexPath: self.indexPathToDelete];
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         cell.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         
                         [self.channel.videoInstancesSet removeObject: videoInstanceToDelete];
                         
                         [videoInstanceToDelete.managedObjectContext deleteObject: videoInstanceToDelete];
                         
                         [self.videoThumbnailCollectionView reloadData];
                         
                         [appDelegate saveContext: YES];
                     }];
}


- (IBAction) addCoverButtonTapped: (UIButton *) button
{
    // Prevent multiple clicks of the add cover button on iPhone
    if (self.isIPhone)
    {
        if (self.isImageSelectorOpen == TRUE)
        {
            return;
        }
        
        self.imageSelectorOpen = TRUE;
    }
    
    [self.channelTitleTextView resignFirstResponder];
}


- (IBAction) selectCategoryButtonTapped: (UIButton *) button
{
    [self.channelTitleTextView resignFirstResponder];
}


- (IBAction) editButtonTapped: (id) sender
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Edit channel"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsHide
                                                        object: self
                                                      userInfo: nil];
    
    [self setEditControlsVisibility: YES];
    [self.createChannelButton removeFromSuperview];
    [self.view addSubview: self.saveChannelButton];
    CGRect newFrame = self.saveChannelButton.frame;
    newFrame.origin.x = self.view.frame.size.width - newFrame.size.width;
    self.saveChannelButton.frame = newFrame;
    self.saveChannelButton.hidden = NO;
    self.cancelEditButton.hidden = NO;
    self.deleteChannelButton.hidden = NO;
    self.backButton.hidden = YES;
    
    if (self.channel.categoryId)
    {
        //If a category is already selected on the channel, we should display it when entering edit mode
        
        NSEntityDescription *categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                          inManagedObjectContext: appDelegate.mainManagedObjectContext];
        
        NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
        [categoriesFetchRequest setEntity: categoryEntity];
        
        NSPredicate *excludePredicate = [NSPredicate predicateWithFormat: @"uniqueId== %@", self.channel.categoryId];
        [categoriesFetchRequest setPredicate: excludePredicate];
        
        NSError *error;
        
        NSArray *selectedCategoryResult = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                              error: &error];
        
        if ([selectedCategoryResult count] > 0)
        {
            Genre *genre = selectedCategoryResult[0];
            NSString *newTitle = nil;
            
            if ([genre isKindOfClass: [SubGenre class]])
            {
                SubGenre *subCategory = (SubGenre *) genre;
                
                if (self.isIPhone)
                {
                    newTitle = [NSString stringWithFormat: @"%@/\n%@", subCategory.genre.name, subCategory.name];
                }
                else
                {
                    newTitle = [NSString stringWithFormat: @"%@/%@", subCategory.genre.name, subCategory.name];
                }
            }
            else
            {
                newTitle = genre.name;
            }
            
            if (!self.isIPhone)
            {
                
            }
            else
            {
                [self.selectCategoryButton  setTitle: newTitle
                                            forState: UIControlStateNormal];
            }
        }
        
        self.selectedCategoryId = self.channel.categoryId;
    }
    
    if (!self.isIPhone)
    {
        self.coverChooserController.selectedImageURL = self.channel.channelCover.imageUrl;
        
        [self.coverChooserController.collectionView reloadData];
    }
}


- (IBAction) cancelEditTapped: (id) sender
{
    // Bit of a hack to fix #57314580
    NSDictionary *userInfo = nil;
    
    if (self.mode == kChannelDetailsModeCreate)
    {
        userInfo = @{@"showSearch" : @"yes"};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                        object: self
                                                      userInfo: userInfo];
    
    if (self.mode == kChannelDetailsModeCreate)
    {
        
        [self.channel.managedObjectContext deleteObject: self.channel];
        
        NSError *error;
        
        [self.channel.managedObjectContext save: &error];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self setEditControlsVisibility: NO];
        
        if (self.isIPhone)
        {
            self.selectedImageURL = nil;
        }
        
        self.selectedCategoryId = nil;
        self.selectedCoverId = nil;
        
        self.saveChannelButton.hidden = YES;
        self.cancelEditButton.hidden = YES;
        self.deleteChannelButton.hidden = YES;
        self.backButton.hidden = NO;
        
        self.channel = self.originalChannel;
        
        // display the BG as it was
        
        [self displayChannelDetails];
        
        
        [self.videoThumbnailCollectionView reloadData];
    }
}


- (IBAction) saveChannelTapped: (id) sender
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"channelSaveButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    self.saveChannelButton.enabled = NO;
    self.deleteChannelButton.enabled = YES;
    [self.activityIndicator startAnimating];
    
    
    self.channel.channelDescription = self.channel.channelDescription ? self.channel.channelDescription : @"";
    
    
    [appDelegate.oAuthNetworkEngine updateChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                 channelId: self.channel.uniqueId
                                                     title: self.channelTitleTextView.text
                                               description: (self.channel.channelDescription)
                                                  category: @""
                                                     cover: @""
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {
                                             
                                             NSString *channelId = resourceCreated[@"id"];
                                             
                                             [self setEditControlsVisibility: NO];
                                             self.saveChannelButton.enabled = YES;
                                             self.deleteChannelButton.enabled = YES;
                                             [self.activityIndicator stopAnimating];
                                             self.saveChannelButton.hidden = YES;
                                             self.deleteChannelButton.hidden = YES;
                                             self.cancelEditButton.hidden = YES;
                                             
                                             
                                             
                                             if(self.editedVideos)
                                                 [self setVideosForChannelById: channelId //  2nd step of the creation process
                                                                     isUpdated: YES];
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                                                                 object: self
                                                                                               userInfo: nil];
                                             
                                             // this block will also call the [self getChanelById:channelId isUpdated:YES] //
                                         }
                                              errorHandler: ^(id error) {
                                                  DebugLog(@"Error @ saveChannelPressed:");
                                                  
                                                  NSString *errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                  NSString *errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_save_description", nil);
                                                  
                                                  NSArray *errorTitleArray = error[@"form_errors"][@"title"];
                                                  
                                                  if ([errorTitleArray count] > 0)
                                                  {
                                                      NSString *errorType = errorTitleArray[0];
                                                      
                                                      if ([errorType isEqualToString: @"Duplicate title."])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_description", nil);
                                                      }
                                                      else if ([errorType isEqualToString: @"Mind your language!"])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_description", nil);
                                                      }
                                                      else
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_save_description", nil);
                                                      }
                                                  }
                                                  
                                                  [self	showError: errorMessage showErrorTitle: errorTitle];
                                                  
                                                  self.saveChannelButton.hidden = NO;
                                                  self.saveChannelButton.enabled = YES;
                                                  self.deleteChannelButton.hidden = NO;
                                                  self.deleteChannelButton.enabled = YES;
                                                  [self.activityIndicator stopAnimating];
                                                  [self.activityIndicator stopAnimating];
                                              }];
}

- (void) resetVideoCollectionViewPosition
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         // Fade out the category tab controller
                         
                         // slide up the video collection view a bit ot its original position
                         self.videoThumbnailCollectionView.contentOffset = CGPointMake(0, kChannelCreationCollectionViewOffsetY);
                         
                         self.videoThumbnailCollectionView.contentOffset = CGPointMake(0, -(kChannelCreationCollectionViewOffsetY));
                     }
                     completion: nil];
}




#pragma mark - Deleting Channels

- (IBAction) deleteChannelPressed: (UIButton *) sender
{
    NSString *message = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_description", nil), self.channel.title];
    NSString *title = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_title", nil), self.channel.title];
    
    self.deleteChannelAlertView = [[UIAlertView alloc] initWithTitle: title
                                                              message: message
                                                             delegate: self
                                                    cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                    otherButtonTitles: NSLocalizedString(@"Delete", nil), nil];
    [self.deleteChannelAlertView show];
}




- (void) alertView: (UIAlertView *) alertView
         willDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (alertView == self.deleteChannelAlertView)
    {
    if (buttonIndex == 1)
    {
        [self deleteChannel];
    }
    }
    else
    {
        if (buttonIndex == 0)
        {
            // cancel, do nothing
            DebugLog(@"Delete cancelled");
        }
        else
        {
            [self deleteVideoInstance];
        }
    }
}


- (void) deleteChannel
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                        object: self
                                                      userInfo: nil];
    
    // return to previous screen as if the back button tapped
    
    appDelegate.viewStackManager.returnBlock = ^{
        
        [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                     channelId: self.channel.uniqueId
                                             completionHandler: ^(id response) {
                                                 
                                                 [appDelegate.currentUser.channelsSet removeObject: self.channel];
                                                 [self.channel.managedObjectContext deleteObject: self.channel];
                                                 [self.originalChannel.managedObjectContext deleteObject:self.originalChannel];
                                                 
                                                 // bring back controls
                                                 
                                                 
                                                 [appDelegate saveContext: YES];
                                                 
                                                 
                                                 
                                             } errorHandler: ^(id error) {
                                                
                                                 DebugLog(@"Delete channel failed");
                                                 
                                             }];
    };
    
    [appDelegate.viewStackManager popController];
}


#pragma mark - Channel Creation (3 steps)

- (IBAction) createChannelPressed: (id) sender
{
    self.isLocked = YES; // prevent back button from firing
    
    self.createChannelButton.enabled = NO;
    [self.activityIndicator startAnimating];
    self.cancelEditButton.hidden = YES;
    
    
    self.channel.title = self.channelTitleTextView.text;
    
    self.channel.channelDescription = self.channel.channelDescription ? self.channel.channelDescription : @"";
    
    
    NSString *cover = self.selectedCoverId;
    
    if ([cover length] == 0 || [cover isEqualToString: kCoverSetNoCover])
    {
        cover = @"";
    }
    
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.channel.title
                                               description: self.channel.channelDescription
                                                  category: @""
                                                     cover: @""
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {
                                             
                                             // shows the message label from the MasterViewController
                                             id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                                             
                                             [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                                                    action: @"channelCreated"
                                                                                                     label: @""
                                                                                                     value: nil] build]];
                                             
                                             NSString *channelId = resourceCreated[@"id"];
                                             
                                             self.createChannelButton.enabled = YES;
                                             self.createChannelButton.hidden = YES;
                                             [self.activityIndicator stopAnimating];
                                             
                                             [self setVideosForChannelById: channelId
                                                                 isUpdated: NO];
                                             
                                         } errorHandler: ^(id error) {
                                             
                                                  self.isLocked = NO;
                                                  
                                                  DebugLog(@"Error @ createChannelPressed:");
                                                  
                                                  NSString *errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                  NSString *errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_create_description", nil);
                                                  
                                                  NSArray *errorTitleArray = error[@"form_errors"][@"title"];
                                                  
                                                  if ([errorTitleArray count] > 0)
                                                  {
                                                      NSString *errorType = errorTitleArray[0];
                                                      
                                                      if ([errorType isEqualToString: @"Duplicate title."])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_existing_dialog_description", nil);
                                                      }
                                                      else if ([errorType isEqualToString: @"Mind your language!"])
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_inappropriate_dialog_description", nil);
                                                      }
                                                      else
                                                      {
                                                          errorTitle = NSLocalizedString(@"channel_creation_screen_error_unknown_title", nil);
                                                          errorMessage = NSLocalizedString(@"channel_creation_screen_error_unknown_create_description", nil);
                                                      }
                                                  }
                                                  
                                                  self.createChannelButton.enabled = YES;
                                                  self.cancelEditButton.hidden = NO;
                                                  
                                                  [self	 showError: errorMessage
                                                    showErrorTitle: errorTitle];
                                              }];
}


// possible actions after waring for creating incomplete channel (such as not defining category)

- (void) setVideosForChannelById: (NSString *) channelId isUpdated: (BOOL) isUpdated
{
    self.isLocked = YES; // prevent back button from firing
    
    [appDelegate.oAuthNetworkEngine updateVideosForChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                          channelId: channelId
                                                   videoInstanceSet: self.channel.videoInstances
                                                      clearPrevious: YES
                                                  completionHandler: ^(id response) {
                                                      // a 204 returned
                                                      
                                                      [self fetchAndStoreUpdatedChannelForId: channelId
                                                                                    isUpdate: isUpdated];
                                                  } errorHandler: ^(id err) {
                                                      // this is also called when trying to save a video that has just been deleted
                                                      
                                                      self.isLocked = NO;
                                                      
                                                      NSString *errorMessage = nil;
                                                      
                                                      NSString *errorTitle = nil;
                                                      
                                                      if ([err isKindOfClass: [NSDictionary class]])
                                                      {
                                                          errorMessage = err[@"message"];
                                                          
                                                          if (!errorMessage)
                                                          {
                                                              errorMessage = err[@"error"];
                                                          }
                                                      }
                                                      
                                                      
                                                      [[NSNotificationCenter defaultCenter]  postNotificationName: kVideoQueueClear
                                                                                                           object: self];
                                                      
                                                      if (isUpdated)
                                                      {
                                                          [self.activityIndicator stopAnimating];
                                                          self.cancelEditButton.hidden = NO;
                                                          self.cancelEditButton.enabled = YES;
                                                          self.createChannelButton.enabled = YES;
                                                          self.createChannelButton.hidden = NO;
                                                          
                                                          if (!errorMessage)
                                                          {
                                                              errorMessage = NSLocalizedString(@"Could not update the channel videos. Please review and try again later.", nil);
                                                          }
                                                          
                                                          DebugLog(@"Error @ setVideosForChannelById:");
                                                          [self showError: errorMessage
                                                           showErrorTitle: errorTitle];
                                                      }
                                                      else                           // isCreated
                                                      {
                                                          [self.activityIndicator stopAnimating];
                                                          
                                                          if (!errorMessage)
                                                          {
                                                              errorMessage = NSLocalizedString(@"Could not add videos to channel. Please review and try again later.", nil);
                                                          }
                                                          
                                                          // if we have an error at this stage then it means that we started a channel with a single invalid video
                                                          // we want to still create that channel, but without that video while waring to the user.
                                                          if (self.channel.videoInstances[0])
                                                          {
                                                              [self.channel.videoInstancesSet removeObject: self.channel.videoInstances[0]];
                                                          }
                                                          
                                                          [self fetchAndStoreUpdatedChannelForId: channelId
                                                                                        isUpdate: isUpdated];
                                                          
                                                          
                                                          [self showError: errorMessage
                                                           showErrorTitle: errorTitle];
                                                      }
                                                  }];
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
                                              
                                              [self reloadUserImage: nil];
                                              
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
    __weak SYNCollectionDetailsViewController *wself = self;
    
    if (channelCreated) // channelCreated will always be true in this implementation, change from self.channels to show message only on creation and not on update
    {
        if (self.channel.title.length > 8 && [[self.channel.title substringToIndex: 8] isEqualToString: @"UNTITLED"])                  // no title
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_title", nil)];
            buttonString = NSLocalizedString(@"enter_title", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
                [wself editButtonTapped: wself.editButton];
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
                [wself editButtonTapped: wself.editButton];
                [wself selectCategoryButtonTapped: wself.selectCategoryButton];
            };
            numberOfConditions++;
        }
        
        if ([self.channel.channelCover.imageUrl isEqualToString: @""])
        {
            [conditionsArray addObject: NSLocalizedString(@"private_condition_cover", nil)];
            buttonString = NSLocalizedString(@"select_cover", nil);
            actionBlock = ^{
                [wself setMode: kChannelDetailsModeEdit];
                [wself editButtonTapped: wself.editButton];
                [wself addCoverButtonTapped: wself.addCoverButton];
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
                    [wself setMode: kChannelDetailsModeEdit];
                    [wself editButtonTapped: wself.editButton];
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







#pragma mark - UITextView delegate

// Try and force everything to uppercase
- (BOOL)		   textView: (UITextView *) textView
shouldChangeTextInRange: (NSRange) range
      replacementText: (NSString *) text
{
    // Stop editing when the return key is pressed
    if ([text isEqualToString: @"\n"])
    {
        [self resignTextView];
        return NO;
    }
    
    if (textView.text.length >= 25 && ![text isEqualToString: @""])
    {
        return NO;
    }
    
    NSRange lowercaseCharRange = [text rangeOfCharacterFromSet: [NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (lowercaseCharRange.location != NSNotFound)
    {
        textView.text = [textView.text
                         stringByReplacingCharactersInRange: range
                         withString: [text uppercaseString]];
        return NO;
    }
    
    return YES;
}


- (void) textViewDidBeginEditing: (UITextView *) textView
{
    if (IS_IPHONE)
    {
        self.createChannelButton.hidden = YES;
        self.saveChannelButton.hidden = YES;
        self.deleteChannelButton.hidden = YES;
        self.cancelTextInputButton.hidden = NO;
        
        
        CGRect bFrame = self.cancelTextInputButton.frame;
        bFrame.origin.y = IS_IOS_7_OR_GREATER ? 22.0f : 8.0f;
        self.cancelTextInputButton.frame = bFrame;
    }
}


#pragma mark - On Boarding Messages

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    self.videoThumbnailCollectionView.scrollsToTop = YES;
    
}


- (void) checkForOnBoarding
{
    
}


- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    
    self.videoThumbnailCollectionView.scrollsToTop = NO;
    
}


- (void) textViewDidEndEditing: (UITextView *) textView
{
    if (self.isIPhone)
    {
        self.createChannelButton.hidden = NO;
        self.saveChannelButton.hidden = NO;
        self.deleteChannelButton.hidden = NO;
        self.cancelTextInputButton.hidden = YES;
    }
}


// Big invisible buttong to cancel title entry
- (IBAction) cancelTitleEntry
{
    [self resignTextView];
}


- (void) resignTextView
{
    [self adjustTextView];
    
    [self.channelTitleTextView resignFirstResponder];
}


- (void) adjustTextView
{
    CGFloat topCorrect = ([self.channelTitleTextView bounds].size.height - [self.channelTitleTextView contentSize].height);
    
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
    
    [self.channelTitleTextView setContentOffset: (CGPoint) { .x = 0, .y = -topCorrect}
                                       animated: NO];
}




- (void) addSubscribeActivityIndicator
{
    self.subscribingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    self.subscribingIndicator.center = self.subscribeButton.center;
    [self.subscribingIndicator startAnimating];
    [self.view addSubview: self.subscribingIndicator];
}




#pragma mark - ScrollView Delegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    // TODO: Implement rest if needed
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
        
        if (self.mode == kChannelDetailsModeDisplay && self.hasAppeared)
        {
            [self clearBackground];
            
            [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                                object: self
                                                              userInfo: @{kChannel: self.channel}];
        }
    }
}


- (void) clearBackground
{
    self.channelCoverImageView.image = nil;
    
    self.blurredBGImageView.image = nil;
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



- (void) headerTapped
{
    [self.videoThumbnailCollectionView setContentOffset: self.originalContentOffset
                                               animated: YES];
}


#pragma mark - user avatar image update

- (void) reloadUserImage: (NSNotification *) note
{
    //If this channel is owned by the logged in user we are subscribing to this notification when the user data changes. we therefore re-load the avatar image
    
    UIImage *placeholder = self.avatarImageView.image ? self.avatarImageView.image : [UIImage imageNamed: @"PlaceholderChannelCreation.png"];
    
    NSArray *thumbnailURLItems = [appDelegate.currentUser.thumbnailURL componentsSeparatedByString: @"/"];
    
    if (thumbnailURLItems.count >= 6) // there is a url string with the proper format
    {
        // whatever is set to be the default size by the server (ex. 'thumbnail_small') //
        NSString *thumbnailSizeString = thumbnailURLItems[5];
        
        NSString *imageUrlString = [appDelegate.currentUser.thumbnailURL stringByReplacingOccurrencesOfString: thumbnailSizeString
                                                                                                   withString: @"thumbnail_large"];
        
        [self.avatarImageView setImageWithURL: [NSURL URLWithString: imageUrlString]
                             placeholderImage: placeholder
                                      options: SDWebImageRetryFailed];
    }
}


#pragma mark - FAVOURITES WORKAROUND. TO BE REMOVED

- (BOOL) isFavouritesChannel
{
    return [self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId] && self.channel.favouritesValue;
}


// since this is called when video overlay is being closed it is also used for the onboarding
- (void) refreshFavouritesChannel
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kChannelUpdateRequest
                                                        object: self
                                                      userInfo: @{kChannel: self.channel}];
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    self.subscribersPopover = nil;
}




@end
