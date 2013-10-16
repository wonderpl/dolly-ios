    //
//  SYNVideoViewerViewController.m
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "BBCyclingLabel.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "NSObject+Blocks.h"
#import "SYNAbstractViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPassthroughView.h"
#import "SYNReportConcernTableViewController.h"
#import "SYNVideoPlaybackViewController.h"
#import "SYNVideoThumbnailSmallCell.h"
#import "SYNVideoViewerThumbnailLayout.h"
#import "SYNVideoViewerThumbnailLayoutAttributes.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "SYNFacebookManager.h"
#import "VideoInstance.h"
#import "SYNImplicitSharingController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Appirater.h"
#import "AMBlurView.h"

@interface SYNVideoViewerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, assign) BOOL userPinchedIn;
@property (nonatomic, assign) BOOL shuttleBarVisible;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGRect originalSwipeFrame;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, assign) CGFloat iPhoneYOffset;
@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, copy) NSArray *videoInstanceArray;
@property (nonatomic, getter = isVideoExpanded) BOOL videoExpanded;
@property (nonatomic, strong) AMBlurView *blurView;
@property (nonatomic, strong) UIView *blurColourView;
@property (nonatomic, strong) IBOutlet BBCyclingLabel *channelCreatorLabel;
@property (nonatomic, strong) IBOutlet BBCyclingLabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet BBCyclingLabel *videoTitleLabel;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *blackPanelView;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *chromeView;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *passthroughView;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *placeholderView;
@property (nonatomic, strong) IBOutlet SYNVideoPlaybackViewController *videoPlaybackViewController;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *heartActivityIndicator;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *shareActivityIndicator;
@property (nonatomic, strong) IBOutlet UIButton *nextVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *previousVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *heartButton;
@property (nonatomic, strong) IBOutlet UIButton* reportConcernButton;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelThumbnailImageView;
@property (nonatomic, strong) IBOutlet UIView *panelView;
@property (nonatomic, strong) IBOutlet UILabel* likesCountLabel;
@property (nonatomic, strong) IBOutlet UIView *swipeView;
@property (nonatomic, strong) SYNReportConcernTableViewController *reportConcernTableViewController;
@property (nonatomic, strong) SYNVideoViewerThumbnailLayout *layout;
@property (nonatomic, strong) UISwipeGestureRecognizer* leftSwipeRecogniser;
@property (nonatomic, strong) UISwipeGestureRecognizer* rightSwipeRecogniser;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecogniser;
@property (nonatomic, strong) UITapGestureRecognizer* doubleTapRecogniser;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecogniser;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

//iPhone specific

@property (nonatomic, assign) UIDeviceOrientation currentOrientation;

@end


@implementation SYNVideoViewerViewController 

#pragma mark - Object lifecycle

- (id) initWithVideoInstanceArray: (NSArray *) videoInstanceArray
                    selectedIndex: (int) selectedIndex;
{
  	if ((self = [super init]))
    {
		self.videoInstanceArray = videoInstanceArray;
        self.currentSelectedIndex = selectedIndex;  
	}
    
	return self;
}


- (void) dealloc
{
    // Defensive programming
    self.rightSwipeRecogniser.delegate = nil;
    self.leftSwipeRecogniser.delegate = nil;
    self.tapRecogniser.delegate = nil;
    self.pinchRecogniser.delegate = nil;
}

