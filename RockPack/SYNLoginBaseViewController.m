//
//  SYNLoginBaseViewController.m
//  rockpack
//
//  Created by Mats Trovik on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "ExternalAccount.h"
#import "GAI.h"
#import "NSString+Utils.h"
#import "RegexKitLite.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNLoginBaseViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIDevice+Hardware.h"
#import "UIInterpolatingMotionEffect+DualAxis.h"
#import "User.h"
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SYNLoginBaseViewController ()

@property (nonatomic, strong) NSArray* backgroundImagesArray;

@end


@implementation SYNLoginBaseViewController

- (id) initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        [self commonInit];
        
    }
    
    return self;
}

        
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}


- (void) reEnableLoginControls
{
    // implement in subclass
}


- (void) commonInit
{
    _appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.reachability = [Reachability reachabilityWithHostname: _appDelegate.networkEngine.hostName];
    
    self.scrollingDirection = ScrollingDirectionNone;
    self.currentOnBoardingPage = 0;
    
    self.loginBackgroundFrontImage.alpha = 0.0;

    // create image array
    NSMutableArray* imagesArray = [[NSMutableArray alloc] initWithCapacity:kLoginOnBoardingMessagesNum];
    for (int i = 0; i < kLoginOnBoardingMessagesNum; i++)
    {
        //[imagesArray addObject: [NSString stringWithFormat: @"login_bg_%i.jpg", (i+1)]];
        [imagesArray addObject: [NSString stringWithFormat: @"login_bg_1.jpg"]]; //Only 1 image for now...
    }
    self.backgroundImagesArray = [NSArray arrayWithArray: imagesArray];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.onBoardingController = [[SYNLoginOnBoardingController alloc] initWithDelegate: self];
    
    CGRect totalImageRect;
    
    CGPoint correctPoint;
    if (IS_IPAD)
    {
        totalImageRect = CGRectMake(0.0, 0.0, 1024.0, 1024.0);
        
        correctPoint = self.view.center; 
    }
    else
    {
        totalImageRect = CGRectMake(0.0, 0.0, [[SYNDeviceManager sharedInstance] currentScreenHeight], [[SYNDeviceManager sharedInstance] currentScreenHeight]);
        correctPoint = self.view.center;
    }
    
    self.loginBackgroundImage.frame = totalImageRect;
    self.loginBackgroundFrontImage.frame = totalImageRect;
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"login_bg_1.jpg"]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.frame = totalImageRect;
    
    [self.view insertSubview: self.backgroundImageView
                    atIndex: 0];
    
    if (IS_IOS_7_OR_GREATER)
    {
        self.lowerParallaxImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"LowerParallaxStars"]];
        self.lowerParallaxImageView.contentMode = UIViewContentModeCenter;
        self.lowerParallaxImageView.frame = totalImageRect;
        
        UIMotionEffectGroup *lowerMotionEffectGroup = [UIInterpolatingMotionEffect dualAxisMotionEffectWithMaxDisplacement: 100.0f];
        
        [self.lowerParallaxImageView addMotionEffect: lowerMotionEffectGroup];
        
        [self.view insertSubview: self.lowerParallaxImageView
                         atIndex: 1];
        
        self.upperParallaxImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"UpperParallaxStars"]];
        self.upperParallaxImageView.contentMode = UIViewContentModeCenter;
        self.upperParallaxImageView.frame = totalImageRect;
        
        UIMotionEffectGroup *upperMotionEffectGroup = [UIInterpolatingMotionEffect dualAxisMotionEffectWithMaxDisplacement: 200.0f];
        
        [self.upperParallaxImageView addMotionEffect: upperMotionEffectGroup];
        
        [self.view insertSubview: self.upperParallaxImageView
                         atIndex: 2];
    }

//    self.loginBackgroundImage.center = correctPoint;
//    self.loginBackgroundFrontImage.center = correctPoint;
//    
    self.loginBackgroundImage.center = CGPointMake(self.view.center.x, self.loginBackgroundImage.center.y);
    
    
//    self.loginBackgroundImage.image = [UIImage imageNamed:self.backgroundImagesArray[0]]; // get the first image
    
    // localise date format for US and UK
    
    NSString* localeFromDevice = [(NSString*)CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
    
    if ([localeFromDevice isEqualToString:@"en-us"])
    {
        NSInteger ddTag = self.ddInputField.tag;
        CGRect ddRect = self.ddInputField.frame;
        
        self.ddInputField.frame = self.mmInputField.frame;
        self.mmInputField.frame = ddRect;
        
        self.ddInputField.tag = self.mmInputField.tag;
        self.mmInputField.tag = ddTag;
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self performSelector: @selector(reachabilityChanged:)
               withObject: nil];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kReachabilityChangedNotification
                                                  object: nil];
}

