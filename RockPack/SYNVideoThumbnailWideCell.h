//
//  SYNThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "VideoInstance.h"
@import UIKit;

typedef enum : NSInteger {
    kVideoThumbnailDisplayModeChannel = 0,
    kVideoThumbnailDisplayModeYoutube = 1
} kVideoThumbnailDisplayMode;

@protocol SYNVideoThumbnailWideCellDelegate <NSObject>

- (void) videoAddButtonTapped: (UIButton *) videoButton;

@end

@interface SYNVideoThumbnailWideCell : UICollectionViewCell

@property (nonatomic) kVideoThumbnailDisplayMode displayMode;
@property (nonatomic, strong) IBOutlet UIButton *addItButton;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UIImageView *videoImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelName;
@property (nonatomic, strong) IBOutlet UILabel *dateAddedLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfViewLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoTitle;
@property (nonatomic, strong) IBOutlet UIView *channelShadowView;
@property (nonatomic, strong) IBOutlet UIView* channelInfoView;
@property (nonatomic, strong) IBOutlet UIView* videoInfoView;
@property (nonatomic, weak) NSString* channelNameText;
@property (nonatomic, weak) NSString* usernameText;
@property (nonatomic, weak) VideoInstance* videoInstance;
@property (nonatomic, weak) id<SYNVideoThumbnailWideCellDelegate> viewControllerDelegate;
@property (weak, nonatomic) IBOutlet UILabel *youTubeUserLabel;

@end
