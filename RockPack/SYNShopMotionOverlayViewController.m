//
//  SYNShopMotionOverlayViewController.m
//  dolly
//
//  Created by Cong on 29/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNShopMotionOverlayViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNShopMotionOverlayViewController ()
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIImageView *tabImage;
@property (strong, nonatomic) IBOutlet UIImageView *shopMotionImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabButtonHorizontal;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabButtonHorizontalConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabButtonVerticalConstant;
@property (strong, nonatomic) IBOutlet UILabel *labelThisVideo;
@property (strong, nonatomic) IBOutlet UILabel *labelShopMotionIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelWillAppear;
@property (strong, nonatomic) IBOutlet UILabel *theMotion;
@property (strong, nonatomic) IBOutlet UILabel *labelTapIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelTapping;

@end

@implementation SYNShopMotionOverlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.labelThisVideo setFont:[UIFont regularCustomFontOfSize:self.labelThisVideo.font.pointSize]];
    if(self.labelShopMotionIcon)
        [self.labelShopMotionIcon setFont:[UIFont regularCustomFontOfSize:self.labelShopMotionIcon.font.pointSize]];
    [self.labelWillAppear setFont:[UIFont regularCustomFontOfSize:self.labelWillAppear.font.pointSize]];
    [self.theMotion setFont:[UIFont regularCustomFontOfSize:self.theMotion.font.pointSize]];
    [self.labelTapIcon setFont:[UIFont regularCustomFontOfSize:self.labelTapIcon.font.pointSize]];
    [self.labelTapping setFont:[UIFont regularCustomFontOfSize:self.labelTapping.font.pointSize]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (IS_IPAD) {
        
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
        
            [self.tabButtonHorizontalConstant setConstant:221];
			[self.tabButtonVerticalConstant setConstant:584];
            
        } else {
            [self.tabButtonHorizontalConstant setConstant:91];
			[self.tabButtonVerticalConstant setConstant:584];
        }
    }
}



@end
