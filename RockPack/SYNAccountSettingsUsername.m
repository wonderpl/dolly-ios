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
#import "SYNTrackingManager.h"

@interface SYNAccountSettingsUsername ()

@end

@implementation SYNAccountSettingsUsername

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.errorLabel.text = @"Your username can only be changed once.";
}


#pragma mark - Save 

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
	
	[[SYNTrackingManager sharedManager] trackAccountPropertyChanged:@"Username"];
    
    [self updateField:@"username" forValue:self.inputField.text withCompletionHandler:^{
       
        self.appDelegate.currentUser.username = self.inputField.text;
        
        
        [self.appDelegate saveContext:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
}



@end
