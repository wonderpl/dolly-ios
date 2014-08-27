//
//  SYNDescriptionViewController.m
//  dolly
//
//  Created by Cong on 27/08/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNDescriptionViewController.h"

static NSString *const HTMLTemplateFilename = @"VideoDescriptionTemplate";

@interface SYNDescriptionViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation SYNDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSURL *templateURL = [[NSBundle mainBundle] URLForResource:HTMLTemplateFilename withExtension:@"html"];
	NSString *templateString = [NSString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:nil];
	NSString *HTMLString = [templateString stringByReplacingOccurrencesOfString:@"%{DESCRIPTION}" withString:self.contentHTML];

    [self.webView loadHTMLString:HTMLString baseURL:nil];
    
    [self.label setText:self.contentHTML];
    
    NSLog(@"%@", self.label.text);

}

@end
