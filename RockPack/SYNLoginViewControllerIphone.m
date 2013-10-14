//
//  SYNLoginViewControllerIphone.m
//  rockpack
//
//  Created by Mats Trovik on 02/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "RegexKitLite.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNLoginViewController.h"
#import "SYNLoginViewControllerIphone.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNTextFieldLoginiPhone.h"
#import "UIFont+SYNFont.h"
#import <FacebookSDK/FacebookSDK.h>

#define kLoginAnimationTransitionDuration 0.3f

@interface SYNLoginViewControllerIphone () <UITextFieldDelegate,
                                            SYNImagePickerControllerDelegate>


@property (nonatomic) BOOL hasAnimated;
@property (nonatomic) BOOL isPreIPhone5;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* ddInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* emailInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* mmInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* passwordInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* registeringUserEmailInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* registeringUserNameInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* registeringUserPasswordInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* userNameInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* yyyyInputField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;
@property (nonatomic, strong) IBOutlet UIImage* avatarImage;
@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundFrontImage;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundImage;
@property (nonatomic, strong) IBOutlet UIImageView* rockpackLogoImage;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;
@property (nonatomic, strong) IBOutlet UILabel* wellSendYouLabel;
@property (nonatomic, strong) IBOutlet UILabel* whatsOnYourChannelLabel;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (nonatomic, strong) NSDateFormatter* formatter;
@property (nonatomic, strong) NSMutableArray* validUsernames;
@property (strong, nonatomic) NSArray *onboardingViewControllers;
@property (strong, nonatomic) NSDateFormatter * dateFormatter;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *loginErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordResetErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *registeringUserErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *signupErrorLabel;
@property (weak, nonatomic) IBOutlet UIView *firstSignupView;
@property (weak, nonatomic) IBOutlet UIView *initialView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *secondSignupView;
@property (weak, nonatomic) IBOutlet UIView *termsAndConditionsView;
@property (weak, nonatomic) IBOutlet UIView *whiteLineView;

@end

@implementation SYNLoginViewControllerIphone 
@synthesize isPreIPhone5;

#pragma mark - Object lifecycle

