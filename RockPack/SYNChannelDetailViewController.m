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
#import "SYNChannelCategoryTableViewController.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNCoverChooserController.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNGenreTabViewController.h"
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
#import "SYNVideoThumbnailRegularCell.h"
#import "SYNInstructionsToShareControllerViewController.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "User.h"
#import "Video.h"
#import "VideoInstance.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelDetailViewController () <UITextViewDelegate,
                                              SYNImagePickerControllerDelegate,
                                              UIPopoverControllerDelegate,
                                              SYNChannelCategoryTableViewDelegate,
                                              SYNChannelCoverImageSelectorDelegate,
                                              SYNVideoThumbnailRegularCellDelegate>


@property (nonatomic, assign)  CGPoint originalContentOffset;
@property (nonatomic, assign)  CGPoint originalMasterControlsViewOrigin;
@property (nonatomic, assign)  CGRect originalSubscribeButtonRect;
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
@property (nonatomic, strong) SYNGenreTabViewController *categoriesTabViewController;
@property (nonatomic, strong) SYNImagePickerController *imagePicker;
@property (nonatomic, strong) SYNModalSubscribersController *modalSubscriptionsContainer;
@property (nonatomic, strong) SYNReportConcernTableViewController *reportConcernController;
@property (nonatomic, strong) UIActivityIndicatorView *subscribingIndicator;
@property (nonatomic, strong) UIImage *originalBackgroundImage;
@property (nonatomic, strong) UIImageView *blurredBGImageView;
@property (nonatomic, strong) UIPopoverController *subscribersPopover;
@property (nonatomic, strong) UIView *coverChooserMasterView;
@property (nonatomic, strong) UIView *noVideosMessageView;
@property (nonatomic, strong) id<SDWebImageOperation> currentWebImageOperation;
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
@property (strong, nonatomic) SYNChannelCategoryTableViewController *categoryTableViewController;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelTextInputButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *textBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *subscribersButton;

@property (nonatomic) BOOL editedVideos;

@end


@implementation SYNChannelDetailViewController

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
    self.categoriesTabViewController.delegate = nil;
    self.imagePicker.delegate = nil;
    
    // This will remove the observer (in the setter)
    self.channelTitleTextView = nil;
}


#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.originalSubscribeButtonRect = self.playChannelButton.frame;
    self.originalSubscribersLabelRect = self.subscribersLabel.frame;
    
    // Take the best guess about how many  videos we have
    //    self.dataItemsAvailable = self.channel.videoInstances.count;
    
    
    self.isIPhone = IS_IPHONE;
    
    // Originally the opacity was required to be 0.25f, but this appears less visible on the actual screen
    // Set custom fonts and shadows for labels
    self.channelOwnerLabel.font = [UIFont boldRockpackFontOfSize: self.channelOwnerLabel.font.pointSize];
    [self addShadowToLayer: self.channelOwnerLabel.layer];
    
    self.subscribersLabel.font = [UIFont boldRockpackFontOfSize: self.subscribersLabel.font.pointSize];
    [self addShadowToLayer: self.subscribersLabel.layer];
    
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    [self addShadowToLayer: self.byLabel.layer];
    
    // Add Rockpack font and shadow to UITextView
    self.channelTitleTextView.font = [UIFont rockpackFontOfSize: self.channelTitleTextView.font.pointSize];
    [self addShadowToLayer: self.channelTitleTextView.layer];
    
    // Display 'Done' instead of 'Return' on Keyboard
    self.channelTitleTextView.returnKeyType = UIReturnKeyDone;
    
    // Needed for shadows to work
    self.channelTitleTextView.backgroundColor = [UIColor clearColor];
    
    self.channelTitleTextView.placeholder = NSLocalizedString(@"channel_creation_screen_field_channeltitle_placeholder", nil);
    
    self.channelTitleTextView.placeholderTextColor = [UIColor colorWithRed: 0.909
                                                                     green: 0.909
                                                                      blue: 0.909
                                                                     alpha: 1.0f];
    // Set delegate so that we can respond to events
    self.channelTitleTextView.delegate = self;
    
    // Shadow for avatar background
    [self addShadowToLayer: self.avatarBackgroundView.layer];
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = self.isIPhone ? CGSizeMake(310.0f, 175.0f) : CGSizeMake(249.0f, 141.0f);
    layout.minimumInteritemSpacing = self.isIPhone ? 0.0f : 4.0f;
    layout.minimumLineSpacing = self.isIPhone ? 4.0f : 4.0f;
    
    layout.footerReferenceSize = [self footerSize];
    
    
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    if (self.isIPhone)
    {
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake([SYNDeviceManager.sharedInstance currentScreenHeight] - 190.0f, 0.0f, 0.0f, 0.0f);
    }
    else
    {
        layout.sectionInset = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(500.0f, 0.0f, 0.0f, 0.0f);
    }
    
    // == Video Cells == //
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
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
    
    if (!self.isIPhone)
    {
        // Create categories tab, but make invisible (alpha = 0) for now
        self.categoriesTabViewController = [[SYNGenreTabViewController alloc] initWithHomeButton: @"other"];
        self.categoriesTabViewController.delegate = self;
        CGRect tabFrame = self.categoriesTabViewController.view.frame;
        tabFrame.origin.y = kChannelCreationCategoryTabOffsetY;
        tabFrame.size.width = self.view.frame.size.width;
        self.categoriesTabViewController.view.frame = tabFrame;
        
        self.categoriesTabViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.categoriesTabViewController.view.alpha = 0.0f;
        [self addChildViewController: self.categoriesTabViewController];
    }
    
    self.originalMasterControlsViewOrigin = self.masterControlsView.frame.origin;
    
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
                                                                                         NSFontAttributeName: [UIFont boldRockpackFontOfSize: 18.0f]}];
        
        [self.addCoverButton setAttributedTitle: attributedCoverString
                                       forState: UIControlStateNormal];
        
        // Now do fancy attributed string
        NSString *categoryString = NSLocalizedString(@"channel_creation_screen_button_selectcat_label", nil);
        
        
        NSMutableAttributedString *attributedCategoryString = [[NSMutableAttributedString alloc] initWithString: categoryString
                                                                                                     attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed: 40.0f / 255.0f
                                                                                                                                                                   green: 45.0f / 255.0f
                                                                                                                                                                    blue: 51.0f / 255.0f
                                                                                                                                                                   alpha: 1.0f],
                                                                                            NSFontAttributeName: [UIFont boldRockpackFontOfSize: 18.0f]}];
        
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
        
        self.addCoverButton.titleLabel.font = [UIFont boldRockpackFontOfSize: self.addCoverButton.titleLabel.font.pointSize];
        self.addCoverButton.titleLabel.numberOfLines = 2;
        self.addCoverButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.addCoverButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.selectCategoryButton.titleLabel.font = [UIFont boldRockpackFontOfSize: self.selectCategoryButton.titleLabel.font.pointSize];
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
    
