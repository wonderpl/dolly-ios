//
//  SYNiPadIntroViewController.m
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNiPadIntroViewController.h"
#import "SYNiPadLoginViewController.h"
#import "SYNiPadIntroToLoginAnimator.h"
#import "SYNIPadSignupViewController.h"
#import "SYNiPadLoginToSignupAnimator.h"
#import "SYNiPadLoginToForgotPasswordAnimator.h"
#import "SYNiPadPasswordForgotViewController.h"
#import "SYNiPadIntroToSignupAnimator.h"
#import "SYNLoginManager.h"
#import "SYNTrackingManager.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "SYNTwitterManager.h"

@import Accounts;

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

static const CGFloat CloudTiming = 0.5f;
static const CGFloat DelayConstant = 0.5;


@interface SYNiPadIntroViewController () <UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIButton *facebookButton;
@property (nonatomic, strong) IBOutlet UIButton *signupButton;

@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UILabel *loginLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutlet UIView *userContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundFood;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundChurch;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundBeach;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundHome;
@property (strong, nonatomic) IBOutlet UIView *backgroundChurchView;
@property (strong, nonatomic) IBOutlet UILabel *messageView;
@property (strong, nonatomic) IBOutlet UILabel *messageView3;
@property (strong, nonatomic) IBOutlet UILabel *messageView4;
@property (strong, nonatomic) IBOutlet UILabel *messageView5;

@property (strong, nonatomic) IBOutlet UIView *orView;
@property (strong, nonatomic) IBOutlet UILabel *alreadyHaveAccountLabel;
@property (strong, nonatomic) IBOutlet UILabel *culture;
@property (strong, nonatomic) IBOutlet UILabel *mind;
@property (strong, nonatomic) IBOutlet UILabel *tech;
@property (strong, nonatomic) IBOutlet UILabel *food;
@property (strong, nonatomic) IBOutlet UILabel *news;
@property (strong, nonatomic) IBOutlet UILabel *wellness;
@property (strong, nonatomic) IBOutlet UILabel *film;
@property (strong, nonatomic) IBOutlet UILabel *learnFrom;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIActionSheet *actionSheet;


@end

@implementation SYNiPadIntroViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationController.delegate = self;
    
    self.spinner.hidden = YES;
    
    self.loginButton.layer.borderColor = [[UIColor clearColor] CGColor];
    self.signupButton.layer.borderColor = [[UIColor clearColor] CGColor];
    
    [self.messageView setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView3 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView4 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView5 setFont:[UIFont regularCustomFontOfSize:24]];
    
    [self.alreadyHaveAccountLabel setFont:[UIFont regularCustomFontOfSize:14]];
    
    [self.culture setFont:[UIFont regularCustomFontOfSize:self.culture.font.pointSize]];
    [self.mind setFont:[UIFont regularCustomFontOfSize:self.mind.font.pointSize]];
    [self.tech setFont:[UIFont regularCustomFontOfSize:self.tech.font.pointSize]];
    [self.food setFont:[UIFont regularCustomFontOfSize:self.food.font.pointSize]];
    [self.news setFont:[UIFont regularCustomFontOfSize:self.news.font.pointSize]];
    [self.wellness setFont:[UIFont regularCustomFontOfSize:self.wellness.font.pointSize]];
    [self.film setFont:[UIFont regularCustomFontOfSize:self.film.font.pointSize]];
    [self.learnFrom setFont:[UIFont regularCustomFontOfSize:self.learnFrom.font.pointSize]];

    
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

    NSMutableArray* animationBlocks = [NSMutableArray new];
    
    typedef void(^animationBlock)(BOOL);
    
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
        [UIView animateWithDuration:1.0 animations:^{
        } completion: getNextAnimation()];
    }];
    
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
        
        frame = self.logoImageView.frame;
        frame.origin.y -= 30;
        self.logoImageView.frame = frame;

        
        [UIView animateWithDuration:1.0 animations:^{
            
            CGRect frame = self.logoImageView.frame;
            frame.origin.y += 30;
            
            self.logoImageView.frame = frame;
            self.logoImageView.alpha = 1.0;
            
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
        
        [UIView animateWithDuration:CloudTiming+0.2 delay:DelayConstant+1.4 options:UIViewAnimationCurveEaseInOut animations:^{
            self.culture.alpha = 1.0;
        } completion:nil];
        
        [UIView animateWithDuration:1.5 delay:DelayConstant+0.2 options:UIViewAnimationCurveEaseInOut animations:^{
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
        [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            self.messageView5.alpha = 1.0;
        } completion:getNextAnimation()];
    }];

    getNextAnimation()(YES);
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackStartScreenView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    self.messageView.hidden = YES;
    self.messageView3.hidden = YES;
    self.messageView4.hidden = YES;
	self.messageView5.hidden = NO;
    self.messageView5.alpha = 1.0;
    
    self.backgroundFood.hidden = YES;
    self.backgroundBeach.hidden = YES;
    self.backgroundChurch.hidden = YES;

}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								  animationControllerForOperation:(UINavigationControllerOperation)operation
											   fromViewController:(UIViewController *)fromVC
												 toViewController:(UIViewController *)toVC {
	if ([fromVC isKindOfClass:[SYNiPadIntroViewController class]] && [toVC isKindOfClass:[SYNiPadLoginViewController class]]) {
		return [SYNiPadIntroToLoginAnimator animatorForPresentation:YES];
	}
	if ([fromVC isKindOfClass:[SYNiPadLoginViewController class]] && [toVC isKindOfClass:[SYNiPadPasswordForgotViewController class]]) {
		return [SYNiPadLoginToForgotPasswordAnimator animatorForPresentation:YES];
	}
	if ([fromVC isKindOfClass:[SYNiPadPasswordForgotViewController class]] && [toVC isKindOfClass:[SYNiPadLoginViewController class]]) {
		return [SYNiPadLoginToForgotPasswordAnimator animatorForPresentation:NO];
	}
	if ([fromVC isKindOfClass:[SYNiPadLoginViewController class]] && [toVC isKindOfClass:[SYNIPadSignupViewController class]]) {
		return [SYNiPadLoginToSignupAnimator animatorForPresentation:YES];
	}
	if ([fromVC isKindOfClass:[SYNIPadSignupViewController class]] && [toVC isKindOfClass:[SYNiPadLoginViewController class]]) {
		return [SYNiPadLoginToSignupAnimator animatorForPresentation:NO];
	}
	if ([fromVC isKindOfClass:[SYNiPadIntroViewController class]] && [toVC isKindOfClass:[SYNIPadSignupViewController class]]) {
		return [SYNiPadIntroToSignupAnimator animatorForPresentation:YES];
	}
    if ([fromVC isKindOfClass:[SYNIPadSignupViewController class]] && [toVC isKindOfClass:[SYNiPadIntroViewController class]]) {
        return [SYNiPadIntroToSignupAnimator animatorForPresentation:NO];
	}
    
    if ([fromVC isKindOfClass:[SYNiPadLoginViewController class]] && [toVC isKindOfClass:[SYNiPadIntroViewController class]]) {
        return [SYNiPadIntroToLoginAnimator animatorForPresentation:NO];
    }

	return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
}

