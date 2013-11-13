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
    
    self.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.followButton.titleLabel.font.pointSize];
  
    
    // Tap for showing video
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showChannel:)];
    self.tap.delegate = self;
    [self addGestureRecognizer: self.tap];
    
    // Touch for highlighting cells when the user touches them (like UIButton)
    self.touch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self action: @selector(showGlossLowlight:)];
    self.touch.delegate = self;
    self.specialSelected = NO;
    
    
    
    if (IS_RETINA)
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
    if(_viewControllerDelegate)
    {
        [self.followButton removeTarget:_viewControllerDelegate
                                 action:@selector(followButtonTapped:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    
    _viewControllerDelegate = viewControllerDelegate;
    
    if(!_viewControllerDelegate)
        return;
    
    [self.followButton addTarget:_viewControllerDelegate
                          action:@selector(followButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
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
    
    // [self showAlertView];
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

-(void) showAlertView{
    NSString *message = @"Are you sure you want to unfollow";
    
    message =  [message stringByAppendingString:@" "];
    
    message =  [message stringByAppendingString:self.channel.title];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Unfollow?" message:message delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    
    [alertView show];
}

- (NSString *) yesButtonTitle
{
    return @"Yes";
}
- (NSString *) noButtonTitle
{
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

-(void) reset
{
    self.videoCountLabel.text = @"";
    self.videoTitleLabel.text = @"";
    self.followerCountLabel.text = @"";
    self.descriptionLabel.text = @"";
    [self.boarderView.layer setBorderWidth:0.0f];
    self.bottomBarView.backgroundColor = [UIColor clearColor];
    self.followButton.hidden = YES;
}

@end
