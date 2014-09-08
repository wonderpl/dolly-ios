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
#import "SYNYouTubeWebVideoPlayer.h"
#import "NSString+StrippingHTML.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Blur.h"
#import "SYNActivityManager.h"
#import "SYNFollowChannelButton.h"
#import "UIColor+SYNColor.h"


static NSString *const HTMLTemplateFilename = @"VideoDescriptionTemplate";

@interface SYNFeedVideoCell () <SYNVideoActionsBarDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;
@property (nonatomic, strong) IBOutlet UIButton *avatarThumbnailButton;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet SYNFollowChannelButton *followButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoTopSpace;

@property (nonatomic, strong) IBOutlet UILabel *labelLabel;
@property (nonatomic, strong) IBOutlet UIButton *curatedByButton;
@property (nonatomic, strong) IBOutlet UIButton *clickToMoreButton;

@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;

@property (nonatomic, strong) IBOutlet UIButton *videoThumbnailButton;

@property (nonatomic, strong) IBOutlet UIView *videoActionsContainer;

@property (nonatomic, strong) SYNVideoActionsBar *actionsBar;

@property (strong, nonatomic) IBOutlet UILabel *originatorDisplayNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *favouriteButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoHeight;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *clickToMoreHeight;
@property (strong, nonatomic) IBOutlet UIButton *loveButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoConstantLeft;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *videoConstantRight;

@end

@implementation SYNFeedVideoCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
    [self.curatedByButton.titleLabel setFont:[UIFont regularCustomFontOfSize: self.curatedByButton.titleLabel.font.pointSize]];
    
    if (IS_IPAD) {
        [self.labelLabel setFont:[UIFont semiboldCustomFontOfSize: self.labelLabel.font.pointSize]];
        self.durationLabel.font = [UIFont semiboldCustomFontOfSize:self.durationLabel.font.pointSize];
        [self.descriptionTextView setFont:[UIFont lightCustomFontOfSize:self.descriptionTextView.font.pointSize]];

    } else {
        [self.labelLabel setFont:[UIFont semiboldCustomFontOfSize: self.labelLabel.font.pointSize]];
        self.durationLabel.font = [UIFont semiboldCustomFontOfSize:self.durationLabel.font.pointSize];
        [self.descriptionTextView setFont:[UIFont lightCustomFontOfSize:self.descriptionTextView.font.pointSize]];
    }

    [self.titleLabel setFont:[UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize]];
	
	self.actionsBar.frame = self.videoActionsContainer.bounds;
	[self.videoActionsContainer addSubview:self.actionsBar];
	
	self.videoThumbnailButton.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.05] CGColor];
	self.videoThumbnailButton.layer.borderWidth = 1.0;
    
    self.videoPlayerCell.hidden = YES;
    self.playButton.hidden = NO;

    if (IS_IPHONE) {
        [self.actionsBar feedBar];
    }
    
    [self.descriptionTopConstraint setConstant:0];
    
    self.clickToMoreButton.layer.cornerRadius = (CGRectGetHeight(self.clickToMoreButton.frame) / 2.0);
	self.clickToMoreButton.layer.borderColor = [[UIColor dollyButtonGreenColor] CGColor];
	self.clickToMoreButton.layer.borderWidth = 1.0;
	
	self.clickToMoreButton.tintColor = [UIColor dollyButtonGreenColor];
    [self.clickToMoreButton.titleLabel setFont:[UIFont regularCustomFontOfSize:self.clickToMoreButton.titleLabel.font.pointSize]];

    self.videoThumbnailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.videoThumbnailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.videoThumbnailButton setContentMode:UIViewContentModeScaleToFill];
    
    [self.originatorDisplayNameLabel setFont:[UIFont regularCustomFontOfSize:self.originatorDisplayNameLabel.font.pointSize]];
    [self setVideoSizeConstant];
}


- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    [self setVideoSizeConstant];
    
}
- (void)prepareForReuse {
    [super prepareForReuse];
    self.playButton.hidden = NO;
    self.videoPlayerCell.hidden = YES;
    self.descriptionTextView.text = @"";
    [self setVideoSizeConstant];

}


