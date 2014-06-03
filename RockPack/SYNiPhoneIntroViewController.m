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

static const CGFloat CloudTiming = 0.5f;
static const CGFloat DelayConstant = 0.5;


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
@property (strong, nonatomic) IBOutlet UILabel *culture;
@property (strong, nonatomic) IBOutlet UILabel *mind;
@property (strong, nonatomic) IBOutlet UILabel *tech;
@property (strong, nonatomic) IBOutlet UILabel *food;
@property (strong, nonatomic) IBOutlet UILabel *news;
@property (strong, nonatomic) IBOutlet UILabel *wellness;
@property (strong, nonatomic) IBOutlet UILabel *fashion;
@property (strong, nonatomic) IBOutlet UILabel *film;
@property (strong, nonatomic) IBOutlet UILabel *learnFrom;
@property (strong, nonatomic) IBOutlet UILabel *experts;

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
    
    
    [self.culture setFont:[UIFont regularCustomFontOfSize:24]];
    [self.mind setFont:[UIFont regularCustomFontOfSize:24]];
    [self.tech setFont:[UIFont regularCustomFontOfSize:24]];
    [self.food setFont:[UIFont regularCustomFontOfSize:24]];
    [self.news setFont:[UIFont regularCustomFontOfSize:24]];
    [self.wellness setFont:[UIFont regularCustomFontOfSize:24]];
    [self.fashion setFont:[UIFont regularCustomFontOfSize:24]];
    [self.film setFont:[UIFont regularCustomFontOfSize:24]];
    [self.learnFrom setFont:[UIFont regularCustomFontOfSize:26]];
    [self.experts setFont:[UIFont regularCustomFontOfSize:24]];


    
    [self.signupButton setTitle:@"Sign up" forState:UIControlStateNormal];
    
    self.signupButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.signupButton.titleLabel.font.pointSize];
    self.signupButton.titleLabel.textColor = [UIColor whiteColor];
    self.signupButton.layer.cornerRadius = self.signupButton.frame.size.height * 0.5;
    [self.signupButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.orText setFont:[UIFont regularCustomFontOfSize:16]];
    
    [self.haveAnAccountLabel setFont:[UIFont regularCustomFontOfSize:14]];
    self.facebookButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.facebookButton.titleLabel.font.pointSize];
    
    self.loginButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.loginButton.titleLabel.font.pointSize];

    
    [self.facebookButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
    
    double delayInSecondChurch = 3.0;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSecondChurch * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CGRect frame = self.backgroundChurch.frame;
        
        frame.size = CGSizeMake(frame.size.width*2, frame.size.height*2);
        frame.origin = CGPointMake(-frame.size.width/4, -frame.size.height/3);
        
        [UIView animateWithDuration:10.0 animations:^{
            self.backgroundChurch.frame = frame;
            self.backgroundChurch.alpha = 0.0;

        }];
        
    });
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
            
            CGRect frame = self.facebookButton.frame;
            frame.origin.y += 30;
            self.facebookButton.frame = frame;
             frame = self.loginButton.frame;
            frame.origin.y -= 30;
            self.loginButton.frame = frame;
            
            frame = self.signupButton.frame;
            frame.origin.y -= 30;
            self.signupButton.frame = frame;


            [UIView animateWithDuration:1.0 animations:^{
                
                CGRect frame = self.logoImageView.frame;
                frame.origin.y += 30;
            	
                self.logoImageView.alpha = 1.0;
                self.logoImageView.frame = frame;
                
                frame = self.facebookButton.frame;
                frame.origin.y -= 30;
                self.facebookButton.frame = frame;
                self.facebookButton.alpha = 1.0;
                self.orView.alpha = 1.0;

                frame = self.loginButton.frame;
                frame.origin.y += 30;
                self.loginButton.frame = frame;
                self.loginButton.alpha = 1.0;

                frame = self.signupButton.frame;
                frame.origin.y += 30;
                self.signupButton.frame = frame;
                self.signupButton.alpha = 1.0;
                self.alreadyHaveAccountLabel.alpha = 1.0;

            } completion: getNextAnimation()];
        }];
        
        [animationBlocks addObject:^(BOOL finished){;
            [UIView animateWithDuration:2.0 animations:^{
                self.messageView.alpha = 1.0;
            } completion: getNextAnimation()];
            [UIView animateWithDuration:4.0 animations:^{
                
                self.messageView.transform = CGAffineTransformMakeScale(1.15, 1.15);
                
            } completion: nil];

        }];

        
        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:CloudTiming delay:DelayConstant+0.4 options:UIViewAnimationCurveEaseInOut animations:^{
                self.culture.alpha = 1.0;
            } completion:nil];
            
            [UIView animateWithDuration:1.5 delay:DelayConstant-0.5 options:UIViewAnimationCurveEaseInOut animations:^{
                CGRect frame = self.backgroundFood.frame;
                
                frame.size = CGSizeMake(frame.size.width*2, frame.size.height*2);
                frame.origin = CGPointMake(-frame.size.width/3, -frame.size.height/3);
                
                self.backgroundFood.frame = frame;
                self.backgroundFood.alpha = 0.0;
                self.messageView.alpha = 0.0;

            } completion:getNextAnimation()];
        }];
        
        
        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:CloudTiming animations:^{
                self.mind.alpha = 1.0;
            } completion: getNextAnimation()];
        }];

        [animationBlocks addObject:^(BOOL finished){;
            [UIView animateWithDuration:CloudTiming animations:^{
                self.tech.alpha = 1.0;
            } completion: getNextAnimation()];
            
            [UIView animateWithDuration:CloudTiming delay:DelayConstant-0.85 options:UIViewAnimationCurveEaseIn animations:^{
                self.culture.alpha = 0.0;
            } completion: nil];

        }];

        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:CloudTiming delay:DelayConstant-0.85 options:UIViewAnimationCurveEaseIn animations:^{
                self.food.alpha = 1.0;
                
            } completion:getNextAnimation()];
        
        }];

        
        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:CloudTiming animations:^{
                self.mind.alpha = 0.0;
            } completion: nil];
            
            [UIView animateWithDuration:1.0 delay:DelayConstant-0.6 options:UIViewAnimationCurveEaseIn animations:^{
                self.news.alpha = 1.0;
                
            } completion:getNextAnimation()];
            
        }];

        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:CloudTiming animations:^{
                self.tech.alpha = 0.0;
                self.wellness.alpha = 1.0;

            } completion: getNextAnimation()];
            
        }];

        
        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:CloudTiming animations:^{
                self.food.alpha = 0.0;
            } completion: getNextAnimation()];
            
            [UIView animateWithDuration:CloudTiming animations:^{
                self.fashion.alpha = 1.0;
            } completion:nil];
            
        }];
        
        [animationBlocks addObject:^(BOOL finished){;
            [UIView animateWithDuration:CloudTiming animations:^{
                self.wellness.alpha = 0.0;
            } completion:getNextAnimation()];
            
        }];

        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateWithDuration:CloudTiming animations:^{
                self.news.alpha = 0.0;
            } completion:nil];

            
            [UIView animateWithDuration:CloudTiming-0.1 delay:DelayConstant options:UIViewAnimationCurveEaseIn animations:^{
                self.film.alpha = 0.0;

            } completion:nil];
            
            [UIView animateWithDuration:2.0 delay:DelayConstant+0.65 options:UIViewAnimationCurveLinear animations:^{
                self.learnFrom.alpha = 1.0;
            } completion:getNextAnimation()];

        }];
        
        [animationBlocks addObject:^(BOOL finished){;

            [UIView animateKeyframesWithDuration:1.3 delay:DelayConstant-0.7 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                self.learnFrom.alpha = 0.0;
                self.backgroundBeach.alpha = 0.0;

            } completion:getNextAnimation ()];
        }];

        
        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateKeyframesWithDuration:1.5 delay:0.2 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                self.messageView4.alpha = 1.0;
            } completion:getNextAnimation()];
            
        }];


        [animationBlocks addObject:^(BOOL finished){;
            
            [UIView animateKeyframesWithDuration:1.0 delay:1.4 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                self.messageView4.alpha = 0.0;
            } completion:getNextAnimation()];
            
        }];

        [animationBlocks addObject:^(BOOL finished){;
            [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                self.messageView5.alpha = 1.0;
            } completion:getNextAnimation()];
        }];
        
        getNextAnimation()(YES);
    
    });

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

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

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
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
