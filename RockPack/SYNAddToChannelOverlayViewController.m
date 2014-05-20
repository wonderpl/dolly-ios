//
//  SYNNewCollectionOverlayViewController.m
//  dolly
//
//  Created by Cong on 21/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAddToChannelOverlayViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNAddToChannelOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIButton *createNewButton;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SYNAddToChannelOverlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.createNewButton.layer.borderColor = [[UIColor whiteColor] CGColor] ;
    self.createNewButton.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
    [self.createNewButton.titleLabel setFont:[UIFont boldCustomFontOfSize:self.createNewButton.titleLabel.font.pointSize]];
    
	[self.textLabel setFont:[UIFont regularCustomFontOfSize:self.textLabel.font.pointSize]];
	[self.titleLabel setFont:[UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize]];
    
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