- (void) setUpInitialState
{
    //Override in subclass
    
}

- (void) setUpLoginStateFromPreviousState: (kLoginScreenState) previousState
{
    self.onBoardingController.view.hidden = YES;
}

- (void) setUpRegisterStateFromState: (kLoginScreenState) previousState
{
    self.onBoardingController.view.hidden = YES;
}

- (BOOL) checkAndSaveRegisteredUser: (SYNOAuth2Credential*) credential
{
    // at this point the user should have been registered
    
    if (!self.appDelegate.currentUser)
    {
        // problem
        DebugLog(@"The user was not registered correctly...");
        return NO;
    }
    
    self.appDelegate.currentOAuth2Credentials = credential;
    
    [SYNActivityManager.sharedInstance updateActivityForCurrentUser];
    
    return YES;
}


#pragma mark - login

- (void) loginForUsername: (NSString*) username
              forPassword: (NSString*) password
        completionHandler: (MKNKUserSuccessBlock) completionBlock
             errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doSimpleLoginForUsername: username forPassword: password completionHandler: ^(SYNOAuth2Credential* credential) {

        // Case where the user is a member of Rockpack but has not signing in this device
        
        [self.appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: credential completionHandler: ^(NSDictionary* dictionary) {

            // the dictionary contains a User dictionary //
            
            
            // by this time the currentUser is set in the DB //
            
            if ([self checkAndSaveRegisteredUser: credential])
            {
                
                DebugLog(@"User Registerd: %@", [dictionary objectForKey: @"username"]);
                
                _appDelegate.currentUser.loginOriginValue = LoginOriginRockpack;
                
                
                // if the user has an External Account with "facebook"
                if(_appDelegate.currentUser.facebookAccount)
                {
                    // Link it with the FB SDK
                    [[SYNFacebookManager sharedFBManager] openSessionFromExistingToken: _appDelegate.currentUser.facebookAccount.token
                                                                             onSuccess: ^{
                                                                                 
                                                                                 DebugLog(@"Linked FB Account");
                                                                                 
                                                                           } onFailure: ^(NSString *errorMessage) {
                                                                                 
                                                                                 DebugLog(@"");
                                                                                 
                                                                           }];
                }
                
                completionBlock(dictionary);
            }
            else
            {
                DebugLog(@"ERROR: User not registered (User: %@)", _appDelegate.currentUser);
            }
        } errorHandler:errorBlock];
        
    } errorHandler:errorBlock];
    
}


#pragma mark - reset password

- (void) doRequestPasswordResetForUsername: (NSString*) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doRequestPasswordResetForUsername: username
                                                         completionHandler: completionBlock
                                                              errorHandler:errorBlock];
}

- (void) doRequestUsernameAvailabilityForUsername: (NSString*) username
                                completionHandler: (MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doRequestUsernameAvailabilityForUsername:username
                                                         completionHandler: completionBlock
                                                              errorHandler:errorBlock];
}


#pragma mark - register user

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine registerUserWithData:userData completionHandler: ^(SYNOAuth2Credential* credential) {
        
        // Case where the user registers
        [self.appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: credential
                                                          completionHandler: ^(NSDictionary* dictionary) {
                                                              [self checkAndSaveRegisteredUser: credential];
                                                              completionBlock(dictionary);
                                                          }
                                                               errorHandler: errorBlock];
    } errorHandler: errorBlock];
}


#pragma mark - upload Avatar

- (void) uploadAvatarImage: (UIImage *) image
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine updateAvatarForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                                         image: image
                                             completionHandler: completionBlock
                                                  errorHandler: errorBlock];
}

- (void) hideOnboarding
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.onBoardingController.view.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.onBoardingController.view.hidden = YES;
                     }];
    
    //Hide backgroundImageView when Reg or Login buttons are Pressed
    self.backgroundImageView.alpha = 0.0f;
    self.backgroundImageView.hidden = YES;
    self.lowerParallaxImageView.alpha = 0.0f;
    self.lowerParallaxImageView.hidden = YES;
    self.upperParallaxImageView.alpha = 0.0f;
    self.upperParallaxImageView.hidden = YES;
    
}