//    if (self.autoplayVideoId)
//    {
//        [self autoplayVideoIfAvailable];
//    }
    
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


- (IBAction) subscribersLabelPressed: (id) sender
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


- (void) updateCategoryButtonText: (NSString *) buttonText
{
    NSMutableAttributedString *attributedCategoryString = [[NSMutableAttributedString alloc] initWithString: buttonText
                                                                                                 attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed: 40.0f / 255.0f
                                                                                                                                                               green: 45.0f / 255.0f
                                                                                                                                                                blue: 51.0f / 255.0f
                                                                                                                                                               alpha: 1.0f],
                                                                                        NSFontAttributeName: [UIFont boldRockpackFontOfSize: 18.0f]}];
    
    // Set text on add cover and select category buttons
    [self.selectCategoryButton setAttributedTitle: attributedCategoryString
                                         forState: UIControlStateNormal];
}


- (void) coverImageChangedHandler: (NSNotification *) notification
{
    NSDictionary *detailDictionary = [notification userInfo];
    NSString *coverArtUrl = (NSString *) detailDictionary[kCoverArt];
    UIImage *coverArtImage = (UIImage *) detailDictionary[kCoverArtImage];
    
    if (!coverArtUrl)
    {
        return;
    }
    
    __weak SYNChannelDetailViewController *wself = self;
    
    if ([coverArtUrl isEqualToString: @""])
    {
        [self clearBackground];
    }
    else if ([coverArtUrl isEqualToString: @"uploading"])
    {
        wself.originalBackgroundImage = coverArtImage;
        UIImage *newImage = [wself croppedImageForCurrentOrientation];
        
        [UIView transitionWithView: self.view
                          duration: 0.35f
                           options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations: ^{
                            wself.channelCoverImageView.image = newImage;
                        }
                        completion: nil];
    }
    else
    {
        NSString *largeImageUrlString = [coverArtUrl stringByReplacingOccurrencesOfString: @"thumbnail_medium"
                                                                               withString: @"background"];
        
        [self.channelCoverImageView setImageWithURL: [NSURL URLWithString: largeImageUrlString]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                            options: SDWebImageRetryFailed
                                          completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                              wself.originalBackgroundImage = wself.channelCoverImageView.image;
                                              
                                              wself.channelCoverImageView.image = [wself croppedImageForCurrentOrientation];
                                          }];
    }
    
    self.selectedCoverId = detailDictionary[kCoverImageReference];
}


#pragma mark - Orientation Methods

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    
    [self.videoThumbnailCollectionView.collectionViewLayout invalidateLayout];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    self.channelCoverImageView.image = [self croppedImageForOrientation: toInterfaceOrientation];
}


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
    
    // Check to see if we have a background URL and we are not already loading one
    if ((self.channel.channelCover.imageBackgroundUrl != nil) && (self.currentWebImageOperation == nil))
    {
        self.currentWebImageOperation = [self loadBackgroundImage];
    }
    
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
    noVideosLabel.font = [UIFont rockpackFontOfSize: self.isIPhone ? 12.0f: 16.0f];
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
    
    if (self.autoplayVideoId)
    {
        [self autoplayVideoIfAvailable];
    }
    
    CGRect orgButtonRect = self.originalSubscribeButtonRect;
    CGRect orgLabelRect = self.originalSubscribersLabelRect;
    
    float offset = IS_IPAD ? 54.0f : 48.0;
    
    // Whether to show play channel button
    if (self.channel.videoInstances.count > 0)
    {
        
        
        [UIView animateWithDuration:kChannelEditModeAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             
                             self.playChannelButton.alpha = 1.0f;
                             
                             CGRect buttonFrame = self.subscribeButton.frame;
                             buttonFrame.origin.x = orgButtonRect.origin.x + offset;
                             self.subscribeButton.frame = buttonFrame;
                             self.editButton.frame = buttonFrame;
                             
                             
                             CGRect labelFrame = self.subscribersLabel.frame;
                             labelFrame.origin.x = orgLabelRect.origin.x + offset;
                             self.subscribersLabel.frame = labelFrame;
                             self.subscribersButton.frame = labelFrame;
            
                         } completion:nil];
        
        
        
        
    }
    else
    {
        
        [UIView animateWithDuration:kChannelEditModeAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             
                             self.playChannelButton.alpha = 0.0f;
                             CGRect buttonFrame = self.subscribeButton.frame;
                             buttonFrame.origin.x = orgButtonRect.origin.x;
                             self.subscribeButton.frame = buttonFrame;
                             self.editButton.frame = buttonFrame;
                             CGRect labelFrame = self.subscribersLabel.frame;
                             labelFrame.origin.x = orgLabelRect.origin.x;
                             self.subscribersLabel.frame = labelFrame;
                             self.subscribersButton.frame = labelFrame;
                             
                         } completion:nil];
        
        
    }
    
    
}


