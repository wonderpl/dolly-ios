//
//  SYNFeedVideoCell.m
//  dolly
//
//  Created by Sherman Lo on 15/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFeedVideoCell.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import "Video.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSString+Timecode.h"
#import "SYNVideoActionsBar.h"
#import <UIButton+WebCache.h>
#import "NSString+StrippingHTML.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Blur.h"

static NSString *const HTMLTemplateFilename = @"VideoDescriptionTemplate";

@interface SYNFeedVideoCell () <SYNVideoActionsBarDelegate>

@property (nonatomic, strong) IBOutlet UIButton *avatarThumbnailButton;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) IBOutlet UILabel *labelLabel;
@property (nonatomic, strong) IBOutlet UIButton *curatedByButton;

@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, strong) IBOutlet UIButton *videoThumbnailButton;

@property (nonatomic, strong) IBOutlet UIView *videoActionsContainer;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) SYNVideoActionsBar *actionsBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstantTop;

@end

@implementation SYNFeedVideoCell

- (void)awakeFromNib {
	[super awakeFromNib];

	self.labelLabel.font = [UIFont italicAlternateFontOfSize:self.labelLabel.font.pointSize];
    
    [self.curatedByButton.titleLabel setFont:[UIFont regularAlternateFontOfSize: self.curatedByButton.titleLabel.font.pointSize]];
    [self.labelLabel setFont:[UIFont regularAlternateFontOfSize: self.labelLabel.font.pointSize]];

	
    self.durationLabel.font = [UIFont regularCustomFontOfSize:self.durationLabel.font.pointSize];
    
    if (IS_IPHONE) {
        [self.descriptionLabel setFont:[UIFont regularAlternateFontOfSize:self.descriptionLabel.font.pointSize]];
    } else {
        [self.descriptionLabel setFont:[UIFont regularCustomFontOfSize:self.descriptionLabel.font.pointSize]];
    }

    [self.titleLabel setFont:[UIFont boldCustomFontOfSize:self.titleLabel.font.pointSize]];
	
	self.actionsBar.frame = self.videoActionsContainer.bounds;
	[self.videoActionsContainer addSubview:self.actionsBar];
	
	self.videoThumbnailButton.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.05] CGColor];
	self.videoThumbnailButton.layer.borderWidth = 1.0;

}

- (void) prepareForReuse {
    [super prepareForReuse];
    [self.heightConstantTop setConstant:18];
    [self setBackgroundColor:[UIColor whiteColor]];
    self.backgroundImage.image = [UIImage new];
    [self.descriptionLabel setText: @""];

}

- (UIImageView *)imageView {
	return self.videoThumbnailButton.imageView;
}

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
	
	self.durationLabel.text = [NSString friendlyLengthFromTimeInterval:videoInstance.video.durationValue];
	self.titleLabel.attributedText = [self attributedStringFromString: videoInstance.title withLineHeight:8];
	
    if (self.videoInstance.video.videoDescription.length > 0) {
        [self.descriptionLabel setAttributedText:[self attributedStringFromString:[self.videoInstance.video.videoDescription stringByStrippingHTML] withLineHeight:1.5]];
        [self.heightConstantTop setConstant:17];

    } else {
        [self.heightConstantTop setConstant:2];
    }
    
    [self layoutIfNeeded];
    
    if (IS_IPHONE) {
        if (self.videoInstance.video.videoDescription.length > 0) {
            self.titleLabel.numberOfLines = 2;
            [self.descriptionLabel setText:[self.videoInstance.video.videoDescription stringByStrippingHTML]];
        } else {
            
            self.titleLabel.numberOfLines = 4;
            [self.heightConstantTop setConstant:8];
            [self layoutIfNeeded];
        }
    }
    
	NSURL *avatarURL = [NSURL URLWithString:self.videoInstance.originator.thumbnailURL];
	[self.avatarThumbnailButton setImageWithURL:avatarURL
									   forState:UIControlStateNormal
							   placeholderImage:[UIImage imageNamed:@"PlaceholderAvatarProfile"]
										options:SDWebImageRetryFailed];
	
	NSURL *thumbnailURL = [NSURL URLWithString:videoInstance.thumbnailURL];
	[self.videoThumbnailButton setImageWithURL:thumbnailURL forState:UIControlStateNormal];
    self.actionsBar.favouritedBy = [videoInstance.starrers array];
	self.actionsBar.favouriteButton.selected = videoInstance.starredByUserValue;
}


