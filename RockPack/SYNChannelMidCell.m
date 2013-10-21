//
//  SYNChannelMidCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "AppConstants.h"
#import "SYNChannelMidCell.h"
#import "SYNDeletionWobbleLayoutAttributes.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelMidCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *lowlightImageView;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end


@implementation SYNChannelMidCell

@synthesize specialSelected;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
#ifdef ENABLE_ARC_MENU
    
    // Add long-press and tap recognizers (once only per cell)
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                   action: @selector(showMenu:)];
    self.longPress.delegate = self;
    [self addGestureRecognizer: self.longPress];
#endif
    
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showChannel:)];
    self.tap.delegate = self;
    [self addGestureRecognizer: self.tap];
    
    // Touch for highlighting cells when the user touches them (like UIButton)
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(showGlossLowlight:)];
    self.touch.delegate = self;
    [self addGestureRecognizer: self.touch];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    self.specialSelected = NO;
    self.deleteButton.layer.opacity = 0.0f;
    
    // Required to make cells look good when wobbling (delete)
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
}


- (void) setChannelTitle: (NSString*) titleString
{
    CGFloat originalWidth = self.titleLabel.frame.size.width;
    
    self.titleLabel.text = titleString;
    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    
    titleFrame.size.width = originalWidth;
    titleFrame.origin.y = self.imageView.frame.size.height - (IS_IOS_7_OR_GREATER ? 8.0f : 0.0f) -titleFrame.size.height + 2.0;
    
    self.titleLabel.frame = titleFrame;
    
}


- (void) setViewControllerDelegate: (id<SYNChannelMidCellDelegate>)  viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    [self.deleteButton addTarget: viewControllerDelegate
                          action: @selector(channelDeleteButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
}


- (void) setSpecialSelected: (BOOL)value
{
    if(value)
    {
        self.panelSelectedImageView.hidden = NO;
    }
    else
    {
        self.panelSelectedImageView.hidden = YES;
    }
}


- (BOOL) specialSelected
{
    return !self.panelSelectedImageView.hidden;
}


#pragma mark - Cell deletion support
#pragma mark Attributes

- (void) applyLayoutAttributes: (SYNDeletionWobbleLayoutAttributes *) layoutAttributes
{
    /*
    if (layoutAttributes.isDeleteButtonHidden || self.deleteButton.enabled == FALSE)
    {
        self.deleteButton.layer.opacity = 0.0;
        [self stopWobbling];
    }
    else
    {
        self.deleteButton.layer.opacity = 1.0;
        [self startWobbling];
    }*/
}


#pragma mark Wobble animations

- (void) startWobbling
{
    // Rotation maths
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath: @"transform.rotation"];
    float startAngle = M_PI/180.0;
    float stopAngle = -startAngle;
    
    // Setup animation
    quiverAnim.fromValue = @(startAngle);
    quiverAnim.toValue = @(stopAngle);
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.2;
    quiverAnim.repeatCount = HUGE_VALF;
    
    // Add a random time offset to stop all cells wobbling in harmony
    float timeOffset = (float)(arc4random() % 100)/100 - 0.50;
    quiverAnim.timeOffset = timeOffset;
    CALayer *layer = self.layer;
    
    // Add the animation to our layer
    [layer addAnimation: quiverAnim
                 forKey: @"wobbling"];
}


- (void) stopWobbling
{
    // Remove the animation from the layer
    CALayer *layer = self.layer;
    [layer removeAnimationForKey: @"wobbling"];
}


- (void) prepareForReuse
{
    [self stopWobbling];
    
    [self.imageView.layer removeAllAnimations];
    [self.imageView setImageWithURL: nil];
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
    NSString *imageName = @"GlossChannelMid";
    
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
