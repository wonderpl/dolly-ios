//
//  SYNButton.m
//  dolly
//
//  Created by Nick Banks on 07/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNButton.h"
#import "UIFont+SYNFont.h"

@implementation SYNButton

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont lightCustomFontOfSize: self.titleLabel.font.pointSize];
}


- (void) setTitle: (NSString *) title
{
    _title = title;
    
    [self setTitle: title
          forState: UIControlStateNormal];
}

- (void) setAttributedTitle: (NSAttributedString *) attributedTitle
{
    _attributedTitle = attributedTitle;
    
    [self setAttributedTitle: attributedTitle
          forState: UIControlStateNormal];
}


- (void)setTitle:(NSString *)title andCount:(NSInteger)count {
    _title = title;
	
	NSString *countString = (count > 0 ? [NSString stringWithFormat:@"%@", @(count)] : @"");
    [self setTitle:[NSString stringWithFormat:@"%@\n%@", title, countString] forState:UIControlStateNormal];
}

@end