#pragma mark - VIEW helper methods

- (void) addShadowToLayer: (CALayer *) layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.3f;
    layer.shadowRadius = 2.0f;
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
    UICollectionViewCell *cell = nil;
    
    SYNVideoThumbnailRegularCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"
                                                                                                 forIndexPath: indexPath];
    
    // special mode for the favorite channel so we cannot delete the videos (un-heart them only)
    
    if (self.channel.favouritesValue)
    {
        videoThumbnailCell.displayMode = kChannelThumbnailDisplayModeDisplayFavourite;
    }
    else
    {
        videoThumbnailCell.displayMode = self.mode;
    }
    
    VideoInstance *videoInstance = self.channel.videoInstances [indexPath.item];
    
    
    [videoThumbnailCell.imageView
     setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
     placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]
     options: SDWebImageRetryFailed];
    
    videoThumbnailCell.titleLabel.text = videoInstance.title;
    videoThumbnailCell.viewControllerDelegate = self;
    
    videoThumbnailCell.addItButton.highlighted = NO;
    videoThumbnailCell.addItButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel: videoInstance];
    
    cell = videoThumbnailCell;
    
    return cell;
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

- (void) resetDataRequestRange
{
    
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
    
    if ([self.channel.resourceURL hasPrefix: @"https"])                          // https does not cache so it is fresh
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


- (void)	  collectionView: (UICollectionView *) collectionView
          didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // the method is being replaced by the 'videoButtonPressed' because other elements on the cell migth be interactive as well
}


- (void) videoButtonPressed: (UIButton *) videoButton
{
    UIView *candidateCell = videoButton;
    
    while (![candidateCell isKindOfClass: [SYNVideoThumbnailRegularCell class]])
    {
        candidateCell = candidateCell.superview;
    }
    
    SYNVideoThumbnailRegularCell *selectedCell = (SYNVideoThumbnailRegularCell *) candidateCell;
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
    self.categoriesTabViewController.view.hidden = visible;
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
    if ([keyPath isEqualToString: kTextViewContentSizeKey])
    {
        UITextView *tv = object;
        //Bottom vertical alignment
        CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
        //            topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
        
        
        [tv setContentOffset: (CGPoint) { .x = 0, .y = -topCorrect}
                    animated: NO];
    }
}


#pragma mark - Control Delegate

- (IBAction) shareChannelButtonTapped: (UIButton *) shareButton
{
    // Get share link pre-emptively
    [self requestShareLinkWithObjectType: @"channel"
                                objectId: self.channel.uniqueId];
    
    [self shareChannel: self.channel
               isOwner: ([self.channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]) ? @(TRUE): @(FALSE)
            usingImage: nil];
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
        NSNotification *navigationNotification = [NSNotification notificationWithName: kNavigateToPage
                                                                               object: self
                                                                             userInfo: @{@"pageName": kProfileViewId}];
        
        [[NSNotificationCenter defaultCenter] postNotification: navigationNotification];
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
    [self showCoverChooser];
    [self hideCategoryChooser];
}


