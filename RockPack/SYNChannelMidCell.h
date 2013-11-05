//
//  SYNChannelMidCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@protocol SYNChannelMidCellDelegate <NSObject>

- (void) channelTapped: (UICollectionViewCell *) cell;

@end


@interface SYNChannelMidCell : UICollectionViewCell

@property (nonatomic) BOOL specialSelected;
@property (nonatomic, weak) Channel* channel;

@property (strong, nonatomic) IBOutlet UILabel *videoCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (strong, nonatomic) IBOutlet UIView *bottomBarView;
@property (strong, nonatomic) IBOutlet UIView *boarderView;

@property (strong, nonatomic) IBOutlet UIButton *followButton;
// detail label for iphone, need better logic than this!!
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *descriptionView;

@property (nonatomic, weak) id<SYNChannelMidCellDelegate> viewControllerDelegate;
-(void) setFollowButtonLabel:(NSString*) strFollowLabel;

-(void) setTitle :(NSString*) titleString;
-(void) setHiddenForFollowButton: (BOOL) hide;




@end
