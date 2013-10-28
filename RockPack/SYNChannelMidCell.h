//
//  SYNChannelMidCell.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNChannelMidCellDelegate <NSObject>

- (void) channelTapped: (UICollectionViewCell *) cell;

@end


@interface SYNChannelMidCell : UICollectionViewCell

@property (nonatomic) BOOL specialSelected;
@property (nonatomic, weak) id<SYNChannelMidCellDelegate> viewControllerDelegate;





@end