- (void) dealloc
{
    // Defensive programming
    self.ddInputField.delegate = nil;;
    self.emailInputField.delegate = nil;
    self.imagePicker.delegate = nil;
    self.mmInputField.delegate = nil;
    self.passwordInputField.delegate = nil;
    self.registeringUserEmailInputField.delegate = nil;
    self.registeringUserNameInputField.delegate = nil;
    self.registeringUserPasswordInputField.delegate = nil;
    self.userNameInputField.delegate = nil;
    self.yyyyInputField.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.isPreIPhone5 = [SYNDeviceManager.sharedInstance currentScreenHeight] < 500;
    
    //Move all subviews offscreen
    CGPoint newCenter = self.loginView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 50.0f;
    }
    self.loginView.center = newCenter;
    
    newCenter = self.passwordView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 40.0f;
    }
    self.passwordView.center = newCenter;

    newCenter = self.firstSignupView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 45.0f;
    }
    self.firstSignupView.center = newCenter;
    
    newCenter = self.secondSignupView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 40.0f;
    }
    self.secondSignupView.center = newCenter;
    
    
    newCenter = self.termsAndConditionsView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 68.0f;
    }
    self.termsAndConditionsView.center = newCenter;
    
    //Setup fonts
    self.userNameInputField.font = [UIFont rockpackFontOfSize:self.userNameInputField.font.pointSize];
    self.userNameInputField.delegate = self;
    self.registeringUserEmailInputField.font = [UIFont rockpackFontOfSize:self.registeringUserEmailInputField.font.pointSize];
    self.registeringUserEmailInputField.delegate = self;
    self.registeringUserNameInputField.font = [UIFont rockpackFontOfSize:self.registeringUserNameInputField.font.pointSize];
    self.registeringUserNameInputField.delegate=self;
    self.registeringUserPasswordInputField.font = [UIFont rockpackFontOfSize:self.registeringUserPasswordInputField.font.pointSize];
    self.registeringUserPasswordInputField.delegate = self;
    self.passwordInputField.font = [UIFont rockpackFontOfSize:self.passwordInputField.font.pointSize];
    self.passwordInputField.delegate = self;
    self.ddInputField.font = [UIFont rockpackFontOfSize:self.ddInputField.font.pointSize];
    self.ddInputField.delegate = self;
    self.mmInputField.font = [UIFont rockpackFontOfSize:self.mmInputField.font.pointSize];
    self.mmInputField.delegate = self;
    self.yyyyInputField.font = [UIFont rockpackFontOfSize:self.yyyyInputField.font.pointSize];
    self.yyyyInputField.delegate = self;
    self.emailInputField.font = [UIFont rockpackFontOfSize:self.emailInputField.font.pointSize];
    self.emailInputField.delegate = self;
    
    self.loginErrorLabel.font = [UIFont rockpackFontOfSize:self.loginErrorLabel.font.pointSize];
    self.passwordResetErrorLabel.font = [UIFont rockpackFontOfSize:self.passwordResetErrorLabel.font.pointSize];
    self.signupErrorLabel.font = [UIFont rockpackFontOfSize:self.signupErrorLabel.font.pointSize];
    
    self.signupButton.titleLabel.font = [UIFont rockpackFontOfSize:17.0f];
    self.loginButton.titleLabel.font = [UIFont rockpackFontOfSize:17.0f];
    
    NSMutableAttributedString* termsString = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"register_screen_legal" , nil)];
    
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)] range: NSMakeRange(36, 17)];
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)] range: NSMakeRange(58, 14)];
    self.termsAndConditionsLabel.attributedText = termsString;
    self.termsAndConditionsLabel.font = [UIFont rockpackFontOfSize:self.termsAndConditionsLabel.font.pointSize];
    
    self.passwordForgottenButton.titleLabel.font = [UIFont rockpackFontOfSize:self.passwordForgottenButton.titleLabel.font.pointSize];
    
    //Setup Keyboard Return Button
    self.userNameInputField.returnKeyType = UIReturnKeyNext;
    self.passwordInputField.returnKeyType = UIReturnKeyGo;
    self.registeringUserEmailInputField.returnKeyType = UIReturnKeyNext;
    self.registeringUserNameInputField.returnKeyType = UIReturnKeyNext;
    self.registeringUserPasswordInputField.returnKeyType = UIReturnKeyNext;
    self.emailInputField.returnKeyType = UIReturnKeySend;
    
    self.state = kLoginScreenStateInitial;
    
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"dd/MM/yyyy";
    
     
    CGRect onBoardingViewFrame = self.onBoardingController.view.frame;
    onBoardingViewFrame.origin.x = 0.0;
    onBoardingViewFrame.size.width = [[SYNDeviceManager sharedInstance] currentScreenWidth];
    if(IS_IPHONE_5)
        onBoardingViewFrame.origin.y = -100.0;
    else
        onBoardingViewFrame.origin.y = self.facebookButton.frame.origin.y - onBoardingViewFrame.size.height - 20.0;
    self.onBoardingController.view.frame = CGRectIntegral(onBoardingViewFrame);
    [self.view addSubview:self.onBoardingController.view];
    [self addChildViewController:self.onBoardingController];
    
    

}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Start"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    self.isPreIPhone5 = [SYNDeviceManager.sharedInstance currentScreenHeight] < 500;
    
    if(!self.hasAnimated){
    
        if (isPreIPhone5) {
            
            self.rockpackLogoImage.frame = CGRectMake(self.rockpackLogoImage.frame.origin.x, 126.0f, self.rockpackLogoImage.frame.size.width, self.rockpackLogoImage.frame.size.height);
            [UIView animateWithDuration:0.3f
                                  delay:0.1f
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.rockpackLogoImage.frame = CGRectMake(self.rockpackLogoImage.frame.origin.x, 35.0f,
                                                                           self.rockpackLogoImage.frame.size.width,
                                                                           self.rockpackLogoImage.frame.size.height);
                                 
                             } completion:^(BOOL finished) {
                             }];
        }
        
        if (!isPreIPhone5) {
            
            self.rockpackLogoImage.frame = self.rockpackLogoImage.frame;
            [UIView animateWithDuration:0.3f
                                  delay:0.1f
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.rockpackLogoImage.frame = CGRectMake(self.rockpackLogoImage.frame.origin.x, 35.0f,
                                                                           self.rockpackLogoImage.frame.size.width,
                                                                           self.rockpackLogoImage.frame.size.height);
                         
                             } completion:^(BOOL finished) {
                            }];
        }
    
        
        
    self.whatsOnYourChannelLabel.frame = self.whatsOnYourChannelLabel.frame;
    self.whatsOnYourChannelLabel.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.whatsOnYourChannelLabel.frame = CGRectMake(self.whatsOnYourChannelLabel.frame.origin.x, 100.0f, self.whatsOnYourChannelLabel.frame.size.width, self.whatsOnYourChannelLabel.frame.size.height);
                         self.whatsOnYourChannelLabel.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                     }];
    
    
    
    self.facebookButton.alpha = 0.0f;
    CGRect facebookButtonFrame = self.facebookButton.frame;
    if(!isPreIPhone5)
        facebookButtonFrame.origin.y += isPreIPhone5 ? 80.0 : IS_IOS_7_OR_GREATER ? 110.0 : 90.0;
    
    self.facebookButton.frame = facebookButtonFrame;
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.facebookButton.alpha = 1.0f;
                         self.facebookButton.frame = CGRectMake(self.facebookButton.frame.origin.x,
                                                                self.facebookButton.frame.origin.y - 20.0f,
                                                                self.facebookButton.frame.size.width,
                                                                self.facebookButton.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         
                         
                     }];
    
    self.signupButton.alpha = 0.0f;
    CGRect signUpButtonFrame = self.signupButton.frame;
    if(!isPreIPhone5)
        signUpButtonFrame.origin.y += isPreIPhone5 ? 80.0 : IS_IOS_7_OR_GREATER ? 110.0 : 90.0;
    self.signupButton.frame = signUpButtonFrame;
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.signupButton.alpha = 1.0f;
                         self.signupButton.frame = CGRectMake(self.signupButton.frame.origin.x, self.signupButton.frame.origin.y - 20.0f, self.signupButton.frame.size.width, self.signupButton.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         
                         
                     }];
    
    self.loginButton.alpha = 0.0f;
    CGRect loginButtonFrame = self.loginButton.frame;
    if(!isPreIPhone5)
        loginButtonFrame.origin.y += isPreIPhone5 ? 80.0 : IS_IOS_7_OR_GREATER ? 110.0 : 90.0;
    self.loginButton.frame = loginButtonFrame;
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.loginButton.alpha = 1.0f;
                         self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x, self.loginButton.frame.origin.y - 20.0f, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                     }];
        
        self.whiteLineView.alpha = 0.0f;
        CGRect whiteLineViewFrame = self.whiteLineView.frame;
        if(!isPreIPhone5)
            whiteLineViewFrame.origin.y += isPreIPhone5 ? 80.0 : IS_IOS_7_OR_GREATER ? 110.0 : 90.0;
        self.whiteLineView.frame = whiteLineViewFrame;
        
        [UIView animateWithDuration:0.3f
                              delay:0.1f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.whiteLineView.alpha = 0.8f;
                             
                             self.whiteLineView.frame = CGRectMake(self.whiteLineView.frame.origin.x, self.whiteLineView.frame.origin.y - 20.0f, self.whiteLineView.frame.size.width, self.whiteLineView.frame.size.height);
                             
                         } completion:^(BOOL finished) {
                         }];
        
        self.hasAnimated=YES;
    }
}

