//
//  SYNVideoActionsCell.h
//  dolly
//
//  Created by Sherman Lo on 11/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNVideoActionsDelegate <NSObject>

- (void)videoActionsFavouritePressed;
- (void)videoActionsAddToChannelPressed;
- (void)videoActionsSharePressed;

@end

@interface SYNVideoActionsCell : UICollectionViewCell

@property (nonatomic, weak) id<SYNVideoActionsDelegate> delegate;

@end
