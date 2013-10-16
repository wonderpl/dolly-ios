//
//  SYNVideoThumbnailRegularCell.h
//  rockpack
//
//  Created by Nick Banks on 03/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    kChannelThumbnailDisplayModeDisplay = 0,
    kChannelThumbnailDisplayModeEdit = 1,
    kChannelThumbnailDisplayModeDisplayFavourite = 2,
    kChannelThumbnailDisplayModeDisplaySearch = 3
} kChannelThumbnailDisplayMode;

@protocol SYNVideoThumbnailRegularCellDelegate <NSObject>

- (void) videoButtonPressed: (UIButton *) videoButton;


@end

@interface SYNVideoThumbnailRegularCell : UICollectionViewCell

@property (nonatomic) kChannelThumbnailDisplayMode displayMode;
@property (nonatomic, strong) IBOutlet UIButton *addItButton;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) id<SYNVideoThumbnailRegularCellDelegate> viewControllerDelegate;

@end
