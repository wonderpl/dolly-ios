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
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNGenreColorManager.h"

@import QuartzCore;

#define kShowDescptionIPhone 320.0f
#define kShowDescptionIPad 280.0f

#define kShowDeleteIPhone 250.0f
#define kShowDeleteIPad 230.0f

@interface SYNChannelMidCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, strong) IBOutlet UIView *separatorView;

@end

@implementation SYNChannelMidCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.followButton.titleLabel.font.pointSize];
    
    if (IS_RETINA)
    {
        [self.boarderView.layer setBorderWidth:0.5f];
    }
    else
    {
        [self.boarderView.layer setBorderWidth:1.0f];
        
    }
    
    self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [self.rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    self.rightSwipe.delegate = self;
    
    [self.containerView addGestureRecognizer:self.rightSwipe];
    
    self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [self.leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    self.leftSwipe.delegate = self;
    
    [self.containerView addGestureRecognizer:self.leftSwipe];
    
    [self.boarderView.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];
    
    self.state = ChannelMidCellStateDefault;
    
    [self.deleteButton.titleLabel setFont:[UIFont lightCustomFontOfSize:19]];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitle:NSLocalizedString(@"Delete?", nil) forState:UIControlStateNormal];
    
    self.deletableCell = NO;
    
    
    if (IS_IPHONE)
    {
        [self.descriptionLabel setFont:[UIFont lightCustomFontOfSize:14]];
    }
    else
    {
        [self.descriptionLabel setFont:[UIFont lightCustomFontOfSize:14]];
    }
    
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
    self.deletableCell = NO;
    
    
    
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

- (void) setChannel:(Channel *)channel
{
    _channel = channel;
    if(!_channel)
    {
        self.videoTitleLabel.text = @"";
		self.separatorView.hidden = YES;
        return;
    }
	
    
    
    if (channel.subscribersCountValue == 1) {
        self.followerCountLabel.text = [NSString stringWithFormat: @"%@ %@", channel.subscribersCount, NSLocalizedString(@"Follower", nil)];

    }
    else
    {
        self.followerCountLabel.text = [NSString stringWithFormat: @"%@ %@", channel.subscribersCount, NSLocalizedString(@"Subscribers", nil)];
    }
    
    if (channel.totalVideosValueValue == 1) {
        self.videoCountLabel.text = [NSString stringWithFormat:@"%@ %@",channel.totalVideosValue, NSLocalizedString(@"Video", nil)];
        
    }
    else
    {
        self.videoCountLabel.text = [NSString stringWithFormat:@"%@ %@",channel.totalVideosValue, NSLocalizedString(@"Videos", nil)];
	}
	self.descriptionLabel.text = channel.channelDescription;
    
    
    self.videoTitleLabel.text =  [channel.title uppercaseString];
    
    [self.videoTitleLabel setFont:[UIFont regularCustomFontOfSize:self.videoTitleLabel.font.pointSize]];
    
    [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];
    
    [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];
    
    [self setBorder];
	
	[self setCategoryColor:[[SYNGenreColorManager sharedInstance] colorFromID:channel.categoryId]];

	self.separatorView.hidden = NO;

}

-(void) setFollowButtonLabel:(NSString*) strFollowLabel
{
    [self.followButton setTitle:strFollowLabel forState:UIControlStateNormal];
    
}

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    if (!self.showsDescriptionOnSwipe) {
		return;
	}
	
    if (self.state == ChannelMidCellStateDefault) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideAllDesciptions object:nil];
        
        [self setState:ChannelMidCellStateDescription withAnimation:YES];
        
    }
    else {
        
        if (self.state == ChannelMidCellStateDescription) {
            
            [self setState:ChannelMidCellStateDefault withAnimation:YES];

        }
        else if(self.state == ChannelMidCellStateDelete){
            [self setState:ChannelMidCellStateDefault withAnimation:YES];

        }
    }
}
- (IBAction)deleteChannel:(id)sender {
    [self.viewControllerDelegate deleteChannelTapped: self];
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)recognizer
{
    if (self.state == ChannelMidCellStateDefault) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideAllDesciptions object:nil];
        
        [self setState:ChannelMidCellStateDelete withAnimation:YES];

    }
    else{
        
        if (self.state == ChannelMidCellStateDelete) {
            [self setState:ChannelMidCellStateDefault withAnimation:YES];

        }else if(self.state == ChannelMidCellStateDescription){
            [self setState:ChannelMidCellStateDefault withAnimation:YES];
            
        }}
    
}
- (IBAction)followChannel:(id)sender
{
    [self.viewControllerDelegate followButtonTapped: self];
}

-(void) setBorder
{
    
    if (IS_RETINA)
    {
        [self.boarderView.layer setBorderWidth:0.5f];
    }
    else
    {
        [self.boarderView.layer setBorderWidth:1.0f];
    }

}


