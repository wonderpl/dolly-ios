//
//  SYNChannelMidCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "AppConstants.h"
#import "SYNChannelMidCell.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import <UIImageView+WebCache.h>
@import QuartzCore;

#define kShowDescptionIPhone 250.0f
#define kShowDescptionIPad 230.0f

#define kShowDeleteIPhone 250.0f
#define kShowDeleteIPad 230.0f

@interface SYNChannelMidCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (nonatomic) BOOL descriptionMode;
@property (nonatomic) BOOL deleteMode;


@end

@implementation SYNChannelMidCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.followButton.titleLabel.font.pointSize];
  
    
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showChannel:)];
    self.tap.delegate = self;
    [self addGestureRecognizer: self.tap];
    
    if (IS_RETINA)
    {
        [self.boarderView.layer setBorderWidth:0.5f];
    }
    else
    {
        [self.boarderView.layer setBorderWidth:1.0f];
        
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
    
    [self.boarderView.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];

}

- (void) setViewControllerDelegate: (id<SYNChannelMidCellDelegate>)  viewControllerDelegate
{
    
    _viewControllerDelegate = viewControllerDelegate;
    
    if(!_viewControllerDelegate)
        return;
    
}




- (void) prepareForReuse
{
    
    self.videoCountLabel.text = @"";
    self.videoTitleLabel.text = @"";
    self.followerCountLabel.text = @"";
    self.descriptionLabel.text = @"";
    [self.boarderView.layer setBorderWidth:0.0f];
    self.bottomBarView.backgroundColor = [UIColor clearColor];
    self.followButton.hidden = YES;
    
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

- (void) setChannel:(Channel *)channel
{
    _channel = channel;
    if(!_channel)
    {
        self.videoTitleLabel.text = @"";
        return;
    }
    
    // TODO: figure out which color to put according to category color
    self.bottomBarView.backgroundColor = [UIColor grayColor];
    
    self.videoTitleLabel.text = _channel.title;
    
}

-(void) setHiddenForFollowButton: (BOOL) hide
{
    self.followButton.hidden = hide;
}



-(void) setFollowButtonLabel:(NSString*) strFollowLabel
{
    [self.followButton setTitle:strFollowLabel forState:UIControlStateNormal];
    
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
}

-(void) setBorder
{
    if (IS_IPAD){
        if (IS_RETINA)
        {
            [self.boarderView.layer setBorderWidth:0.5f];
        }
        else
        {
            [self.boarderView.layer setBorderWidth:1.0f];
        }
    }
}

@end
