//
//  SYNLoginViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "NSString+Utils.h"
#import "RegexKitLite.h"
#import "SYNAccountSettingsPopoverBackgroundView.h"
#import "SYNActivityManager.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNDeviceManager.h"
#import "SYNLoginErrorArrow.h"
#import "SYNLoginViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuth2Credential.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNTextFieldLogin.h"
#import "UIFont+SYNFont.h"
#import "User.h"

@interface SYNLoginViewController ()  <UITextFieldDelegate,
                                       SYNImagePickerControllerDelegate,
                                       UIPageViewControllerDataSource,
                                       UIPageViewControllerDelegate>

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) CGRect facebookButtonInitialFrame;
@property (nonatomic) CGRect initialUsernameFrame;
@property (nonatomic) CGRect signUpButtonInitialFrame;
@property (nonatomic, readonly) CGFloat elementsOffsetY;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* ddInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* emailInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* mmInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* passwordInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* userNameInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* yyyyInputField;
@property (nonatomic, strong) IBOutlet UIButton* faceImageButton;
@property (nonatomic, strong) IBOutlet UIButton* facebookSignInButton;
@property (nonatomic, strong) IBOutlet UIButton* finalLoginButton;
@property (nonatomic, strong) IBOutlet UIButton* loginButton;
@property (nonatomic, strong) IBOutlet UIButton* registerButton;
@property (nonatomic, strong) IBOutlet UIButton* registerNewUserButton;
@property (nonatomic, strong) IBOutlet UIButton* sendEmailButton;
@property (nonatomic, strong) IBOutlet UIButton* signUpButton;
@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView* dividerImageView;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundImage;
@property (nonatomic, strong) IBOutlet UIImageView* titleImageView;
@property (nonatomic, strong) IBOutlet UILabel* memberLabel;
@property (nonatomic, strong) IBOutlet UILabel* passwordForgottenLabel;
@property (nonatomic, strong) IBOutlet UILabel* secondaryFacebookMessage;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabelSide;
@property (nonatomic, strong) IBOutlet UILabel* areYouNewLabel;
@property (nonatomic, strong) IBOutlet UILabel* wellSendYouLabel;
@property (nonatomic, strong) IBOutlet UILabel* whatsOnYourChannelLabel;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (nonatomic, strong) NSArray* mainFormElements;
@property (nonatomic, strong) NSMutableDictionary* labelsToErrorArrows;
@property (nonatomic, strong) UIButton* termsAndConditionsButton;
@property (nonatomic, strong) UIPopoverController* cameraMenuPopoverController;
@property (nonatomic, strong) UIPopoverController* cameraPopoverController;
@property (strong, nonatomic) NSArray *onboardingViewControllers;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end


#define kOffsetForRegisterForm 100.0

@implementation SYNLoginViewController

@synthesize state;
@synthesize signUpButton, facebookSignInButton;
@synthesize loginButton, finalLoginButton, passwordInputField, registerButton, userNameInputField;
@synthesize passwordForgottenButton, passwordForgottenLabel, areYouNewLabel, memberLabel, termsAndConditionsLabel;
@synthesize activityIndicator, dividerImageView, secondaryFacebookMessage;
@synthesize isAnimating, termsAndConditionsLabelSide;
@synthesize emailInputField, dobView, registerNewUserButton;
@synthesize titleImageView;
@synthesize ddInputField, mmInputField, yyyyInputField;
@synthesize labelsToErrorArrows;
@synthesize faceImageButton, facebookButtonInitialFrame, signUpButtonInitialFrame;
@synthesize sendEmailButton;
@synthesize wellSendYouLabel;
@synthesize elementsOffsetY;
@synthesize termsAndConditionsButton;

#pragma mark - Object lifecycle

- (void) dealloc
{
    self.imagePicker.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    activityIndicator.hidesWhenStopped = YES;
    
        // == Setup Fonts for labels (except Input Fields)
    UIFont* rockpackBigLabelFont = [UIFont rockpackFontOfSize: 20];
        
    memberLabel.font = rockpackBigLabelFont;
    areYouNewLabel.font = rockpackBigLabelFont;
        
    passwordForgottenLabel.font = [UIFont rockpackFontOfSize: 14.0];
    secondaryFacebookMessage.font = [UIFont rockpackFontOfSize: 20.0];
    termsAndConditionsLabel.font = [UIFont rockpackFontOfSize: 14.0];
    termsAndConditionsLabelSide.font = termsAndConditionsLabel.font;
    wellSendYouLabel.font = [UIFont rockpackFontOfSize: 16.0];
         
    NSMutableAttributedString* termsString = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"register_screen_legal", nil)];
    
    
    

        // TERMS & SERVICESs
    
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)] range: NSMakeRange(36, 17)];
    
        
    
    
        // PRIVACY POLICY
    
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)] range: NSMakeRange(58, 14)];    
        
    
        // add terms buttons
    termsAndConditionsLabel.attributedText = termsString;
    termsAndConditionsLabelSide.attributedText = termsAndConditionsLabel.attributedText;
    
    self.termsAndConditionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.termsAndConditionsButton.frame = self.termsAndConditionsLabel.frame;
    [self.termsAndConditionsButton addTarget:self action:@selector(termsAndConditionsPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:termsAndConditionsButton];
    
    
    labelsToErrorArrows = [[NSMutableDictionary alloc] init];
        
    ddInputField.keyboardType = UIKeyboardTypeNumberPad;
    mmInputField.keyboardType = UIKeyboardTypeNumberPad;
    yyyyInputField.keyboardType = UIKeyboardTypeNumberPad;
    
    facebookButtonInitialFrame = facebookSignInButton.frame;
    signUpButtonInitialFrame = signUpButton.frame;
        
    emailInputField.keyboardType = UIKeyboardTypeEmailAddress;
        
    self.mainFormElements = @[];
        
    // == Setup Input Fields
        
    UIFont* rockpackInputFont = [UIFont rockpackFontOfSize: 20];
    NSArray* textFieldsToSetup = @[emailInputField, userNameInputField, passwordInputField,
                                       ddInputField, mmInputField, yyyyInputField];
        
    for (UITextField* tf in textFieldsToSetup)
    {
        tf.font = rockpackInputFont;
//        // -- this is to create the left padding for the text fields (hack) -- //
//        tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 57)];
//        tf.leftViewMode = UITextFieldViewModeAlways;
    }
    
    if([[SYNDeviceManager sharedInstance] isPortrait])
    {
        
        signUpButton.center = CGPointMake(facebookSignInButton.center.x + 304.0, signUpButton.center.y);

    }
    
    CGRect signUpButtonFrame  = signUpButton.frame;
    if([[SYNDeviceManager sharedInstance] isPortrait])
        signUpButtonFrame.origin.x = 644.0f;
    
    signUpButton.frame = signUpButtonFrame;
    
    self.state = kLoginScreenStateInitial;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outerViewTapped:)];
    [self.view addGestureRecognizer:tapGesture];
    
    
    CGRect onBoardingViewFrame = self.onBoardingController.view.frame;
    onBoardingViewFrame.origin.x = 0.0;
    onBoardingViewFrame.origin.y = [[SYNDeviceManager sharedInstance] isLandscape] ? 100.0 : 280.0;
    self.onBoardingController.view.frame = onBoardingViewFrame;
    [self.view addSubview:self.onBoardingController.view];
    [self addChildViewController:self.onBoardingController];
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];

    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Start"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    memberLabel.center = CGPointMake(memberLabel.center.x, loginButton.center.y - 54.0);
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
    
}


