//
//  SYNAccountSettingsTextInputController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "RegexKitLite.h"
#import "SYNAccountSettingBasicController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
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
    }
    
    return self;
}


- (void) dealloc
{
    // Stop observing everything
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Defensive programming
    self.inputField.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    self.view.backgroundColor = IS_IPAD ? [UIColor clearColor] : [UIColor whiteColor];
    
    // on iPhone the view appears in a Navigation Controller and needs to offset from the top bar
    lastTextFieldY = IS_IPHONE ? 84.0 : 0.0f;
    
    
    
    
    inputField = [self createInputField];
    
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
    
    self.spinner.center = self.saveButton.center;
    [self.view addSubview: self.spinner];
    
    
    
    
    
    errorLabel.textColor = [UIColor colorWithRed: (11.0/255.0)
                                           green: (166.0/255.0)
                                            blue: (171.0/255.0)
                                           alpha: (1.0)];
    
    errorLabel.font = [UIFont lightCustomFontOfSize: 18];
    errorLabel.numberOfLines = 0;
    errorLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview: errorLabel];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.frame = self.navigationController.view.frame;
    
    errorLabel = [[UILabel alloc] initWithFrame: CGRectMake(5.0,
                                                            saveButton.frame.origin.y + saveButton.frame.size.height + 6.0,
                                                            self.preferredContentSize.width - 10.0,
                                                            50)];
    
    // == Save Button == //
    
    UIImage* buttonImage = [UIImage imageNamed: @"ButtonAccountSaveDefault.png"];
    saveButton = [UIButton buttonWithType: UIButtonTypeCustom];
    saveButton.frame = CGRectMake(self.view.frame.size.width * 0.5f - buttonImage.size.width * 0.5f,
                                  0.0f,
                                  buttonImage.size.width,
                                  buttonImage.size.height);
    
    
    [saveButton setImage: buttonImage
                forState: UIControlStateNormal];
    
    [saveButton setImage: [UIImage imageNamed: @"ButtonAccountSaveHighlighted.png"]
                forState: UIControlStateHighlighted];
    
    [saveButton setImage: [UIImage imageNamed: @"ButtonAccountSaveHighlighted.png"]
                forState: UIControlStateDisabled];
    
    
    [saveButton addTarget: self
                   action: @selector(saveButtonPressed:)
         forControlEvents: UIControlEventTouchUpInside];
    
    
    [self.view addSubview: saveButton];
}


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
    errorTextFrame.origin.y = saveButtonFrame.origin.y + saveButtonFrame.size.height + 10.0;
    errorLabel.frame = CGRectIntegral(errorTextFrame);
    
    
    lastTextFieldY += newInputField.frame.size.height + 10.0;
    
    return newInputField;
}

- (void) saveButtonPressed: (UIButton *) button
{
    
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
            isMatched = [input isMatchedByRegex: @"^[a-zA-Z\\.]+$"];
            break;
            
        case UserFieldTypeUsername:
            isMatched = [input isMatchedByRegex: @"^[a-zA-Z0-9\\._]+$"];
            break;
            
        case UserFieldTypeEmail:
            isMatched = [input isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
            break;
            
        case UserFieldPassword:
            isMatched = [input isMatchedByRegex: @"^[a-zA-Z0-9\\._]+$"];
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