- (void) setVideoLabelWithColor:(UIColor*) textColor{
    
    BOOL hasLabel = ([self.videoInstance.label length]);
	if (hasLabel) {
		self.labelLabel.text = self.videoInstance.label;
		
		[self.curatedByButton setAttributedTitle:nil forState:UIControlStateNormal];
	} else {
		self.labelLabel.text = nil;
		
		NSString *channelOwnerName = self.videoInstance.channel.channelOwner.displayName;
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont regularAlternateFontOfSize:self.labelLabel.font.pointSize],
                                      NSForegroundColorAttributeName : textColor};
		
        if (!channelOwnerName) {
			channelOwnerName = @"";
        }
        
        NSAttributedString *curatedByString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Added by %@", channelOwnerName] attributes:attributes ];
		[self.curatedByButton setAttributedTitle:curatedByString forState:UIControlStateNormal];
    }

}

- (void)setDarkView {
    
    [self setBackgroundColor:[UIColor blackColor]];
	NSURL *thumbnailURL = [NSURL URLWithString:self.videoInstance.thumbnailURL];
	[self.videoThumbnailButton setImageWithURL:thumbnailURL forState:UIControlStateNormal];
	[self.backgroundImage setImageWithURL:thumbnailURL];
    UIImage *blurredImage = [UIImage blurredImageFromImage:self.backgroundImage.image blurValue:@4.0];
    [self.backgroundImage setImage:blurredImage];
    
    [self.curatedByButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.labelLabel setTextColor:[UIColor whiteColor]];
    [self.durationLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.descriptionLabel setTextColor:[UIColor whiteColor]];
    [self setVideoLabelWithColor: [UIColor whiteColor]];
    [self.actionsBar setLightAssets];
    
}

- (void)setLightView {
    [self.curatedByButton setTitleColor:[UIColor colorWithRed: 112.0f / 255.0f
                                                        green: 121.0f / 255.0f
                                                         blue: 123.0f / 255.0f
                                                        alpha: 1.0f] forState:UIControlStateNormal];
    
    [self.labelLabel setTextColor:[UIColor colorWithRed: 112.0f / 255.0f
                                                  green: 121.0f / 255.0f
                                                   blue: 123.0f / 255.0f
                                                  alpha: 1.0f]];
    
    [self.durationLabel setTextColor:[UIColor colorWithRed: 183.0f / 255.0f
                                                     green: 188.0f / 255.0f
                                                      blue: 189.0f / 255.0f
                                                     alpha: 1.0f]];
    
    if (IS_IPHONE) {
        [self.titleLabel setTextColor:[UIColor colorWithRed: 46.0f / 255.0f
                                                      green: 46.0f / 255.0f
                                                       blue: 50.0f / 255.0f
                                                      alpha: 1.0f]];        
    }
    
    [self.descriptionLabel setTextColor:[UIColor colorWithRed: 46.0f / 255.0f
                                                        green: 46.0f / 255.0f
                                                         blue: 50.0f / 255.0f
                                                        alpha: 1.0f]];
    
    
    [self setVideoLabelWithColor: [UIColor colorWithRed: 112.0f / 255.0f
                           green: 121.0f / 255.0f
                            blue: 123.0f / 255.0f
                           alpha: 1.0f]];

    
    [self.actionsBar setDarkAssets];
    
    
}

//TODO: make into category
-(NSMutableAttributedString*) attributedStringFromString:(NSString *) string withLineHeight:(int) lineHeight{
	
    if (!string) {
		return [[NSMutableAttributedString alloc] initWithString: @""];
	}
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: string];
	
	NSInteger strLength = [attributedString length];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineBreakMode = NSLineBreakByTruncatingTail;
	[style setLineSpacing:lineHeight];
	[style setAlignment:NSTextAlignmentLeft];
	
	[attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, strLength)];
	return attributedString;

    
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

- (IBAction)avatarThumbnailPressed:(UIButton *)button {
	[self.delegate videoCellAvatarPressed:self];
}

- (IBAction)videoThumbnailPressed:(UIButton *)button {
	[self.delegate videoCellThumbnailPressed:self];
}

- (IBAction)addedByPressed:(UIButton *)button {
	[self.delegate videoCell:self addedByPressed:button];
}

@end
