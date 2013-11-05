//
//  SYNAccountSettingsTextInputController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "RegexKitLite.h"
#import "SYNAccountSettingsTextInputController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "RegexKitLite.h"
@import QuartzCore;

@interface SYNAccountSettingsTextInputController ()

@property (nonatomic) CGFloat lastTextFieldY;

@property (nonatomic) CGFloat sizeInContainer;

@property (nonatomic, assign) CGRect selectedFrame;

@end


@implementation SYNAccountSettingsTextInputController

@synthesize inputField, saveButton, errorLabel;
@synthesize appDelegate;
@synthesize lastTextFieldY;
@synthesize spinner;
@synthesize sizeInContainer;

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
    
    // Removed in dealloc
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWasShown:)
                                                 name: UIKeyboardDidShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillBeHidden:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    self.preferredContentSize = CGSizeMake(IS_IPAD ? 380 : [SYNDeviceManager.sharedInstance currentScreenWidth], IS_IPAD ? 476 : [SYNDeviceManager.sharedInstance currentScreenHeight]);
    
    self.view.backgroundColor = IS_IPAD ? [UIColor clearColor] : [UIColor whiteColor];
    
    self.sizeInContainer = self.preferredContentSize.width - 20.0;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, self.preferredContentSize.width, self.preferredContentSize.height)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
    
    lastTextFieldY = 10.0;
    
    UIImage* buttonImage = [UIImage imageNamed: @"ButtonAccountSaveDefault.png"];
    saveButton = [UIButton buttonWithType: UIButtonTypeCustom];
    saveButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    saveButton.center = CGPointMake((IS_IPAD ? 190.0 : 160.0), saveButton.center.y);
    
    [saveButton setImage: buttonImage
                forState: UIControlStateNormal];
    
    [saveButton setImage: [UIImage imageNamed: @"ButtonAccountSaveHighlighted.png"]
                forState: UIControlStateHighlighted];
    
    [saveButton setImage: [UIImage imageNamed: @"ButtonAccountSaveHighlighted.png"]
                forState: UIControlStateDisabled];
    
    [self.scrollView addSubview: saveButton];
    
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
    
    [self.scrollView addSubview: inputField];
    
    self.spinner.center = self.saveButton.center;
    [self.view addSubview: self.spinner];
    
    [saveButton addTarget: self
                   action: @selector(saveButtonPressed:)
         forControlEvents: UIControlEventTouchUpInside];
    
    // navigation back button
    UIButton *backButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage *backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    [backButton setImage: backButtonImage forState: UIControlStateNormal];
    [backButton addTarget: self action: @selector(didTapBackButton:) forControlEvents: UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    errorLabel = [[UILabel alloc] initWithFrame: CGRectMake(10.0,
                                                            saveButton.frame.origin.y + saveButton.frame.size.height + 10.0,
                                                            self.preferredContentSize.width - 20.0,
                                                            50)];
    
    errorLabel.textColor = [UIColor colorWithRed: (11.0/255.0)
                                           green: (166.0/255.0)
                                            blue: (171.0/255.0)
                                           alpha: (1.0)];
    
    errorLabel.font = [UIFont lightCustomFontOfSize: 18];
    errorLabel.numberOfLines = 0;
    errorLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview: errorLabel];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    saveButton.enabled = YES;
    CGFloat maxY;
    for (UIView* view in self.scrollView.subviews)
    {
        maxY = MAX(maxY,view.frame.origin.y + view.frame.size.height);
    }
    
    CGRect newFrame = self.scrollView.frame;
    newFrame.size = self.preferredContentSize;
    self.scrollView.frame = newFrame;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, maxY);
    if(maxY < self.scrollView.frame.size.height)
    {
        CGRect newFrame = self.scrollView.frame;
        newFrame.size = self.scrollView.contentSize;
        self.scrollView.frame = newFrame;
    }
}


- (void) didTapBackButton: (id) sender
{
    if (self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
}


- (SYNPaddedUITextField *) createInputField
{
    
    
    SYNPaddedUITextField *newInputField = [[SYNPaddedUITextField alloc] initWithFrame: CGRectMake(10.0,
                                                                                                  lastTextFieldY,
                                                                                                  self.sizeInContainer,
                                                                                                  40.0)];
    
    newInputField.backgroundColor = [UIColor colorWithWhite:(255.0/255.0) alpha:(1.0)];
    newInputField.layer.cornerRadius = 0.0f;
    newInputField.layer.borderWidth = 1.0f;
    newInputField.layer.borderColor = [UIColor colorWithWhite:(209.0/255.0) alpha:(1.0)].CGColor;
    newInputField.textColor = [UIColor darkGrayColor];
    newInputField.delegate = self;
    
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
    [self.scrollView scrollRectToVisible:self.selectedFrame animated:YES];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorLabel.text = @"";
    return YES;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat topOfKeyboard = [[SYNDeviceManager sharedInstance] currentScreenHeight] - MIN(kbSize.height,kbSize.width); //Keyboard is relative to fixed orientation. Always use smallest dimension.
    CGPoint bottomOfScrollView = [self.view.window.rootViewController.view convertPoint:CGPointMake(0.0, self.scrollView.frame.size.height + self.scrollView.frame.origin.y) fromView:self.view];
    bottomOfScrollView.y +=20.0f; //statusbar
    CGFloat overlap = bottomOfScrollView.y - topOfKeyboard;
    if(overlap > 0)
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, overlap, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        [self.scrollView scrollRectToVisible:self.selectedFrame animated:YES];


        
        self.scrollView.bounces = YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIView* nextView = [self.scrollView viewWithTag: textField.tag + 1];
    if (nextView)
    {
        [nextView becomeFirstResponder];
        [self.scrollView scrollRectToVisible:self.selectedFrame animated:YES];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    self.scrollView.bounces = NO;
}

@end