#pragma mark - Onboarding support

- (void) hideOnboarding
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.pageViewController.view.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         self.pageViewController.view.hidden = TRUE;
                     }];
    self.backgroundImageView.hidden = YES;
    self.lowerParallaxImageView.alpha = 0.0f;
    self.lowerParallaxImageView.hidden = YES;
    self.upperParallaxImageView.alpha = 0.0f;
    self.upperParallaxImageView.hidden = YES;
}

- (void) showOnboarding
{
    self.pageViewController.view.hidden = FALSE;
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.pageViewController.view.alpha = 1.0f;
                     } completion: nil];
    
    self.backgroundImageView.hidden = NO;
    self.lowerParallaxImageView.alpha = 1.0f;
    self.lowerParallaxImageView.hidden = NO;
    self.upperParallaxImageView.alpha = 1.0f;
    self.upperParallaxImageView.hidden = NO;
}


#pragma mark - Page View Controller Data Source

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController
       viewControllerBeforeViewController: (UIViewController *) viewController
{
    NSUInteger numberOfOnboardViewControllers = self.onboardingViewControllers.count;
    int index = 0;
    for (UIViewController *vc in self.onboardingViewControllers)
    {
        if (vc == viewController)
        {
#ifdef WRAP_AROUND
            if (index == 0)
            {
                return nil;
            }
            else
            {
                return self.onboardingViewControllers[index - 1];
            }
#else
            if (index == 0)
            {
                return self.onboardingViewControllers [numberOfOnboardViewControllers - 1];
            }
            else
            {
                return self.onboardingViewControllers [index - 1];
            }
#endif
        }
        
        index++;
    }
    
    // If we got here then we didn't find the viewcontroller
    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController
        viewControllerAfterViewController: (UIViewController *) viewController
{
    NSUInteger numberOfOnboardViewControllers = self.onboardingViewControllers.count;
    int index = 0;
    for (UIViewController *vc in self.onboardingViewControllers)
    {
        if (vc == viewController)
        {
#ifdef WRAP_AROUND
            if (index == (self.onboardingViewControllers.count - 1))
            {
                return nil;
            }
            else
            {
                return self.onboardingViewControllers[(index + 1) % numberOfOnboardViewControllers];
            }
#else
            return self.onboardingViewControllers [(index + 1) % numberOfOnboardViewControllers];
#endif
        }
        
        index++;
    }
    
    // If we got here then we didn't find the viewcontroller
    return nil;
}



- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return self.onboardingViewControllers.count;
}


- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    // Start off showing the first view controller
    return 0;
}

-(void)termsAndConditionsPressed:(UIButton*)button withEvent:(UIEvent*)event
{
    CGPoint center = [[[event allTouches] anyObject] locationInView:button];
    BOOL isLeft = center.x > (self.termsAndConditionsButton.frame.size.width * 0.5);
    NSURL* urlToGo;
    if(isLeft)
    {
        urlToGo = [NSURL URLWithString: kLoginPrivacyUrl];
        
    }
    else
    {
        urlToGo = [NSURL URLWithString: kLoginTermsUrl];
    }
    
    [[UIApplication sharedApplication] openURL:urlToGo];
}



#pragma mark - States and Transitions

