//
//  SYNThumbnailCell.h
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoInstance.h"

typedef enum : NSInteger {
    kVideoThumbnailDisplayModeChannel = 0,
    kVideoThumbnailDisplayModeYoutube = 1
} kVideoThumbnailDisplayMode;

@protocol SYNVideoThumbnailWideCellDelegate <NSObject>

- (void) videoAddButtonTapped: (UIButton *) videoButton;

- (void) arcMenuSelectedCell: (UICollectionViewCell *) selectedCell
           andComponentIndex: (NSInteger) componentIndex;

- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer;

@end

@interface SYNVideoThumbnailWideCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *videoImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UIView *channelShadowView;
@property (nonatomic, strong) IBOutlet UILabel *videoTitle;
@property (nonatomic, strong) IBOutlet UILabel *channelName;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UIButton *addItButton;
@property (nonatomic, strong) IBOutlet UIView* channelInfoView;
@property (nonatomic, strong) IBOutlet UIView* videoInfoView;


@property (nonatomic, strong) IBOutlet UILabel *numberOfViewLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateAddedLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *youTubeUserLabel;

@property (nonatomic, weak) VideoInstance* videoInstance;

@property (nonatomic, weak) NSString* usernameText;
@property (nonatomic, weak) NSString* channelNameText;

@property (nonatomic) kVideoThumbnailDisplayMode displayMode;

// This is used to indicate the UIViewController that 
@property (nonatomic, weak) id<SYNVideoThumbnailWideCellDelegate> viewControllerDelegate;

@end
