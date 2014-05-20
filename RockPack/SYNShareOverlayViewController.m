//
//  SYNShareOverlayViewController.m
//  dolly
//
//  Created by Cong on 21/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNShareOverlayViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNShareOverlayViewController ()
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *searchTextLabel;

@end

@implementation SYNShareOverlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.titleLabel setFont:[UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize]];

    [self.textLabel setFont:[UIFont regularCustomFontOfSize:self.textLabel.font.pointSize]];

    [self.searchTextLabel setFont:[UIFont regularCustomFontOfSize:self.searchTextLabel.font.pointSize]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (IS_IPAD) {
        
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
        } else {
        }
    }
}

@end