- (IBAction) selectCategoryButtonTapped: (UIButton *) button
{
    [self.channelTitleTextView resignFirstResponder];
    [self showCategoryChooser];
    [self hideCoverChooser];
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
                [self updateCategoryButtonText: newTitle];
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
        
        if (self.isIPhone)
        {
            [self backButtonTapped: nil];
        }
        else
        {
            [appDelegate.viewStackManager popController];
        }
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
        
        self.categoryTableViewController = nil;
        self.saveChannelButton.hidden = YES;
        self.cancelEditButton.hidden = YES;
        self.deleteChannelButton.hidden = YES;
        self.backButton.hidden = NO;
        
        self.channel = self.originalChannel;
        
        // display the BG as it was
        
        [self displayChannelDetails];
        
        self.currentWebImageOperation = [self loadBackgroundImage];
        
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
    
    [self hideCategoryChooser];
    
    self.channel.channelDescription = self.channel.channelDescription ? self.channel.channelDescription : @"";
    
    NSString *category = [self categoryIdStringForServiceCall];
    
    NSString *cover = [self coverIdStringForServiceCall];
    
    [appDelegate.oAuthNetworkEngine updateChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                 channelId: self.channel.uniqueId
                                                     title: self.channelTitleTextView.text
                                               description: (self.channel.channelDescription)
                                                  category: category
                                                     cover: cover
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {
                                             
                                             id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

                                             [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                                                    action: @"channelEdited"
                                                                                                     label: category
                                                                                                     value: nil] build]];
                                             
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


#pragma mark - Cover choice

- (void) showCoverChooser
{
    if (!self.isIPhone)
    {
        // Check to see if we are already display the cover chooser
        if (self.coverChooserMasterView.alpha == 0.0f)
        {
            [self.coverChooserController updateCoverArt];
            
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 // Fade up the category tab controller
                                 self.coverChooserMasterView.alpha = 1.0f;
                                 
                                 // slide down the video collection view a bit
                                 self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(kChannelCreationCollectionViewOffsetY +
                                                                                                   kChannelCreationCategoryAdditionalOffsetY, 0, 0, 0);
                                 
                                 self.videoThumbnailCollectionView.contentOffset = CGPointMake(0, -(kChannelCreationCollectionViewOffsetY +
                                                                                                    kChannelCreationCategoryAdditionalOffsetY));
                             }
                             completion: nil];
        }
    }
    else
    {
        self.coverImageSelector = [[SYNChannelCoverImageSelectorViewController alloc] initWithSelectedImageURL: (self.selectedImageURL) ? self.
                                                                                              selectedImageURL: self.channel.channelCover.imageUrl];
        self.coverImageSelector.imageSelectorDelegate = self;
        CGRect startFrame = self.coverImageSelector.view.frame;
        startFrame.origin.y = self.view.frame.size.height;
        self.coverImageSelector.view.frame = startFrame;
        [self.view addSubview: self.coverImageSelector.view];
        
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.coverImageSelector.view.frame;
                             endFrame.origin.y = 0.0f;
                             self.coverImageSelector.view.frame = endFrame;
                         }
                         completion: nil];
    }
}


- (void) hideCoverChooser
{
    if (self.coverChooserMasterView.alpha == 1.0f)
    {
        [UIView animateWithDuration: kChannelEditModeAnimationDuration
                         animations: ^{
                             // Fade out the category tab controller
                             self.coverChooserMasterView.alpha = 0.0f;
                         }
                         completion: nil];
    }
}


#pragma mark - Genre Choose Bar

- (void) showCategoryChooser
{
    if (!self.isIPhone)
    {
        [self.view addSubview: self.categoriesTabViewController.view];
        
        if (self.categoriesTabViewController.view.alpha == 0.0f)
        {
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 // Fade up the category tab controller //
                                 self.categoriesTabViewController.view.alpha = 1.0f;
                             }
                             completion: ^(BOOL finished) {
                                 if ([self.selectedCategoryId isEqualToString: @""])
                                 {
                                     // if no category has been selected the "other" category if it exists
                                     if (self.categoriesTabViewController.otherGenre)
                                     {
                                         [self handleNewTabSelectionWithGenre: self.categoriesTabViewController.otherGenre];
                                     }
                                 }
                                 else
                                 {
                                     NSIndexPath *genreIndexPath = [self.categoriesTabViewController findIndexPathForGenreId: self.selectedCategoryId];
                                     
                                     if (!genreIndexPath)
                                     {
                                         //"Other/other" selected. Do nothing
                                         return;
                                     }
                                     
                                     Genre *genreSelected =
                                     [self.categoriesTabViewController selectAndReturnGenreForIndexPath: genreIndexPath
                                                                                       andSubcategories: YES];
                                     
                                     if (genreSelected)
                                     {
                                         if ([genreSelected isMemberOfClass: [Genre class]])
                                         {
                                             [self updateCategoryButtonText: genreSelected.name];
                                         }
                                         else
                                         {
                                             [self updateCategoryButtonText: [NSString stringWithFormat: @"%@/%@",
                                                                              ((SubGenre *) genreSelected).genre.name, genreSelected.name]];
                                         }
                                     }
                                     else
                                     {
                                         [self.categoriesTabViewController deselectAll];
                                     }
                                 }
                                 
                                 [UIView  animateWithDuration: 0.4f
                                                        delay: 0.1f
                                                      options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                                                   animations: ^{
                                                       // slide down the video collection view a bit //
                                                       CGFloat totalY =
                                                       kChannelCreationCollectionViewOffsetY + kChannelCreationCategoryAdditionalOffsetY;
                                                       self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(totalY, 0, 0, 0);
                                                       
                                                       CGFloat totalX =
                                                       kChannelCreationCollectionViewOffsetY + kChannelCreationCategoryAdditionalOffsetY;
                                                       self.videoThumbnailCollectionView.contentOffset = CGPointMake(0, -(totalX));
                                                   }
                                                   completion: ^(BOOL finished) {
                                                   }];
                             }];
        }
    }
    else // isIPhone
    {
        if (!self.categoryTableViewController)
        {
            self.categoryTableViewController = [[SYNChannelCategoryTableViewController alloc] initWithNibName: @"SYNChannelCategoryTableViewControllerFullscreen~iphone"
                                                                                                       bundle: [NSBundle mainBundle]];
            self.categoryTableViewController.categoryTableControllerDelegate = self;
            self.categoryTableViewController.showAllCategoriesHeader = NO;
            
            [self.view addSubview: self.categoryTableViewController.view];
            
            BOOL hasACategory = [self.selectedCategoryId length] > 0;
            
            [self.categoryTableViewController setSelectedCategoryForId: hasACategory ? self.
                                                    selectedCategoryId: nil];
            
            if (!hasACategory)
            {
                // Set the default other/other subgenre
                NSArray *filteredSubcategories = [[self.categoryTableViewController.otherGenre.subgenres array] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"isDefault == YES"]];
                
                if ([filteredSubcategories count] == 1)
                {
                    SubGenre *otherSubGenre = filteredSubcategories[0];
                    
                    self.selectedCategoryId = otherSubGenre.uniqueId;
                    
                    [self.selectCategoryButton setTitle: [NSString stringWithFormat: @"%@/\n%@", otherSubGenre.genre.name, otherSubGenre.name]
                                               forState: UIControlStateNormal];
                }
            }
        }
        else
        {
            // Check to see if the panel is already displayed (prevent multiple taps on choose category button)
            if (self.categoryTableViewController.view.frame.origin.y == 0.0f)
            {
                return;
            }
        }
        
        CGRect startFrame = self.categoryTableViewController.view.frame;
        startFrame.origin.y = self.view.frame.size.height;
        startFrame.size.height = self.view.frame.size.height;
        self.categoryTableViewController.view.frame = startFrame;
        
        [self.view addSubview: self.categoryTableViewController.view];
        
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.y = 0.0f;
                             self.categoryTableViewController.view.frame = endFrame;
                         }
                         completion: nil];
    }
}


