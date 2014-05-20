//
//  SYNOnBoardingSectionHeader.m
//  dolly
//
//  Created by Cong on 21/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNOnBoardingSectionHeader.h"
#import "UIFont+SYNFont.h"

@interface SYNOnBoardingSectionHeader ()

@property (strong, nonatomic) IBOutlet UILabel *sectionTitle;

@end

@implementation SYNOnBoardingSectionHeader

- (void) awakeFromNib
{
    self.sectionTitle.font = [UIFont lightCustomFontOfSize:self.sectionTitle.font.pointSize];
    self.sectionTitle.textColor = [UIColor blackColor];
    
    
}

- (void)setTitleText : (NSString*) string {
	string = [string uppercaseString];
	UIColor *color = [UIColor colorWithRed: (112.0f / 255.0f)
									 green: (123.0f / 255.0f)
									  blue: (123.0f / 255.0f)
									 alpha: 1.0f];
	
	NSDictionary *attributes = @{
								 NSKernAttributeName : @(2.5f),
								 NSFontAttributeName : [UIFont lightCustomFontOfSize:self.sectionTitle.font.pointSize],
								 NSForegroundColorAttributeName : color
								 };
	
	NSAttributedString *attributedString =
    [[NSAttributedString alloc]
	 initWithString:string attributes:attributes];
	
	self.sectionTitle.attributedText = attributedString;
}



@end