- (void) setState: (kLoginScreenState) newState
{
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (newState == state)
        return;
    
    if (newState == kLoginScreenStateInitial)
    {
        // This gets called before the GA is setup, so move to viewDidAppear
//        [GAI.sharedInstance.defaultTracker sendView: @"Start"];
        [self setUpInitialState];
    }
    else if (newState == kLoginScreenStateLogin)
    {
        [tracker set: kGAIScreenName
               value: @"Login"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        
        [self setUpLoginStateFromPreviousState:state];
    }
    else if (newState == kLoginScreenStateRegister)
    {
        [tracker set: kGAIScreenName
               value: @"Register"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        
        [self setUpRegisterStateFromState: state];
    }
    else if (newState == kLoginScreenStatePasswordRetrieve)
    {
        [tracker set: kGAIScreenName
               value: @"Forgot password"];
        
        [tracker send: [[GAIDictionaryBuilder createAppView] build]];
        
        [self setUpPasswordState];
    }
    
    state = newState;
}


- (kLoginScreenState) state
{
    return state;
}


- (void) setUpInitialState
{
    [super setUpInitialState];
    
    // controls to hide initially
    NSArray* controlsToHide = @[userNameInputField, passwordInputField, finalLoginButton, secondaryFacebookMessage,
                                areYouNewLabel, registerButton, passwordForgottenLabel,
                                passwordForgottenButton, termsAndConditionsLabel, dobView, emailInputField,
                                registerNewUserButton, dividerImageView, faceImageButton, self.avatarImageView, sendEmailButton,
                                wellSendYouLabel, termsAndConditionsLabelSide];
    
    for (UIView* control in controlsToHide)
    {
        control.alpha = 0.0;
    }
    
    termsAndConditionsButton.enabled = NO;
    
    dobView.center = CGPointMake(dobView.center.x - 50.0, dobView.center.y);
    emailInputField.center = CGPointMake(emailInputField.center.x - 50.0, emailInputField.center.y);
    faceImageButton.center = CGPointMake(faceImageButton.center.x - 50.0, faceImageButton.center.y);
    self.avatarImageView.center = CGPointMake(self.avatarImageView.center.x - 50.0, self.avatarImageView.center.y);
    
    facebookSignInButton.enabled = YES;
    facebookSignInButton.alpha = 1.0;
    
    CGRect facebookButtonFrame = facebookSignInButton.frame;
    if([[SYNDeviceManager sharedInstance] isPortrait])
        facebookButtonFrame.origin.x = 150.0f;
    
    facebookSignInButton.frame = facebookButtonFrame;
    
    facebookSignInButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    
    _facebookLoginIsInProcess = NO;
    
    if ([SYNDeviceManager.sharedInstance isPortrait])
    {
        faceImageButton.center = CGPointMake(78.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(78.0, self.avatarImageView.center.y);
        passwordForgottenLabel.center = CGPointMake(115.0, passwordForgottenLabel.center.y);
        
    }

    signUpButton.enabled = YES;
    signUpButton.alpha = 1.0;
    signUpButton.hidden = NO;
    
    
    
    loginButton.enabled = YES;
    loginButton.hidden = NO;
    
    finalLoginButton.enabled = YES;
    
    userNameInputField.enabled = YES;
    passwordInputField.enabled = YES;
    
    [activityIndicator stopAnimating];
    
    
    // on boarding
    
    
}


- (void) setUpPasswordState
{    
    self.initialUsernameFrame = userNameInputField.frame;
    loginButton.frame = registerButton.frame;
    sendEmailButton.enabled = YES;
    memberLabel.center = CGPointMake(loginButton.center.x,
                                     registerButton.center.y - 57.0);
    
    userNameInputField.placeholder = NSLocalizedString(@"forgot_password_screen_form_field_username_placeholder", nil);
    
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
    
    [UIView animateWithDuration: 0.5
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations: ^{
                         facebookSignInButton.alpha = 0.0;
                         CGFloat diff = passwordInputField.frame.origin.y - userNameInputField.frame.origin.y;
                         userNameInputField.frame = passwordInputField.frame;
                         passwordInputField.alpha = 0.0;
                         emailInputField.alpha = 0.0;
                         finalLoginButton.alpha = 0.0;
                         passwordForgottenLabel.alpha = 0.0;
                         loginButton.alpha = 1.0;
                         
                         registerButton.alpha = 0.0;
                         
                         memberLabel.alpha = 1.0;
                         areYouNewLabel.alpha = 0.0;
                         sendEmailButton.alpha = 1.0;
                         dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y + diff);
                     }
                     completion: ^(BOOL finished) {
                         dividerImageView.frame = CGRectIntegral(dividerImageView.frame);
                         [UIView animateWithDuration: 0.3
                                          animations: ^{
                                              wellSendYouLabel.alpha = 1.0;
                                          }];
                     }];
}


- (void) setUpLoginStateFromPreviousState: (kLoginScreenState) previousState
{
    [super setUpLoginStateFromPreviousState:previousState];
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         self.loginBackgroundFrontImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         self.loginBackgroundImage.hidden = YES;
                         self.loginBackgroundFrontImage.hidden = YES;
                     }];
    
    secondaryFacebookMessage.alpha = 0.0;
    
    [self clearAllErrorArrows];
    
    isAnimating = YES;
    userNameInputField.placeholder = NSLocalizedString(@"login_screen_form_field_username_placeholder", nil);
    
    self.userNameInputField.returnKeyType = UIReturnKeyNext;
    self.passwordInputField.returnKeyType = UIReturnKeyGo;
    
    if (previousState == kLoginScreenStateInitial)
    {
        facebookSignInButton.frame = CGRectMake(userNameInputField.frame.origin.x - 4.0, 322.0, facebookSignInButton.frame.size.width, facebookSignInButton.frame.size.height);
        facebookSignInButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        NSArray* loginForControls = @[facebookSignInButton, userNameInputField, passwordInputField, finalLoginButton];
        float delay = 0.0;
        
        for (UIView* control in loginForControls)
        {
            control.hidden = NO;
            
            [UIView animateWithDuration: 0.4
                                  delay: delay
                                options: UIViewAnimationCurveEaseInOut
                             animations: ^{
                                 control.alpha = 1.0;
                                 control.center = CGPointMake(control.center.x, control.center.y - self.elementsOffsetY);
                             }
                             completion: ^(BOOL finished) {
                             }];
            
            delay += 0.05;
        }
        
        [UIView animateWithDuration: 0.3
                         animations: ^{
                             signUpButton.alpha = 0.0; // right of facebook button
                             signUpButton.hidden = YES;
                             
                             memberLabel.alpha = 0.0;
                             loginButton.alpha = 0.0;
                             
                             titleImageView.alpha = 0.0;
                             self.whatsOnYourChannelLabel.alpha = 0.0f;
                         }
                         completion: ^(BOOL finished) {
                             [self placeSecondaryElements];
                             
                             dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - self.elementsOffsetY);
                             
                             [UIView animateWithDuration: 0.2
                                              animations: ^{
                                                  passwordForgottenButton.alpha = 1.0;
                                                  passwordForgottenLabel.alpha = 1.0;
                                                  
                                                  dividerImageView.alpha = 1.0;
                                              }
                                              completion: ^(BOOL finished) {
                                                  [UIView animateWithDuration: 0.2
                                                                   animations: ^{
                                                                       areYouNewLabel.alpha = 1.0;
                                                                       registerButton.alpha = 1.0;
                                                                       
                                                                       termsAndConditionsLabel.alpha = 1.0;
                                                                       
                                                                       
                                                                   }
                                                                   completion: ^(BOOL finished) {
                                                                       isAnimating = NO;
                                                                       
                                                                       termsAndConditionsButton.enabled = YES;
                                                                       termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
                                                                       
                                                                       emailInputField.center = CGPointMake(emailInputField.center.x,
                                                                                                            emailInputField.center.y - self.elementsOffsetY);
                                                                       dobView.center = CGPointMake(dobView.center.x,
                                                                                                    dobView.center.y - self.elementsOffsetY);
                                                                       
                                                                       memberLabel.center = CGPointMake(memberLabel.center.x,
                                                                                                        registerButton.center.y - 57.0);
                                                                       
                                                                       
                                                                       memberLabel.frame = CGRectIntegral(memberLabel.frame);
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       sendEmailButton.frame = CGRectIntegral(sendEmailButton.frame);
                                                                       
                                                                       registerNewUserButton.center = CGPointMake(registerNewUserButton.center.x,
                                                                                                                  registerNewUserButton.center.y - self.elementsOffsetY);
                                                                       
                                                                       
                                                                       faceImageButton.center = CGPointMake(faceImageButton.center.x,
                                                                                                            faceImageButton.center.y - self.elementsOffsetY);
                                                                       
                                                                       self.avatarImageView.center = CGPointMake(self.avatarImageView.center.x,
                                                                                                            self.avatarImageView.center.y - self.elementsOffsetY);
                                                                       
                                                                       [userNameInputField becomeFirstResponder];
                                                                       
                                                                   }];
                                              }];
                         }];
        
    }
    else if (previousState == kLoginScreenStateRegister)
    {
        [UIView animateWithDuration: 0.5
                         animations: ^{
                             facebookSignInButton.alpha = 1.0;
                             facebookSignInButton.enabled = YES;
                             facebookSignInButton.center = CGPointMake(self.userNameInputField.center.x, facebookSignInButton.center.y);
                             
                             emailInputField.alpha = 0.0;
                             emailInputField.center = CGPointMake(userNameInputField.center.x - 50.0,
                                                                  emailInputField.center.y);
                             
                             dobView.alpha = 0.0;
                             dobView.center = CGPointMake(userNameInputField.center.x - 50.0,
                                                          dobView.center.y);

                             dividerImageView.alpha = 1.0;
                             
                             registerNewUserButton.alpha = 0.0;
                             
                             finalLoginButton.alpha = 1.0;
                             
                             finalLoginButton.center = CGPointMake(userNameInputField.center.x,
                                                                   finalLoginButton.center.y);
                             
                             faceImageButton.alpha = 0.0;
                             faceImageButton.center = CGPointMake(faceImageButton.center.x - 50.0,
                                                                  faceImageButton.center.y);
                             
                             self.avatarImageView.alpha = 0.0;
                             self.avatarImageView.center = CGPointMake(self.avatarImageView.center.x - 50.0,
                                                                  self.avatarImageView.center.y);
                             
                             passwordForgottenButton.alpha = 1.0;
                             passwordForgottenLabel.alpha = 1.0;
                             
                             registerButton.alpha = 1.0;
                             areYouNewLabel.alpha = 1.0;
                             
                             loginButton.alpha = 0.0;
                             memberLabel.alpha = 0.0;

                             termsAndConditionsLabelSide.alpha = 0.0;

                             termsAndConditionsLabel.alpha = 1.0;
                             
                         }
                         completion: ^(BOOL finished) {
                             isAnimating = NO;
                             
                             termsAndConditionsButton.enabled = YES;
                             termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
                             [userNameInputField becomeFirstResponder];
                         }];
    }
    else if (previousState == kLoginScreenStatePasswordRetrieve)
    {
        [UIView animateWithDuration: 0.5
                         animations: ^{
                             facebookSignInButton.alpha = 1.0;
                             facebookSignInButton.enabled = YES;
                             
                             CGFloat diff = userNameInputField.frame.origin.y - self.initialUsernameFrame.origin.y;
                             dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - diff);
                             
                             userNameInputField.frame = self.initialUsernameFrame;
                             
                             finalLoginButton.alpha = 1.0;

                             passwordForgottenButton.alpha = 1.0;
                             passwordForgottenLabel.alpha = 1.0;
                             
                             registerButton.alpha = 1.0;
                             areYouNewLabel.alpha = 1.0;
                             
                             loginButton.alpha = 0.0;
                             memberLabel.alpha = 0.0;
                             
                             sendEmailButton.alpha = 0.0;
                             
                             passwordInputField.alpha = 1.0;
                             wellSendYouLabel.alpha = 0.0;
                             
                             termsAndConditionsLabel.alpha = 1.0;
                             
                         }
                         completion: ^(BOOL finished) {
                             isAnimating = NO;
                             termsAndConditionsButton.enabled = YES;
                             [userNameInputField becomeFirstResponder];
                         }];
    }
}

