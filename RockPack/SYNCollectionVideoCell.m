//
//  SYNCollectionVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionVideoCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "NSString+Timecode.h"
#import <UIImageView+WebCache.h>
#import "SYNVideoActionsBar.h"
#import "UIColor+SYNColor.h"

@interface SYNCollectionVideoCell () <SYNVideoActionsBarDelegate>
@property (nonatomic, strong) SYNVideoActionsBar *actionsBar;
@property (strong, nonatomic) IBOutlet UIView *containerView;


@end

@implementation SYNCollectionVideoCell 

- (void)awakeFromNib{
    [super awakeFromNib];
    
	self.actionsBar.frame = self.videoActionsContainer.bounds;
	[self.videoActionsContainer addSubview:self.actionsBar];
	self.titleLabel.font = [UIFont boldCustomFontOfSize:self.titleLabel.font.pointSize];
	self.durationLabel.font = [UIFont regularCustomFontOfSize:self.durationLabel.font.pointSize];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                       action: @selector(showVideo)];

}

#pragma mark - Set Video Instance

- (void)setVideoInstance: (VideoInstance *) videoInstance{
    _videoInstance = videoInstance;
    
	self.durationLabel.text = [NSString friendlyLengthFromTimeInterval:videoInstance.video.durationValue];

    if (!_videoInstance)
        return;
    
    [self.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDImageCacheTypeNone];
    
    self.titleLabel.text = videoInstance.title;
    self.actionsBar.favouritedBy = [videoInstance.starrers array];
	self.actionsBar.favouriteButton.selected = videoInstance.starredByUserValue;

}

#pragma mark - Set delegate


- (void)setDelegate:(id<SYNCollectionVideoCellDelegate>)delegate {
    _delegate = delegate;
    
    //set an extra delete delegate
    [self.deleteButton addTarget:_delegate
                          action:@selector(deleteVideoInstancePressed:)
                   forControlEvents:UIControlEventTouchUpInside];

}

- (void)setUpVideoTap {
    [self.imageView addGestureRecognizer: self.tap];

}


- (SYNVideoActionsBar *)actionsBar {
	if (!_actionsBar) {
		SYNVideoActionsBar *bar = [SYNVideoActionsBar bar];
		bar.delegate = self;
		
		self.actionsBar = bar;
	}
	return _actionsBar;
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar favouritesButtonPressed:(UIButton *)button {
	[self.delegate videoCell:self favouritePressed:button];
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar addToChannelButtonPressed:(UIButton *)button {
	[self.delegate videoCell:self addToChannelPressed:button];
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar shareButtonPressed:(UIButton *)button {
	[self.delegate videoCell:self sharePressed:button];
}

- (void)showVideo {
    [self.delegate showVideoForCell:self];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    
    if (editable) {
        self.deleteButton.hidden = NO;
        self.removeVideoImage.hidden = NO;
		self.videoActionsContainer.hidden = YES;
        self.containerView.layer.borderColor = [[UIColor dollyRed] CGColor];
        self.containerView.layer.borderWidth = 1.0;
        self.containerView.layer.cornerRadius = 10;
        [self.imageView removeGestureRecognizer:self.tap];
        
    } else {
        self.deleteButton.hidden = YES;
        self.removeVideoImage.hidden = YES;
		self.videoActionsContainer.hidden = NO;
        self.containerView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.containerView.layer.borderWidth = 1.0;
        self.containerView.layer.cornerRadius = 0;
        [self.imageView addGestureRecognizer:self.tap];
        
	}
}

@end
