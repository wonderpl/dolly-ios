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

@end

@implementation SYNDiscoverSearchOverlayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.titleLabel setFont:[UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize]];
    
	[self.textLabel setFont:[UIFont regularCustomFontOfSize:self.textLabel.font.pointSize]];
    
    
}


@end
