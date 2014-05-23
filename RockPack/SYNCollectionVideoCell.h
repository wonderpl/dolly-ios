//
//  SYNCollectionVideoCell.h
//  dolly
//
//  Created by Michael Michailidis on 06/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSocialAddButton.h"
#import "VideoInstance.h"
#import "SYNSocialActionsDelegate.h"
#import "SYNVideoInfoCell.h"

@class SYNCollectionVideoCell;

@protocol SYNCollectionVideoCellDelegate <NSObject>

- (void)videoCell:(SYNCollectionVideoCell *)cell favouritePressed:(UIButton *)button;
- (void)videoCell:(SYNCollectionVideoCell *)cell addToChannelPressed:(UIButton *)button;
- (void)videoCell:(SYNCollectionVideoCell *)cell sharePressed:(UIButton *)button;
- (void)showVideoForCell:(SYNCollectionVideoCell *)cell;
@end

@interface SYNCollectionVideoCell : UICollectionViewCell <SYNVideoInfoCell>
 
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIView *videoActionsContainer;
@property (strong, nonatomic) IBOutlet UIImageView *removeVideoImage;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) id<SYNCollectionVideoCellDelegate> delegate;
@property (nonatomic, weak) VideoInstance* videoInstance;


-(void) setUpVideoTap;


@end
