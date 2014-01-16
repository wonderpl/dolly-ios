//
//  SYNExampleUserCell.m
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNExampleUserCell.h"
#import "UIFont+SYNFont.h"

@interface SYNExampleUserCell ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

@end

@implementation SYNExampleUserCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame) / 2.0;
	self.imageView.layer.masksToBounds = YES;
	
	self.nameLabel.font = [UIFont lightCustomFontOfSize:self.nameLabel.font.pointSize];
	self.descriptionLabel.font = [UIFont lightCustomFontOfSize:self.descriptionLabel.font.pointSize];
}

@end
