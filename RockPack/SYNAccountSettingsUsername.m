//
//  SYNAccountSettingsUsername.m
//  rockpack
//
//  Created by Michael Michailidis on 02/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAccountSettingsUsername.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"

@interface SYNAccountSettingsUsername ()

@end

@implementation SYNAccountSettingsUsername


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"accountPropertyChanged"
                                                            label: @"Username"
                                                            value: nil] build]];
    
    self.view.backgroundColor = [UIColor whiteColor];

    
    self.errorLabel.text = @"Your username can only be changed once.";
    
}
-(void)saveButtonPressed:(UIButton*)button
{
    [self.inputField resignFirstResponder];
    
    if([self.inputField.text isEqualToString:self.appDelegate.currentUser.username]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
        
    
    if(![self formIsValid]) {
        self.errorLabel.text = NSLocalizedString (@"You Have Entered Invalid Characters", nil);
        return;
    }
    
    [self updateField:@"username" forValue:self.inputField.text withCompletionHandler:^{
       
        self.appDelegate.currentUser.username = self.inputField.text;
        
        
        [self.appDelegate saveContext:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
}



@end