-(void)setFeedCollectionView:(UICollectionView*)collectionView
{
    NSLog(@"WTF???");
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IOS_7_OR_GREATER)
    {
        self.yOffset = -10.0f;
        self.iPhoneYOffset = 0.0f;
    }
    else
    {
        self.yOffset = 0.0f;
        self.iPhoneYOffset = 20.0f;
    }
    
    BOOL isLandscape = [SYNDeviceManager.sharedInstance isLandscape];
    
    if (IS_IPHONE)
    {
        // Set custom fonts
        self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 12.0f];
        self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 10.0f];
        self.videoTitleLabel.font = [UIFont rockpackFontOfSize: 13.0f];
        
        // Cross-face transitions
        self.channelTitleLabel.transitionDuration = kTextCrossfadeDuration;
        self.channelCreatorLabel.transitionDuration = kTextCrossfadeDuration;
        self.videoTitleLabel.transitionDuration = kTextCrossfadeDuration;
    }
    else
    {
        // Set custom fonts
        self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 15.0f];
        self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 12.0f];
        self.videoTitleLabel.font = [UIFont rockpackFontOfSize: 18.0f];
        
        // Cross-face transitions
        self.channelTitleLabel.transitionDuration = kTextCrossfadeDuration;
        self.channelCreatorLabel.transitionDuration = kTextCrossfadeDuration;
        self.videoTitleLabel.transitionDuration = kTextCrossfadeDuration;
        
        self.channelCreatorLabel.textColor = [UIColor whiteColor];
        self.channelCreatorLabel.text = @"";
        [self.videoPlaybackViewController updateChannelCreator: @""];
    }
    
    self.channelTitleLabel.textColor = [UIColor colorWithRed: 40.0f/ 255.0f green: 45.0f/ 255.0f blue: 51.0f/ 255.0f alpha: 1.0f];
    self.channelCreatorLabel.textColor  = [UIColor colorWithRed: 80.0f/ 255.0f green: 90.0f/ 255.0f blue: 102.0f/ 255.0f alpha: 1.0f];
    self.videoTitleLabel.textColor = [UIColor colorWithRed: 40.0f/ 255.0f green: 45.0f/ 255.0f blue: 51.0f/ 255.0f alpha: 1.0f];
    
    self.videoTitleLabel.numberOfLines = 2;
    self.videoTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailSmallCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"];
    
    // Set custom flow layout to handle the chroma highlighting
    self.layout = [[SYNVideoViewerThumbnailLayout alloc] init];
    self.layout.itemSize = IS_IPHONE ? CGSizeMake(202.0f , 114.0f):CGSizeMake(204.0f , 106.0f);
    self.layout.minimumInteritemSpacing = 2.0f;
    self.layout.minimumLineSpacing = 0.0f;
    self.layout.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
    
    // Fake up an index path from our selected array index
    self.layout.selectedItemIndexPath = [NSIndexPath indexPathForItem: self.currentSelectedIndex
                                                            inSection: 0];
    
    self.videoThumbnailCollectionView.collectionViewLayout = self.layout;
    
    // Create the video playback view controller, and insert it in the right place in the view hierarchy
    CGRect videoFrame, blackPanelFrame;
    UIView *videoView;
    
    if (IS_IPHONE)
    {
        // iPhone
        videoView = self.view;
        videoFrame = self.placeholderView.frame;
        videoFrame.size.height = 180.0f;
        blackPanelFrame = CGRectMake(0, 0, 1024, 768);
        
        CGRect panelViewFrame = self.panelView.frame;
        CGFloat iOS7Correction = IS_IOS_7_OR_GREATER ? 20.0f : 0.0f;
        
        panelViewFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] - panelViewFrame.size.height - self.videoThumbnailCollectionView.frame.size.height- 30 + iOS7Correction;
        
        self.panelView.frame = panelViewFrame;
    }
    else
    {
        videoView = self.passthroughView;
        // iPad
        videoFrame = CGRectMake(142, 71, 739, 416);

        if (isLandscape)
        {
            // Landscape
            
            blackPanelFrame = CGRectMake(0, 0 + self.yOffset, 1024, 768);
        }
        else
        {
            // Portrait
            blackPanelFrame = CGRectMake(128, -128 + self.yOffset, 768, 1024);
        }
    }
    
    
    self.blackPanelView = [[SYNPassthroughView alloc] initWithFrame: blackPanelFrame];
    self.blackPanelView.backgroundColor = [UIColor blackColor];
    self.blackPanelView.alpha = 0.0f;
    self.blackPanelView.autoresizingMask = UIViewAutoresizingNone;
    
    [videoView insertSubview: self.blackPanelView
                aboveSubview: self.panelView];
    
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    self.videoPlaybackViewController = [SYNVideoPlaybackViewController sharedInstance];
    
    __weak typeof(self) weakSelf = self;
    
    self.videoPlaybackViewController.updateBlock = ^ {
            [weakSelf scheduleFadeOutShuttleBar];
    };

    [self.videoPlaybackViewController updateWithFrame: videoFrame
                                       channelCreator: videoInstance.video.sourceUsername
                                         indexUpdater: ^(int newIndex){
                                             weakSelf.currentSelectedIndex = newIndex;
                                             [weakSelf updateVideoDetailsForIndex: weakSelf.currentSelectedIndex];
                                             
                                             // We need to scroll the current thumbnail before the view appears (with no animation)
                                             [weakSelf scrollToCellAtIndex: weakSelf.currentSelectedIndex
                                                              animated: YES];
                                         }];
    
    self.videoPlaybackViewController.view.autoresizingMask = UIViewAutoresizingNone;

    [videoView insertSubview: self.videoPlaybackViewController.view
                     aboveSubview: self.blackPanelView];
    
    
    self.rightSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                          action: @selector(userTouchedPreviousVideoButton:)];
    
    self.rightSwipeRecogniser.delegate = self;
    [self.rightSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.swipeView addGestureRecognizer: self.rightSwipeRecogniser];
    
    self.leftSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                         action: @selector(userTouchedNextVideoButton:)];
    
    self.leftSwipeRecogniser.delegate = self;
    [self.leftSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.swipeView addGestureRecognizer: self.leftSwipeRecogniser];
    
    self.tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                 action: @selector(userTappedVideo)];
    
    self.tapRecogniser.numberOfTapsRequired = 1;
    self.tapRecogniser.delegate = self;
    [self.swipeView addGestureRecognizer: self.tapRecogniser];
    
    self.doubleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                 action: @selector(userTouchedMaxMinButton)];
    
    self.doubleTapRecogniser.numberOfTapsRequired = 2;
    self.doubleTapRecogniser.delegate = self;
    [self.swipeView addGestureRecognizer: self.doubleTapRecogniser];
    
    // Magic needed for it all to work
    [self.tapRecogniser requireGestureRecognizerToFail: self.doubleTapRecogniser];

#ifdef ALLOW_PINCH_OUT
    self.pinchRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                     action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: self.pinchRecogniser];
