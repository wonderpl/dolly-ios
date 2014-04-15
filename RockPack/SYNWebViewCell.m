//
//  SYNWebViewCell.m
//  dolly
//
//  Created by Sherman Lo on 10/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNWebViewCell.h"

static NSString *const HTMLTemplateFilename = @"VideoDescriptionTemplate";

@interface SYNWebViewCell () <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

@implementation SYNWebViewCell

- (void)prepareForReuse {
	[super prepareForReuse];
	
	self.delegate = nil;
}

- (CGFloat)contentHeight {
	return self.webView.scrollView.contentSize.height;
}

- (void)setContentHTML:(NSString *)contentHTML {
	_contentHTML = contentHTML;
	
	NSURL *templateURL = [[NSBundle mainBundle] URLForResource:HTMLTemplateFilename withExtension:@"html"];
	NSString *templateString = [NSString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:nil];
	NSString *HTMLString = [templateString stringByReplacingOccurrencesOfString:@"%{DESCRIPTION}" withString:contentHTML];
	
	[self.webView loadHTMLString:HTMLString baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.delegate webViewCellContentLoaded:self];
}

@end