-(void)reEnableLoginControls
{
    
}


#pragma mark - Onboarding support




#pragma mark - button IBActions

- (IBAction) facebookTapped: (id) sender
{
    [self hideOnboarding];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"facebookLogin"
                                                            label: nil
                                                            value: nil] build]];
    
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    [self doFacebookLoginAnimation];
    
    [self loginThroughFacebookWithCompletionHandler:^(NSDictionary * dictionary) {
        
        
        [self completeLoginProcess];
        
    } errorHandler:^(id error) {
        [self doFacebookFailAnimation];
        if([error isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* formErrors = error[@"form_errors"];

            
            if (formErrors)
            {
                [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
                                            message: NSLocalizedString(@"facebook_login_error_description", nil)
                                           delegate: nil
                                  cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                  otherButtonTitles: nil] show];
            }
            
        }
        else if([error isKindOfClass:[NSString class]])
        {
            // TODO: Use custom alert box here
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
                                        message: error
                                       delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil] show];
            
            DebugLog(@"Log in failed!");
        }
        else
        {
            //Should not happen!
        }

    }];
}


- (IBAction) signupTapped: (id) sender
{
    [self hideOnboarding];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"userRegistration"
                                                            label: @"Rockpack"
                                                            value: nil] build]];
    
    // Google analytics support
    [tracker set: kGAIScreenName
           value: @"Register"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         self.loginBackgroundFrontImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                     }];
    
    self.state = kLoginScreenStateRegister;
    
    [self turnOnButton:self.cancelButton];
    [self turnOnButton:self.nextButton];
    
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.firstSignupView.center;
        newCenter.x = 160.0f;
        self.firstSignupView.center = newCenter;
        
        newCenter = self.termsAndConditionsView.center;
        newCenter.x = 160.0f;
        self.termsAndConditionsView.center = newCenter;
        
        newCenter = self.initialView.center;
        newCenter.x = -160.0f;
        self.initialView.center = newCenter;
        
    } completion:nil];
    
}


