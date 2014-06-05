//
//  SYNDiscoverSearchOverlayViewController.m
//  dolly
//
//  Created by Cong on 05/06/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNDiscoverSearchOverlayViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNDiscoverSearchOverlayViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UILabel *foodLabel;
@property (strong, nonatomic) IBOutlet UILabel *chefs;

@end

@implementation SYNDiscoverSearchOverlayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.titleLabel setFont:[UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize]];
	[self.chefs setFont:[UIFont semiboldCustomFontOfSize:self.chefs.font.pointSize]];
    [self.textLabel setFont:[UIFont regularCustomFontOfSize:self.textLabel.font.pointSize]];

	[self.header setFont: [UIFont semiboldCustomFontOfSize: self.header.font.pointSize]];
    
    NSDictionary *attributes = @{
								 NSKernAttributeName : @(2.5f),
								 NSFontAttributeName : [UIFont lightCustomFontOfSize:self.foodLabel.font.pointSize],
								 };
	
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"FOOD" attributes:attributes];
	
	self.foodLabel.attributedText = attributedString;

}



@end