-(void)reEnableLoginControls
{
    userNameInputField.enabled = YES;
    passwordInputField.enabled = YES;
    
    [activityIndicator stopAnimating];
    finalLoginButton.enabled = YES;
    
    facebookSignInButton.enabled = YES;
    
    [userNameInputField becomeFirstResponder];
    
}

- (void) setUpRegisterStateFromState: (kLoginScreenState) previousState
{
    [super setUpRegisterStateFromState:previousState];
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         self.loginBackgroundFrontImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         self.loginBackgroundImage.hidden = YES;
                         self.loginBackgroundFrontImage.hidden = YES;
                     }];
    
    //Make member label grey
    self.memberLabel.textColor = self.memberLabel.textColor;
    self.memberLabel.shadowColor = self.memberLabel.shadowColor;
    
    [UIView animateWithDuration:0.6f
                          delay:1.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.memberLabel.textColor = [UIColor colorWithRed:(130.0f/255.0f) green:(141.0f/255.0f) blue:(145.0f/255.0f) alpha:(1.0f)];
                         self.memberLabel.shadowColor = [UIColor whiteColor];
                         
                     } completion:^(BOOL finished) {
                     }];
    
    secondaryFacebookMessage.alpha = 0.0;
    
    [self clearAllErrorArrows];
    isAnimating = YES;
    userNameInputField.placeholder = NSLocalizedString(@"login_screen_form_field_username_placeholder", nil);
    
    
    self.userNameInputField.returnKeyType = UIReturnKeyNext;
    self.passwordInputField.returnKeyType = UIReturnKeyNext;
    
    if (previousState == kLoginScreenStateInitial)
    {
        emailInputField.center = CGPointMake(userNameInputField.center.x,
                                             emailInputField.center.y);
        emailInputField.frame = CGRectIntegral(emailInputField.frame);
        
        
        dobView.center = CGPointMake(userNameInputField.center.x,
                                     dobView.center.y);
        dobView.frame = CGRectIntegral(dobView.frame);
        
        facebookSignInButton.frame = CGRectMake(userNameInputField.frame.origin.x - 4.0, 322.0, facebookSignInButton.frame.size.width, facebookSignInButton.frame.size.height);
        facebookSignInButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        NSArray* loginForControls = @[emailInputField, userNameInputField, passwordInputField, dobView, registerNewUserButton];
        float delay = 0.05;
        for (UIView* control in loginForControls)
        {
            control.hidden = NO;
            
            [UIView animateWithDuration: 0.5
                                  delay: delay
                                options: UIViewAnimationCurveEaseInOut
                             animations: ^{
                                 control.alpha = 1.0;
                                 control.center = CGPointMake(control.center.x, control.center.y - self.elementsOffsetY);
                             }
                             completion: ^(BOOL finished) {
                             }];
            delay += 0.05;
        }
        
        [UIView animateWithDuration:0.4
                         animations: ^{
                             memberLabel.alpha = 0.0;
                             loginButton.alpha = 0.0;
                             
                             signUpButton.alpha = 0.0;
                             signUpButton.hidden = YES;
                         }
                         completion: ^(BOOL finished) {
                             finalLoginButton.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y - self.elementsOffsetY);
                             
                             facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + kOffsetForRegisterForm, facebookSignInButton.center.y - self.elementsOffsetY);
                             
                             [self placeSecondaryElements];
                             
                             memberLabel.center = CGPointMake(loginButton.center.x, areYouNewLabel.center.y - 8.0);
                             
                             CGRect faceRect = faceImageButton.frame;
                             faceRect.origin.x = userNameInputField.frame.origin.x - 10.0 - faceRect.size.width;
                             faceRect.origin.y -= self.elementsOffsetY;
                             faceImageButton.frame = faceRect;
                             self.avatarImageView.frame = faceRect;
                             
                             isAnimating = NO;
                             
                             [UIView animateWithDuration: 0.3
                                              animations: ^{
                                                  memberLabel.alpha = 1.0;
                                                  loginButton.alpha = 1.0;
                                                  faceImageButton.alpha = 1.0;
                                                  self.avatarImageView.alpha = 1.0;
                                                  
                                                  termsAndConditionsLabelSide.alpha = 1.0;
                                              }
                                              completion: ^(BOOL finished) {
                                                  [emailInputField becomeFirstResponder];
                                                  self.termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
                                                  self.termsAndConditionsButton.enabled = YES;
                                              }];
                         }];
    }
    else if (previousState == kLoginScreenStateLogin)
    {
        // prepare in the correct place
        
        loginButton.center = CGPointMake(registerButton.center.x, registerButton.center.y);
        memberLabel.center = CGPointMake(loginButton.center.x,
                                         registerButton.center.y - 57.0);
        memberLabel.frame = CGRectIntegral(memberLabel.frame);
        
        [UIView animateWithDuration: 0.5
                         animations: ^{
                             emailInputField.alpha = 1.0;
                             emailInputField.center = CGPointMake(userNameInputField.center.x,
                                                                  emailInputField.center.y);
                             
                             dobView.alpha = 1.0;
                             CGRect dobRect = dobView.frame;
                             dobRect.origin.x = self.userNameInputField.frame.origin.x;
                             dobView.frame = dobRect;
                             
                             faceImageButton.alpha = 1.0;
                             self.avatarImageView.alpha = 1.0;
                             CGRect faceRect = faceImageButton.frame;
                             faceRect.origin.x = userNameInputField.frame.origin.x - 10.0 - faceRect.size.width;
                             faceImageButton.frame = faceRect;
                             self.avatarImageView.frame = faceRect;
                             
                             loginButton.alpha = 1.0;
                             memberLabel.alpha = 1.0;
                             
                             termsAndConditionsLabelSide.alpha = 1.0;
                             
                             // move facebook button to the right
                             facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + kOffsetForRegisterForm,
                                                                       facebookSignInButton.center.y);
                         } completion: ^(BOOL finished) {
                             self.termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
                             self.termsAndConditionsButton.enabled = YES;
                             [emailInputField becomeFirstResponder];
                         }];
    }
    
    [UIView animateWithDuration: 0.4
                     animations: ^{
                         
                         facebookSignInButton.alpha = 0.0;
                         
                         titleImageView.alpha = 0.0;
                         self.whatsOnYourChannelLabel.alpha = 0.0;
                         registerNewUserButton.alpha = 1.0;
                         
                         dividerImageView.alpha = 0.0;
                         
                         registerNewUserButton.alpha = 1.0;
                         
                         termsAndConditionsLabel.alpha = 0.0;
                         
                         passwordForgottenButton.alpha = 0.0;
                         passwordForgottenLabel.alpha = 0.0;
                         
                         finalLoginButton.alpha = 0.0;
                         finalLoginButton.center = CGPointMake(finalLoginButton.center.x + 50.0,
                                                               finalLoginButton.center.y);
                         
                         registerButton.alpha = 0.0;
                         areYouNewLabel.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         isAnimating = NO;
                         termsAndConditionsButton.enabled = YES;
                     }];
}