- (IBAction) loginTapped: (id) sender
{
    [self hideOnboarding];

    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Login"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         self.loginBackgroundFrontImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    self.state = kLoginScreenStateLogin;
    
    [self turnOnButton:self.backButton];
    [self turnOnButton:self.confirmButton];
    
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.loginView.center;
        newCenter.x = 160.0f;
        self.loginView.center = newCenter;
        
        newCenter = self.initialView.center;
        newCenter.x = -160.0f;
        self.initialView.center = newCenter;
    } completion:^(BOOL finished) {
        [self.userNameInputField becomeFirstResponder];
        
    }];
}


- (IBAction) forgotPasswordTapped: (id) sender
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Forgot password"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
     
    self.state = kLoginScreenStatePasswordRetrieve;
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.passwordView.center;
        newCenter.x = 160.0f;
        self.passwordView.center = newCenter;
        
        newCenter = self.loginView.center;
        newCenter.x = -160.0f;
        self.loginView.center = newCenter;
    } completion:^(BOOL finished) {
        [self.emailInputField becomeFirstResponder];
        
    }];

}


- (IBAction) photoButtonTapped: (id) sender
{
            self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController:self];
            self.imagePicker.delegate = self;
            [self.imagePicker presentImagePickerAsPopupFromView:nil arrowDirection:UIPopoverArrowDirectionLeft];
}


- (IBAction) backbuttonTapped: (id) sender
{
    switch (self.state)
    {
        case kLoginScreenStateRegisterStepTwo:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            [self turnOnButton:self.nextButton];
            [self turnOnButton:self.cancelButton];
            self.state = kLoginScreenStateRegister;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.secondSignupView.center;
                newCenter.x = 480.0f;
                self.secondSignupView.center = newCenter;
                
                newCenter = self.firstSignupView.center;
                newCenter.x = 160.0f;
                self.firstSignupView.center = newCenter;
                
                newCenter = self.termsAndConditionsView.center;
                newCenter.x = 160.0f;
                self.termsAndConditionsView.center = newCenter;
                
                
            } completion:^(BOOL finished) {
                [self.registeringUserNameInputField becomeFirstResponder];
                [self turnOffButton:self.backButton];
            }];
            
            break;
        }
        case kLoginScreenStatePasswordRetrieve:
        {
            self.state = kLoginScreenStateLogin;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.passwordView.center;
                newCenter.x = 480.0f;
                self.passwordView.center = newCenter;
                
                newCenter = self.loginView.center;
                newCenter.x = 160.0f;
                self.loginView.center = newCenter;
            } completion:^(BOOL finished) {
                [self.userNameInputField becomeFirstResponder];
            }];

            break;
        }
        case kLoginScreenStateLogin:
        default:
        {
            //Fade in login background
            self.loginBackgroundImage.alpha = 0.0f;
            
            [self showOnboarding];
            
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options: UIViewAnimationCurveEaseInOut
                             animations:^{
                                 self.loginBackgroundImage.alpha = 1.0f;
                                 self.loginBackgroundFrontImage.alpha = 1.0f;
                                 
                             } completion:^(BOOL finished) {
                             }];
            
            self.state = kLoginScreenStateInitial;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.loginView.center;
                newCenter.x = 480.0f;
                self.loginView.center = newCenter;
                newCenter = self.initialView.center;
                newCenter.x = 160.0f;
                self.initialView.center = newCenter;
            } completion:nil];
            [[self.loginView subviews] makeObjectsPerformSelector:@selector(resignFirstResponder)];
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            break;
        }
    }
}