#endif
    
    if ([videoInstance.channel.channelOwner.displayName length] == 0)
    {
        [self.channelThumbnailImageView setImageWithURL: nil
                                       placeholderImage:nil];
    }
    
    else if ([videoInstance.channel.channelOwner.displayName length] > 0)
    {
        [self.channelThumbnailImageView setImageWithURL: [NSURL URLWithString: videoInstance.channel.channelCover.imageSmallUrl]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                                options: SDWebImageRetryFailed];
    }
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Video Viewer"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    [self.videoPlaybackViewController setPlaylist: self.videoInstanceArray
                                    selectedIndex: self.currentSelectedIndex
                                         autoPlay: TRUE];
    
    // likes count
    self.likesCountLabel.font = [UIFont rockpackFontOfSize:self.likesCountLabel.font.pointSize];
    self.likesCountLabel.text = @"0";
    
    
    
    //iOS 7 Blur
    if (IS_IOS_7_OR_GREATER)
    {
        // Do iOS7 Tingz
        self.blurView = [AMBlurView new];
//        self.blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        CGRect blurFrame = CGRectMake(0.0f, 0.0f, [[SYNDeviceManager sharedInstance] currentScreenWidth], [[SYNDeviceManager sharedInstance] currentScreenHeight] + 2.0f);
        
        [self.blurView setFrame: blurFrame];
        
        self.blurColourView = [[UIView alloc]initWithFrame: blurFrame];
        self.blurColourView.backgroundColor = [UIColor colorWithWhite:0.0f/255.0f alpha:0.2f];
        
        self.view.backgroundColor = [UIColor clearColor];
        
        [self.view insertSubview: self.blurView
                         atIndex: 0];
        
        [self.view insertSubview:self.blurColourView
                         atIndex:1];
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if (IS_IPHONE)
    {
        CGRect videoFrame = self.videoPlaybackViewController.view.frame;
        videoFrame.origin = self.placeholderView.frame.origin;
        self.videoPlaybackViewController.view.frame = videoFrame;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(deviceOrientationChange:)
                                                     name: UIDeviceOrientationDidChangeNotification
                                                   object: nil];
        
        self.currentOrientation = SYNDeviceManager.sharedInstance.orientation;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        self.originalFrame = self.placeholderView.frame;
        self.originalSwipeFrame = self.swipeView.frame;
        
        if (self.currentOrientation == UIDeviceOrientationLandscapeLeft)
        {
            [self handleMinMax];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(refreshAddbuttonStatus:)
                                                     name: kVideoQueueClear
                                                   object: nil];
    }
    
    
    // The min / max button is only active on the iPhone
    [self.videoPlaybackViewController.shuttleBarMaxMinButton addTarget: self
                                                                action: @selector(userTouchedMaxMinButton)
                                                      forControlEvents: UIControlEventTouchUpInside];
    
    // Update all the labels corresponding to the selected videos
    [self updateVideoDetailsForIndex: self.currentSelectedIndex];
    
    // We need to scroll the current thumbnail before the view appears (with no animation)
    [self scrollToCellAtIndex: self.currentSelectedIndex
                     animated: YES];
    
    [self scheduleFadeOutShuttleBar];

}


- (void) viewWillDisappear: (BOOL) animated
{
    // Let's make sure that we stop playing the current video
    if (IS_IPHONE)
    {
        //Stop generating notifications
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }

    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Remember to remove the target, as we may be drilling down deeper to another vc (and then returning, which would mean multiple
    // targets were added
    [self.videoPlaybackViewController.shuttleBarMaxMinButton removeTarget: self
                                                                   action: @selector(userTouchedMaxMinButton)
                                                         forControlEvents: UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteShowNetworkMessages
                                                        object: nil];

    [super viewWillDisappear: animated];
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    CGRect blackPanelFrame;
    CGRect blurViewFrame;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        // Landscape
        blackPanelFrame = CGRectMake(0, 0 + self.yOffset, 1024, 768);
        blurViewFrame = CGRectMake(0, 0, 1024, 768);        
        if (self.isVideoExpanded)
        {
            self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.384f, 1.384f);
        }
    }
    else
    {
        // Portrait
        blackPanelFrame = CGRectMake(128, -128 + self.yOffset, 768, 1024);
        blurViewFrame = CGRectMake(0, 0, 768, 1024);
        
        if (self.isVideoExpanded)
        {
            self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0392f, 1.0392f);
            self.videoPlaybackViewController.view.center = CGPointMake(512, 374 + self.yOffset);
        }
    }
    
    self.blackPanelView.frame = blackPanelFrame;
    self.blurView.frame = blurViewFrame;
    self.blurColourView.frame = blurViewFrame;
}