- (void) hideCategoryChooser
{
    if (self.categoriesTabViewController.view.alpha == 1.0f)
    {
        [UIView animateWithDuration: kChannelEditModeAnimationDuration
                         animations: ^{
                             // Fade out the category tab controller
                             self.categoriesTabViewController.view.alpha = 0.0f;
                         }
                         completion: ^(BOOL finished) {
                             [self.categoriesTabViewController.view removeFromSuperview];
                         }];
    }
}


- (void) resetVideoCollectionViewPosition
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         // Fade out the category tab controller
                         self.categoriesTabViewController.view.alpha = 0.0f;
                         
                         // slide up the video collection view a bit ot its original position
                         self.videoThumbnailCollectionView.contentOffset = CGPointMake(0, kChannelCreationCollectionViewOffsetY);
                         
                         self.videoThumbnailCollectionView.contentOffset = CGPointMake(0, -(kChannelCreationCollectionViewOffsetY));
                     }
                     completion: nil];
}




#pragma mark - iPad Category Tab Delegate

- (BOOL) showSubGenres
{
    return YES;
}


- (void) handleNewTabSelectionWithGenre: (Genre *) genre
{
    // the tab selector should alwaysreturn a genre. If no genre is sent, the "Othre" category is missing and we will have to make do with an empty string.
    if (!genre)
    {
        self.selectedCategoryId = @"";
        [self updateCategoryButtonText: @"OTHER"];
        return;
    }
    
    // update the text field with the format "GENRE/SUBGENRE"
    if ([genre isMemberOfClass: [SubGenre class]])
    {
        [self hideCategoryChooser];
        NSString *buttonText = [NSString stringWithFormat: @"%@/%@", ((SubGenre *) genre).genre.name, genre.name];
        [self updateCategoryButtonText: buttonText];
        self.selectedCategoryId = genre.uniqueId;
        
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                               action: @"channelCategorised"
                                                                label: buttonText
                                                                value: nil] build]];
    }
    else
    {
        NSArray *filteredSubcategories = [[genre.subgenres array] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"isDefault == YES"]];
        
        if ([filteredSubcategories count] == 1)
        {
            SubGenre *otherSubGenre = filteredSubcategories[0];
            
            self.selectedCategoryId = otherSubGenre.uniqueId;
            
            [self updateCategoryButtonText: [NSString stringWithFormat: @"%@/%@", otherSubGenre.genre.name, otherSubGenre.name]];
        }
        else
        {
            self.selectedCategoryId = genre.uniqueId;
            [self updateCategoryButtonText: genre.name];
        }
    }
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
    
    [self hideCategoryChooser];
    
    self.channel.title = self.channelTitleTextView.text;
    
    self.channel.channelDescription = self.channel.channelDescription ? self.channel.channelDescription : @"";
    
    NSString *category = [self categoryIdStringForServiceCall];
    
    NSString *cover = self.selectedCoverId;
    
    if ([cover length] == 0 || [cover isEqualToString: kCoverSetNoCover])
    {
        cover = @"";
    }
    
    [appDelegate.oAuthNetworkEngine createChannelForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     title: self.channel.title
                                               description: self.channel.channelDescription
                                                  category: category
                                                     cover: cover
                                                  isPublic: YES
                                         completionHandler: ^(NSDictionary *resourceCreated) {
                                             
                                             // shows the message label from the MasterViewController
                                             id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                                             
                                             [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                                                    action: @"channelCreated"
                                                                                                     label: category
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
    __weak SYNChannelDetailViewController *wself = self;
    
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
            
            if ([lastController isKindOfClass: [SYNExistingChannelsViewController class]])
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


#pragma mark - channel and cover id preparation

- (NSString *) categoryIdStringForServiceCall
{
    NSString *category = self.selectedCategoryId;
    
    if ([category length] == 0)
    {
        category = self.channel.categoryId;
        
        if ([category length] == 0)
        {
            category = @"";
        }
    }
    
    return category;
}


- (NSString *) coverIdStringForServiceCall
{
    NSString *cover = self.selectedCoverId;
    
    if ([cover length] == 0)
    {
        cover = @"KEEP";
    }
    else if ([cover isEqualToString: kCoverSetNoCover])
    {
        cover = @"";
    }
    
    return cover;
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
    
    // == Cover Image == //
    if (self.mode == kChannelDetailsModeDisplay) // only load bg on display, creation will insert new bg
    {
        self.currentWebImageOperation = [self loadBackgroundImage];
    }
}


- (void) checkForOnBoarding
{
    
    if(![appDelegate.viewStackManager controllerViewIsVisible:self])
        return;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger onBoarding1State = [defaults integerForKey:kInstruction1OnBoardingState];
    
    if(!onBoarding1State || onBoarding1State == 1) // has shown on channel details and can show here IF videos are present
    {
        SYNInstructionsToShareControllerViewController* itsVC = [[SYNInstructionsToShareControllerViewController alloc] initWithDelegate:self andState:InstructionsShareStatePressAndHold];
        
        [appDelegate.viewStackManager presentCoverViewController:itsVC];
        
        [defaults setInteger:2 forKey:kInstruction1OnBoardingState]; // inc by one
        
    }
}


- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    
    self.videoThumbnailCollectionView.scrollsToTop = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kMainControlsChangeLeave
                                                        object: self];
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


#pragma mark - Report a concern

- (IBAction) userTouchedReportConcernButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if (!self.reportConcernController)
        {
            self.reportConcernController = [[SYNReportConcernTableViewController alloc] init];
            
            [self.reportConcernController reportConcernFromView: button
                                               inViewController: self
                                          popOverArrowDirection: UIPopoverArrowDirectionLeft
                                                     objectType: @"channel"
                                                       objectId: self.channel.uniqueId
                                                 completedBlock: ^{
                                                     button.selected = NO;
                                                     self.reportConcernController = nil;
                                                 }];
        }
    }
}