- (IBAction) cancelTapped: (id) sender
{
    switch (self.state)
    {
        case kLoginScreenStateRegister:
        {
            //Fade in login background
            self.loginBackgroundImage.alpha = 0.0f;
            
            [self showOnboarding];
            
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options: UIViewAnimationCurveEaseInOut
                             animations:^{
                                 self.loginBackgroundImage.alpha = 1.0f;
                                 self.loginBackgroundFrontImage.alpha = 1.0f;
                                 
                             } completion:^(BOOL finished) {
                             }];
            
            self.state = kLoginScreenStateInitial;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.firstSignupView.center;
                newCenter.x = 480.0f;
                self.firstSignupView.center = newCenter;
                
                newCenter = self.termsAndConditionsView.center;
                newCenter.x = 480.0f;
                self.termsAndConditionsView.center = newCenter;
                
                newCenter = self.initialView.center;
                newCenter.x = 160.0f;
                self.initialView.center = newCenter;
            } completion:nil];
            [self turnOffButton:self.cancelButton];
            [self turnOffButton:self.nextButton];
            [[self.firstSignupView subviews] makeObjectsPerformSelector:@selector(resignFirstResponder)];
            break;
        }
        default:
            break;
    }

}


- (IBAction) confirmTapped: (id) sender
{
    BOOL valid = YES;
    switch (self.state) {
            case kLoginScreenStateLogin:
                valid = [self loginFormIsValidForUsername:self.userNameInputField password:self.passwordInputField];
                break;
            case kLoginScreenStateRegisterStepTwo:
                valid = [self registrationFormIsValidForEmail:self.registeringUserEmailInputField userName:self.registeringUserNameInputField password:self.registeringUserPasswordInputField dd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
                break;
            case kLoginScreenStatePasswordRetrieve:
                valid = [self resetPasswordFormIsValidForUsername:self.emailInputField];
                break;
            default:
                valid = NO;
                break;
    }
    
    //Registration screen has no space for the keyboard together with the error message. ensure keyboard is always not showing on this screen.
    [self.registeringUserEmailInputField resignFirstResponder];
    [self.registeringUserPasswordInputField resignFirstResponder];
    [self.ddInputField resignFirstResponder];
    [self.yyyyInputField resignFirstResponder];
    [self.mmInputField resignFirstResponder];
    
    if(!valid)
    {
        return;
    }
    
    // Hide the keyboard.
    [self.userNameInputField resignFirstResponder];
    [self.passwordInputField resignFirstResponder];
    [self.emailInputField resignFirstResponder];
    
    if(![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    switch (self.state) {
        case kLoginScreenStateLogin:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            self.activityIndicator.hidden = NO;
            self.activityIndicator.center = self.confirmButton.center;
            [self.activityIndicator startAnimating];
            [self loginForUsername:self.userNameInputField.text forPassword:self.passwordInputField.text completionHandler:^(NSDictionary* dictionary) {
         
//                DebugLog(@"User Registerd: %@", [dictionary objectForKey:@"username"]);
                
                [self.activityIndicator stopAnimating];
                
                [self completeLoginProcess];
                
                id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

                [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                       action: @"userLogin"
                                                                        label: @"Rockpack"
                                                                        value: nil] build]];
                
            } errorHandler:^(NSDictionary* errorDictionary) {
                
                [self.activityIndicator stopAnimating];
                [self turnOnButton:self.backButton];
                [self turnOnButton:self.confirmButton];
                
                NSError* networkError = [errorDictionary valueForKey:@"nserror"];
                if (networkError.code >= 500 && networkError.code <600) {
                    return;
                }
                
                NSString* savingError = errorDictionary[@"saving_error"];
                if(savingError) {
                    self.loginErrorLabel.text = NSLocalizedString(@"login_screen_saving_error", nil);
                } else {
                    self.loginErrorLabel.text = NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil);
                }
                
                
            }];
            break;
        }
        case kLoginScreenStateRegisterStepTwo:
        {
            self.activityIndicator.center = self.confirmButton.center;
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            self.ddInputField.text = [self zeroPadIfOneCharacter:self.ddInputField.text];
            self.mmInputField.text = [self zeroPadIfOneCharacter:self.mmInputField.text];
            NSDictionary* userData = @{@"username": self.registeringUserNameInputField.text,
                                       @"password": self.registeringUserPasswordInputField.text,
                                       @"date_of_birth": [NSString stringWithFormat:@"%@-%@-%@", self.yyyyInputField.text, self.mmInputField.text, self.ddInputField.text],
                                       @"locale":@"en-US",
                                       @"email": self.registeringUserEmailInputField.text};
            [self registerUserWithData:userData completionHandler:^(NSDictionary*dictionary) {
                [self.activityIndicator stopAnimating];
                
                if(self.avatarImage)
                {
                    [self uploadAvatarImage: self.avatarImage completionHandler: ^(id dummy){
                    }
                               errorHandler: ^(id dictionary) {
                                   [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title", nil)
                                                               message: NSLocalizedString(@"register_screen_form_avatar_upload_description", nil)
                                                              delegate: nil
                                                     cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                                     otherButtonTitles: nil] show];
                               }];
                }
                [self completeLoginProcess];
                
            } errorHandler:^(NSDictionary* errorDictionary) {
                
                [self.activityIndicator stopAnimating];
                [self turnOnButton:self.backButton];
                [self turnOnButton:self.confirmButton];
                
                NSError* networkError = [errorDictionary valueForKey:@"nserror"];
                if (networkError.code >= 500 && networkError.code <600) {
                    return;
                }
                
                NSDictionary* formErrors = errorDictionary[@"form_errors"];
                NSString* errorString;
                BOOL append = NO;
                if (formErrors)
                {
                    NSArray* usernameError = formErrors[@"username"];
                    if(usernameError)
                    {
                        errorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Username", nil), usernameError[0]];
                        append = YES;
                    }
                    
                    NSArray* emailError = formErrors[@"email"];
                    if (emailError)
                    {
                        NSString* emailErrorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Email", nil),emailError[0]];
                        if(append)
                        {
                            errorString = [NSString stringWithFormat:@"%@\n%@",errorString, emailErrorString];
                        }
                        else
                        {
                            errorString = emailErrorString;
                        }
                    }
                    
                    NSArray* passwordError = formErrors[@"password"];
                    if (passwordError)
                    {
                        NSString* passwordErrorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Password", nil),passwordError[0]];
                        if(append)
                        {
                            errorString = [NSString stringWithFormat:@"%@\n%@",errorString, passwordErrorString];
                        }
                        else
                        {
                            errorString = passwordErrorString;
                        }
                    }
                    
                    NSArray* dateError = formErrors[@"date_of_birth"];
                    if (dateError)
                    {
                        NSString* dateErrorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"DOB", nil),dateError[0]];
                        if(append)
                        {
                            errorString = [NSString stringWithFormat:@"%@\n%@",errorString, dateErrorString];
                        }
                        else
                        {
                            errorString = dateErrorString;
                        }
                    }
                    
                    if(errorString)
                    {
                        self.signupErrorLabel.text = errorString;
                        CGFloat width = self.signupErrorLabel.frame.size.width;
                        [self.signupErrorLabel sizeToFit];
                        CGRect newFrame = self.signupErrorLabel.frame;
                        newFrame.size.width = width;
                        self.signupErrorLabel.frame = newFrame;
                    }
                }

            }];
            break;
        }
        case kLoginScreenStatePasswordRetrieve:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            [self doRequestPasswordResetForUsername:self.emailInputField.text completionHandler:^(NSDictionary *completionInfo) {
                if ([completionInfo valueForKey:@"error"])
                {
                    self.passwordResetErrorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_username_user_unknown", nil);
                    [self turnOnButton:self.backButton];
                    [self turnOnButton:self.confirmButton];
                    
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"forgot_password_screen_complete_title", nil)
                                                message: NSLocalizedString(@"forgot_password_screen_complete_message", nil)
                                               delegate: nil
                                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                      otherButtonTitles: nil] show];
                    [self turnOnButton:self.backButton];
                    
                }

            } errorHandler:^(NSError *error) {
                self.passwordResetErrorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_request_failed_error", nil);
                [self turnOnButton:self.backButton];
                [self turnOnButton:self.confirmButton];
            }];
            break;
        }
        default:
            break;
    } 
}