#pragma mark - Button Actions

- (IBAction) doLogin: (id) sender
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"userLogin"
                                                            label: @"Rockpack"
                                                            value: nil] build]];
    
    [self clearAllErrorArrows];
    
    [self resignAllFirstResponders];
    
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    if (![self loginFormIsValidForUsername:userNameInputField password:passwordInputField])
        return;
    
    finalLoginButton.enabled = NO;
    
    [UIView animateWithDuration: 0.1 animations:^
     {
         finalLoginButton.alpha = 0.0;
     }];
    
    activityIndicator.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y);
    [activityIndicator startAnimating];
    
    [self loginForUsername: userNameInputField.text
               forPassword: passwordInputField.text
         completionHandler: ^(NSDictionary* dictionary) {
            
             DebugLog(@"User Registerd: %@", dictionary[@"username"]);
             
             // by this time the currentUser is set in the DB //
             
             [activityIndicator stopAnimating];
             
             [self completeLoginProcess];
             
         }
              errorHandler:^(NSDictionary* errorDictionary) {
                  
                  finalLoginButton.enabled = YES;
                  
                  [activityIndicator stopAnimating];
                  
                  [UIView animateWithDuration: 0.3
                                   animations: ^{
                                       finalLoginButton.alpha = 1.0;
                                   }
                                   completion: ^(BOOL finished) {
                                       [userNameInputField becomeFirstResponder];
                                   }];
                  
                  NSDictionary* errors = errorDictionary [@"error"];
                  if (errors)
                  {
                      [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil)
                                 nextToView: userNameInputField];
                      
                      [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil)
                                 nextToView: passwordInputField];
                  }
                  
                  NSDictionary* savingError = errorDictionary [@"saving_error"];
                  if(savingError)
                  {
                      [self placeErrorLabel: NSLocalizedString(@"login_screen_saving_error", nil)
                                 nextToView: passwordInputField];
                  }

                  
              }];
}


- (IBAction) goToLoginForm: (id) sender
{
    [self hideOnboarding];
    
    if (isAnimating)
        return;
    
    self.state = kLoginScreenStateLogin;
}


- (IBAction) sendEmailButtonPressed: (id) sender
{
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
        return;
    
    if (![self resetPasswordFormIsValidForUsername:self.userNameInputField])
        return;
    
    [self doRequestPasswordResetForUsername:self.userNameInputField.text completionHandler: ^(NSDictionary * completionInfo) {
        
        if ([completionInfo valueForKey: @"error"])
        {
            [self placeErrorLabel: NSLocalizedString(@"forgot_password_screen_form_field_username_user_unknown", nil)
                       nextToView: self.userNameInputField];
            
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"forgot_password_screen_complete_title", nil)
                                        message: NSLocalizedString(@"forgot_password_screen_complete_message", nil)
                                       delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil] show];
            
        }

    } errorHandler: ^(NSError *error) {
        if (error.code<500 || error.code >= 600)
        {
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"forgot_password_screen_complete_title", nil)
                                    message: NSLocalizedString(@"forgot_password_screen_form_field_request_failed_error", nil)
                                   delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"OK", nil)
                          otherButtonTitles: nil] show];
        }
    }];
}


