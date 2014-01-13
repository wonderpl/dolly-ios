//
//  SYNWebViewViewController.m
//  dolly
//
//  Created by Cong on 13/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNWebViewViewController.h"

@interface SYNWebViewViewController ()

@end

@implementation SYNWebViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)backTapped:(id)sender {
    
    [self.webView goForward];
    
}
- (IBAction)forawrdTapped:(id)sender {
    
    [self.webView goBack];
}

@end