- (IBAction) nextTapped: (id) sender
{
    BOOL valid = YES;
    switch (self.state) {
            case kLoginScreenStateRegister:
               [self.registeringUserNameInputField resignFirstResponder];
               valid = [self registrationFormPartOneIsValidForUserName:self.registeringUserNameInputField];
               break;
            default:
            valid = NO;
                break;
        }
    
    if(!valid)
    {
        return;
    }
    
    if(!self.validUsernames)
    {
        self.validUsernames = [NSMutableArray array];
    }
    else
    {
        if([self.validUsernames indexOfObject:self.registeringUserNameInputField.text] !=NSNotFound)
        {
            [self showRegistrationStep2];
            return;
        }
    }
    
    [self.activityIndicator startAnimating];
    [self turnOffButton:self.cancelButton];
    [self turnOffButton:self.nextButton];
    
    [self doRequestUsernameAvailabilityForUsername:self.registeringUserNameInputField.text completionHandler:^(NSDictionary *result) {
        
        [self.activityIndicator stopAnimating];
        [self turnOnButton:self.cancelButton];
        
        NSNumber* availabilitynumber = result[@"available"];
        if(availabilitynumber)
        {
        BOOL usernameAvailable = [availabilitynumber boolValue];
            if(usernameAvailable)
            {
                [self.validUsernames addObject:self.registeringUserNameInputField.text];
                [self showRegistrationStep2];
            }
            else
            {
                [self turnOnButton:self.nextButton];
                self.registeringUserErrorLabel.text = NSLocalizedString(@"register_screen_form_field_username_already_taken", nil);
            }
        }
        else
        {
            NSArray* formErrors = result[@"message"];
            NSString* errorString = self.registeringUserErrorLabel.text = NSLocalizedString(@"unknown_error_message", nil);
            if (formErrors && [formErrors count]>0)
            {
                errorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Username", nil), formErrors[0]];
            }
            
            self.registeringUserErrorLabel.text = errorString;
            
            [self turnOnButton:self.nextButton];
        }
    } errorHandler:^(NSError *error) {
        
        [self.activityIndicator stopAnimating];
        [self turnOnButton:self.cancelButton];
        [self turnOnButton:self.nextButton];
        self.registeringUserErrorLabel.text = NSLocalizedString(@"unknown_error_message", nil);

        
    }];

    
}