#pragma mark - Cover selection and upload support

- (void) userTouchedCameraButton: (UIButton *) button
{
    //Show imagePicker
    self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController: self];
    self.imagePicker.delegate = self;
    
    [self.imagePicker presentImagePickerAsPopupFromView: button
                                         arrowDirection: UIPopoverArrowDirectionLeft];
}


#pragma mark - SYNImagePickerDelegate

- (void)	   picker: (SYNImagePickerController *) picker
 finishedWithImage: (UIImage *) image
{
    //Imagepicker has picked an image
    self.channelCoverImageView.image = image;
    [self uploadChannelImage: image];
    self.imagePicker = nil;
}


#pragma mark - Upload channel cover image

- (void) uploadChannelImage: (UIImage *) imageToUpload
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"channelCoverUploaded"
                                                            label: nil
                                                            value: nil] build]];
    
    self.createChannelButton.enabled = FALSE;
    self.saveChannelButton.enabled = FALSE;
    [self.activityIndicator startAnimating];
    
    [self.coverChooserController createCoverPlaceholder: imageToUpload];
    
    // Upload the image for this user
    [appDelegate.oAuthNetworkEngine uploadCoverArtForUserId: appDelegate.currentOAuth2Credentials.userId
                                                      image: imageToUpload
                                          completionHandler: ^(NSDictionary *dictionary) {
                                              self.createChannelButton.enabled = TRUE;
                                              self.saveChannelButton.enabled = TRUE;
                                              [self.activityIndicator stopAnimating];
                                              
                                              NSString *imageUrl = dictionary [@"thumbnail_url"];
                                              
                                              if (imageUrl && [imageUrl isKindOfClass: [NSString class]])
                                              {
                                                  if (!self.selectedImageURL)
                                                  {
                                                      self.selectedImageURL = imageUrl;
                                                  }
                                                  
                                                  // [self.coverChooserController updateUserArtWithURL: imageUrl];
                                                  // DebugLog(@"Success");
                                              }
                                              else
                                              {
                                                  DebugLog(@"Failed to upload wallpaper URL");
                                              }
                                              
                                              self.selectedCoverId = dictionary[@"cover_ref"];
                                          } errorHandler: ^(NSError *error) {
                                                   self.createChannelButton.enabled = TRUE;
                                                   self.saveChannelButton.enabled = TRUE;
                                                   [self.activityIndicator stopAnimating];
                                                   DebugLog(@"%@", [error debugDescription]);
                                               }];
    
    NSDictionary *userInfo = @{kCoverArt: @"uploading", kCoverArtImage: imageToUpload};
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kCoverArtChanged
                                                        object: self
                                                      userInfo: userInfo];
}


#pragma mark - iPhone viewcontroller dismissal
- (IBAction) backButtonTapped: (id) sender
{
    CATransition *animation = [CATransition animation];
    
    [animation setType: kCATransitionReveal];
    [animation setSubtype: kCATransitionFromLeft];
    
    [animation setDuration: 0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.view.window.layer addAnimation: animation
                                  forKey: nil];
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}


- (void) addSubscribeActivityIndicator
{
    self.subscribingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    self.subscribingIndicator.center = self.subscribeButton.center;
    [self.subscribingIndicator startAnimating];
    [self.view addSubview: self.subscribingIndicator];
}