- (void) handlePinchGesture: (UIPinchGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // At this stage, we don't know whether the user is pinching in or out
        self.userPinchedOut = FALSE;
        self.userPinchedIn = FALSE;
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        //        DebugLog (@"UIGestureRecognizerStateChanged");
        float scale = sender.scale;
        
        if (scale < 1.0)
        {
            self.userPinchedIn = TRUE;
        }
        else
        {
            self.userPinchedOut = TRUE;
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        DebugLog (@"UIGestureRecognizerStateEnded");
        
        if (self.userPinchedOut == TRUE)
        {
            // TODO: Zoom video to full screen
        }
        else if (self.userPinchedIn == TRUE)
        {
            // TODO: Zoom video back to windowed
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        DebugLog (@"UIGestureRecognizerStateCancelled");
    }
}


#pragma mark - Video playback control

- (void) playVideoAtIndex: (int) index
{
    // We should start playing the selected video and scroll the thumbnnail so that it appears under the arrow
    self.currentSelectedIndex = index;
    
    [self scrollToCellAtIndex: index
                     animated: YES];
    
    [self.videoPlaybackViewController playVideoAtIndex: index];
    [self updateVideoDetailsForIndex: index];
}


#pragma mark - Update index and details

// We need to override the standard setter so that we can update our flow layout for highlighting (colour / monochrome)
- (void) setCurrentSelectedIndex: (int) currentSelectedIndex
{
    // Deselect the old thumbnail (if there is one, and it is not the same as the new one)
    if (_currentSelectedIndex != currentSelectedIndex)
    {
        SYNVideoThumbnailSmallCell *oldCell = (SYNVideoThumbnailSmallCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: _currentSelectedIndex
                                                                                                                                                           inSection: 0]];
        // This will colour the cell monochrome
        oldCell.colour = NO;
    }
    
    // Now fade up the new image to full colour
    SYNVideoThumbnailSmallCell *newCell = (SYNVideoThumbnailSmallCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: currentSelectedIndex
                                                                                                                                                       inSection: 0]];
    
    newCell.colour = YES;
    
    _currentSelectedIndex = currentSelectedIndex;
    
    self.layout.selectedItemIndexPath = [NSIndexPath indexPathForItem: currentSelectedIndex
                                                            inSection: 0];
    
    // Now set the channel thumbail for the new
    VideoInstance *videoInstance = self.videoInstanceArray [currentSelectedIndex];
    
    if (!videoInstance)
    {
        AssertOrLog(@"Non-nil video instance unexpected");
    }
    
    if ([videoInstance.channel.channelOwner.displayName length] == 0)
    {
        [self.channelThumbnailImageView setImageWithURL: nil
                                       placeholderImage: nil];
    }
    
    else if ([videoInstance.channel.channelOwner.displayName length] > 0)
    {
        [self.channelThumbnailImageView setImageWithURL: [NSURL URLWithString: videoInstance.channel.channelCover.imageSmallUrl]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                                options: SDWebImageRetryFailed];
    }
}


- (void) updateVideoDetailsForIndex: (int) index
{
    VideoInstance *videoInstance = self.videoInstanceArray [index];
    
    // In video overlay feed display BY followed by username, in video overlay search if no user name display nothing
    if ([videoInstance.channel.channelOwner.displayName length] <= 0) {
        self.channelCreatorLabel.text = @"";
        [self.videoPlaybackViewController updateChannelCreator: videoInstance.video.sourceUsername];
    }
    else
    {
        self.channelCreatorLabel.text = [NSString stringWithFormat:@"By %@", videoInstance.channel.channelOwner.displayName];
        [self.videoPlaybackViewController updateChannelCreator: videoInstance.video.sourceUsername];
    }
    
    self.channelTitleLabel.text = videoInstance.channel.title;
    self.videoTitleLabel.text = videoInstance.title;
    self.heartButton.selected = videoInstance.starredByUserValue;
    self.likesCountLabel.text = [videoInstance.video.starCount stringValue];
    
    [self refreshAddbuttonStatus:nil];
    
}


// The built in UICollectionView scroll to index doesn't work correctly with contentOffset set to non-zero, so roll our own here
- (void) scrollToCellAtIndex: (int) index
                    animated: (BOOL) animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: index
                                                 inSection: 0];
    
    [self.videoThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                              atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally
                                                      animated: animated];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
//    DebugLog (@"Items in section %d", self.videoInstanceArray.count);
    return self.videoInstanceArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailSmallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"
                                                                                 forIndexPath: indexPath];
    
    VideoInstance *videoInstance = self.videoInstanceArray [indexPath.item];
    
    cell.titleLabel.text = videoInstance.title;
    
    SYNVideoViewerThumbnailLayoutAttributes* attributes = (SYNVideoViewerThumbnailLayoutAttributes *)[self.layout layoutAttributesForItemAtIndexPath: indexPath];
    
    BOOL thumbnailIsColour = attributes.isHighlighted;
    
    if (thumbnailIsColour)
    {
        cell.colour = TRUE;
    }
    else
    {
        cell.colour = FALSE;
    }
    
    cell.imageWithURL = videoInstance.video.thumbnailURL;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if(self.isVideoExpanded)
    {
        return;
    }
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoBarClick"
                                                            label: nil
                                                            value: nil] build]];
    
    // We should start playing the selected vide and scroll the thumbnnail so that it appears under the arrow
    [self playVideoAtIndex: indexPath.item];
}


#pragma mark - UICollectionViewDelegateFlowLayout delegates

// A better solution than the previous implementation that used referenceSizeForHeaderInSection and referenceSizeForFooterInSection
- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView
                         layout: (UICollectionViewLayout*) collectionViewLayout
         insetForSectionAtIndex: (NSInteger)section
{
    CGFloat insetWidth = IS_IPHONE ? 81.0f : 438.0f;
    
    // We only have one section, so add both trailing and leading insets
    return UIEdgeInsetsMake (0, insetWidth, 0, insetWidth );
}


#pragma mark - User actions

- (IBAction) userTouchedNextVideoButton: (id) sender
{
    if(self.isVideoExpanded)
    {
        return;
    }
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoNextClick"
                                                            label: @"next"
                                                            value: nil] build]];
    
    int index = (self.currentSelectedIndex + 1) % self.videoInstanceArray.count;

    
    [self playVideoAtIndex: index];
}