- (IBAction) termsTapped: (id) sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: kLoginTermsUrl]];

}


- (IBAction) privacyPolicyTapped: (id) sender
{

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: kLoginPrivacyUrl]];
    
}


#pragma mark - show registration step 2 animation

-(void)showRegistrationStep2
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Register 2"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    self.state = kLoginScreenStateRegisterStepTwo;
    [self turnOnButton:self.backButton];
    [self turnOnButton:self.confirmButton];
    [self turnOffButton:self.nextButton];
    [self turnOffButton:self.cancelButton];
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.secondSignupView.center;
        newCenter.x = 160.0f;
        self.secondSignupView.center = newCenter;
        
        newCenter = self.firstSignupView.center;
        newCenter.x = -160.0f;
        self.firstSignupView.center = newCenter;
        
    } completion:^(BOOL finished) {
        [self.registeringUserEmailInputField becomeFirstResponder];
    }];
    
}


#pragma mark - facebook UI animation

- (void) doFacebookLoginAnimation
{
    self.activityIndicator.center = self.initialView.center;
    self.activityIndicator.hidden = NO;
    self.activityIndicator.color = [UIColor whiteColor];
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.signupButton.alpha = 0.0f;
        self.loginButton.alpha = 0.0f;
        self.facebookButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if(finished)
        {
            self.signupButton.enabled = NO;
            self.loginButton.enabled = NO;
            self.facebookButton.enabled = NO;
        }
    }];
}


- (void) doFacebookFailAnimation
{
    [self.activityIndicator stopAnimating];
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.signupButton.alpha = 1.0f;
        self.loginButton.alpha = 1.0f;
        self.facebookButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if(finished)
        {
            self.signupButton.enabled = YES;
            self.loginButton.enabled = YES;
            self.facebookButton.enabled = YES;
        }
    }];
}


#pragma mark - login completion

- (void) completeLoginProcess
{

    [self.activityIndicator stopAnimating];
    
    if (self.loginBackgroundImage.alpha == 1.0f)
    {
        //Fade out login background
        self.loginBackgroundImage.alpha = 1.0f;
        
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.loginBackgroundImage.alpha = 0.0f;
                             self.loginBackgroundFrontImage.alpha = 0.0f;
                             
                         } completion:^(BOOL finished) {
                         }];
    }
    
    UIImageView *splashView = nil;
    if([SYNDeviceManager.sharedInstance currentScreenHeight]>480.0f)
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default-568h"]];
    }
    else
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
    }
    splashView.center = CGPointMake(160.0f, splashView.center.y - 20.0f);
    splashView.alpha = 0.0;
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         splashView.alpha = 1.0;
                     }
                     completion: ^(BOOL finished)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName: kLoginCompleted
                                                             object: self];
         
         
     }];
}

