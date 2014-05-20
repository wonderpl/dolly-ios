//
//  SYNDiscoverOverlayHighlightsViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNDiscoverOverlayHighlightsViewController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "SYNFollowUserButton.h"

@interface SYNDiscoverOverlayHighlightsViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet SYNFollowUserButton *followButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SYNDiscoverOverlayHighlightsViewController

- (void)viewDidLoad
{
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
	self.followButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.followButton.selected = NO;
    
    [super viewDidLoad];
    self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
    
    self.textLabel.font = [UIFont regularCustomFontOfSize:self.textLabel.font.pointSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (IS_IPAD) {
        
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            self.container.frame = CGRectMake(464, 145, 562, 191);
        } else {
            self.container.frame = CGRectMake(206, 145, 562, 191);

        }
    }
}


@end