- (IBAction) userTouchedPreviousVideoButton: (id) sender
{
    if(self.isVideoExpanded)
    {
        return;
    }
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoNextClick"
                                                            label: @"prev"
                                                            value: nil] build]];
    
    int index = self.currentSelectedIndex -  1;
    
    // wrap around if necessary
    if (index < 0)
    {
        index = self.videoInstanceArray.count - 1;
    }
    
    [self playVideoAtIndex: index];
}


- (IBAction) userTouchedVideoAddItButton: (UIButton *) addItButton
{
    if(self.isVideoExpanded)
    {
        return;
    }
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoPlusButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    if (IS_IPAD && [appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueRemove
                                                        object: self
                                                      userInfo: @{@"VideoInstance" : videoInstance}];
        addItButton.selected = NO;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                            object: self
         
                                                          userInfo: @{@"VideoInstance" : videoInstance}];
        addItButton.selected = YES;
        [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                         action: @"select"
                                                videoInstanceId: videoInstance.uniqueId
                                              completionHandler: ^(id response) {
                                              }
                                                   errorHandler: ^(id error) {
                                                       DebugLog (@"Acivity not recorded: Select");
                                                   }]; 
    }
    
    if (!IS_IPAD)
    {
        addItButton.selected = NO;
    }
    
}

- (IBAction) toggleStarButton: (UIButton *) button
{
    if(self.isVideoExpanded)
    {
        return;
    }

    // if the user does NOT have a FB account linked, no prompt
    
    ExternalAccount* facebookAccount = appDelegate.currentUser.facebookAccount;
    
    BOOL doesNotHavePublishPermissions = ![[SYNFacebookManager sharedFBManager] hasActiveSessionWithPermissionType:FacebookPublishPermission];
    BOOL doesNotHaveAutopostStarFlagSet = !(facebookAccount.flagsValue & ExternalAccountFlagAutopostStar);
    
    if( facebookAccount && (facebookAccount.noautopostValue == NO) && (doesNotHavePublishPermissions || doesNotHaveAutopostStarFlagSet) ) 
    {
        
        // then show panel, the newtork code will check for permissions in the FB Engine, is they exist then the code is triggered automatically and the flag is set,
        // if not then the flag is set after the net call
        
        
        __weak SYNVideoViewerViewController* wself = self;
        SYNImplicitSharingController* implicitSharingController = [SYNImplicitSharingController controllerWithBlock:^(BOOL allowedAutoSharing){
            [wself toggleStarButton:button];
            if(allowedAutoSharing)
            {
                // track
                
                id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                
                [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                       action: @"videoShared"
                                                                        label: @"fbi"
                                                                        value: nil] build]];
            }
            
        }];
        [self addChildViewController:implicitSharingController];
        
        implicitSharingController.view.alpha = 0.0f;
        implicitSharingController.view.center = CGPointMake(self.view.center.x, self.view.center.y);
        implicitSharingController.view.frame = CGRectIntegral(implicitSharingController.view.frame);
        [self.view addSubview:implicitSharingController.view];
        [UIView animateWithDuration:0.3 animations:^{
            implicitSharingController.view.alpha = 1.0f;
        }];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissImplicitSharing)];
        [self.view addGestureRecognizer:tapGesture];
        
        
        
        return;
    }
    
    
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoStarButtonClick"
                                                            label: @"Viewer"
                                                            value: nil] build]];
    
    button.selected = !button.selected;
    
    NSString *starAction = (button.selected == TRUE) ? @"star" : @"unstar";
    
    button.enabled = NO;
    
    [self.heartActivityIndicator startAnimating];
    
    __weak VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    __weak SYNVideoViewerViewController* wself = self;
    MKNKUserErrorBlock finishBlock = ^(id obj) {
        
        [wself updateVideoDetailsForIndex: self.currentSelectedIndex];
        
        [wself.heartActivityIndicator stopAnimating];
        
        button.enabled = YES;
    };
    
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: starAction
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(id response) {
                                              
                                              
                                              BOOL previousStarringState = videoInstance.starredByUserValue;
                                              NSNumber* previousStarCount = videoInstance.video.starCount;
                                              if (previousStarringState)
                                              {
                                                  // Currently highlighted, so decrement
                                                  videoInstance.starredByUserValue = FALSE;
                                                  videoInstance.video.starCountValue -= 1;
                                              }
                                              else
                                              {
                                                  // Currently highlighted, so increment
                                                  videoInstance.starredByUserValue = TRUE;
                                                  videoInstance.video.starCountValue += 1;
                                                  [Appirater userDidSignificantEvent: FALSE];
                                              }
                                              
                                              NSError* error;
                                              if(![videoInstance.managedObjectContext save:&error]) // something went wrong
                                              {
                                                  // revert to previous state
                                                  videoInstance.starredByUserValue = previousStarringState;
                                                  videoInstance.video.starCount = previousStarCount;
                                                  button.selected = !button.selected;
                                              }
                                              
                                              
                                              finishBlock(response);
                                              
                                          } errorHandler: ^(id error) {
                                                   DebugLog(@"Could not star video");
                                                   button.selected = !button.selected;
                                                   finishBlock(error);
                                               }];
    
    
    
    
}



