//
//  SYNAboutViewController.m
//  dolly
//
//  Created by Michael Michailidis on 18/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAboutViewController.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "AppConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAboutViewController ()

@property (nonatomic, strong) IBOutlet UIImageView* logoImageView;
@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UIButton* termsButton;
@property (nonatomic, strong) IBOutlet UIButton* policyButton;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;

@end

@implementation SYNAboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Information";
    
    // Button Styling
    
    self.termsButton.layer.cornerRadius = 10.0f;
    self.policyButton.layer.cornerRadius = 10.0f;
    
    UIColor* color = [UIColor colorWithRed:(188.0f/255.0f)
                                     green:(186.0f/255.0f)
                                      blue:(212.0f/255.0f)
                                     alpha:1.0f];
    
    
    self.termsButton.layer.borderColor = color.CGColor;
    self.policyButton.layer.borderColor = color.CGColor;
    
    self.termsButton.layer.borderWidth = 1.0f;
    self.policyButton.layer.borderWidth = 1.0f;
    
    self.termsButton.titleLabel.font = [UIFont regularCustomFontOfSize:14.0f];
    [self.termsButton setTitleColor:color forState:UIControlStateNormal];
    
    self.policyButton.titleLabel.font = [UIFont regularCustomFontOfSize:14.0f];
    [self.policyButton setTitleColor:color forState:UIControlStateNormal];
    
    
    // Style the content of the TextView
    
    NSMutableAttributedString* attributedMutString = [[NSMutableAttributedString alloc] init];
    
    NSMutableParagraphStyle *paragrapStyleCenter = [[NSMutableParagraphStyle alloc] init];
    paragrapStyleCenter.alignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *paragrapStyleLeft = [[NSMutableParagraphStyle alloc] init];
    paragrapStyleLeft.alignment = NSTextAlignmentLeft;
    
    
    [attributedMutString appendAttributedString: [[NSAttributedString alloc] initWithString: @"Mayberry v1.0.4\n"
                                                                                 attributes: @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                               NSParagraphStyleAttributeName: paragrapStyleCenter,
                                                                                               NSFontAttributeName: [UIFont regularCustomFontOfSize:20]}]];
    
    [attributedMutString appendAttributedString: [[NSAttributedString alloc] initWithString: @"@ 2013 Rockpack Ltd.\n\n\n"
                                                                                 attributes: @{NSForegroundColorAttributeName: [UIColor dollyTextMediumGray],
                                                                                               NSParagraphStyleAttributeName: paragrapStyleCenter,
                                                                                               NSFontAttributeName: [UIFont regularCustomFontOfSize:15]}]];
    
    
    NSArray* creditsArray = @[@"FacebookSDK by Facebook", @"CKImagePicker by George Kitz", @"FacebookSDK by Facebook",
                              @"FacebookSDK by Facebook", @"CKImagePicker by George Kitz", @"FacebookSDK by Facebook",
                              @"FacebookSDK by Facebook", @"CKImagePicker by George Kitz", @"FacebookSDK by Facebook",
                              @"FacebookSDK by Facebook", @"CKImagePicker by George Kitz", @"FacebookSDK by Facebook"];
    
    for (NSString* credit in creditsArray)
    {
        [attributedMutString appendAttributedString: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@\n\n", credit]
                                                                                     attributes: @{NSForegroundColorAttributeName: [UIColor dollyTextMediumGray],
                                                                                                   NSParagraphStyleAttributeName: paragrapStyleLeft,
                                                                                                   NSFontAttributeName: [UIFont regularCustomFontOfSize:15]}]];
    }
    
    self.textView.attributedText = attributedMutString;
    
    
    [self.textView sizeToFit];
    
    CGFloat offset = self.textView.frame.origin.y + self.textView.frame.size.height;
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, offset)];
    
    
}

-(IBAction)buttonPressed:(UIButton*)sender
{
    
    
    if(sender == self.termsButton)
    {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kURLTermsAndConditions]];
        
    }
    else if(sender == self.policyButton)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kURLPrivacy]];
        
        
    }
    
}
@end