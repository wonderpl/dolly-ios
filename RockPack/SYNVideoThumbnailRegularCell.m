//
//  SYNVideoThumbnailRegularCell.m
//  rockpack
//
//  Created by Nick Banks on 03/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNTouchGestureRecognizer.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNVideoThumbnailRegularCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

@end


@implementation SYNVideoThumbnailRegularCell

- (void) awakeFromNib
{
    [super awakeFromNib];

    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showVideo:)];
    self.tap.delegate = self;
    [self addGestureRecognizer: self.tap];

    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    // Touch for highlighting cells when the user touches them (like UIButton)
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(showGlossLowlight:)];
    
    self.touch.delegate = self;
    [self addGestureRecognizer: self.touch];
}


#pragma mark - Switch between display and edit modes

- (void) setDisplayMode: (kChannelThumbnailDisplayMode) displayMode
{
    _displayMode = displayMode;
    
    if (displayMode == kChannelThumbnailDisplayModeDisplay)
    {
        self.addItButton.hidden = YES;
        self.tap.enabled = TRUE;
        self.deleteButton.hidden = YES;
    }
    else if (displayMode == kChannelThumbnailDisplayModeDisplaySearch)
    {
        self.addItButton.hidden = NO;
        self.tap.enabled = TRUE;
        self.deleteButton.hidden = YES;
    }
    else if (displayMode == kChannelThumbnailDisplayModeEdit)
    {
        self.addItButton.hidden = YES;
        self.tap.enabled = NO;
        self.deleteButton.hidden = NO;
    }
    else if (displayMode == kChannelThumbnailDisplayModeDisplayFavourite)
    {
        self.addItButton.hidden = YES;
        self.tap.enabled = YES;
        self.deleteButton.hidden = YES;
    }
    else
    {
        AssertOrLog(@"Unexpected option");
    }
}


- (void) setViewControllerDelegate: (id<SYNVideoThumbnailRegularCellDelegate>) delegate
{
    _viewControllerDelegate = delegate;
    
    // Add button targets
    
    [self.deleteButton addTarget: self.viewControllerDelegate
                          action: @selector(videoDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [self.addItButton addTarget: self.viewControllerDelegate
                         action: @selector(videoAddButtonTapped:)
               forControlEvents: UIControlEventTouchUpInside];
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    [self.imageView.layer removeAllAnimations];
    [self.imageView setImageWithURL:nil];
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


- (void) showVideo: (UITapGestureRecognizer *) recognizer
{
    [self.viewControllerDelegate videoButtonPressed: self.addItButton];
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

@end
