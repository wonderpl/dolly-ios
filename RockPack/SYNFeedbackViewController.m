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
#import "SYNMasterViewController.h"

@interface SYNFeedbackViewController () <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UISlider* slider;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* sliderLabel;
@property (nonatomic, strong) IBOutlet UITextView* textView;

// label

@property (nonatomic, strong) IBOutlet UILabel* minValueLabel;
@property (nonatomic, strong) IBOutlet UILabel* maxValueLabel;
@property (nonatomic, strong) IBOutlet UILabel* currentValueLabel;

@end

@implementation SYNFeedbackViewController

static NSString* placeholderText = @"Your feedback...";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Feedback", nil);
    
    ///self.currentValueLabel.hidden = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(sendButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(closeButtonPressed:)];
    
    
    
    // setting fonts
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    self.sliderLabel.font = [UIFont regularCustomFontOfSize:self.sliderLabel.font.pointSize];
    
    self.minValueLabel.font = [UIFont regularCustomFontOfSize:self.minValueLabel.font.pointSize];
    self.maxValueLabel.font = [UIFont regularCustomFontOfSize:self.maxValueLabel.font.pointSize];
    self.currentValueLabel.font = [UIFont regularCustomFontOfSize:self.currentValueLabel.font.pointSize];
    
    self.textView.font = [UIFont regularCustomFontOfSize:self.textView.font.pointSize];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    
    // set the initial state
    
    [self sliderMoved:self.slider];
    
    self.textView.text = placeholderText;
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:(128.0f/255.0f)
                                                                          green:(128.0f/255.0f)
                                                                           blue:(128.0f/255.0f)
                                                                          alpha:1.0f]];
}

- (void) keyboardNotified: (NSNotification*) notification
{
    
    CGRect sFrame = self.navigationController.view.frame;
    if([notification.name isEqualToString:UIKeyboardWillShowNotification])
    {
        sFrame.origin.y -= 200.0f;
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])
    {
        sFrame.origin.y += 200.0f;
    }
    __weak SYNFeedbackViewController* wself = self;
    [UIView animateWithDuration:0.3f animations:^{
        wself.navigationController.view.frame = sFrame;
    }];
    
}
#pragma mark - Top Button Callbacks

- (void) sendButtonPressed:(UIBarButtonItem*)buttonItem
{
    [self sendMessage];
}

- (void) closeButtonPressed:(UIBarButtonItem*)buttonItem
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    
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

#pragma mark - UISlider

- (IBAction)sliderMoved:(UISlider*)slider
{
    self.currentValueLabel.text = [NSString stringWithFormat:@"%0.1f", slider.value];
    self.currentValueLabel.hidden = NO;
    
    
    CGFloat xPosition = ((self.slider.frame.size.width - 34.0f) * (self.slider.value/10.0f)) + self.slider.frame.origin.x + 17.0f;
    
    
    self.currentValueLabel.center = CGPointMake(xPosition, self.currentValueLabel.center.y);
    
    
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; // optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeholderText;
        textView.textColor = [UIColor lightTextColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
