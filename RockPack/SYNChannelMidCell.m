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

@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

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
    [self.deleteButton setTitle:NSLocalizedString(@"Delete ?", nil) forState:UIControlStateNormal];
    
    self.deletableCell = NO;
    
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
    
    self.videoTitleLabel.text = [_channel.title uppercaseString];
    [self.videoTitleLabel setFont:[UIFont regularCustomFontOfSize:self.videoTitleLabel.font.pointSize]];
    
    [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];
    
    [self.followerCountLabel setFont:[UIFont regularCustomFontOfSize:self.followerCountLabel.font.pointSize]];

}

-(void) setFollowButtonLabel:(NSString*) strFollowLabel
{
    [self.followButton setTitle:strFollowLabel forState:UIControlStateNormal];
    
}

- (IBAction)rightSwipe:(UISwipeGestureRecognizer *)recognizer
{
    
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


@end