- (void) doFacebookLoginAnimation
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         if (!signUpButton.hidden)
                         {
                             signUpButton.alpha = 0.0;
                             signUpButton.center = CGPointMake(signUpButton.center.x + 10.0, signUpButton.center.y);
                         }
                     }
                     completion: ^(BOOL finished) {
                         [activityIndicator startAnimating];
                     }];
    
    userNameInputField.enabled = NO;
    [userNameInputField resignFirstResponder];
    passwordForgottenButton.enabled = NO;
    [passwordForgottenLabel resignFirstResponder];
    finalLoginButton.enabled = NO;
    loginButton.enabled = NO;
    passwordForgottenButton.enabled = NO;
    
    activityIndicator.color = [UIColor whiteColor];
    
    activityIndicator.center = CGPointMake(facebookSignInButton.frame.origin.x + facebookSignInButton.frame.size.width + 35.0,
                                           facebookSignInButton.center.y);
}

- (void) doFacebookFailAnimation
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         if (!signUpButton.hidden)
                         {
                             signUpButton.alpha = 1.0;
                             signUpButton.center = CGPointMake(signUpButton.center.x - 10.0, signUpButton.center.y);
                         }
                     }
                     completion: ^(BOOL finished) {
                     }];
    
    userNameInputField.enabled = YES;
    passwordForgottenButton.enabled = YES;
    finalLoginButton.enabled = YES;
    loginButton.enabled = YES;
    passwordForgottenButton.enabled = YES;
    
    [activityIndicator stopAnimating];
}


- (IBAction) signInWithFacebook: (id) sender
{
    [self hideOnboarding];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"facebookLogin"
                                                            label: nil
                                                            value: nil] build]];
    
    _facebookLoginIsInProcess = NO;
    
    [self clearAllErrorArrows];
    
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    facebookSignInButton.enabled = NO;
    [self doFacebookLoginAnimation];
    
    [self loginThroughFacebookWithCompletionHandler: ^(NSDictionary * dictionary) {
        
        
        [activityIndicator stopAnimating];
        [self completeLoginProcess];
        
    }  errorHandler:^(id error) {
        
        [self doFacebookFailAnimation];
        facebookSignInButton.enabled = YES;
        
        if ([error isKindOfClass: [NSDictionary class]])
        {
            NSDictionary* formErrors = error[@"form_errors"];
            
            if (formErrors)
            {
                secondaryFacebookMessage.text = NSLocalizedString(@"facebook_login_error_description", nil);
                secondaryFacebookMessage.alpha = 1.0;
            }
            
        }
        else if ([error isKindOfClass: [NSString class]])
        {_facebookLoginIsInProcess = NO;
            
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


- (IBAction) forgottenPasswordPressed: (id) sender
{
    self.state = kLoginScreenStatePasswordRetrieve;
    
    //Make member label grey
    self.memberLabel.textColor = self.memberLabel.textColor;
    self.memberLabel.shadowColor = self.memberLabel.shadowColor;
    
    [UIView animateWithDuration:0.6f
                          delay:1.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.memberLabel.textColor = [UIColor colorWithRed:(130.0f/255.0f) green:(141.0f/255.0f) blue:(145.0f/255.0f) alpha:(1.0f)];
                         self.memberLabel.shadowColor = [UIColor whiteColor];
                         
                     } completion:^(BOOL finished) {
                     }];
}


- (void) showAutologinWithCredentials: (SYNOAuth2Credential*) credentials
{
    //    activityIndicator.center = CGPointMake(facebookSignInButton.frame.origin.x + facebookSignInButton.frame.size.width + 35.0,
    //                                           facebookSignInButton.center.y);
    //
    //    [UIView animateWithDuration:0.3 animations:^{
    //        signUpButton.alpha = 0.0;
    //    } completion:^(BOOL finished) {
    //        [activityIndicator startAnimating];
    //        [self completeLoginProcess:credentials];
    //    }]; 
}

- (void) resignAllFirstResponders
{
    NSArray* allTextFields = @[emailInputField, userNameInputField, passwordForgottenButton, ddInputField, mmInputField, yyyyInputField];
    
    for (UITextField* textField in allTextFields)
    {
        [textField resignFirstResponder];
    }
}


- (NSString*) dateStringFromCurrentInput
{
    return [NSString stringWithFormat: @"%@-%@-%@", yyyyInputField.text, mmInputField.text, ddInputField.text];
}


- (IBAction) registerNewUser: (id) sender
{
    // Check Text Fields
    [self clearAllErrorArrows];
    
    if (![self registrationFormIsValidForEmail:emailInputField userName:userNameInputField password:passwordInputField dd:ddInputField mm:mmInputField yyyy:yyyyInputField])
        return;
    
    [self resignAllFirstResponders];
    
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         registerNewUserButton.alpha = 0.0;
                     }];
    
    NSDictionary* userData = @{@"username": userNameInputField.text,
                               @"password": passwordInputField.text,
                               @"date_of_birth": [self dateStringFromCurrentInput],
                               @"locale":@"en-US",
                               @"email": emailInputField.text};
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate* birthdayDate = [dateFormatter dateFromString: [self dateStringFromCurrentInput]];
    
    // Calculate age, taking account of leap-years etc. (probably too accurate!)
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                                      fromDate: birthdayDate
                                                                        toDate: NSDate.date
                                                                       options: 0];
    
    NSInteger age = [ageComponents year];
    
    NSString *ageString = [NSString ageCategoryStringFromInt: age];
    
    // Now set the age
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"userRegistration"
                                                            label: @"Rockpack"
                                                            value: nil] build]];
    
    [tracker set: [GAIFields customDimensionForIndex: kGADimensionAge]
           value: ageString];
    
    activityIndicator.center = CGPointMake(registerNewUserButton.center.x, registerNewUserButton.center.y);
    [activityIndicator startAnimating];
    
    [self registerUserWithData: userData
             completionHandler: ^(NSDictionary* dictionary){
                 
                 [activityIndicator stopAnimating];
                 
                 [self completeLoginProcess];
                 
                 if (self.avatarImage)
                 {
                     [self uploadAvatar: self.avatarImage];
                 }
             }
                  errorHandler: ^(NSDictionary* errorDictionary){
                      registerNewUserButton.enabled = YES;
                      
                      [activityIndicator stopAnimating];
                      registerNewUserButton.alpha = 1.0;
                      
                      NSDictionary* formErrors = errorDictionary[@"form_errors"];
                      
                      if (formErrors)
                      {
                          [self showRegistrationError: formErrors];
                      }
                      
                  }];
}


- (void) uploadAvatar: (UIImage *) avatarImage;
{
    [self uploadAvatarImage:avatarImage completionHandler:^(NSDictionary* dictionary) {
//        DebugLog(@"Avatar uploaded successfully");
    }
               errorHandler:^(NSDictionary* errorDictionary) {
                   DebugLog(@"Avatar upload failed");
                   [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title", nil)
                                               message: NSLocalizedString(@"register_screen_form_avatar_upload_description", nil)
                                              delegate: nil
                                     cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                     otherButtonTitles: nil] show];
               }];
}


