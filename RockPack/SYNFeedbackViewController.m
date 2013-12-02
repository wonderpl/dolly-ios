//
//  SYNFeedbackViewController.m
//  dolly
//
//  Created by Michael Michailidis on 02/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFeedbackViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "UIFont+SYNFont.h"

@interface SYNFeedbackViewController ()

@property (nonatomic, strong) IBOutlet UISlider* slider;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* sliderLabel;
@property (nonatomic, strong) IBOutlet UITextView* textView;

@end

@implementation SYNFeedbackViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Feedback", nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(sendButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(closeButtonPressed:)];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
    self.sliderLabel.font = [UIFont regularCustomFontOfSize:self.sliderLabel.font.pointSize];
}

#pragma mark - Top Button Callbacks

- (void) sendButtonPressed:(UIBarButtonItem*)buttonItem
{
    [self sendMessage];
}

- (void) closeButtonPressed:(UIBarButtonItem*)buttonItem
{
    
    
}

- (void) sendMessage
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString* message = self.textView.text;
    NSNumber* score = [NSNumber numberWithFloat:self.slider.value];
    
    [appDelegate.oAuthNetworkEngine sendFeedbackForMessage:message
                                                  andScore:score
                                         completionHandler:^(id responce) {
                                             
                                             
                                             
                                            } errorHandler:^(id error) {
                                             
                                             
        
                                            }];
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"placeholder text here..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"placeholder text here...";
        textView.textColor = [UIColor lightTextColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
