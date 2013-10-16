//
//  SYNChannelThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>


@interface SYNChannelThumbnailCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;
@property (nonatomic, strong) IBOutlet UILabel *byLabel;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end


@implementation SYNChannelThumbnailCell

- (void) awakeFromNib
{
    [super awakeFromNib];

    
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showChannel:)];
    self.tap.delegate = self;
    [self addGestureRecognizer: self.tap];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    // Touch for highlighting cells when the user touches them (like UIButton)
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(showGlossLowlight:)];
    
    self.touch.delegate = self;
    [self addGestureRecognizer: self.touch];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    self.displayNameLabel.font = [UIFont rockpackFontOfSize: self.displayNameLabel.font.pointSize];
    self.byLabel.font = [UIFont rockpackFontOfSize: self.byLabel.font.pointSize];
    
    self.deleteButton.hidden = YES;
    
    
    if (IS_IOS_7_OR_GREATER) {
        self.displayNameLabel.frame = CGRectMake(self.displayNameLabel.frame.origin.x, self.displayNameLabel.frame.origin.y - 1.0f, self.displayNameLabel.frame.size.width, self.displayNameLabel.frame.size.height);
    }
}


- (void) showDeleteButton: (BOOL) showDeleteButton
{
    self.deleteButton.hidden = showDeleteButton ? FALSE : TRUE;
}


- (void) setViewControllerDelegate: (id<SYNChannelThumbnailCellDelegate>) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    
    [self.displayNameButton addTarget: self.viewControllerDelegate
                               action: @selector(displayNameButtonPressed:)
                     forControlEvents: UIControlEventTouchUpInside];
    
    [self.deleteButton addTarget: self.viewControllerDelegate
                          action: @selector(channelDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
}


- (void) setChannelTitle: (NSString *) titleString
{
    CGRect titleFrame = self.titleLabel.frame;
    
    CGSize expectedSize = [titleString sizeWithFont: self.titleLabel.font
                                  constrainedToSize: CGSizeMake(titleFrame.size.width, 500.0)
                                      lineBreakMode: self.titleLabel.lineBreakMode];
    
    titleFrame.size.height = expectedSize.height;
    titleFrame.origin.y = self.imageView.frame.size.height - titleFrame.size.height - 4.0;
    
    self.titleLabel.frame = titleFrame;
    
    
    self.titleLabel.text = titleString;
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    [self.imageView.layer removeAllAnimations];
    [self.layer removeAllAnimations];
    
    [self.imageView setImageWithURL: nil];
    
    self.deleteButton.hidden = TRUE;
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


- (void) showChannel: (UITapGestureRecognizer *) recognizer
{
    // Just need to reference any button in the cell (as there is no longer an actual video button)
    [self.viewControllerDelegate channelTapped: self];
}



// This is used to lowlight the gloss image on touch
- (void) showGlossLowlight: (SYNTouchGestureRecognizer *) recognizer
{
    // Default iPad gloss image
    NSString *imageName = @"GlossChannelThumbnail";
    
    // Use different image for iPhone
    if (IS_IPHONE)
    {
       imageName = @"GlossChannelProfile";
    }

    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // Set lowlight tint
            UIImage *glossImage = [UIImage imageNamed: imageName];
            UIImage *lowlightImage = [glossImage tintedImageUsingColor: [UIColor colorWithWhite: 0.0
                                                                                          alpha: 0.3]];
            self.lowlightImageView.image = lowlightImage;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.lowlightImageView.image = [UIImage imageNamed: imageName];
        }
        default:
            break;
    }
}

@end
