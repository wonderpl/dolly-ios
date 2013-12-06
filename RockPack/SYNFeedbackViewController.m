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
#import <QuartzCore/QuartzCore.h>

@interface SYNFeedbackViewController () <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UISlider* slider;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* sliderLabel;
@property (nonatomic, strong) IBOutlet UITextView* textView;

@property (nonatomic) BOOL hasTouchedSlider;

// label

@property (nonatomic, strong) IBOutlet UILabel* minValueLabel;
@property (nonatomic, strong) IBOutlet UILabel* maxValueLabel;
@property (nonatomic, strong) IBOutlet UILabel* currentValueLabel;

@property (nonatomic, strong) IBOutlet UIView* containerSlider;

@end

@implementation SYNFeedbackViewController

static NSString* placeholderText = @"Your feedback...";

- (void) setHasTouchedSlider:(BOOL)hasTouchedSlider
{
    _hasTouchedSlider = hasTouchedSlider;
    
    NSArray* relatedViews = @[self.slider, self.minValueLabel, self.maxValueLabel, self.currentValueLabel];
    
    [UIView animateWithDuration:0.2f animations:^{
        
        for (UIView* v in relatedViews)
            v.alpha = _hasTouchedSlider ? 1.0f : 0.5f;
        
    }];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Feedback", nil);
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(sendButtonPressed:)];
    
    NSDictionary* textAttributes = @{NSFontAttributeName: [UIFont regularCustomFontOfSize: IS_IPAD ? 18.0f : 15.0f],
                                     NSForegroundColorAttributeName: [UIColor colorWithWhite:(128.0f/255.0f) alpha:1.0f]};
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:textAttributes
                                                          forState:UIControlStateNormal];
    
    if(IS_IPAD)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(closeButtonPressed:)];
        
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:textAttributes
                                                             forState:UIControlStateNormal];
    }
    
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    // setting fonts
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    
    self.sliderLabel.font = [UIFont regularCustomFontOfSize:self.sliderLabel.font.pointSize];
    
    self.minValueLabel.font = [UIFont regularCustomFontOfSize:self.minValueLabel.font.pointSize];
    
    self.maxValueLabel.font = [UIFont regularCustomFontOfSize:self.maxValueLabel.font.pointSize];
    
    self.currentValueLabel.font = [UIFont regularCustomFontOfSize:self.currentValueLabel.font.pointSize];
    
    self.textView.font = [UIFont regularCustomFontOfSize:self.textView.font.pointSize];
    
    
    
    
    
    // add lines around container
    CGColorRef lineColorRef = [UIColor colorWithRed:(177.0f/255.0f)
                                              green:(177.0f/255.0f)
                                               blue:(177.0f/255.0f)
                                              alpha:1.0f].CGColor;
    
    self.containerSlider.layer.borderColor = lineColorRef;
    self.containerSlider.layer.borderWidth = IS_RETINA ? 0.5f : 1.0f;
    
    self.textView.layer.borderColor = lineColorRef;
    self.textView.layer.borderWidth = IS_RETINA ? 0.5f : 1.0f;
    
    
    // set the initial state
    
    [self sliderMoved:self.slider];
    
    self.textView.text = placeholderText;
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed: (128.0f/255.0f)
                                                                          green: (128.0f/255.0f)
                                                                           blue: (128.0f/255.0f)
                                                                          alpha: 1.0f]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    self.hasTouchedSlider = NO;
    
    
}


- (void) dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) keyboardNotified: (NSNotification*) notification
{
    if(IS_IPAD)
    {
        CGRect sFrame = self.navigationController.view.frame;
        if([notification.name isEqualToString:UIKeyboardWillShowNotification])
            sFrame.origin.y -= 110.0f;
        else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])
            sFrame.origin.y += 110.0f;
        __weak SYNFeedbackViewController* wself = self;
        [UIView animateWithDuration:0.3f animations:^{
            wself.navigationController.view.frame = sFrame;
        }];
    }
    else // is IPHONE
    {
        
    }
    
    
}
#pragma mark - Top Button Callbacks

- (void) sendButtonPressed:(UIBarButtonItem*)buttonItem
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self sendMessage];
}

- (void) closeButtonPressed:(UIBarButtonItem*)buttonItem
{
    if(IS_IPAD)
    {
        SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

- (void) sendMessage
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString* message = self.textView.text;
    NSNumber* score = [NSNumber numberWithFloat:self.slider.value];
    
    [appDelegate.oAuthNetworkEngine sendFeedbackForMessage:message
                                                  andScore:score
                                         completionHandler:^(id responce) {
                                             
                                             self.navigationItem.rightBarButtonItem.enabled = YES;
                                             self.navigationItem.leftBarButtonItem.enabled = YES;
                                            } errorHandler:^(id error) {
                                             
                                             self.navigationItem.rightBarButtonItem.enabled = YES;
                                                self.navigationItem.leftBarButtonItem.enabled = YES;
                                            }];
}

#pragma mark - UISlider

- (IBAction)sliderMoved:(UISlider*)slider
{
    
    self.hasTouchedSlider = YES;
    
    self.currentValueLabel.text = [NSString stringWithFormat:@"%i", (int)slider.value];
    
    CGFloat ratio = self.slider.value/self.slider.maximumValue;
    
    CGFloat xPosition = ((self.slider.frame.size.width - 30.0f) * ratio) + self.slider.frame.origin.x + 15.0f;
    
    
    self.currentValueLabel.center = CGPointMake(xPosition, self.currentValueLabel.center.y);
    
    
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholderText]) {
        textView.text = @"";
        self.navigationItem.rightBarButtonItem.enabled = YES;
        textView.textColor = [UIColor blackColor]; // optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = placeholderText;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        textView.textColor = [UIColor lightTextColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