-(void)dismissImplicitSharing
{
    SYNImplicitSharingController* implicitSharingController;
    for (UIViewController* child in self.childViewControllers) {
        if([child isKindOfClass:[SYNImplicitSharingController class]])
            implicitSharingController = (SYNImplicitSharingController*)child;
    }
    if(!implicitSharingController)
        return;
    
    [implicitSharingController dismiss];
}


- (IBAction) userTouchedCloseButton: (id) sender
{
    if(self.isVideoExpanded)
    {
        return;
    }
    // Call the close method on our parent
    [self.overlayParent removeVideoOverlayController];
}


// The user touched the invisible button above the channel thumbnail, taking the user to the channel page
- (IBAction) userTouchedChannelButton: (id) sender
{
    if(self.isVideoExpanded)
    {
        return;
    }
    if(self.shownFromChannelScreen)
    {
        //Don't navigate to the channel in a new view controller, instead just pop this video player
        [self userTouchedCloseButton:nil];
        return;
    }
    [self.overlayParent removeVideoOverlayController];
    
    // Get the video instance for the currently selected video
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [appDelegate.viewStackManager viewChannelDetails: videoInstance.channel];
    
}


// The user touched the invisible button above the user details, taking the user to the profile page
- (IBAction) userTouchedProfileButton: (id) sender
{
    if(self.isVideoExpanded)
    {
        return;
    }
    [self.overlayParent removeVideoOverlayController];
    
    // Get the video instance for the currently selected video
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [appDelegate.viewStackManager viewProfileDetails: videoInstance.channel.channelOwner];
}

- (void) userTappedVideo
{
        [self fadeUpShuttleBar];
        [self scheduleFadeOutShuttleBar];
}


- (void) handleMinMax
{
    if (IS_IPAD)
    {
        // iPad
        if (self.isVideoExpanded)
        {
            if ([SYNDeviceManager.sharedInstance isLandscape])
            {
                // Landscape
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 0.0f;
                                    self.chromeView.alpha = 1.0f;
                                    self.swipeView.frame =  CGRectMake(172, 142, 676, 251);
                                    self.blackPanelView.frame = CGRectMake(0, 0 + self.yOffset, 1024, 768);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 279);
                                }
                                completion: ^(BOOL success){
                                    [self.videoPlaybackViewController.shuttleBarMaxMinButton setImage: [UIImage imageNamed: @"ButtonShuttleBarMaximise.png"]
                                                                                             forState: UIControlStateNormal];
                                    
                                }];
            }
            else
            {
                // Portrait
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 0.0f;
                                    self.chromeView.alpha = 1.0f;
                                    self.swipeView.frame =  CGRectMake(172, 142, 676, 251);
                                    self.blackPanelView.frame = CGRectMake(128, -128 + self.yOffset, 768, 1024);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 279);
                                }
                                completion: ^(BOOL success){
                                    [self.videoPlaybackViewController.shuttleBarMaxMinButton setImage: [UIImage imageNamed: @"ButtonShuttleBarMaximise.png"]
                                                                                             forState: UIControlStateNormal];
                                }];
            }
        }
        else
        {
            // 
            if ([SYNDeviceManager.sharedInstance isLandscape])
            {
                // Landscape
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 1.0f;
                                    self.chromeView.alpha = 0.0f;
                                    self.swipeView.frame =  CGRectMake(0, 140, 1024, 410);
                                    self.blackPanelView.frame = CGRectMake(0, 0 + self.yOffset, 1024, 768);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.384f, 1.384f);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 374);
                                }
                                completion: ^(BOOL success){
                                    [self.videoPlaybackViewController.shuttleBarMaxMinButton setImage: [UIImage imageNamed: @"ButtonShuttleBarMinimise.png"]
                                                                                             forState: UIControlStateNormal];
                                }];
            }
            else
            {
                // Portrait
                [UIView transitionWithView: self.view
                                  duration: 0.5f
                                   options: UIViewAnimationOptionCurveEaseInOut
                                animations: ^ {
                                    self.blackPanelView.alpha = 1.0f;
                                    self.chromeView.alpha = 0.0f;
                                    self.swipeView.frame =  CGRectMake(0, 210, 1024, 290);
                                    self.blackPanelView.frame = CGRectMake(128, -128 + self.yOffset, 768, 1024);
                                    self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0392f, 1.0392f);
                                    self.videoPlaybackViewController.view.center = CGPointMake(512, 374);
                                }
                                completion: ^(BOOL success){
                                    [self.videoPlaybackViewController.shuttleBarMaxMinButton setImage: [UIImage imageNamed: @"ButtonShuttleBarMinimise.png"]
                                                                                             forState: UIControlStateNormal];
                                }];
                                    
            }
        }
        
        self.videoExpanded = !self.videoExpanded;
    }
    else
    {
//        if (self.videoExpanded == TRUE)
//        {
//            [self scheduleFadeOutShuttleBar];
//        }
    }
}


- (void) userTouchedMaxMinButton
{    
    if (IS_IPHONE)
    {
        if (self.currentOrientation == UIDeviceOrientationPortrait)
        {
            UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
            
            if (UIDeviceOrientationIsLandscape(deviceOrientation))
            {
                [self changePlayerOrientation: deviceOrientation];
            }
            else
            {
                [self changePlayerOrientation: UIDeviceOrientationLandscapeLeft];
            }
        }
        else
        {
            [self changePlayerOrientation: UIDeviceOrientationPortrait];
        }
        
//        self.videoExpanded = !self.videoExpanded;
    }
    else
    {
        // We are on the iPad
        [self handleMinMax];
    }
    
    if (self.isVideoExpanded)
    {
        // Update google analytics
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                               action: @"videoMaximizeClick"
                                                                label: nil
                                                                value: nil] build]];
    }
}