#pragma mark - iPhone Category Table delegate

- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
               didSelectCategory: (Genre *) category
{
    if (category)
    {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                               action: @"channelCategorised"
                                                                label: category.name
                                                                value: nil] build]];
        
        NSArray *filteredSubcategories = [[category.subgenres array] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"isDefault == YES"]];
        
        if ([filteredSubcategories count] == 1)
        {
            SubGenre *otherSubGenre = filteredSubcategories[0];
            
            self.selectedCategoryId = otherSubGenre.uniqueId;
            
            [self.selectCategoryButton setTitle: [NSString stringWithFormat: @"%@/\n%@", otherSubGenre.genre.name, otherSubGenre.name]
                                       forState: UIControlStateNormal];
        }
        else
        {
            self.selectedCategoryId = category.uniqueId;
            
            [self.selectCategoryButton setTitle: category.name
                                       forState: UIControlStateNormal];
        }
        
        [self hideCategoriesTable];
    }
}


- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
            didSelectSubCategory: (SubGenre *) subCategory
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"channelCategorised"
                                                            label: subCategory.name
                                                            value: nil] build]];
    
    self.selectedCategoryId = subCategory.uniqueId;
    
    [self.selectCategoryButton setTitle: [NSString stringWithFormat: @"%@/\n%@", subCategory.genre.name, subCategory.name]
                               forState: UIControlStateNormal];
    
    [self hideCategoriesTable];
}


- (void) categoryTableControllerDeselectedAll: (SYNChannelCategoryTableViewController *) tableController
{
    [self hideCategoriesTable];
}


- (void) hideCategoriesTable
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         CGRect endFrame = self.categoryTableViewController.view.frame;
                         endFrame.origin.y = self.view.frame.size.height;
                         self.categoryTableViewController.view.frame = endFrame;
                     }
                     completion: ^(BOOL finished) {
                         [self.categoryTableViewController.view removeFromSuperview];
                     }];
}


#pragma mark - iPhone Cover Chooser delegate

- (void) closeImageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         CGRect endFrame = self.coverImageSelector.view.frame;
                         endFrame.origin.y = self.view.frame.size.height;
                         self.coverImageSelector.view.frame = endFrame;
                     }
                     completion: ^(BOOL finished) {
                         [self.coverImageSelector.view removeFromSuperview];
                         self.coverImageSelector = nil;
                     }];
    
    self.imageSelectorOpen = FALSE;
}


- (void) imageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
      didSelectUIImage: (UIImage *) image
{
    [self uploadChannelImage: image];
    [self closeImageSelector: imageSelector];
    self.selectedImageURL = nil;
}


- (void) imageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
        didSelectImage: (NSString *) imageUrlString
          withRemoteId: (NSString *) remoteId
{
    self.selectedCoverId = remoteId;
    
    self.selectedImageURL = imageUrlString;
    
    NSString *largeImageUrlString = [imageUrlString stringByReplacingOccurrencesOfString: @"thumbnail_medium"
                                                                              withString: @"background"];
    
    __weak SYNChannelDetailViewController *wself = self;
    
    [self.channelCoverImageView setImageWithURL: [NSURL URLWithString: largeImageUrlString]
                               placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                        options: SDWebImageRetryFailed
                                      completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                          wself.originalBackgroundImage = wself.channelCoverImageView.image;
                                          wself.channelCoverImageView.image = [wself croppedImageForCurrentOrientation];
                                      }];
    
    
    [self closeImageSelector: imageSelector];
}


#pragma mark - ScrollView Delegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (scrollView == self.videoThumbnailCollectionView)
    {
        CGFloat fadeSpan = (self.isIPhone) ? kChannelDetailsFadeSpaniPhone : kChannelDetailsFadeSpan;
        CGFloat blurOpacity;
        
        // Try this first
        // when reaching far right hand side, load a new page
        if (scrollView.contentSize.height > 0 && (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight)
            && self.isLoadingMoreContent == NO)
        {
            [self loadMoreVideos];
        }
        
        if (scrollView.contentOffset.y <= self.originalContentOffset.y)
        {
            self.masterControlsView.alpha = 1.0f;
            CGRect frame = self.masterControlsView.frame;
            frame.origin.y = self.originalMasterControlsViewOrigin.y;
            self.masterControlsView.frame = frame;
            self.shareButton.userInteractionEnabled = YES;
            
            blurOpacity = 0.0;
        }
        else
        {
            self.shareButton.userInteractionEnabled = NO;
            CGFloat differenceInY = -(self.originalContentOffset.y - scrollView.contentOffset.y);
            
            CGRect frame = self.masterControlsView.frame;
            
            frame.origin.y = self.originalMasterControlsViewOrigin.y - (differenceInY / 1.5);
            
            self.masterControlsView.frame = frame;
            
            if (differenceInY < fadeSpan)
            {
                CGFloat fadeCoefficient = (differenceInY / fadeSpan);
                self.masterControlsView.alpha = 1.0 - fadeCoefficient * fadeCoefficient;
            }
            else
            {
                self.masterControlsView.alpha = 0.0f;
            }
            
            // blur background
            blurOpacity = differenceInY > 140 ? 1.0 : differenceInY / 140.0; // 1 .. 0
        }
        
        self.blurredBGImageView.alpha = 0.0 + blurOpacity;
    }
}


