//
//  SYNiPhoneIntroViewController.m
//  dolly
//
//  Created by Sherman Lo on 7/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPhoneIntroViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNFacebookManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "NSString+Utils.h"
#import "SYNiPhoneLoginViewController.h"
#import "SYNiPhoneLoginAnimator.h"
#import "SYNLoginManager.h"
#import "SYNTrackingManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Reachability.h>

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

static const CGFloat TransitionPause = 3.5f;


@interface SYNiPhoneIntroViewController () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) SYNAppDelegate *appDelegate;

@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIButton *facebookButton;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *signupButton;
@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UIView *orView;
@property (strong, nonatomic) IBOutlet UILabel *alreadyHaveAccountLabel;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundHome;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundMountain;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundFood;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundChurch;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundBeach;
@property (strong, nonatomic) IBOutlet UILabel *orText;
@property (strong, nonatomic) IBOutlet UILabel *haveAnAccountLabel;

@property (strong, nonatomic) IBOutlet UILabel *messageView;
@property (strong, nonatomic) IBOutlet UILabel *messageView2;
@property (strong, nonatomic) IBOutlet UILabel *messageView3;
@property (strong, nonatomic) IBOutlet UILabel *messageView4;
@property (strong, nonatomic) IBOutlet UILabel *messageView5;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopConstraint;

@end

@implementation SYNiPhoneIntroViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationController.delegate = self;
	
	self.appDelegate = [[UIApplication sharedApplication] delegate];
	
    
    NSMutableArray* animationBlocks = [NSMutableArray new];
    
    typedef void(^animationBlock)(BOOL);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    
    
    if (!IS_IPHONE_5 && IS_IPHONE) {
        [self.buttonContainerViewTopConstraint setConstant:186];
        [self.messageContainerViewTopConstraint setConstant:-64];
    }
    
    [self.subtitleLabel setFont:[UIFont semiboldCustomFontOfSize:28]];
    [self.messageView setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView2 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView3 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView4 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView5 setFont:[UIFont regularCustomFontOfSize:24]];

    
    [self.signupButton setTitle:@"Sign up" forState:UIControlStateNormal];
    
    self.signupButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.signupButton.titleLabel.font.pointSize];
    self.signupButton.titleLabel.textColor = [UIColor whiteColor];
    self.signupButton.layer.cornerRadius = self.signupButton.frame.size.height * 0.5;
    [self.signupButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.orText setFont:[UIFont regularCustomFontOfSize:16]];
    
    [self.haveAnAccountLabel setFont:[UIFont regularCustomFontOfSize:14]];
    self.facebookButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.facebookButton.titleLabel.font.pointSize];
    
    self.loginButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.loginButton.titleLabel.font.pointSize];

    
    [self.facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        animationBlock (^getNextAnimation)() = ^{
            animationBlock block = (animationBlock)[animationBlocks firstObject];
            if (block){
                [animationBlocks removeObjectAtIndex:0];
                return block;
            }else{
                return ^(BOOL finished){};
            }
        };
        
        [animationBlocks addObject:^(BOOL finished){;
            self.logoImageView.alpha = 0.5;
            [UIView animateWithDuration:1.0 animations:^{
                
                CGRect frame = self.logoImageView.frame;
                frame.origin.y += 30;
            	
                self.logoImageView.alpha = 1.0;
                self.logoImageView.frame = frame;
            } completion: getNextAnimation()];
        }];
        
        
        [animationBlocks addObject:^(BOOL finished){;
            CGRect frame = self.messageView.frame;
            frame.origin.y -= 30;
            self.messageView.frame = frame;
            self.messageView.alpha = 1.0;

            [UIView animateWithDuration:1.0 animations:^{
                CGRect frame = self.messageView.frame;
                frame.origin.y += 30;
                self.messageView.frame = frame;
                self.messageView.alpha = 1.0;
            } completion: getNextAnimation()];
        }];
        
        [animationBlocks addObject:^(BOOL finished){;
            
            CGRect frame = self.facebookButton.frame;
            frame.origin.y += 30;
            self.facebookButton.frame = frame;

            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.facebookButton.frame;
                frame.origin.y -= 30;
                self.facebookButton.frame = frame;
                self.facebookButton.alpha = 1.0;
                self.orView.alpha = 1.0;
            } completion: getNextAnimation()];
        }];

        
        [animationBlocks addObject:^(BOOL finished){;
            CGRect frame = self.loginButton.frame;
            frame.origin.y -= 30;
            self.loginButton.frame = frame;

            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.loginButton.frame;
                frame.origin.y += 30;
                self.loginButton.frame = frame;
                self.loginButton.alpha = 1.0;
            } completion: getNextAnimation()];
        }];
        
        [animationBlocks addObject:^(BOOL finished){;
            CGRect frame = self.signupButton.frame;
            frame.origin.y -= 30;
            self.signupButton.frame = frame;

            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.signupButton.frame;
                frame.origin.y += 30;
                self.signupButton.frame = frame;
                self.signupButton.alpha = 1.0;
                self.alreadyHaveAccountLabel.alpha = 1.0;
            } completion: getNextAnimation()];
        }];


        [animationBlocks addObject:^(BOOL finished){;
            [UIView animateWithDuration:1.5 delay:TransitionPause options:UIViewAnimationCurveEaseInOut animations:^{
                CGRect frame = self.backgroundFood.frame;
                
                frame.size = CGSizeMake(frame.size.width*2, frame.size.height*2);
                frame.origin = CGPointMake(-frame.size.width/3, -frame.size.height/3);
                
                self.backgroundFood.frame = frame;
                self.backgroundFood.alpha = 0.0;

                self.messageView.alpha = 0.0;
                
                self.messageView2.transform = CGAffineTransformMakeTranslation(0, 120);
				self.messageView2.alpha = 1.0;

            } completion:getNextAnimation()];
        }];
        
        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:TransitionPause animations:^{
            } completion: getNextAnimation()];
        }];
        

        [animationBlocks addObject:^(BOOL finished){;
            
            CGRect frame = self.backgroundChurch.frame;
            frame.origin.x -= self.backgroundChurch.frame.size.width/2;
            frame.origin.y -= self.backgroundChurch.frame.size.height/2;
            
            self.backgroundChurch.frame = frame;
                        
            self.logoImageView.translatesAutoresizingMaskIntoConstraints = YES;
            self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
            self.backgroundChurch.translatesAutoresizingMaskIntoConstraints = YES;
            self.messageView2.translatesAutoresizingMaskIntoConstraints = YES;

            self.backgroundChurch.layer.anchorPoint = CGPointMake(0, 0);
            
            [UIView animateWithDuration:1.0 delay:TransitionPause options:UIViewAnimationCurveEaseInOut animations:^{
                self.backgroundChurch.transform = CGAffineTransformMakeRotation(DEGREES_RADIANS(45));
                self.backgroundChurch.alpha = 0.0;
                
                self.messageView2.alpha = 0.0;
                self.messageView3.alpha = 1.0;
                
            } completion:getNextAnimation()];
            
        }];
        

        [animationBlocks addObject:^(BOOL finished){;
            [UIView animateWithDuration:0.4 animations:^{
                self.messageView3.alpha = 1.0;
            } completion: getNextAnimation()];
        }];

        [animationBlocks addObject:^(BOOL finished){;
            
            
            [UIView animateWithDuration:1.5 delay:TransitionPause options:UIViewAnimationCurveEaseInOut animations:^{
                CGRect frame = self.messageView3.frame;
                
                frame.origin.x -= 30;
                self.messageView3.frame = frame;
                self.messageView3.alpha = 0.0;
                frame = self.backgroundBeach.frame;
                frame.origin.x -= 30;
                self.backgroundBeach.frame = frame;
                self.backgroundBeach.alpha = 0.0;
                self.messageView4.alpha = 1.0;

            } completion:getNextAnimation()];
            
        }];

        
        [animationBlocks addObject:^(BOOL finished){;

            self.backgroundMountain.translatesAutoresizingMaskIntoConstraints = YES;
            self.backgroundMountain.layer.anchorPoint = CGPointMake(1.0, 0.0);
            
            CGRect frame = self.backgroundMountain.frame;
            frame.origin.x += self.backgroundMountain.frame.size.width/2;
            frame.origin.y -= self.backgroundMountain.frame.size.height/2;
            
            self.backgroundMountain.frame = frame;
            
            [UIView animateWithDuration:1.5 delay:3.5 options:UIViewAnimationCurveEaseInOut animations:^{
                
                self.backgroundMountain.layer.transform = CATransform3DMakeRotation(M_PI/2, 0.0, 1.0, 0.0);
                self.backgroundMountain.alpha = 0.0;
                self.messageView4.alpha = 0.0;
                self.messageView5.alpha = 1.0;
                
            } completion:getNextAnimation()];
            
        }];
        
        getNextAnimation()(YES);

    
    
    });

}

