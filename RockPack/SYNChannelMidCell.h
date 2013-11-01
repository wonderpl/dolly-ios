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

@property (nonatomic, weak) id<SYNChannelMidCellDelegate> viewControllerDelegate;
-(void) setFollowButtonLabel: (ProfileType) profile;

-(void) setTitle :(NSString*) titleString;
-(void) setHiddenForFollowButton: (BOOL) hide;




@end
