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
@import QuartzCore;

#define kShowDescptionIPhone 250.0f
#define kShowDescptionIPad 230.0f

#define kShowDeleteIPhone 250.0f
#define kShowDeleteIPad 230.0f

@interface SYNChannelMidCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) SYNTouchGestureRecognizer *touch;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (nonatomic) BOOL descriptionMode;
@property (nonatomic) BOOL deleteMode;


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
        [self.followerCountLabel setFont:[UIFont lightCustomFontOfSize:10]];
        [self.videoCountLabel setFont:[UIFont lightCustomFontOfSize:10]];

        [self.descriptionLabel setFont:[UIFont lightCustomFontOfSize:10]];
        
      //  [self.boarderView.layer setBorderColor:[[UIColor grayColor]CGColor]];
      //  [self.boarderView.layer setBorderWidth:0.5f];
        [self.followButton.titleLabel setFont:[UIFont lightCustomFontOfSize:10]];
        
    }
    else
    {
        [self.videoTitleLabel setFont:[UIFont lightCustomFontOfSize:18]];
        [self.videoCountLabel setFont:[UIFont regularCustomFontOfSize:14]];
        [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:14]];
        [self.boarderView.layer setBorderColor:[[UIColor grayColor]CGColor]];
        
        if (IS_RETINA)
        {
            [self.boarderView.layer setBorderWidth:0.5f];
        }
        else
        {
            [self.boarderView.layer setBorderWidth:1.0f];
            
        }
        
    }
    
    self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDescriptionSwipe:)];
    [self.rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    self.rightSwipe.delegate = self;
    
    [self.containerView addGestureRecognizer:self.rightSwipe];
    
    self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [self.leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    self.leftSwipe.delegate = self;
    
    [self.containerView addGestureRecognizer:self.leftSwipe];
    self.deleteMode = NO;
    self.descriptionMode = NO;

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

-(void) setBottomBarColor:(UIColor*) color
{
    [self.bottomBarView setBackgroundColor:color];
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

- (IBAction)showDescriptionSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideAllDesciptions object:nil];

    if (self.deleteMode || self.descriptionMode) {
        [self moveToCentre];
    }
    else
    {
        [self showDescription];

    }
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)recognizer
{
 
    if (self.deleteMode || self.descriptionMode) {
        [self moveToCentre];
    }
    else
    {
       // [self showDelete];
    }
    
}

-(void) showDescription
{
    [UIView animateWithDuration:0.5f animations:^{
        if (self.containerView.frame.origin.x ==0)
        {
            CGRect tmpRect = self.containerView.frame;
            if (IS_IPHONE)
            {
                tmpRect.origin.x += kShowDescptionIPhone;
            }
            else
            {
                tmpRect.origin.x += kShowDescptionIPad;
            }
            self.containerView.frame = tmpRect;
            self.descriptionMode = YES;

        }
    }];
    

}

-(void) moveToCentre {
    [UIView animateWithDuration:0.5f animations:^{
        
        if (self.containerView.frame.origin.x !=0)
        {
            CGRect tmpRect = self.containerView.frame;
            
                tmpRect.origin.x = 0;
            self.containerView.frame = tmpRect;
            self.deleteMode = NO;
            self.descriptionMode = NO;

        }
    }];
}



-(void) showDelete{

    [UIView animateWithDuration:0.5f animations:^{
        
            CGRect tmpRect = self.containerView.frame;
            
            if (IS_IPHONE)
            {
                tmpRect.origin.x -= 50;
            }
            else
            {
                tmpRect.origin.x -= 50;
            }
            self.containerView.frame = tmpRect;
        self.deleteMode = YES;
    }];

    
}
- (IBAction)followChannel:(id)sender
{
    [self.viewControllerDelegate followButtonTapped: self];

   // [self showAlertView];
}


-(void) showAlertView{
    NSString *message = @"Are you sure you want to unfollow";
    
    message =  [message stringByAppendingString:@" "];

   message =  [message stringByAppendingString:self.channel.title];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Unfollow?" message:message delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    [alertView show];
}

- (NSString *) yesButtonTitle{
    return @"Yes";
}
- (NSString *) noButtonTitle{
    return @"Cancel";
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:[self yesButtonTitle]])
    {
        if (self.channel != nil)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: kChannelSubscribeRequest
                                                                object: self
                                                              userInfo: @{kChannel : self.channel}];
        }
    }
}



@end
