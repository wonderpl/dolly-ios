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
#import <UIImageView+WebCache.h>
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNGenreManager.h"
#import "SYNActivityManager.h"
#import "UIColor+SYNColor.h"


@import QuartzCore;

#define kShowDescptionIPhone 320.0f
#define kShowDescptionIPad 280.0f

#define kShowDeleteIPhone 250.0f
#define kShowDeleteIPad 230.0f
#define kShowInboardingAnimationDistance 30.0f
#define kShowInboardingAnimationTime 0.3f


@interface SYNChannelMidCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIView *separatorView;

@end

@implementation SYNChannelMidCell

- (void)awakeFromNib {
	
    [super awakeFromNib];
    
    self.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.followButton.titleLabel.font.pointSize];
    
	[self.view.layer setBorderWidth:IS_RETINA ? 0.5 : 1.0];
    
    self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [self.rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    self.rightSwipe.delegate = self;
    
    [self.view addGestureRecognizer:self.rightSwipe];
    
    self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [self.leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    self.leftSwipe.delegate = self;
    
    [self.view addGestureRecognizer:self.leftSwipe];
    
    [self.view.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];
    
    self.state = ChannelMidCellStateDefault;
    
    [self.deleteButton.titleLabel setFont:[UIFont lightCustomFontOfSize:19]];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitle:NSLocalizedString(@"Delete?", nil) forState:UIControlStateNormal];
    
    self.deletableCell = NO;
    
    if (IS_IPHONE) {
        [self.descriptionLabel setFont:[UIFont lightCustomFontOfSize:self.descriptionLabel.font.pointSize]];
        [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];
    } else {
        [self.descriptionLabel setFont:[UIFont lightCustomFontOfSize:self.descriptionLabel.font.pointSize]];
        [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];
    }
	
	self.descriptionLabel.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];

	self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    
    self.selected = NO;

    self.isFromProfile = NO;

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

}

- (void)setViewControllerDelegate: (id<SYNChannelMidCellDelegate>)  viewControllerDelegate {
    _viewControllerDelegate = viewControllerDelegate;
}

- (void)prepareForReuse {
    self.videoTitleLabel.text = @"";
    self.followerCountLabel.text = @"";
    self.descriptionLabel.text = @"";
    [self.view.layer setBorderWidth:0.0f];
    self.deletableCell = NO;
    self.selected = NO;

}

#pragma mark - Gesture regognizer support