- (void) showOnboarding
{
    self.backgroundImageView.hidden = NO;
    
    //Show backgroundImageView when back button is Pressed
    self.onBoardingController.view.hidden = NO;
    self.lowerParallaxImageView.hidden = NO;
    self.upperParallaxImageView.hidden = NO;
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.onBoardingController.view.alpha = 1.0;
                         self.backgroundImageView.alpha = 1.0f;
                         self.lowerParallaxImageView.alpha = 1.0f;
                         self.upperParallaxImageView.alpha = 1.0f;
                     } completion: nil];
    
    
}

#pragma mark - login facebook

-(void) loginThroughFacebookWithCompletionHandler: (MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    // figure out if it exists in account
    
//    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
//    ACAccountType* facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
//    NSArray *facebookAccounts = [accountStore accountsWithAccountType:facebookAccountType];
//    NSLog(@"Accounts:\n%@", facebookAccounts);
//    
//    NSDictionary *options = @{ACFacebookAppIdKey : @"217008995103822",
//                              ACFacebookPermissionsKey : @[@"publish_stream"],
//                              ACFacebookAudienceKey : ACFacebookAudienceEveryone};
//    
//    if(facebookAccountType.accessGranted)
//    {
//        NSLog(@"User had granted Facebook Access");
//    }
//    else
//    {
//        NSLog(@"User had revoked Facebook Access");
//        [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error) {
//            if (granted)
//            {
//                NSLog(@"Granted!");
//                
//            }
//            else
//            {
//                NSLog(@"NOT Granted (error: %@)", error);
//            }
//        }];
//        return;
//    }
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        // Log our user's age in Google Analytics
        NSString *birthday = dictionary[@"birthday"];
        
        if (birthday)
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"MM/dd/yyyy"];
            NSDate* birthdayDate = [dateFormatter dateFromString: birthday];
            
            // Calculate age, taking account of leap-years etc. (probably too accurate!)
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                                              fromDate: birthdayDate
                                                                                toDate: NSDate.date
                                                                               options: 0];
            
            NSInteger age = [ageComponents year];
            
            NSString *ageString = [NSString ageCategoryStringFromInt: age];
            
            // Now set the age
            id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
            
            [tracker set: [GAIFields customDimensionForIndex: kGADimensionAge]
                   value: ageString];
        }
        
        [self doFacebookLoginAnimation];
        
        
        // We need to check if the expiration date is valid (if the user is using the native iOS Facebook settings, it will be invalid ([NSDate distantFuture])
        NSDate *expDate = nil;
        
        if ([accessTokenData.expirationDate compare: [NSDate distantFuture]] != NSOrderedSame)
        {
            expDate = accessTokenData.expirationDate;
        }
        
        // after the log-in with FB through its SDK, log in with the server hitting "/ws/login/external/"
        [_appDelegate.oAuthNetworkEngine doFacebookLoginWithAccessToken: accessTokenData.accessToken
                                                                expires: expDate
                                                            permissions: accessTokenData.permissions // @"read" at this time
                                                      completionHandler: ^(SYNOAuth2Credential* credential) {
                                                          
            // get the user data
                                                          
            [_appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: credential
                                                                  completionHandler: ^(NSDictionary* dictionary) {
                                                                  
                if ([self checkAndSaveRegisteredUser: credential])
                {
                    _appDelegate.currentUser.loginOriginValue = LoginOriginFacebook;
                }
                else
                {
                    DebugLog(@"ERROR: User not registered (User: %@)", _appDelegate.currentUser);
                    // TODO: handle user not being registered propery
                }
                                                                      
                                                         
                    
                completionBlock(dictionary);
                                                                  
                                                                  
            } errorHandler:errorBlock];
        } errorHandler: errorBlock];
    }
    onFailure: ^(NSString* errorString)
     {
         errorBlock(errorString);
     }];
}


#pragma mark - Reachability change

