//
//  SYNAccountSettingsEmail.m
//  rockpack
//
//  Created by Michael Michailidis on 02/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAccountSettingsEmail.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"

@interface SYNAccountSettingsEmail ()

@end

@implementation SYNAccountSettingsEmail


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"accountPropertyChanged"
                                                            label: @"Email"
                                                            value: nil] build]];

    
}


- (void) saveButtonPressed: (UIButton*) button
{
    
    [self.inputField resignFirstResponder];
    
    if ([self.inputField.text isEqualToString: self.appDelegate.currentUser.emailAddress])
    {
        [self.navigationController popViewControllerAnimated: YES];
        return;
    }
        
    
    if (![self formIsValid])
    {
        self.errorLabel.text = NSLocalizedString (@"You Have Entered Invalid Characters", nil);
        return;
    }
    
    [self updateField:@"email" forValue:self.inputField.text withCompletionHandler: ^{
        self.appDelegate.currentUser.emailAddress = self.inputField.text;
        
        
        [self.appDelegate saveContext: YES];
        
        [self.navigationController popViewControllerAnimated: YES];
    }];
}

@end
