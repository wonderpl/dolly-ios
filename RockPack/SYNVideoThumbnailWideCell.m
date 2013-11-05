//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNNetworkEngine.h"
#import "SYNTouchGestureRecognizer.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import "UIImageView+WebCache.h"
@import QuartzCore;

@interface SYNVideoThumbnailWideCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *channelButton;
@property (nonatomic, strong) IBOutlet UIButton *profileButton;
@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;
@property (nonatomic, strong) IBOutlet UILabel* byLabel;
@property (nonatomic, strong) IBOutlet UILabel* fromLabel;
@property (nonatomic, strong) IBOutlet UIView *videoPlaceholder;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation SYNVideoThumbnailWideCell

@synthesize displayMode = _displayMode;
@synthesize usernameText;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.videoTitle.font = [UIFont regularCustomFontOfSize: self.videoTitle.font.pointSize];
    
    self.fromLabel.font = [UIFont lightCustomFontOfSize: self.fromLabel.font.pointSize];
    self.channelName.font = [UIFont regularCustomFontOfSize: self.channelName.font.pointSize];
    
    self.usernameLabel.font = [UIFont lightCustomFontOfSize: self.usernameLabel.font.pointSize];
    self.byLabel.font = [UIFont lightCustomFontOfSize: self.byLabel.font.pointSize];
    
    self.numberOfViewLabel.font = [UIFont lightCustomFontOfSize: self.numberOfViewLabel.font.pointSize];
    self.youTubeUserLabel.font = [UIFont lightCustomFontOfSize: self.youTubeUserLabel.font.pointSize];
    self.dateAddedLabel.font = [UIFont lightCustomFontOfSize: self.dateAddedLabel.font.pointSize];
    self.durationLabel.font = [UIFont lightCustomFontOfSize: self.durationLabel.font.pointSize];
    
    self.displayMode = kVideoThumbnailDisplayModeChannel; // default is channel
    
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showVideo:)];
    self.tap.delegate = self;
    [self.videoPlaceholder addGestureRecognizer: self.tap];
    
    // Touch for highlighting cells when the user touches them (like UIButton)
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(showGlossLowlight:)];
    
    self.touch.delegate = self;
    [self.videoPlaceholder addGestureRecognizer: self.touch];
}



#pragma mark - Switch Between Modes

- (void) setDisplayMode: (kVideoThumbnailDisplayMode) displayMode
{
    _displayMode = displayMode;
    
    if (displayMode == kVideoThumbnailDisplayModeChannel)
    {
        self.addItButton.hidden = NO;
        self.videoInfoView.hidden = YES;
        self.channelInfoView.hidden = NO;
    }
    else if (displayMode == kVideoThumbnailDisplayModeYoutube)
    {
        self.addItButton.hidden = NO;
        self.channelInfoView.hidden = YES;
        self.videoInfoView.hidden = NO;
    }
    else
    {
        AssertOrLog(@"Unexpected option");
    }
}


#pragma mark - Asynchronous image loading support

// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (id<SYNVideoThumbnailWideCellDelegate>) delegate
{
    _viewControllerDelegate = delegate;

    // Add button targets
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(videoAddButtonTapped:)
               forControlEvents: UIControlEventTouchUpInside];
    
    // User touches channel thumbnail
    [self.channelButton addTarget: self.viewControllerDelegate
                           action: @selector(channelButtonTapped:)
                 forControlEvents: UIControlEventTouchUpInside];
    
    // User touches user details
    [self.profileButton addTarget: self.viewControllerDelegate
                           action: @selector(profileButtonTapped:)
                 forControlEvents: UIControlEventTouchUpInside];
}


- (void) setUsernameText: (NSString *) text
{
    if (IS_IPAD)
    {
        //CGRect byFrame = self.byLabel.frame;
        CGRect usernameFrame = self.usernameLabel.frame;
        
        if ([SYNDeviceManager.sharedInstance isLandscape])
        {
            // Landscape
            //byFrame.origin.x = 78.0f;
            usernameFrame.origin.x = 78.0f;
            //byFrame.origin.y = 66.0f;
            usernameFrame.origin.y = 66.0f;
            usernameFrame.size.width = 160.0f;
        }
        else
        {
            // Portrait
            //byFrame.origin.x = 10.0f;
            usernameFrame.origin.x = 10.0f;
            //byFrame.origin.y = 86.0f;
            usernameFrame.origin.y = 86.0f;
            usernameFrame.size.width = 108.0f;
        }
        
        // Update label positions
        //self.byLabel.frame = byFrame;
        self.usernameLabel.frame = usernameFrame;
        
        self.usernameLabel.text = [NSString stringWithFormat: @"%@\n\n", text]; 
    }
    else
    {
        self.usernameLabel.text = text;
    }
}


- (void) setChannelNameText:(NSString *)channelNameText
{
    if (IS_IPAD)
    {
        CGRect currentFrame = self.channelName.frame;
        CGFloat defaultWidth = currentFrame.size.width;
        UIView *referenceView = self.channelImageView.hidden ? self.usernameLabel : self.channelImageView;
        CGFloat maxHeight = referenceView.frame.origin.y - self.channelName.frame.origin.y;
        self.channelName.text = channelNameText;
        [self.channelName sizeToFit];
        currentFrame = self.channelName.frame;
        currentFrame.size.width = defaultWidth;
        currentFrame.size.height = MIN(currentFrame.size.height, maxHeight);
        self.channelName.frame = currentFrame;
    }
    else
    {
        self.channelName.text = channelNameText;
    }
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    [self.layer removeAllAnimations];
    
    [self.videoImageView.layer removeAllAnimations];
    [self.videoImageView setImageWithURL:nil];
    
    [self.channelImageView.layer removeAllAnimations];
    [self.channelImageView setImageWithURL:nil];
}


#pragma mark - Gesture regognizer support


// Required to pass through events to controls overlaid on view with gesture recognizers
- (BOOL) gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch: (UITouch *) touch
{
    if ([touch.view isKindOfClass: [UIControl class]])
    {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    
    return YES; // handle the touch
}

// This is used to lowlight the gloss image on touch
- (void) showGlossLowlight: (SYNTouchGestureRecognizer *) recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // Set lowlight tint
            UIImage *glossImage = [UIImage imageNamed: @"GlossVideo.png"];
            UIImage *lowlightImage = [glossImage tintedImageUsingColor: [UIColor colorWithWhite: 0.0
                                                                                          alpha: 0.3]];
            self.lowlightImageView.image = lowlightImage;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.lowlightImageView.image = [UIImage imageNamed: @"GlossVideo.png"];
        }
        default:
            break;
    }
}


- (void) showVideo: (UILongPressGestureRecognizer *) recognizer
{
    [self.viewControllerDelegate performSelector:@selector(videoButtonPressed:) withObject: self.videoPlaceholder];
}

@end
