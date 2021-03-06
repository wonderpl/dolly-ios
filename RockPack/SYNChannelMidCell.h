//
//  SYNChannelMidCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Channel.h"
#import "SYNSocialButton.h"
@import UIKit;

@class SYNChannelMidCell;

@protocol SYNChannelMidCellDelegate <NSObject>

@optional
- (void) cellStateChanged;
- (void) followButtonTapped:(SYNChannelMidCell *)cell;
- (void) deleteChannelTapped:(SYNChannelMidCell *)cell;


typedef enum {
    
    ChannelMidCellStateDefault = 0,
    ChannelMidCellStateDescription = 1,
    ChannelMidCellStateDelete = 2,
    ChannelMidCellStateAnimating = 3

    
} ChannelMidCellState;

@end


@interface SYNChannelMidCell : UICollectionViewCell{
    BOOL _selected;
}

@property (nonatomic, weak) Channel* channel;
@property (nonatomic) BOOL deletableCell;
@property (nonatomic, assign) BOOL showsDescriptionOnSwipe;

@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic) ChannelMidCellState state;
@property (assign, nonatomic) BOOL isFromProfile;

@property (strong, nonatomic) IBOutlet SYNSocialButton *followButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, weak) id<SYNChannelMidCellDelegate> viewControllerDelegate;
-(void) setFollowButtonLabel:(NSString*) strFollowLabel;
-(void) setBorder;
-(void) setState:(ChannelMidCellState)state withAnimation:(BOOL) animated;
-(void) descriptionAndDeleteAnimation;
-(void) descriptionAnimation;

@end
