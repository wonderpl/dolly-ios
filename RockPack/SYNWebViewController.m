//
//  SYNWebViewController.m
//  dolly
//
//  Created by Cong on 13/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNWebViewController.h"

@interface SYNWebViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

@implementation SYNWebViewController

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)backTapped:(id)sender {
    [self.webView goForward];
    
}

- (IBAction)forwardTapped:(id)sender {
    [self.webView goBack];
}

@end
