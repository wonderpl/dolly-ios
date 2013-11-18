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

@interface SYNAboutViewController ()

@property (nonatomic, strong) IBOutlet UIImageView* logoImageView;
@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UIButton* termsButton;
@property (nonatomic, strong) IBOutlet UIButton* policyButton;

@end

@implementation SYNAboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Information";
    
    
    // Style the content of the TextView
    
    NSMutableAttributedString* attributedMutString = [[NSMutableAttributedString alloc] init];
    
    NSMutableParagraphStyle *paragrapStyleCenter = [[NSMutableParagraphStyle alloc] init];
    paragrapStyleCenter.alignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *paragrapStyleLeft = [[NSMutableParagraphStyle alloc] init];
    paragrapStyleLeft.alignment = NSTextAlignmentLeft;
    
    
    [attributedMutString appendAttributedString: [[NSAttributedString alloc] initWithString: @"Mayberry v1.0.4\n"
                                                                                 attributes: @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                               NSParagraphStyleAttributeName: paragrapStyleCenter,
                                                                                               NSFontAttributeName: [UIFont regularCustomFontOfSize:23]}]];
    
    [attributedMutString appendAttributedString: [[NSAttributedString alloc] initWithString: @"@ 2013 Rockpack Ltd.\n\n\n"
                                                                                 attributes: @{NSForegroundColorAttributeName: [UIColor dollyTextMediumGray],
                                                                                               NSParagraphStyleAttributeName: paragrapStyleCenter,
                                                                                               NSFontAttributeName: [UIFont regularCustomFontOfSize:18]}]];
    
    
    NSArray* creditsArray = @[@"FacebookSDK by Facebook", @"CKImagePicker by George Kitz", @"FacebookSDK by Facebook"];
    for (NSString* credit in creditsArray)
    {
        [attributedMutString appendAttributedString: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@\n\n", credit]
                                                                                     attributes: @{NSForegroundColorAttributeName: [UIColor dollyTextMediumGray],
                                                                                                   NSParagraphStyleAttributeName: paragrapStyleLeft,
                                                                                                   NSFontAttributeName: [UIFont regularCustomFontOfSize:18]}]];
    }
    
    self.textView.attributedText = attributedMutString;
    
}

-(IBAction)buttonPressed:(UIButton*)sender
{
    if(sender == self.termsButton)
    {
        
        
        
    }
    else if(sender == self.policyButton)
    {
        
        
        
    }
    
}
@end
