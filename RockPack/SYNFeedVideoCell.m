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
#import "SYNActivityManager.h"
#import "SYNFollowUserButton.h"
#import "UIColor+SYNColor.h"


static NSString *const HTMLTemplateFilename = @"VideoDescriptionTemplate";

@interface SYNFeedVideoCell () <SYNVideoActionsBarDelegate>

@property (nonatomic, strong) IBOutlet UIButton *avatarThumbnailButton;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet SYNFollowUserButton *followButton;

@property (nonatomic, strong) IBOutlet UILabel *labelLabel;
@property (nonatomic, strong) IBOutlet UIButton *curatedByButton;
@property (strong, nonatomic) IBOutlet UIButton *clickToMoreButton;

@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, strong) IBOutlet UIButton *videoThumbnailButton;

@property (nonatomic, strong) IBOutlet UIView *videoActionsContainer;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) SYNVideoActionsBar *actionsBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstantTop;
@property (strong, nonatomic) IBOutlet UILabel *originatorDisplayNameLabel;

@end

@implementation SYNFeedVideoCell

- (void)awakeFromNib {
	[super awakeFromNib];
    [self.curatedByButton.titleLabel setFont:[UIFont regularCustomFontOfSize: self.curatedByButton.titleLabel.font.pointSize]];
    
    if (IS_IPAD) {
        [self.labelLabel setFont:[UIFont regularCustomFontOfSize: self.labelLabel.font.pointSize]];
        self.durationLabel.font = [UIFont regularCustomFontOfSize:self.durationLabel.font.pointSize];
        [self.descriptionLabel setFont:[UIFont lightCustomFontOfSize:self.descriptionLabel.font.pointSize]];

    } else {
        [self.labelLabel setFont:[UIFont semiboldCustomFontOfSize: self.labelLabel.font.pointSize]];
        self.durationLabel.font = [UIFont semiboldCustomFontOfSize:self.durationLabel.font.pointSize];
        [self.descriptionLabel setFont:[UIFont lightCustomFontOfSize:self.descriptionLabel.font.pointSize]];
    }

	

    if (IS_IPHONE) {
        [self.titleLabel setFont:[UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize]];
    } else {
        [self.titleLabel setFont:[UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize]];

    }
	
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
    self.actionsBar.frame = self.videoActionsContainer.bounds;


}