-(void)setState:(ChannelMidCellState)state
{
    _state = state;
    switch (_state)
    {
        case ChannelMidCellStateDefault:
        {
            
                CGRect tmpRect = self.containerView.frame;
                tmpRect.origin.x = 0;
                self.containerView.frame = tmpRect;
                
            
        }
            
            break;
        case ChannelMidCellStateDelete:{
            //Not all channels can be deleted
            //Only channels you own are deleteable
            if (self.deletableCell) {
                self.deleteButton.hidden = NO;
                self.descriptionLabel.hidden = YES;
                
                    CGRect tmpRect = self.containerView.frame;
                    
                    if (IS_IPHONE)
                    {
                        tmpRect.origin.x = -120;
                    }
                    else
                    {
                        tmpRect.origin.x = -120;
                    }
                    self.containerView.frame = tmpRect;
                
            }
            
        }
            
            break;
        case ChannelMidCellStateDescription:
        {
            
            self.deleteButton.hidden = YES;
            self.descriptionLabel.hidden = NO;
                CGRect tmpRect = self.containerView.frame;
                if (IS_IPHONE)
                {
                    tmpRect.origin.x = kShowDescptionIPhone;
                }
                else
                {
                    tmpRect.origin.x = kShowDescptionIPad;
                }
                self.containerView.frame = tmpRect;
        }
            break;
    }

    
}

-(void)setState:(ChannelMidCellState)state withAnimation:(BOOL) animated
{
    
    if (!animated) {
        _state = state;
        return;
    }
    _state = state;
    switch (_state)
    {
        case ChannelMidCellStateDefault:
        {
            [UIView animateWithDuration:0.5f animations:^{
                
                CGRect tmpRect = self.containerView.frame;
                tmpRect.origin.x = 0;
                self.containerView.frame = tmpRect;
                
            }];
            
        }
            
            break;
        case ChannelMidCellStateDelete:{
            //Not all channels can be deleted
            //Only channels you own are deleteable
            if (self.deletableCell) {
            self.deleteButton.hidden = NO;
            self.descriptionLabel.hidden = YES;
            [UIView animateWithDuration:0.5f animations:^{
                
                CGRect tmpRect = self.containerView.frame;
                
                if (IS_IPHONE)
                {
                    tmpRect.origin.x = -120;
                }
                else
                {
                    tmpRect.origin.x = -120;
                }
                self.containerView.frame = tmpRect;
            }];
            
            }
            
        }
            
            break;
        case ChannelMidCellStateDescription:
        {
            
            self.deleteButton.hidden = YES;
            self.descriptionLabel.hidden = NO;
            [UIView animateWithDuration:0.5f animations:^{
                CGRect tmpRect = self.containerView.frame;
                if (IS_IPHONE)
                {
                    tmpRect.origin.x = kShowDescptionIPhone;
                }
                else
                {
                    tmpRect.origin.x = kShowDescptionIPad;
                }
                self.containerView.frame = tmpRect;
            }];
            
        }
            break;
    }
    
}

-(void) setCategoryColor: (UIColor*) color
{
    [self.bottomBarView setBackgroundColor:color];
    [self.boarderView setBackgroundColor:color];
    [self.descriptionLabel setBackgroundColor:color];
}


-(void) inboardingAnimationFromMode:(ProfileType) type {
    
    if (type == kModeOtherUsersProfile) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect tmpRect = self.containerView.frame;
            if (IS_IPHONE)
            {
                tmpRect.origin.x += 30;
            }
            else
            {
                tmpRect.origin.x += 30;
            }
            self.containerView.frame = tmpRect;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect tmpRect = self.containerView.frame;
                if (IS_IPHONE)
                {
                    tmpRect.origin.x -= 30;
                }
                else
                {
                    tmpRect.origin.x -= 30;
                }
                self.containerView.frame = tmpRect;
                
            }];
            
        }];

    } else if (type == kModeMyOwnProfile) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect tmpRect = self.containerView.frame;
            
            if (IS_IPHONE)
            {
                tmpRect.origin.x += 30;
            }
            else
            {
                tmpRect.origin.x += 30;
            }
            self.containerView.frame = tmpRect;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect tmpRect = self.containerView.frame;
                if (IS_IPHONE)
                {
                    tmpRect.origin.x -= 60;
                }
                else
                {
                    tmpRect.origin.x -= 60;
                }
                self.containerView.frame = tmpRect;
                
                self.descriptionLabel.hidden=YES;
            } completion:^(BOOL finished) {
                
                
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect tmpRect = self.containerView.frame;
                    if (IS_IPHONE)
                    {
                        tmpRect.origin.x += 30;
                    }
                    else
                    {
                        tmpRect.origin.x += 30;
                    }
                    self.containerView.frame = tmpRect;
                } completion:^(BOOL finished) {
                    self.descriptionLabel.hidden=YES;
                }];
            }];
            
        }];
    }
    
}


@end