- (void) reachabilityChanged: (NSNotification*) notification
{
    #ifdef PRINT_REACHABILITY
    NSString* reachabilityString;
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        reachabilityString = @"WiFi";
    else if ([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
        reachabilityString = @"WWAN";
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
        reachabilityString = @"None";
    
    //    DebugLog(@"Reachability == %@", reachabilityString);
#endif
    
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if ([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
    {
        NSString* message = IS_IPAD ? NSLocalizedString(@"No_Network_iPad", nil)
        : NSLocalizedString(@"No_Network_iPhone", nil);
        [self presentNetworkErrorViewWithMesssage: message];
    }
}


- (void) applicationResume{
    if (!self.reachability)
    {
        self.reachability = [Reachability reachabilityWithHostname: _appDelegate.networkEngine.hostName];
    }
    [self reachabilityChanged:nil];
}


- (void) presentNetworkErrorViewWithMesssage: (NSString*) message
{
    if (self.networkErrorView)
    {
        [self.networkErrorView setText:message];
        return;
    }
    
    self.networkErrorView = [SYNNetworkMessageView errorView];
    [self.networkErrorView setCenterVerticalOffset:18.0f];
    self.networkErrorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BarNetworkLogin"]];
    self.networkErrorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleWidth;
    [self.networkErrorView setText:message];
    
    CGRect errorViewFrame = self.networkErrorView.frame;
    errorViewFrame.origin.y = -(self.networkErrorView.height);
    self.networkErrorView.frame = errorViewFrame;
    
    [self.view addSubview:self.networkErrorView];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect endFrame = self.networkErrorView.frame;
        endFrame.origin.y = 0.0f;
        self.networkErrorView.frame = endFrame;
    }];
}


- (void) hideNetworkErrorView
{
    [UIView animateWithDuration:0.3
                          delay:0.1 options:UIViewAnimationCurveEaseInOut
                     animations:^{
        CGRect errorViewFrame = self.networkErrorView.frame;
        errorViewFrame.origin.y = -(self.networkErrorView.height);
        self.networkErrorView.frame = errorViewFrame;
    } completion: ^(BOOL finished) {
        if (finished)
        {
            [self.networkErrorView removeFromSuperview];
            self.networkErrorView = nil;
        }
    }];
}


#pragma mark - check network before sending request
- (BOOL) isNetworkAccessibleOtherwiseShowErrorAlert
{
    BOOL isReachable = ![self.reachability currentReachabilityStatus] == NotReachable;
    if (! isReachable)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login_screen_form_no_connection_dialog_title",nil) message:NSLocalizedString(@"login_screen_form_no_connection_dialog_message",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        [alert show];
    }
    return isReachable;
}


- (void) doFacebookLoginAnimation
{
    // to be implemented by subclass
}

- (void) doFacebookFailAnimation
{
    // to be implemented by subclass
}


#pragma mark - form validation

- (BOOL) registrationFormPartOneIsValidForUserName: (UITextField*) userNameInputField
{
    
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    if (![userNameInputField.text isMatchedByRegex:@"^[a-zA-Z0-9]+$"])
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_invalid", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    if (userNameInputField.text.length > 20)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_too_long", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    
    return YES;
}


- (BOOL) registrationFormIsValidForEmail: (UITextField*) emailInputField
                                userName: (UITextField*) userNameInputField
                                password: (UITextField*) passwordInputField
                                      dd: (UITextField*) ddInputField
                                      mm: (UITextField*) mmInputField
                                    yyyy: (UITextField*) yyyyInputField
{
    if (emailInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_email_error_empty",nil)
                   nextToView: emailInputField];
        
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Regular expression through RegexKitLite.h (not arc compatible) == //
    
    if (![emailInputField.text isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"])
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_email_error_empty", nil)
                   nextToView: emailInputField];
        
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Determine if we are in login or registration mode by asking if the Register button is visible and show different error messages == //
    
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    //register_screen_form_field_username_error_too_long
    // == Username must be
    
    if (![userNameInputField.text isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"])
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_invalid", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (userNameInputField.text.length > 20)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_too_long", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Determine if we are in login or registration mode by asking if the Register button is visible and show different error messages == //
    
    if (passwordInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_password_error_empty", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    return [self dateValidForDd: ddInputField
                             mm: mmInputField
                           yyyy: yyyyInputField];
}


- (BOOL) dateValidForDd: (UITextField*) ddInputField
                     mm: (UITextField*) mmInputField
                   yyyy: (UITextField*) yyyyInputField
{
    // == Check for date == //
    
    NSArray* dobTextFields = @[mmInputField, ddInputField, yyyyInputField];

    // == Check wether the DOB fields contain numbers == //
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    
    for (UITextField* dobField in dobTextFields)
    {
        if (dobField.text.length == 0)
        {
            [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                       nextToView: yyyyInputField];
            
            [ddInputField becomeFirstResponder];
            
            return NO;
        }
        
        if (dobField.text.length == 1)
        {
            dobField.text = [NSString stringWithFormat:@"0%@", dobField.text]; // add a trailing 0
        }
        
        if (![numberFormatter numberFromString: dobField.text])
        {
            [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                       nextToView: yyyyInputField];
            
            [dobField becomeFirstResponder];
            
            return NO;
        }
    }
    
    if (yyyyInputField.text.length < 4)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                   nextToView: yyyyInputField];
        return NO;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate* potentialDate = [dateFormatter dateFromString: [NSString stringWithFormat:@"%@-%@-%@", yyyyInputField.text, [self zeroPadIfOneCharacter:mmInputField.text], [self zeroPadIfOneCharacter:ddInputField.text]]];
    
    // == Not a real date == //
    
    if (!potentialDate)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                   nextToView: yyyyInputField];
        
        return NO;
    }
    
    NSDate* nowDate = [NSDate date];
    
    // == In the future == //
    
    if ([nowDate compare:potentialDate] == NSOrderedAscending) {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_future", nil)
                   nextToView: yyyyInputField];
        
        return NO;
    }
    
    // == Yonger than 13 == //
    
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* nowDateComponents = [gregorian components:(NSYearCalendarUnit) fromDate:nowDate];
    nowDateComponents.year -= 13;
    
    NSDate* tooYoungDate = [gregorian dateFromComponents:nowDateComponents];
    
    if ([tooYoungDate compare:potentialDate] == NSOrderedAscending) {
        
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_under_13", nil)
                   nextToView: yyyyInputField];
        
        return NO;
    }
    
    return YES;
}