- (void) setVideoSizeConstant {
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [self.videoConstantLeft setConstant:46];
        [self.videoConstantRight setConstant:46];
        self.actionsBar.frame = CGRectMake(0, 0, 694, 36);

    } else {
        [self.videoConstantLeft setConstant:130];
        [self.videoConstantRight setConstant:130];
        self.actionsBar.frame = CGRectMake(0, 0, 782, 36);

    }
}

- (UIImageView *)imageView {
	return self.videoThumbnailButton.imageView;
}

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
    
    [self.titleLabel setText:videoInstance.title];
    self.labelLabel.text = videoInstance.label;
    self.durationLabel.text = [NSString friendlyLengthFromTimeInterval:videoInstance.video.durationValue];

    if (self.videoInstance.video.videoDescription.length > 0) {
        
        //TODO: Counting characters is not goog enough, need to check for new lines aswell. eg. lists.
        NSString *descriptionText = [self.videoInstance.video.videoDescription stringByStrippingHTML];
        
        int maxStringLength = IS_IPHONE ? 90 : 170;
        
        int stringLength = [descriptionText length] > maxStringLength ? maxStringLength : [descriptionText length];
        NSString *shortDescription = [descriptionText substringToIndex:  stringLength];
        
        NSString *trimmedString = [shortDescription stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSString *endString = @"See More";
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@... %@", trimmedString, endString]];
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"continue//:"
                                 range:[[attributedString string] rangeOfString:endString]];
        
        [attributedString addAttribute:NSFontAttributeName
                      value:[UIFont lightCustomFontOfSize:self.descriptionTextView.font.pointSize]
                      range:NSMakeRange(0, stringLength)];

        
        if ([descriptionText length] > maxStringLength) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont regularCustomFontOfSize:self.descriptionTextView.font.pointSize]
                                     range:[[attributedString string] rangeOfString:endString]];
        }
        
        [self attributedString:attributedString withLineHeight:2];
        
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor dollyGreen],
                                         NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
        
        self.descriptionTextView.linkTextAttributes = linkAttributes;
        self.descriptionTextView.attributedText = attributedString;
        self.descriptionTextView.delegate = self;
        
        [self.descriptionTextView setScrollEnabled:NO];

    }
    
    if (IS_IPHONE) {
        if (self.videoInstance.video.videoDescription.length > 0) {
            self.titleLabel.numberOfLines = 2;
//            [self.descriptionLabel setAttributedText:[self attributedStringFromString:[self.videoInstance.video.videoDescription stringByStrippingHTML] withLineHeight:2]];
        }
    }

	NSURL *avatarURL = [NSURL URLWithString:self.videoInstance.originator.thumbnailURL];
	[self.avatarThumbnailButton setImageWithURL:avatarURL
									   forState:UIControlStateNormal
							   placeholderImage:[UIImage imageNamed:@"PlaceholderAvatarProfile"]
										options:SDWebImageRetryFailed];
    
    NSURL *thumbnailURL = [NSURL URLWithString:videoInstance.thumbnailURL];
	[self.videoThumbnailButton setImageWithURL:thumbnailURL forState:UIControlStateNormal];
    [self.videoThumbnailButton setContentScaleFactor:1.3];

    self.actionsBar.favouritedBy = [videoInstance.starrers array];
	self.actionsBar.favouriteButton.selected = videoInstance.starredByUserValue;
    
    [self.originatorDisplayNameLabel setText:self.videoInstance.originator.displayName];
 
    self.followButton.selected = [[SYNActivityManager sharedInstance] isSubscribedToUserId:self.videoInstance.originator.uniqueId];
    
    BOOL isClickToMoreHidden = ([self.videoInstance.video.linkTitle length] == 0);
    BOOL hasDescription = [self.videoInstance.video.videoDescription length];
    BOOL hasClickToMore = [self.videoInstance.video.linkTitle length];

    self.clickToMoreButton.hidden = isClickToMoreHidden;
	[self.clickToMoreButton setTitle:self.videoInstance.video.linkTitle forState:UIControlStateNormal];
    
    if (isClickToMoreHidden == YES) {

        BOOL isFavouritedByFriends = [[videoInstance.starrers array] count] > 0;
        if (isFavouritedByFriends == YES) {
            [self.descriptionTopConstraint setConstant:-10];
        } else {
                [self.descriptionTopConstraint setConstant:-30];
        }
        
    } else {
        [self.descriptionTopConstraint setConstant:30];
    }

    BOOL hasLabel = ([self.videoInstance.label length]);
	if (hasLabel) {
		self.labelLabel.text = [self.videoInstance.label uppercaseString];
		[self.curatedByButton setAttributedTitle:nil forState:UIControlStateNormal];
	} else {
		self.labelLabel.text = nil;
		
		NSString *channelOwnerName = self.videoInstance.channel.channelOwner.displayName;
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont semiboldCustomFontOfSize:self.labelLabel.font.pointSize],
                                      NSForegroundColorAttributeName : [UIColor colorWithRed: 112.0f / 255.0f
                                                                                       green: 121.0f / 255.0f
                                                                                        blue: 123.0f / 255.0f
                                                                                       alpha: 1.0f]};
		
        if (!channelOwnerName) {
			channelOwnerName = @"";
        }
        
        NSMutableAttributedString *curatedByString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"ADDED BY %@", [channelOwnerName uppercaseString]] attributes:attributes ];
		[self.curatedByButton setAttributedTitle:curatedByString forState:UIControlStateNormal];

	}
    
    [self.durationLabel setTextColor:[UIColor colorWithRed: 112.0f / 255.0f
                                                    green: 121.0f / 255.0f
                                                     blue: 123.0f / 255.0f
                                                     alpha: 1.0f]];

    if (IS_IPHONE) {
        if (!hasDescription && !hasClickToMore) {
//            [self.videoTopSpace setConstant:20];
            self.titleLabel.numberOfLines = 3;
        } else {
//            [self.videoTopSpace setConstant:5];
            self.titleLabel.numberOfLines = 2;
            
        }
	}
    
}

