//
//  SYNAboutViewController.m
//  dolly
//
//  Created by Michael Michailidis on 18/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAboutViewController.h"

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