- (void)viewWillDisappear:(BOOL)animated {

    self.messageView.hidden = YES;
    self.messageView2.hidden = YES;
    self.messageView3.hidden = YES;
    self.messageView4.hidden = YES;
	self.messageView5.hidden = NO;
    self.messageView5.alpha = 1.0;
    
    self.backgroundFood.hidden = YES;
    self.backgroundBeach.hidden = YES;
    self.backgroundMountain.hidden = YES;
    self.backgroundChurch.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	[[SYNTrackingManager sharedManager] trackStartScreenView];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								  animationControllerForOperation:(UINavigationControllerOperation)operation
											   fromViewController:(UIViewController *)fromVC
												 toViewController:(UIViewController *)toVC {
	return [SYNiPhoneLoginAnimator animatorForPresentation:(operation == UINavigationControllerOperationPush)];
}

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - button IBActions

- (IBAction)fadebookButtonPressed:(UIButton *)button {
	[[SYNTrackingManager sharedManager] trackFacebookLogin];
	
	Reachability *reachability = [Reachability reachabilityWithHostname:self.appDelegate.networkEngine.hostName];
    BOOL isReachable = ([reachability currentReachabilityStatus] != NotReachable);
	if (!isReachable) {
		[self showNetworkInacessibleAlert];
		return;
	}
    
	[[SYNLoginManager sharedManager] loginThroughFacebookWithCompletionHandler:^(NSDictionary* dictionary) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted object:self];
	} errorHandler:^(id error) {
		if ([error isKindOfClass:[NSDictionary class]]) {
			NSDictionary *formErrors = error[@"form_errors"];
			
			if (formErrors) {
				[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
											message: NSLocalizedString(@"facebook_login_error_description", nil)
										   delegate: nil
								  cancelButtonTitle: NSLocalizedString(@"OK", nil)
								  otherButtonTitles: nil] show];
			}
        } else if ([error isKindOfClass:[NSString class]]) {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
                                        message: error
                                       delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil] show];
            
            DebugLog(@"Log in failed!");
        }
	}];
}

- (void)showNetworkInacessibleAlert {
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login_screen_form_no_connection_dialog_title", nil)
								message:NSLocalizedString(@"login_screen_form_no_connection_dialog_message", nil)
							   delegate:nil
					  cancelButtonTitle:nil
					  otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
}


@end