-(NSMutableAttributedString*) attributedStringFromString:(NSString *) string {
	
	if (!string) {
		return [[NSMutableAttributedString alloc] initWithString: @""];
	}
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: string];
	
	NSInteger strLength = [attributedString length];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineBreakMode = NSLineBreakByWordWrapping;
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

- (IBAction)playVideo:(id)sender {
    self.videoPlayerCell.hidden = NO;
    self.playButton.hidden = YES;
    [self.delegate videoCellThumbnailPressed:self];
}

-(NSMutableAttributedString*) attributedString:(NSMutableAttributedString *)string withLineHeight:(int) lineHeight{
	
    if (!string) {
		return [[NSMutableAttributedString alloc] initWithString: @""];
	}
    
	NSInteger strLength = [string length];
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.lineBreakMode = NSLineBreakByWordWrapping;
	[style setLineSpacing:lineHeight];
	[style setAlignment:NSTextAlignmentLeft];
	
	[string addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, strLength)];
	return string;
}
- (IBAction)addButtonTapped:(id)sender {
    [self.delegate videoCell:self addToChannelPressed:sender];
}

- (IBAction)favouriteButtonTapped:(id)sender {
    [self.delegate videoCell:self favouritePressed:sender];
}

- (IBAction)shareButtonTapped:(id)sender {
    [self.delegate videoCell:self sharePressed:sender];
}

- (IBAction)clickToMoreTapped:(id)sender {
    [self.delegate videoCell:self clickToMorePressed:sender];
}

- (IBAction)followButtonTapped:(id)sender {
    [self.delegate videoCell:self followButtonPressed:sender];

}
- (IBAction)descriptionButtonTapped:(id)sender {
    [self.delegate videoCell:self descriptionButtonTapped:sender];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
	[self.delegate videoCell:self descriptionButtonTapped:nil];
    return NO;
}

@end
