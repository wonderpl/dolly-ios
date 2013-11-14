//
//  SYNAccountSettingsTextInputController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPaddedUITextField.h"
@import UIKit;

typedef enum
{
    UserFieldTypeFullName = 0,
    UserFieldTypeUsername,
    UserFieldTypeEmail,
    UserFieldPassword
} UserFieldType;

@interface SYNAccountSettingBasicController : UIViewController <UITextFieldDelegate>
{
    UserFieldType currentFieldType;
}

@property (nonatomic, strong) SYNPaddedUITextField *inputField;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) SYNAppDelegate *appDelegate;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

- (id) initWithUserFieldType: (UserFieldType) userFieldType;

- (void) updateField: (NSString *) field
            forValue: (id) newValue
            withCompletionHandler: (MKNKBasicSuccessBlock) successBlock;

- (SYNPaddedUITextField *) createInputField;
- (void) saveButtonPressed: (UIButton *) button;

- (BOOL) formIsValid;
- (BOOL) inputIsValid:(NSString*)input;

@end
