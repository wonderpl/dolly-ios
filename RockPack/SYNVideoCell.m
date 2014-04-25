//
//  SYNVideoCell.m
//  dolly
//
//  Created by Sherman Lo on 10/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoCell.h"
#import "VideoInstance.h"
#import "ChannelOwner.h"
#import "UIFont+SYNFont.h"
#import <UIImageView+WebCache.h>

@interface SYNVideoCell ()

@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *originatorLabel;

@end

@implementation SYNVideoCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
	self.originatorLabel.font = [UIFont regularCustomFontOfSize:self.originatorLabel.font.pointSize];
}

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
	
	[self.thumbnailImageView setImageWithURL:[NSURL URLWithString:videoInstance.thumbnailURL]];
	
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineHeightMultiple = 1.3;
	NSDictionary *attributes = @{ NSParagraphStyleAttributeName : paragraphStyle };
	
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:videoInstance.title
																		   attributes:attributes];
	
	self.titleLabel.attributedText = attributedString;
	self.originatorLabel.text = videoInstance.originator.displayName;
}

@end