- (BOOL) loginFormIsValidForUsername: (UITextField*) userNameInputField
                            password: (UITextField*) passwordInputField
{
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (passwordInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_password_error_empty", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}


- (BOOL) resetPasswordFormIsValidForUsername: (UITextField*) userNameInputField
{
    
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"forgot_password_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
    
}


- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view
{
    //Override in subclass
}


- (NSString*) zeroPadIfOneCharacter: (NSString*) inputString
{
    if ([inputString length]==1)
    {
        return [NSString stringWithFormat:@"0%@",inputString];
    }
    
    return inputString;
}


#pragma mark - ScrollView (on boarding) Delegate Methods

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    CGFloat scrollerWidth = self.onBoardingController.scrollView.frame.size.width;
    
    CGFloat pinnedOffsetX = self.currentOnBoardingPage * scrollerWidth - self.onBoardingController.scrollView.contentOffset.x;
    CGFloat ratio = fabsf(pinnedOffsetX / scrollerWidth);
    
    BOOL shouldFade = YES;
    
    if (pinnedOffsetX < 0.0) // scrolling towards right -->, pick next
    {
        if (self.currentOnBoardingPage == 3)
            shouldFade = NO;
        self.scrollingDirection = ScrollingDirectionRight;
    }
    else if(pinnedOffsetX > 0.0) // scrolling towards left <--, pick next
    {
        if (self.currentOnBoardingPage == 0)
            shouldFade = NO;
        self.scrollingDirection = ScrollingDirectionLeft;
    }
    else // at rest
    {
        self.scrollingDirection = ScrollingDirectionNone;
    }
    
    if (shouldFade)
    {
        self.loginBackgroundImage.alpha = 1 - ratio;
        self.loginBackgroundFrontImage.alpha = ratio;
    }
    else
    {
        self.loginBackgroundImage.alpha = 1.0;
        self.loginBackgroundFrontImage.alpha = 1.0;
    }   
}


- (void) setScrollingDirection: (ScrollingDirection) scrollingDirection
{
    if (_scrollingDirection == scrollingDirection)
        return;
    
    _scrollingDirection = scrollingDirection;

    if (self.currentOnBoardingPage < 0)
        self.currentOnBoardingPage = 0;
    else if (self.currentOnBoardingPage > kLoginOnBoardingMessagesNum - 1)
        self.currentOnBoardingPage = kLoginOnBoardingMessagesNum - 1;
}


- (void) scrollViewDidEndDecelerating: (UIScrollView *) scrollView
{
    CGFloat contentOffsetX = self.onBoardingController.scrollView.contentOffset.x;
    self.currentOnBoardingPage = (NSInteger)floorf(contentOffsetX / self.onBoardingController.scrollView.frame.size.width);
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"cardSlide"
                                                            label: [NSString stringWithFormat:@"%i", (_currentOnBoardingPage + 1)]
                                                            value: nil] build]];
}


- (void) setCurrentOnBoardingPage: (NSInteger) currentOnBoardingPage
{
    _currentOnBoardingPage = currentOnBoardingPage;
    self.onBoardingController.pageControl.currentPage = currentOnBoardingPage;
    self.scrollingDirection = ScrollingDirectionNone; // when we have a number we are at rest
}


@end
