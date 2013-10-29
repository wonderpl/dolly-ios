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

@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (strong, nonatomic) IBOutlet UILabel *videoCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (strong, nonatomic) IBOutlet UIView *bottomBarView;
@property (strong, nonatomic) IBOutlet UIView *boarderView;

@property (strong, nonatomic) IBOutlet UIButton *followButton;
// detail label for iphone, need better logic than this!!
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;

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
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self action: @selector(showGlossLowlight:)];
    self.touch.delegate = self;
   // [self addGestureRecognizer: self.touch];
    self.specialSelected = NO;
    
    // Required to make cells look good when wobbling (delete)
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = UIScreen.mainScreen.scale;
    
    if (IS_IPHONE) {
        [self.videoTitleLabel setFont:[UIFont lightCustomFontOfSize:19]];
        [self.detailsLabel setFont:[UIFont lightCustomFontOfSize:10]];
        
        [self.boarderView.layer setBorderColor:[[UIColor grayColor]CGColor]];
        [self.boarderView.layer setBorderWidth:1.0f];

        
    }else{
        [self.videoTitleLabel setFont:[UIFont lightCustomFontOfSize:18]];
        [self.videoCountLabel setFont:[UIFont regularCustomFontOfSize:14]];
        [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:14]];
        [self.boarderView.layer setBorderColor:[[UIColor grayColor]CGColor]];
        [self.boarderView.layer setBorderWidth:1.0f];
        
    }
    
}

- (void) setViewControllerDelegate: (id<SYNChannelMidCellDelegate>)  viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
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
    
   // [self.imageView.layer removeAllAnimations];
    //[self.imageView setImageWithURL: nil];
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

@end