- (IBAction) userTouchedVideoShareButton: (UIButton *) videoShareButton
{
    // Get share link pre-emptively
    [self requestShareLinkWithObjectType: @"video_instance"
                                objectId: [(VideoInstance *)self.videoInstanceArray[self.currentSelectedIndex] uniqueId]];
    
    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    [self shareVideoInstance: videoInstance];
}

- (IBAction) userTouchedReportConcernButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        if (!self.reportConcernTableViewController)
        {
            // Create out concerns table view controller
            self.reportConcernTableViewController = [[SYNReportConcernTableViewController alloc] init];
            
            VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
            
            [self.reportConcernTableViewController reportConcernFromView: button
                                                        inViewController: self
                                                   popOverArrowDirection: UIPopoverArrowDirectionDown
                                                              objectType: @"video"
                                                                objectId: videoInstance.video.uniqueId
                                                          completedBlock: ^{
                                                              button.selected = NO;
                                                              self.reportConcernTableViewController = nil;
                                                          }];
        }
    }
}


#pragma mark - orientation change iPhone
- (void) deviceOrientationChange: (NSNotification*) note
{
    UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
    
    if (self.currentOrientation != newOrientation && (newOrientation ==  UIDeviceOrientationPortrait || UIDeviceOrientationIsLandscape(newOrientation)))
    {
        [self changePlayerOrientation:newOrientation];
    }
}

-(void) changePlayerOrientation: (UIDeviceOrientation) newOrientation
{
    if (newOrientation == UIDeviceOrientationPortrait)
    {
        self.videoExpanded = FALSE;
        
        [self.videoPlaybackViewController.shuttleBarMaxMinButton setImage: [UIImage imageNamed: @"ButtonShuttleBarMaximise.png"]
                                                                 forState: UIControlStateNormal];
        
        self.currentOrientation = UIDeviceOrientationPortrait;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [UIView transitionWithView: self.view
                          duration: 0.5f
                           options: UIViewAnimationOptionCurveEaseInOut
                        animations: ^ {
                            self.blackPanelView.alpha = 0.0f;
                            self.chromeView.alpha = 1.0f;
                            self.swipeView.transform = CGAffineTransformIdentity;
                            self.videoPlaybackViewController.view.transform = CGAffineTransformIdentity;
                            self.videoPlaybackViewController.shuttleBarView.transform = CGAffineTransformIdentity;
                            self.swipeView.frame = self.originalSwipeFrame;
                            CGRect videoFrame = self.videoPlaybackViewController.view.frame;
                            videoFrame.origin = self.originalFrame.origin;
                            self.videoPlaybackViewController.view.frame = videoFrame;
//                            self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
                            [self.videoPlaybackViewController resetShuttleBarFrame];
                            self.iPhonePanelImageView.alpha = 1.0f;
                        }
                        completion:^(BOOL finished) {
                            if (finished)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNoteShowNetworkMessages object:nil];
                            }
                        }];
    }
    else if (UIDeviceOrientationIsLandscape(newOrientation))
    {
        self.videoExpanded = TRUE;
        
        [self.videoPlaybackViewController.shuttleBarMaxMinButton setImage: [UIImage imageNamed: @"ButtonShuttleBarMinimise.png"]
                                                                 forState: UIControlStateNormal];
        self.currentOrientation = newOrientation;
        [[UIApplication sharedApplication] setStatusBarHidden: YES
                                                withAnimation: UIStatusBarAnimationSlide];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteHideNetworkMessages
                                                            object: nil];
        
        self.swipeView.transform = CGAffineTransformIdentity;
        [UIView transitionWithView: self.view
                          duration: 0.5f
                           options: UIViewAnimationOptionCurveEaseInOut
                        animations: ^ {
                            CGRect fullScreenFrame = CGRectMake(0,0,[SYNDeviceManager.sharedInstance currentScreenHeight], [SYNDeviceManager.sharedInstance currentScreenWidth]);
                            if (fullScreenFrame.size.width < fullScreenFrame.size.height)
                            {
                                //Device orientation may confuse screen dimensions. Ensure the width is always the larger dimension.
                                fullScreenFrame = CGRectMake(0,0,[SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight]);
                            }
                            
                            self.blackPanelView.alpha = 1.0f;
                            self.chromeView.alpha = 0.0f;
                            self.swipeView.frame =  fullScreenFrame;
                            self.swipeView.center = CGPointMake(fullScreenFrame.size.height/2.0f,fullScreenFrame.size.width/2.0f - self.iPhoneYOffset);
                            self.videoPlaybackViewController.view.center = CGPointMake(fullScreenFrame.size.height/2.0f,fullScreenFrame.size.width/2.0f - self.iPhoneYOffset);
                            
                            self.swipeView.transform = CGAffineTransformMakeRotation((newOrientation==UIDeviceOrientationLandscapeLeft) ? M_PI_2 : -M_PI_2 );
                            
                            CGFloat scaleFactor = fullScreenFrame.size.width / self.videoPlaybackViewController.view.frame.size.width;
//                            DebugLog (@"w1 = %f, w2 = %f", fullScreenFrame.size.width, self.videoPlaybackViewController.view.frame.size.width);
                            if (self.videoPlaybackViewController.view.frame.size.width < self.videoPlaybackViewController.view.frame.size.height)
                            {
                                scaleFactor = self.videoPlaybackViewController.view.frame.size.height / fullScreenFrame.size.height;
                            }
                            
                            self.videoPlaybackViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeRotation((newOrientation==UIDeviceOrientationLandscapeLeft) ? M_PI_2 : -M_PI_2 ),scaleFactor,scaleFactor);
                            self.videoPlaybackViewController.shuttleBarView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0f/scaleFactor,1.0f/scaleFactor);

                            //
                            CGRect shuttleBarFrame = self.videoPlaybackViewController.shuttleBarView.frame;
                            shuttleBarFrame.size.width = fullScreenFrame.size.width*(1.0f/scaleFactor);
                            shuttleBarFrame.size.height = kShuttleBarHeight*(1.0f/scaleFactor);
                            shuttleBarFrame.origin.x = 0.0f;
                            shuttleBarFrame.origin.y = (self.videoPlaybackViewController.view.frame.size.width - kShuttleBarHeight)*(1.0f/scaleFactor);
                            self.videoPlaybackViewController.shuttleBarView.frame = shuttleBarFrame;
                            
                            self.iPhonePanelImageView.alpha = 0.0f;
                        }
                        completion: ^(BOOL success){
                            CGFloat adjustment = ([SYNDeviceManager.sharedInstance currentScreenWidth] > 480) ? 0 : 25;
                            CGPoint currentCenter = self.swipeView.center;
                            currentCenter.x += (newOrientation == UIDeviceOrientationLandscapeLeft) ? 44+adjustment : -(44+adjustment);
                            self.swipeView.center = currentCenter;
                            
                            [self scheduleFadeOutShuttleBar];

                        }];
    }
}