// Required to pass through events to controls overlaid on view with gesture recognizers
- (BOOL)gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch: (UITouch *) touch {
    if ([touch.view isKindOfClass: [UIControl class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    
    return YES; // handle the touch
}

- (void)setChannel:(Channel *)channel {
    _channel = channel;
    if(!_channel) {
        self.videoTitleLabel.text = @"";
		self.separatorView.hidden = YES;
        return;
    }
    
	
	NSString *labelText = @"";
	
    if (channel.subscribersCountValue == 1) {
        labelText = [NSString stringWithFormat: @"%@ %@", channel.subscribersCount, NSLocalizedString(@"Follower", nil)];
		
    } else {
        
        if (channel.subscribersCount<0) {
            channel.subscribersCount = 0;
        }
        
        labelText = [NSString stringWithFormat: @"%@ %@", channel.subscribersCount, NSLocalizedString(@"Subscribers", nil)];
    }
    
    if (channel.totalVideosValueValue == 1) {
        labelText = [NSString stringWithFormat:@"%@   |   %@ %@", labelText, channel.totalVideosValue, NSLocalizedString(@"Video", nil)];
    } else {
        labelText = [NSString stringWithFormat:@"%@   |   %@ %@", labelText, channel.totalVideosValue, NSLocalizedString(@"Videos", nil)];
	}
	
	
	self.followerCountLabel.text = labelText;
	
	self.descriptionLabel.text = channel.channelDescription;
    self.videoTitleLabel.text =  channel.title;
    [self.videoTitleLabel setFont:[UIFont boldCustomFontOfSize:self.videoTitleLabel.font.pointSize]];
    [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];
    [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];
    [self setBorder];
	
	self.separatorView.hidden = NO;
	
	self.followButton.selected = [[SYNActivityManager sharedInstance] isSubscribedToChannelId:self.channel.uniqueId];
	
}

- (void)setFollowButtonLabel:(NSString*) strFollowLabel {
    [self.followButton setTitle:strFollowLabel forState:UIControlStateNormal];
}

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)recognizer {
	
    if (!self.isFromProfile) {
        return;
    }

    if (self.state == ChannelMidCellStateDefault) {
		[self.viewControllerDelegate cellStateChanged];
        [self setState:ChannelMidCellStateDescription withAnimation:YES];
		
    }
    else {
		if(self.state == ChannelMidCellStateDelete){
            [self setState:ChannelMidCellStateDefault withAnimation:YES];
			
        }
    }
}

- (IBAction)leftSwipe:(UISwipeGestureRecognizer *)recognizer {
    
    if (!self.isFromProfile) {
        return;
    }

    if (self.state == ChannelMidCellStateDefault) {
		[self.viewControllerDelegate cellStateChanged];
        [self setState:ChannelMidCellStateDelete withAnimation:YES];
    }
    else{
		if(self.state == ChannelMidCellStateDescription){
            [self setState:ChannelMidCellStateDefault withAnimation:YES];
        }}
    
}

- (IBAction)deleteChannel:(id)sender {
    [self.viewControllerDelegate deleteChannelTapped: self];
}

- (IBAction)followChannel:(id)sender {
    [self.viewControllerDelegate followButtonTapped:self];
}

- (void)setBorder {
    if (IS_RETINA) {
        [self.view.layer setBorderWidth:0.5f];
    } else {
        [self.view.layer setBorderWidth:1.0f];
    }
}


- (void)setState:(ChannelMidCellState)state {
	if (state == _state) {
		return;
	}
    _state = state;
    switch (_state) {
        case ChannelMidCellStateDefault: {
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
				
				tmpRect.origin.x = tmpRect.size.width-120;
				self.containerView.frame = tmpRect;
                
            }
        }
            
            break;
        case ChannelMidCellStateDescription: {
            self.deleteButton.hidden = YES;
            self.descriptionLabel.hidden = NO;
			CGRect tmpRect = self.containerView.frame;
			if (IS_IPHONE) {
				tmpRect.origin.x = kShowDescptionIPhone;
			} else {
				tmpRect.origin.x = kShowDescptionIPad;
			}
			self.containerView.frame = tmpRect;
        }
            break;
            
        case ChannelMidCellStateAnimating: {
            
        }
            break;
    }
}

- (void)setState:(ChannelMidCellState)state withAnimation:(BOOL) animated {
    
	_state = state;
	
    if (!animated) {
        return;
    }
	
	
    switch (state) {
        case ChannelMidCellStateDefault: {
            [UIView animateWithDuration:0.5f animations:^{
                CGRect tmpRect = self.containerView.frame;
                tmpRect.origin.x = 0;
                self.containerView.frame = tmpRect;
            }];
        }
            
            break;
        case ChannelMidCellStateDelete: {
            //Not all channels can be deleted
            //Only channels you own are deleteable
            if (self.deletableCell) {
				self.deleteButton.hidden = NO;
				self.descriptionLabel.hidden = YES;
                
				
				[UIView animateWithDuration:0.5f animations:^{
					CGRect tmpRect = self.containerView.frame;
					tmpRect.origin.x = -120;
					self.containerView.frame = tmpRect;
				}];
            }
            
        }
            
            break;
        case ChannelMidCellStateDescription: {

            self.deleteButton.hidden = YES;
            self.descriptionLabel.hidden = NO;
            [UIView animateWithDuration:0.5f animations:^{
                CGRect tmpRect = self.containerView.frame;
                if (IS_IPHONE) {
                    tmpRect.origin.x = kShowDescptionIPhone;
                } else {
                    tmpRect.origin.x = kShowDescptionIPad;
                }
                self.containerView.frame = tmpRect;
            }];
        }
            break;
        case ChannelMidCellStateAnimating: {
			
        }
            break;
    }
	_state = state;
}


- (void)descriptionAnimation {
    self.state = ChannelMidCellStateAnimating;
	
    float iphoneValue = 250;
    float ipadValue = 230;
	__block CGRect tmpRect = self.containerView.frame;
	
    self.deleteButton.hidden = YES;
    [UIView animateWithDuration:2.0 animations:^{
        
        if (IS_IPHONE)
        {
            tmpRect.origin.x += iphoneValue;
        }
        else
        {
            tmpRect.origin.x += ipadValue;
        }
        self.containerView.frame = tmpRect;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0 animations:^{
            CGRect tmpRect = self.containerView.frame;
            if (IS_IPHONE)
            {
                tmpRect.origin.x -= iphoneValue;
            }
            else
            {
                tmpRect.origin.x -= ipadValue;
            }
            self.containerView.frame = tmpRect;
            
        } completion:^(BOOL finished) {
            self.deleteButton.hidden = NO;
            [self setState:ChannelMidCellStateDefault withAnimation:NO];
			
        }];
    }];
}


- (void)descriptionAndDeleteAnimation {
    __block CGRect tmpRect = self.containerView.frame;
	
    self.state = ChannelMidCellStateAnimating;
    
    [UIView animateWithDuration:1.5 animations:^{
        
        if (IS_IPHONE)
        {
            tmpRect.origin.x += 250;
        }
        else
        {
            tmpRect.origin.x += 230;
        }
        self.containerView.frame = tmpRect;
    }  completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0f animations:^{
            CGRect tmpRect = self.containerView.frame;
            if (IS_IPHONE)
            {
                tmpRect.origin.x -= 250;
            }
            else
            {
                tmpRect.origin.x -= 230;
            }
            self.containerView.frame = tmpRect;
			
        } completion:^(BOOL finished) {
			
            self.descriptionLabel.hidden = YES;
            
            [UIView animateWithDuration:1.0 animations:^{
                CGRect tmpRect = self.containerView.frame;
				tmpRect.origin.x -= 120;
                self.containerView.frame = tmpRect;
				
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1.4f animations:^{
                    CGRect tmpRect = self.containerView.frame;
					tmpRect.origin.x += 120;
                    self.containerView.frame = tmpRect;
                } completion:^(BOOL finished) {
                    [self setState:ChannelMidCellStateDefault withAnimation:NO];
                }];
				
            }];
            
        }];
        
    }];
}

-(void)setSelected:(BOOL)selected
{
    
    if (_selected == selected) {
        return;
    }
    _selected = selected;
	
    
    if (self.isFromProfile) {
        return;
    }
    if (selected) {
			self.videoTitleLabel.textColor = [UIColor whiteColor];
			self.followerCountLabel.textColor = [UIColor whiteColor];
            self.containerView.backgroundColor = [UIColor dollyBlue];
    } else {
			self.videoTitleLabel.textColor = [UIColor blackColor];
			self.followerCountLabel.textColor = [UIColor colorWithRed: 175.0f / 255.0f
                                                                green: 175.0f / 255.0f
                                                                 blue: 181.0f / 255.0f
                                                                alpha: 1.0f];
			self.containerView.backgroundColor = [UIColor whiteColor];
    }
    
}

-(BOOL)isSelected
{
    return _selected;
}


@end