#pragma mark - Image render

- (UIImage *) croppedImageForCurrentOrientation
{
    return [self croppedImageForOrientation: [(SYNDeviceManager *) SYNDeviceManager.sharedInstance orientation]];
}


- (UIImage *) croppedImageForOrientation: (UIInterfaceOrientation) orientation
{
    CGRect croppingRect;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        croppingRect = CGRectMake(0.0, 128.0, 1024.0, 768.0);
    }
    else
    {
        croppingRect = CGRectMake(128.0, 0.0, 768.0, 1024.0);
    }
    
    if (self.originalBackgroundImage == nil) // set the bg var once
    {
        // in most cases this will not be called its a failsafe
        self.originalBackgroundImage = self.channelCoverImageView.image;
    }
    
    if (self.originalBackgroundImage.size.height != 1024.0f)
    {
        // we expect square images 1024 x 1024 px
        // scale the crop Rect
        // should only happen when uploading new images.
        CGFloat scaleX = self.originalBackgroundImage.size.width / 1024.0f;
        CGFloat scaleY = self.originalBackgroundImage.size.height / 1024.0f;
        croppingRect = CGRectApplyAffineTransform(croppingRect, CGAffineTransformMakeScale(scaleX, scaleY));
    }
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([self.originalBackgroundImage CGImage], croppingRect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage: croppedImageRef];
    
    [self renderBlurredBackgroundWithCGImage: croppedImageRef];
    
    CGImageRelease(croppedImageRef);
    
    return croppedImage;
}


- (void) renderBlurredBackgroundWithCGImage: (CGImageRef) imageRef
{
    if (!self.blurredBGImageView)
    {
        self.blurredBGImageView = [[UIImageView alloc] init];
        self.blurredBGImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.blurredBGImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.blurredBGImageView.backgroundColor = [UIColor clearColor];
        self.blurredBGImageView.alpha = 0.0f;
        
        [self.view insertSubview: self.blurredBGImageView
                    aboveSubview: self.channelCoverImageView];
    }
    
    self.blurredBGImageView.frame = self.channelCoverImageView.frame;
    
    CGImageRetain(imageRef);
    
    __weak SYNChannelDetailViewController *wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.backgroundCIImage = [CIImage imageWithCGImage: imageRef];
        
        self.context = [CIContext contextWithOptions: nil];
        
        CGFloat imageWidth = CGImageGetWidth(imageRef);
        CGFloat imageHeight = CGImageGetHeight(imageRef);
        CGFloat largestDimension = MAX(imageWidth, imageHeight);
        
        CGFloat blurRadius = 7.0f;
        
        if (largestDimension != 1024.0f)
        {
            //we expect one side to be 1024 px
            //If not we are processing a cropped image for upload.
            //Attempt to adjust the blur scale.
            blurRadius *= largestDimension / 1024.0f;
            // Make min radius 1.0px if the image is really small so we do at least see some blurring
            blurRadius = MAX(blurRadius, 1.0f);
        }
        
        self.filter = [CIFilter filterWithName: @"CIGaussianBlur"];
        
        [self.filter setValue: self.backgroundCIImage
                       forKey: @"inputImage"];
        
        [self.filter setValue: @(blurRadius)
                       forKey: @"inputRadius"];
        
        CIImage *outputImage = [self.filter outputImage];
        
        CGImageRef cgimg = [self.context createCGImage: outputImage
                                              fromRect: CGRectMake(0.0f, 0.0f, imageWidth, imageHeight)];
        
        UIImage *bgImage = [UIImage imageWithCGImage: cgimg];
        CGImageRelease(cgimg);
        
        [wself.blurredBGImageView
         performSelectorOnMainThread: @selector(setImage:)
         withObject: bgImage
         waitUntilDone: YES];
        
        CGImageRelease(imageRef);
    });
}


- (id<SDWebImageOperation>) loadBackgroundImage
{
    __weak SDWebImageManager *shareImageManager = SDWebImageManager.sharedManager;
    __weak SYNChannelDetailViewController *wself = self;
    
    // Make sure we have a valid background URL
    if (self.channel.channelCover.imageBackgroundUrl)
    {
        return [shareImageManager downloadWithURL: [NSURL URLWithString: self.channel.channelCover.imageBackgroundUrl]
                                          options: SDWebImageRetryFailed
                                         progress: nil
                                        completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                            if (!wself || !image)
                                            {
                                                return;
                                            }
                                            
                                            wself.originalBackgroundImage = image;
                                            
                                            UIImage *croppedImage = [wself croppedImageForCurrentOrientation];
                                            
                                            
                                            [UIView transitionWithView: wself.view
                                                              duration: 0.35f
                                                               options: UIViewAnimationOptionTransitionCrossDissolve
                                                            animations: ^{
                                                                
                                                                wself.channelCoverImageView.image = croppedImage;
                                                                
                                                            } completion: ^(BOOL finished) {
                                                                
                                                            }];
                                            
                                            [wself.channelCoverImageView setNeedsLayout];
                                        }];
    }
    else
    {
        return nil;
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


- (void) videoOverlayDidDissapear
{
    
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


- (NavigationButtonsAppearance) navigationAppearance
{
    return NavigationButtonsAppearanceWhite;
}

- (BOOL) needsHeaderButton
{
    return NO;
}



@end
