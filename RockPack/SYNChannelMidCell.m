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

#define SHOW_DESCRIPTION_AMOUNT 225.0f

@interface SYNChannelMidCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;


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
  //  [self addGestureRecognizer: self.longPress];
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
    
    if (IS_IPHONE)
    {
        [self.videoTitleLabel setFont:[UIFont lightCustomFontOfSize:19]];
        [self.detailsLabel setFont:[UIFont lightCustomFontOfSize:10]];
        
        [self.boarderView.layer setBorderColor:[[UIColor grayColor]CGColor]];
        [self.boarderView.layer setBorderWidth:0.5f];
        [self.followButton.titleLabel setFont:[UIFont lightCustomFontOfSize:10]];
        
    }
    else
    {
        [self.videoTitleLabel setFont:[UIFont lightCustomFontOfSize:18]];
        [self.videoCountLabel setFont:[UIFont regularCustomFontOfSize:14]];
        [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:14]];
        [self.boarderView.layer setBorderColor:[[UIColor grayColor]CGColor]];
        [self.boarderView.layer setBorderWidth:.5f];
        
    }
    
    self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDescription:)];
    [self.rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    self.rightSwipe.delegate = self;

    [self.containerView addGestureRecognizer:self.rightSwipe];

    self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideDescription:)];
    [self.leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    self.leftSwipe.delegate = self;
    
    [self.containerView addGestureRecognizer:self.leftSwipe];
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

-(void) setHiddenForFollowButton: (BOOL) hide
{
    self.followButton.hidden = hide;
}

-(void) setTitle :(NSString*) titleString
{
    [self.videoTitleLabel setText:titleString];
}

-(void) setFollowButtonLabel:(NSString*) strFollowLabel
{
        [self.followButton setTitle:strFollowLabel forState:UIControlStateNormal];
        [self.followButton.titleLabel setFont:[UIFont lightCustomFontOfSize:10]];
}

- (IBAction)showDescription:(UISwipeGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.5f animations:^{
        if (self.containerView.frame.origin.x ==0)
        {
            CGRect tmpRect = self.containerView.frame;
            tmpRect.origin.x += SHOW_DESCRIPTION_AMOUNT;

            self.containerView.frame = tmpRect;
        }
    }];
}

- (IBAction)hideDescription:(UISwipeGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.5f animations:^{
        
        if (self.containerView.frame.origin.x !=0)
        {
            CGRect tmpRect = self.containerView.frame;
            tmpRect.origin.x -= SHOW_DESCRIPTION_AMOUNT;

            self.containerView.frame = tmpRect;
            
        }
    }];
    
    
}

- (IBAction)followChannel:(id)sender
{
    if (self.channel != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                            object: self
                                                          userInfo: @{kChannel : self.channel}];
    }
}


@end