- (void) showRegistrationError: (NSDictionary*) errorDictionary
{
    // form errors
    NSArray* usernameError = errorDictionary[@"username"];
    //NSArray* localeError = [errorDictionary objectForKey:@"locale"];
    NSArray* passwordError = errorDictionary[@"password"];
    NSArray* emailError = errorDictionary[@"email"];
    
    if (usernameError)
        [self placeErrorLabel: (NSString*)usernameError[0]
                   nextToView: userNameInputField];
    
    // TODO: deal with locale
    
    if (passwordError)
        [self placeErrorLabel: (NSString*)passwordError[0]
                   nextToView: passwordInputField];
    
    if (emailError)
        [self placeErrorLabel: (NSString*)emailError[0]
                   nextToView: emailInputField];
    
}


#pragma mark - Error Arrows

- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) targetView
{
    SYNLoginErrorArrow* errorArrow = labelsToErrorArrows[[NSValue valueWithPointer:(__bridge const void *)(targetView)]];
    if (errorArrow)
    {
        [errorArrow setMessage:errorText];
        return;
    }
    
    errorArrow = [SYNLoginErrorArrow withMessage:errorText];
    
    errorArrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    CGPoint newPosition = targetView.center;
    newPosition = [self.view convertPoint:newPosition fromView:targetView.superview];
    newPosition.x +=  (errorArrow.frame.size.width/2.0f + targetView.frame.size.width/2.0f - 20.0);
    errorArrow.center = newPosition;
    errorArrow.frame = CGRectIntegral(errorArrow.frame);
    
    errorArrow.alpha = 0.0;
    
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         errorArrow.alpha = 1.0;
                     }];
    
    labelsToErrorArrows[[NSValue valueWithPointer:(__bridge const void *)(targetView)]] = errorArrow;
    [self.view addSubview:errorArrow];
}


- (void) clearAllErrorArrows
{
    [labelsToErrorArrows enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop)
     {
         SYNLoginErrorArrow* arrow = (SYNLoginErrorArrow*)value;
         [arrow removeFromSuperview];
     }];
    
    [labelsToErrorArrows removeAllObjects];
}


- (void) outerViewTapped: (UITapGestureRecognizer*) recogniser
{
    
    
    [labelsToErrorArrows enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop){
        
        SYNLoginErrorArrow* arrow = (SYNLoginErrorArrow*)value;
        [UIView animateWithDuration:0.2
                         animations: ^{
                             arrow.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [labelsToErrorArrows removeObjectForKey:key];
                             [arrow removeFromSuperview];
                         }];
    }];
}


- (IBAction) registerPressed: (id) sender
{
    if (self.isAnimating)
        return;
    
    self.state = kLoginScreenStateRegister;
}


- (IBAction) signUp: (id) sender
{
    [self hideOnboarding];
    
    self.state = kLoginScreenStateRegister;
}


- (void) completeLoginProcess
{
    [activityIndicator stopAnimating];
    
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
    
    UIImageView *splashView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 748)];
    splashView.image = IS_IOS_7_OR_GREATER ? [UIImage imageNamed:  @"Default-Landscape-iOS7.png"]  : [UIImage imageNamed:  @"Default-Landscape.png"];
    splashView.alpha = 0.0;
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         splashView.alpha = 1.0;
                     }
                     completion: ^(BOOL finished) {
                         [[NSNotificationCenter defaultCenter] postNotificationName: kLoginCompleted
                                                                             object: self];
                         
                     }];
}


#pragma mark - TextField Delegate Methods

- (BOOL) textField: (UITextField *) textField
         shouldChangeCharactersInRange: (NSRange) range
         replacementString: (NSString *) newCharacter
{
    
    NSUInteger oldLength = textField.text.length;
    NSUInteger replacementLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + replacementLength) - rangeLength;
    
    
    if ((textField == ddInputField || textField == mmInputField) && newLength > 2)
        return NO;
    if (textField == yyyyInputField && newLength > 4)
        return NO;
    if(textField == self.userNameInputField && newLength > 20 && self.state == kLoginScreenStateRegister && newLength > oldLength)
        return NO;
    
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    if (textField == ddInputField || textField == mmInputField || textField == yyyyInputField)
        if (![numberFormatter numberFromString:newCharacter] && newCharacter.length != 0) // is backspace, length is 0
            return NO;
    
    
    NSValue* key = [NSValue valueWithPointer:(__bridge const void *)(textField)];
    SYNLoginErrorArrow* possibleErrorArrow =
    (SYNLoginErrorArrow*)labelsToErrorArrows[key];
    
    if (possibleErrorArrow)
    {
        [UIView animateWithDuration: 0.2
                         animations: ^{
                             possibleErrorArrow.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [possibleErrorArrow removeFromSuperview];
                             [labelsToErrorArrows removeObjectForKey:key];
                         }];
    }
    return YES;
}