- (IBAction)facebookButtonPressed:(UIButton *)button {
    
    [[SYNTrackingManager sharedManager] trackFacebookLogin];

	[self disableLoginButtons];
	
	__weak typeof(self) weakSelf = self;
	
	[[SYNLoginManager sharedManager] loginThroughFacebookWithCompletionHandler:^(NSDictionary *dictionary) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted
															object:self];
        
        
	} errorHandler:^(id error) {
		[weakSelf enableLoginButtons];
		
        NSLog(@"error :error :%@", error);
        if ([error isKindOfClass:[NSString class]]) {
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
									message: error
								   delegate: nil
						  cancelButtonTitle: NSLocalizedString(@"OK", nil)
						  otherButtonTitles: nil] show];

        }  else if ([error isKindOfClass:[NSDictionary class]]) {
        
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"facebook_login_error_title", nil)
                                        message:error[@"error"]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            
            
        }
		DebugLog(@"Log in failed!");
	}];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
	[self enableLoginButtons];
}

- (void)disableLoginButtons {
	self.signupButton.enabled = NO;
	self.loginButton.enabled = NO;
	self.facebookButton.enabled = NO;
	[UIView animateWithDuration:0.3 animations:^{
		self.signupButton.alpha = 0.0;
		self.loginButton.alpha = 0.0;
	}];
}

- (void)enableLoginButtons {
	self.signupButton.enabled = YES;
	self.loginButton.enabled = YES;
	self.facebookButton.enabled = YES;
	[UIView animateWithDuration:0.3 animations:^{
		self.signupButton.alpha = 1.0;
		self.loginButton.alpha = 1.0;
	}];
}
- (IBAction)twitterButtonPressed:(id)sender {

    [[SYNTrackingManager sharedManager] trackTwitterLogin];
    
    [[SYNTwitterManager sharedTwitterManager] refreshTwitterAccounts:^(BOOL completion) {
        if (completion) {
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (ACAccount *acct in [[SYNTwitterManager sharedTwitterManager] accounts]) {
                [self.actionSheet addButtonWithTitle:acct.username];
            }
            self.actionSheet.cancelButtonIndex = [self.actionSheet addButtonWithTitle:@"Cancel"];
            [self.actionSheet showInView:self.view];
        }
    }];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
        
		ACAccount *account = [[[SYNTwitterManager sharedTwitterManager] accounts] objectAtIndex:buttonIndex];
        
        [[SYNLoginManager sharedManager]loginThroughTwitterWithAccount:account CompletionHandler:^(NSDictionary * response) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted
                                                                object:self];
            self.spinner.hidden = YES;
            [self.spinner stopAnimating];
            
        } errorHandler:nil];
    }
}


@end
