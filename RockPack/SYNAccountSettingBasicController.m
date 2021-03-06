//
//  SYNAccountSettingsTextInputController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingBasicController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "NSString+Validation.h"
#import "UIColor+SYNColor.h"
@import QuartzCore;

@interface SYNAccountSettingBasicController ()

@property (nonatomic) CGFloat lastTextFieldY;

@property (nonatomic) CGFloat sizeInContainer;

@property (nonatomic, assign) CGRect selectedFrame;

@end


@implementation SYNAccountSettingBasicController

@synthesize inputField, saveButton, errorLabel;
@synthesize appDelegate;
@synthesize lastTextFieldY;
@synthesize spinner;

#pragma mark - Object lifecycle

- (id) initWithUserFieldType: (UserFieldType) userFieldType
{
    if (self = [super init])
    {
        currentFieldType = userFieldType;
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        
        [self.spinner setColor:[UIColor dollyActivityIndicator]];
        
    }
    
    return self;
}




#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // on iPhone the view appears in a Navigation Controller and needs to offset from the top bar
    lastTextFieldY = IS_IPHONE ? 84.0 : 64.0f;
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.frame = self.navigationController.view.frame;
    
    // == Save Button (add first because subsequent calls offset it to the bottom) == //
    
    
    saveButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    saveButton.frame = CGRectMake(self.view.frame.size.width * 0.5f - 70.0f,
                                  0.0f,
                                  140.0f,
                                  34.0f);
    
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    
    UIColor* color = [UIColor dollyGreen];
    
    saveButton.layer.borderColor = color.CGColor;
    saveButton.layer.borderWidth = 1.0f;
    saveButton.layer.cornerRadius = 10.0f;
    
    saveButton.titleLabel.font = [UIFont regularCustomFontOfSize:16.0f];
    
    [saveButton setTitleColor: color
                     forState: UIControlStateNormal];
    
    [saveButton addTarget: self
                   action: @selector(saveButtonPressed:)
         forControlEvents: UIControlEventTouchUpInside];
    
    
    [self.view addSubview: saveButton];
    
    
    inputField = [self createInputField];
    
    self.inputField.tag = 1 ;
    self.inputField.delegate = self;
    
    switch (currentFieldType)
    {
        case UserFieldTypeFullName:
            self.inputField.text = appDelegate.currentUser.firstName;
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconFullname.png"]];
            break;
            
        case UserFieldTypeUsername:
            self.inputField.text = appDelegate.currentUser.username;
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconUsername.png"]];
            break;
            
        case UserFieldTypeEmail:
            self.inputField.text = appDelegate.currentUser.emailAddress;
            self.inputField.leftViewMode = UITextFieldViewModeAlways;
            self.inputField.leftView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconEmail.png"]];
            break;
            
        default:
            break;
    }
    
    [self.view addSubview: inputField];
    
	if (IS_IPAD) {
		errorLabel = [[UILabel alloc] initWithFrame: CGRectMake(5.0,
																CGRectGetMaxY(saveButton.frame) + 2.0,
																self.view.frame.size.width - 10.0,
																24)];
	} else {
		errorLabel = [[UILabel alloc] initWithFrame: CGRectMake(5.0,
																CGRectGetMaxY(saveButton.frame) + 2.0,
																self.view.frame.size.width - 10.0,
																50)];
	}
    
    // == Spinner == //
    
    
    self.spinner.center = self.saveButton.center;
    [self.view addSubview: self.spinner];
    
    
    // == Error == //
    
	errorLabel.textColor = [UIColor redColor];
    errorLabel.font = [UIFont lightCustomFontOfSize: 18];
    errorLabel.numberOfLines = 0;
    errorLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview: errorLabel];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.inputField.delegate = nil;
}

#pragma mark - Utility Methods

- (SYNPaddedUITextField *) createInputField
{
    
    // 1. Create the new text field
    SYNPaddedUITextField *newInputField = [[SYNPaddedUITextField alloc] initWithFrame: CGRectMake(5.0,
                                                                                                  lastTextFieldY,
                                                                                                  self.view.frame.size.width - 10.0f,
                                                                                                  40.0)];
    
    
    newInputField.delegate = self;
    
    // 2. Move the Save Button Down
    CGRect saveButtonFrame = saveButton.frame;
    saveButtonFrame.origin.y = newInputField.frame.origin.y + newInputField.frame.size.height + 10.0;
    self.saveButton.frame = saveButtonFrame;
    
    
    CGRect errorTextFrame = errorLabel.frame;
    errorTextFrame.origin.y = saveButtonFrame.origin.y + saveButtonFrame.size.height + 2.0;
    errorLabel.frame = CGRectIntegral(errorTextFrame);
    
    
    lastTextFieldY += newInputField.frame.size.height + 10.0;
    
    return newInputField;
}

- (void) saveButtonPressed: (UIButton *) button
{
    // to be implemented in subclass
}

#pragma mark - Validating

- (BOOL) formIsValid
{
    return [self inputIsValid:self.inputField.text];
}

- (BOOL) inputIsValid:(NSString*)input
{
    BOOL isMatched = NO;
    
    switch (currentFieldType)
    {
        case UserFieldTypeFullName:
			isMatched = YES;
            break;
            
        case UserFieldTypeUsername:
			isMatched = [input isValidUsername];
            break;
            
        case UserFieldTypeEmail:
			isMatched = [input isValidEmail];
            break;
            
        case UserFieldPassword:
			isMatched = [input isValidPassword];
            break;
    }
    return isMatched;
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) updateField: (NSString *) field
            forValue: (id) newValue
            withCompletionHandler: (MKNKBasicSuccessBlock) successBlock
{
    self.saveButton.hidden = YES;
    
    self.spinner.center = self.saveButton.center;
    
    [self.spinner startAnimating];
    
    [self.appDelegate.oAuthNetworkEngine changeUserField: field
                                                 forUser: self.appDelegate.currentUser
                                            withNewValue: newValue
                                       completionHandler: ^(NSDictionary * dictionary){
                                           
                                           [self.spinner stopAnimating];
                                           self.saveButton.hidden = NO;
                                           self.saveButton.enabled = YES;
                                           
                                           successBlock();
                                           
                                           [[NSNotificationCenter defaultCenter]  postNotificationName: kUserDataChanged
                                                                                                object: self
                                                                                              userInfo: @{@"user": appDelegate.currentUser}];
                                           
                                           [self.spinner stopAnimating];
                                           
                                       } errorHandler: ^(id errorInfo) {
                                           
                                           [self.spinner stopAnimating];
                                           
                                                self.saveButton.hidden = NO;
                                                self.saveButton.enabled = YES;
                                                
                                                if (!errorInfo || ![errorInfo isKindOfClass: [NSDictionary class]])
                                                {
                                                    return;
                                                }
                                                
                                                NSString *message = errorInfo[@"message"];
                                                
                                                if (message)
                                                {
                                                    if ([message isKindOfClass: [NSArray class]])
                                                    {
                                                        self.errorLabel.text = (NSString *) ((NSArray *) message)[0];
                                                    }
                                                    else if ([message isKindOfClass: [NSString class]])
                                                    {
                                                        self.errorLabel.text = message;
                                                    }
                                                }
                                            }];
}

#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.selectedFrame = textField.frame;
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorLabel.text = @"";
    return YES;
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIView* nextView = [self.view viewWithTag: textField.tag + 1];
    if (nextView)
    {
        [nextView becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}



@end
