//
//  SYNChannelMidCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "Channel.h"
@import UIKit;

@protocol SYNChannelMidCellDelegate <NSObject>

- (void) channelTapped: (UICollectionViewCell *) cell;
- (void) followButtonTapped: (UICollectionViewCell *) cell;
- (void) deleteButtonTapped: (UICollectionViewCell *) cell;


typedef enum {
    
    ChannelMidCellStateDefault = 0,
    ChannelMidCellStateDescription = 1,
    ChannelMidCellStateDelete = 2
    
} ChannelMidCellState;

@end


@interface SYNChannelMidCell : UICollectionViewCell

@property (nonatomic, weak) Channel* channel;
@property (nonatomic) BOOL deletableCell;

@property (strong, nonatomic) IBOutlet UILabel *videoCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (strong, nonatomic) IBOutlet UIView *bottomBarView;
@property (strong, nonatomic) IBOutlet UIView *boarderView;
@property (nonatomic) ChannelMidCellState state;

@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, weak) id<SYNChannelMidCellDelegate> viewControllerDelegate;
-(void) setFollowButtonLabel:(NSString*) strFollowLabel;
-(void) setHiddenForFollowButton: (BOOL) hide;
-(void) setBorder;


@end
