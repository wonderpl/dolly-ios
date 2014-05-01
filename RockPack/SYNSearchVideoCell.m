//
//  SYNSearchVideoCell.m
//  dolly
//
//  Created by Cong Le on 01/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNSearchVideoCell.h"
#import "VideoInstance.h"
#import "ChannelOwner.h"
#import "UIFont+SYNFont.h"
#import <UIImageView+WebCache.h>

@interface SYNSearchVideoCell ()

@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *originatorLabel;

@end

@implementation SYNSearchVideoCell


- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
	self.originatorLabel.font = [UIFont regularCustomFontOfSize:self.originatorLabel.font.pointSize];
	
	self.thumbnailImageView.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.05] CGColor];
	self.thumbnailImageView.layer.borderWidth = 1.0;

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

#pragma mark - SYNVideoInfoCell protocol

- (UIImageView *)imageView {
	return self.thumbnailImageView;
}



@end
