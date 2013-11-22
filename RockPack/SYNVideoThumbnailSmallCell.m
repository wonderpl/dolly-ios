//
//  SYNVideoThumbnailSmallCell.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNVideoThumbnailSmallCell.h"
#import "UIFont+SYNFont.h"
#import <UIImageView+WebCache.h>

@interface SYNVideoThumbnailSmallCell ()

@property (nonatomic, strong) IBOutlet UIImageView *colourImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end


@implementation SYNVideoThumbnailSmallCell

#pragma mark - Public class

+ (UINib *)nib {
	return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

#pragma mark - Public

- (void)setImageWithURL:(NSString *)urlString {
	[self.colourImageView setImageWithURL:[NSURL URLWithString:urlString]];
}

#pragma mark - Overridden

- (void)awakeFromNib {
	[super awakeFromNib];

	self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
}

- (void)prepareForReuse {
	[self.colourImageView cancelCurrentImageLoad];
	
	self.colourImageView.image = nil;
}

@end
