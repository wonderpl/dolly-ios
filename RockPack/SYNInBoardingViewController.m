//
//  SYNInBoardingViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNInBoardingViewController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
@interface SYNInBoardingViewController ()

@end

@implementation SYNInBoardingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [self.view addGestureRecognizer:tapGesture];
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)screenTapped:(UITapGestureRecognizer*)tapGesture {
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
    }];

}


@end