- (IBAction) textfieldDidChange: (id) sender
{

    UIView* nextView = [self.view viewWithTag: ((UITextField*)sender).tag + 1];
    if(sender == self.ddInputField && [self.ddInputField.text length] == 2)
    {
        if(nextView && [nextView isKindOfClass:[UITextField class]])
            [(UITextField*)nextView becomeFirstResponder];

    }
    else if(sender == self.mmInputField && [self.mmInputField.text length] == 2)
    {
        if(nextView && [nextView isKindOfClass:[UITextField class]])
            [(UITextField*)nextView becomeFirstResponder];

    }
    else if(sender == self.yyyyInputField && [self.yyyyInputField.text length] == 4)
    {
       
        
    }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    if (self.state == kLoginScreenStateLogin)
    {
        
        if (self.userNameInputField.text.length < 1) {
            self.userNameInputField.returnKeyType = UIReturnKeyNext;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        if (self.passwordInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeyGo;
            [self.passwordInputField becomeFirstResponder];
            return YES;
        }
        
        [self doLogin:self.finalLoginButton];
    }
    else if (self.state == kLoginScreenStateRegister)
    {
        if (self.emailInputField.text.length < 1) {
            self.emailInputField.returnKeyType = UIReturnKeyNext;
            [self.emailInputField becomeFirstResponder];
            return YES;
        }
        
        if (self.userNameInputField.text.length < 1) {
            self.userNameInputField.returnKeyType = UIReturnKeyNext;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        
        if (self.passwordInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeyNext;
            [self.passwordInputField becomeFirstResponder];
            return YES;
        }
        if (self.ddInputField.text.length < 1) {
            self.ddInputField.returnKeyType = UIReturnKeyNext;
            [self.ddInputField becomeFirstResponder];
            return YES;
        }
        if (self.mmInputField.text.length < 1) {
            self.mmInputField.returnKeyType = UIReturnKeyNext;
            [self.mmInputField becomeFirstResponder];
            return YES;
        }
        if (self.yyyyInputField.text.length < 1) {
            self.yyyyInputField.returnKeyType = UIReturnKeyDone;
            [self.yyyyInputField becomeFirstResponder];
            return YES;
        }
        
        [self registerNewUser:self.registerNewUserButton];
        return YES;
    
    }
    else if (self.state == kLoginScreenStatePasswordRetrieve)
    {
        if (self.userNameInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeySend;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        
        [self sendEmailButtonPressed:self.sendEmailButton];
        return YES;
    
    }

    // default case just go to the next text field (from 6 text fields)
    [((UITextField*)[self.view viewWithTag: (textField.tag+1)%6]) becomeFirstResponder];
    
    return YES;
}


#pragma mark - Avatar image selection

- (IBAction) faceButtonImagePressed: (UIButton*) button
{
    self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController:self];
    self.imagePicker.delegate = self;
    [self.imagePicker presentImagePickerAsPopupFromView:button arrowDirection:UIPopoverArrowDirectionLeft];
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


#pragma mark - Rotation support

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    [self clearAllErrorArrows];
    CGRect facebookButtonFrame = facebookSignInButton.frame;
    CGRect onBoardingFrame = self.onBoardingController.view.frame;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        signUpButton.center = CGPointMake(524.0, signUpButton.center.y);
        facebookButtonFrame.origin.x = 150.0f;
        passwordForgottenLabel.center = CGPointMake(115.0, passwordForgottenLabel.center.y);
        faceImageButton.center = CGPointMake(84.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(124.0, self.avatarImageView.center.y);
        termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, 714.0);
        termsAndConditionsLabelSide.center = CGPointMake(termsAndConditionsLabelSide.center.x, 714.0);        
        registerButton.center = CGPointMake(registerButton.center.x, 704.0);
        onBoardingFrame.origin.y = 280.0;
    }
    else
    {
        signUpButton.center = CGPointMake(670.0, signUpButton.center.y);
        facebookButtonFrame.origin.x = 293.0f;
        passwordForgottenLabel.center = CGPointMake(248.0, passwordForgottenLabel.center.y);
        faceImageButton.center = CGPointMake(254.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(254.0, self.avatarImageView.center.y);
        termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, 370.0);
        termsAndConditionsLabelSide.center = CGPointMake(termsAndConditionsLabelSide.center.x, 370.0);
        registerButton.center = CGPointMake(registerButton.center.x, 358.0);
        onBoardingFrame.origin.y = 100.0;
    }
    
    
    
    self.onBoardingController.view.frame = onBoardingFrame;
    
    areYouNewLabel.center = CGPointMake(areYouNewLabel.center.x, registerButton.center.y - 44.0);
    
    if (self.state != kLoginScreenStateInitial)
    {
        loginButton.center = registerButton.center;
        
        memberLabel.center = CGPointMake(loginButton.center.x, areYouNewLabel.center.y - 8.0);
    }
    else
    {
        facebookSignInButton.frame = facebookButtonFrame;
        memberLabel.center = CGPointMake(loginButton.center.x, loginButton.center.y - 54.0);
    }
    
    loginButton.frame = CGRectIntegral(loginButton.frame);
    registerButton.frame = CGRectIntegral(registerButton.frame);
    signUpButton.frame = CGRectIntegral(signUpButton.frame);
    passwordForgottenLabel.frame = CGRectIntegral(passwordForgottenLabel.frame);
    termsAndConditionsLabelSide.frame = CGRectIntegral(termsAndConditionsLabelSide.frame);
    faceImageButton.frame = CGRectIntegral(faceImageButton.frame);
    self.avatarImageView.frame = CGRectIntegral(self.avatarImageView.frame);
    areYouNewLabel.frame = CGRectIntegral(areYouNewLabel.frame);
    
    if(termsAndConditionsLabel.alpha > 0.0)
        termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
    else
        termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
    
//    for (NSValue* targetViewPointerValue in labelsToErrorArrows)
//    {
//        UIView* targetView = (UIView*)[targetViewPointerValue pointerValue];
//        if(!targetView)
//            continue;
//        
//        SYNLoginErrorArrow* errorArrow = (SYNLoginErrorArrow*)[labelsToErrorArrows objectForKey:targetViewPointerValue];
//        
//        CGPoint newPosition = targetView.center;
//        newPosition = [self.view convertPoint:newPosition fromView:targetView.superview];
//        newPosition.x +=  (errorArrow.frame.size.width/2.0f + targetView.frame.size.width/2.0f - 20.0);
//        errorArrow.center = newPosition;
//        errorArrow.frame = CGRectIntegral(errorArrow.frame);
//        
//    }
    
}



- (CGFloat) elementsOffsetY
{
        if ([SYNDeviceManager.sharedInstance isLandscape])
            return 284.0;
        else
            return 284.0;    
}


- (void) placeSecondaryElements
{
    CGFloat registerOffsetY = [SYNDeviceManager.sharedInstance isPortrait] ? 704.0 : 358.0;
    registerButton.center = CGPointMake(registerButton.center.x, registerOffsetY);
    areYouNewLabel.center = CGPointMake(areYouNewLabel.center.x, registerButton.center.y - 44.0);
    memberLabel.center = CGPointMake(loginButton.center.x, areYouNewLabel.center.y);
    loginButton.center = registerButton.center;
    dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - self.elementsOffsetY);
    passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - self.elementsOffsetY);
    passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - self.elementsOffsetY);
    CGFloat termsOffsetY = [SYNDeviceManager.sharedInstance isPortrait] ? 714.0 : 370.0;
    termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, termsOffsetY);
    termsAndConditionsLabelSide.center = CGPointMake(termsAndConditionsLabelSide.center.x, termsOffsetY);
    
    loginButton.frame = CGRectIntegral(loginButton.frame);
    registerButton.frame = CGRectIntegral(registerButton.frame);
    signUpButton.frame = CGRectIntegral(signUpButton.frame);
    passwordForgottenLabel.frame = CGRectIntegral(passwordForgottenLabel.frame);
    faceImageButton.frame = CGRectIntegral(faceImageButton.frame);
    self.avatarImageView.frame = CGRectIntegral(self.avatarImageView.frame);
    areYouNewLabel.frame = CGRectIntegral(areYouNewLabel.frame);
    termsAndConditionsLabel.frame = CGRectIntegral(termsAndConditionsLabel.frame);
    termsAndConditionsLabelSide.frame = CGRectIntegral(termsAndConditionsLabelSide.frame);
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
    
    if(termsAndConditionsLabel.alpha > 0.0)
        termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
    else
        termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
}

@end