- (void) scheduleFadeOutShuttleBar
{
    self.shuttleBarVisible = FALSE;
    
//    self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
    // Arrange to fade out shuttle bar
    [self performBlock: ^{
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^ {
                             self.videoPlaybackViewController.shuttleBarView.alpha = 0.0f;
                         }
                         completion: nil];
    }
            afterDelay: 6.0f
 cancelPreviousRequest: YES];

}

- (void) fadeOutShuttleBar
{
    self.shuttleBarVisible = FALSE;
    
    //    self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
    // Arrange to fade out shuttle bar
    [self performBlock: ^{
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^ {
                             self.videoPlaybackViewController.shuttleBarView.alpha = 0.0f;
                         }
                         completion: nil];
    }
            afterDelay: 0.0f
 cancelPreviousRequest: YES];
    
}

- (void) fadeUpShuttleBar
{
    self.shuttleBarVisible = TRUE;
    
    // Arrange to fade out shuttle bar
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
                     }
                     completion: nil];

}


#pragma mark - play and pause video if active

- (void) playIfVideoActive
{
    [self.videoPlaybackViewController playIfVideoActive];
}

- (void) pauseIfVideoActive
{
    [self.videoPlaybackViewController pauseIfVideoActive];
}

#pragma mark - refresh addbutton status
-(void)refreshAddbuttonStatus:(NSNotification*)note
{
    //We should only track the status of the queue on iPad since iPhone only ever adds one object at a time
    VideoInstance* videoInstance = self.videoInstanceArray[self.currentSelectedIndex];
    self.addVideoButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance];
}



#pragma mark - Appear animation

-(void)prepareForAppearAnimation
{
    self.addVideoButton.alpha = 0.0f;
    self.addVideoButton.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
    
    self.shareButton.alpha = 0.0f;
    self.shareButton.transform = CGAffineTransformMakeTranslation(self.shareButton.frame.size.width, 0.0f);
    
    self.heartButton.alpha = 0.0f;
    self.heartButton.transform = CGAffineTransformMakeTranslation(-self.shareButton.frame.size.width, 0.0f);
    
    self.likesCountLabel.alpha = 0.0f;
    self.likesCountLabel.transform = CGAffineTransformMakeTranslation(-80.0f, 0.0f);
    
    if(self.currentSelectedIndex>1 || [self.videoInstanceArray count] < 4)
    {
        [self scrollToCellAtIndex:MAX(0, self.currentSelectedIndex - 3) animated:NO];
    }
    else
    {
        [self scrollToCellAtIndex:3 animated:NO];
    }
    self.videoThumbnailCollectionView.alpha = 0.0f;
}

-(void)runAppearAnimation
{
    
    [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationCurveEaseInOut animations:^{
        
        self.addVideoButton.transform = CGAffineTransformIdentity;
        
        self.shareButton.transform = CGAffineTransformIdentity;
        
        self.heartButton.transform = CGAffineTransformIdentity;
        
        self.likesCountLabel.transform = CGAffineTransformIdentity;
        
        self.addVideoButton.alpha = 1.0f;
        
        self.likesCountLabel.alpha = 1.0f;
        
        self.shareButton.alpha = 1.0f;
        
        self.heartButton.alpha = 1.0f;

    } completion:nil];

    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.videoThumbnailCollectionView.alpha = 1.0f;
    } completion:nil];
    
    [self scrollToCellAtIndex:self.currentSelectedIndex animated:YES];
}


@end
