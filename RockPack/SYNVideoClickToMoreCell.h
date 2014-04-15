//
//  SYNVideoClickToMoreCell.h
//  dolly
//
//  Created by Sherman Lo on 11/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNVideoClickToMoreCellDelegate <NSObject>

- (void)clickToMoreButtonPressed;

@end

@interface SYNVideoClickToMoreCell : UICollectionViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, weak) id<SYNVideoClickToMoreCellDelegate> delegate;

@end
