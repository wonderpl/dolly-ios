//
//  SYNChannelThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 11/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@protocol SYNChannelThumbnailCellDelegate <NSObject>

- (void) channelTapped: (UICollectionViewCell *) cell;

@end


@interface SYNChannelThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton *displayNameButton;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView* shadowOverlayImageView;
@property (nonatomic, strong) IBOutlet UILabel *displayNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString* imageUrlString;
@property (nonatomic, weak) Channel* channel;
@property (nonatomic, weak) id<SYNChannelThumbnailCellDelegate> viewControllerDelegate;

- (void) setChannelTitle: (NSString*) titleString;
- (void) showDeleteButton: (BOOL) showDeleteButton;

@end