#pragma mark - UITextField delegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    
    NSUInteger oldLength = textField.text.length;
    NSUInteger replacementLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + replacementLength) - rangeLength;
    
    
    if ((textField == self.ddInputField || textField == self.mmInputField) && newLength > 2)
        return NO;
    if (textField == self.yyyyInputField && newLength > 4)
        return NO;
    if(textField == self.registeringUserNameInputField && newLength > 20)
        return NO;
    
    
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    if (textField == self.ddInputField || textField == self.mmInputField || textField == self.yyyyInputField)
        if (![numberFormatter numberFromString:newCharacter] && newCharacter.length != 0) // is backspace, length is 0
            return NO;

    return YES;
}

- (IBAction) textfieldDidChange: (id) sender
{
    self.signupErrorLabel.text = @"";
    self.loginErrorLabel.text = @"";
    self.passwordResetErrorLabel.text = @"";
    self.registeringUserErrorLabel.text = @"";
    
    UIView* nextView = [self.view viewWithTag: ((UITextField*)sender).tag + 1];
    
    if(sender == self.ddInputField && [self.ddInputField.text length] == 2)
    {
        if(nextView && [nextView isKindOfClass:[UITextField class]])
            [(UITextField*)nextView becomeFirstResponder];
        
        if([self.mmInputField.text length] > 0 && [self.yyyyInputField.text length]>0 )
        {
            [self dateValidForDd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
        }
    }
    else if(sender == self.mmInputField && [self.mmInputField.text length]==2)
    {
        if(nextView && [nextView isKindOfClass:[UITextField class]])
            [(UITextField*)nextView becomeFirstResponder];
        
        if([self.ddInputField.text length] > 0 && [self.yyyyInputField.text length]>0 )
        {
            [self dateValidForDd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
        }
    }
    else if(sender == self.yyyyInputField && [self.yyyyInputField.text length] >= 4)
    {
    
        [sender resignFirstResponder];
        [self dateValidForDd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
    }
    
    if(![self.signupErrorLabel.text isEqualToString: @""])
    {
        [sender resignFirstResponder];
    }
    
}


- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    UIView* nextView = [self.view viewWithTag: textField.tag + 1];
    if (nextView)
    {
        [nextView becomeFirstResponder];
    }
    else
    {
        switch (textField.tag) {
            case 2:
            case 4:
            case 12:
                //Last field on a form. Confirm!
                if(self.confirmButton.enabled)
                {
                    [self confirmTapped:nil];
                }
                break;
            case 6:
                //First page of Sign Up. Go next!
                if(self.nextButton.enabled)
                {
                    [self nextTapped:nil];
                }
                break;
            default:
                [textField resignFirstResponder];
                break;
        }
    }
    
    
    return YES;
}


#pragma mark - button enabling convenience methods

- (void) turnOnButton: (UIButton*) button
{
    button.hidden = NO;
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.alpha = 1.0f;
    } completion:nil];
    
}


- (void) turnOffButton: (UIButton*) button
{
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.alpha = 0.0f;
    } completion:nil];
}


- (void) picker: (SYNImagePickerController *) picker
         finishedWithImage: (UIImage *) image
{
    self.imagePicker = nil;
    // Save our avatar
    self.avatarImage = image;
    
    // And update on-screen avatar
    self.avatarImageView.image = image;
}



#pragma mark - validation
- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view
{
    
    UILabel* errorLabel = nil;
    switch (self.state) {
        case kLoginScreenStateLogin:
            errorLabel = self.loginErrorLabel;
            break;
        case kLoginScreenStateRegister:
            errorLabel = self.registeringUserErrorLabel;
            break;
        case kLoginScreenStateRegisterStepTwo:
            errorLabel = self.signupErrorLabel;
            break;
        case kLoginScreenStatePasswordRetrieve:
            errorLabel = self.passwordResetErrorLabel;
            break;
        default:
            break;
    }
    
    errorLabel.text = errorText;
}

- (void) applicationResume
{
    [self doFacebookFailAnimation];
    [super applicationResume];
        
}


@end