- (UIImageView *)imageView {
	return self.videoThumbnailButton.imageView;
}

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
	
	self.durationLabel.text = [NSString friendlyLengthFromTimeInterval:videoInstance.video.durationValue];
    
    [self.titleLabel setText:videoInstance.title];// = [self attributedStringFromString: videoInstance.title withLineHeight:8];
	
    if (self.videoInstance.video.videoDescription.length > 0) {
        [self.descriptionLabel setAttributedText:[self attributedStringFromString:[self.videoInstance.video.videoDescription stringByStrippingHTML] withLineHeight:12]];
        [self.heightConstantTop setConstant:17];

    } else {
        [self.heightConstantTop setConstant:2];
    }
    
    [self layoutIfNeeded];
    
    if (IS_IPHONE) {
        if (self.videoInstance.video.videoDescription.length > 0) {
            self.titleLabel.numberOfLines = 2;
            [self.descriptionLabel setAttributedText:[self attributedStringFromString:[self.videoInstance.video.videoDescription stringByStrippingHTML] withLineHeight:2]];
        } else {
            
//            self.titleLabel.numberOfLines = 4;
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
    self.videoThumbnailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.videoThumbnailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;

	[self.videoThumbnailButton setImageWithURL:thumbnailURL forState:UIControlStateNormal];
    [self.videoThumbnailButton setContentMode:UIViewContentModeScaleToFill];

    [self.videoThumbnailButton setContentScaleFactor:1.3];

    self.actionsBar.favouritedBy = [videoInstance.starrers array];
    
    
    
    
	self.actionsBar.favouriteButton.selected = videoInstance.starredByUserValue;
    self.actionsBar.frame = self.videoActionsContainer.bounds;
    [self.actionsBar layoutIfNeeded];
    
    
    NSLog(@"ddddd %@", self.videoInstance.originator.displayName);
    
    [self.originatorDisplayNameLabel setText:self.videoInstance.originator.displayName];
    
    [self.originatorDisplayNameLabel setFont:[UIFont regularCustomFontOfSize:self.originatorDisplayNameLabel.font.pointSize]];
 
   self.followButton.selected = [[SYNActivityManager sharedInstance] isSubscribedToUserId:self.videoInstance.originator.uniqueId];
    
    
    
    self.clickToMoreButton.layer.cornerRadius = (CGRectGetHeight(self.clickToMoreButton.frame) / 2.0);
	self.clickToMoreButton.layer.borderColor = [[UIColor dollyButtonGreenColor] CGColor];
	self.clickToMoreButton.layer.borderWidth = 1.0;
	
	self.clickToMoreButton.tintColor = [UIColor dollyButtonGreenColor];

    self.clickToMoreButton.hidden = ([self.videoInstance.video.linkTitle length] == 0);
	[self.clickToMoreButton setTitle:self.videoInstance.video.linkTitle forState:UIControlStateNormal];

}


- (void) setVideoLabelWithColor:(UIColor*) textColor{
    
    BOOL hasLabel = ([self.videoInstance.label length]);
	if (hasLabel) {
		self.labelLabel.text = [self.videoInstance.label uppercaseString];
		[self.curatedByButton setAttributedTitle:nil forState:UIControlStateNormal];
	} else {
		self.labelLabel.text = nil;
		
		NSString *channelOwnerName = self.videoInstance.channel.channelOwner.displayName;
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont semiboldCustomFontOfSize:self.labelLabel.font.pointSize],
                                      NSForegroundColorAttributeName : textColor};
		
        if (!channelOwnerName) {
			channelOwnerName = @"";
        }
        
        NSAttributedString *curatedByString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"ADDED BY %@", [channelOwnerName uppercaseString]] attributes:attributes ];
		[self.curatedByButton setAttributedTitle:curatedByString forState:UIControlStateNormal];
    }

}

- (void)setDarkView {
    
    [self setBackgroundColor:[UIColor blackColor]];
	NSURL *thumbnailURL = [NSURL URLWithString:self.videoInstance.thumbnailURL];
	[self.videoThumbnailButton setImageWithURL:thumbnailURL forState:UIControlStateNormal];
//    [self.videoThumbnailButton setContentMode:UIViewContentModeScaleToFill];
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
    
    [self.durationLabel setTextColor:[UIColor colorWithRed: 112.0f / 255.0f
                                                    green: 121.0f / 255.0f
                                                     blue: 123.0f / 255.0f
                                                     alpha: 1.0f]];
    
    [self.titleLabel setTextColor:[UIColor colorWithRed: 46.0f / 255.0f
                                                  green: 46.0f / 255.0f
                                                   blue: 50.0f / 255.0f
                                                  alpha: 1.0f]];
    
    [self.descriptionLabel setTextColor:[UIColor colorWithRed: 46.0f / 255.0f
                                                        green: 46.0f / 255.0f
                                                         blue: 50.0f / 255.0f
                                                        alpha: 1.0f]];
    
    
    [self setVideoLabelWithColor: [UIColor colorWithRed: 112.0f / 255.0f
                                                  green: 121.0f / 255.0f
                                                   blue: 123.0f / 255.0f
                                                  alpha: 1.0f]];

    [self.originatorDisplayNameLabel setTextColor:[UIColor colorWithRed: 46.0f / 255.0f
                                                                 green: 46.0f / 255.0f
                                                                  blue: 50.0f / 255.0f
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
	style.lineBreakMode = NSLineBreakByWordWrapping;
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
