//
//  SYNLoginBaseViewController.h
//  rockpack
//
//  Created by Mats Trovik on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "Reachability.h"
#import "SYNAppDelegate.h"
#import "SYNImagePickerController.h"
#import "SYNLoginOnBoardingController.h"
#import "SYNNetworkMessageView.h"
#import "SYNNetworkOperationJsonObject.h"
#import "SYNOAuth2Credential.h"
#import "SYNTextFieldLoginiPhone.h"


#define kLoginTermsUrl @"http://rockpack.com/tos"
#define kLoginPrivacyUrl @"http://rockpack.com/privacy"

typedef enum : NSInteger {
    kLoginScreenStateNull = 0,
    kLoginScreenStateInitial,
    kLoginScreenStateLogin,
    kLoginScreenStateRegister,
    kLoginScreenStatePasswordRetrieve,
    kLoginScreenStateRegisterStepTwo
} kLoginScreenState;


@interface SYNLoginBaseViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) NSInteger currentOnBoardingPage;
@property (nonatomic) ScrollingDirection scrollingDirection;
@property (nonatomic, assign) kLoginScreenState state;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundFrontImage;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundImage;
@property (nonatomic, strong) IBOutlet UITextField* ddInputField;
@property (nonatomic, strong) IBOutlet UITextField* mmInputField;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) SYNImagePickerController* imagePicker;
@property (nonatomic, strong) SYNLoginOnBoardingController* onBoardingController;
@property (nonatomic, strong) SYNNetworkMessageView* networkErrorView;
@property (nonatomic,assign) SYNAppDelegate* appDelegate;
@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIImageView * upperParallaxImageView;
@property (nonatomic, strong) UIImageView * lowerParallaxImageView;


- (BOOL) checkAndSaveRegisteredUser: (SYNOAuth2Credential*) credential;

- (void) loginForUsername: (NSString*) username
              forPassword: (NSString*) password
        completionHandler: (MKNKUserSuccessBlock) completionBlock
             errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doRequestPasswordResetForUsername: (NSString*) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock;

- (void) doRequestUsernameAvailabilityForUsername: (NSString*) username
                                completionHandler: (MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKErrorBlock) errorBlock;

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) uploadAvatarImage: (UIImage *) image
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) loginThroughFacebookWithCompletionHandler: (MKNKJSONCompleteBlock) completionBlock
                                      errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) setUpInitialState;
- (void) setUpLoginStateFromPreviousState: (kLoginScreenState) previousState;
- (void) setUpRegisterStateFromState: (kLoginScreenState) previousState;

- (void) reEnableLoginControls;

- (BOOL) isNetworkAccessibleOtherwiseShowErrorAlert;

- (void) doFacebookLoginAnimation;
- (void) doFacebookFailAnimation;

- (void) hideOnboarding;
- (void) showOnboarding;

// Form validation

- (BOOL) registrationFormPartOneIsValidForUserName: (UITextField*) userNameInputField;

- (BOOL) registrationFormIsValidForEmail: (UITextField*) emailInputField
                                userName: (UITextField*) userNameInputField
                                password: (UITextField*) passwordInputField
                                      dd: (UITextField*) ddInputField
                                      mm: (UITextField*) mmInputField
                                    yyyy: (UITextField*) yyyyInputField;

- (BOOL) dateValidForDd: (UITextField*) ddInputField
                     mm: (UITextField*) mmInputField
                   yyyy: (UITextField*) yyyyInputField;

- (BOOL) loginFormIsValidForUsername: (UITextField*) userNameInputField
                            password: (UITextField*) passwordInputField;

- (BOOL) resetPasswordFormIsValidForUsername: (UITextField*) userNameInputField;

- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view;

- (NSString*) zeroPadIfOneCharacter: (NSString*) inputString;

// Additional reachability enablig for resume from background scenario
- (void) applicationResume;

@end
