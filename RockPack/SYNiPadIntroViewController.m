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

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

static const CGFloat TransitionPause = 3.5f;


@interface SYNiPadIntroViewController () <UINavigationControllerDelegate>

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
@property (strong, nonatomic) IBOutlet UIImageView *backgroundMountain;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundHome;
@property (strong, nonatomic) IBOutlet UIView *backgroundChurchView;
@property (strong, nonatomic) IBOutlet UILabel *messageView;
@property (strong, nonatomic) IBOutlet UILabel *messageView2;
@property (strong, nonatomic) IBOutlet UILabel *messageView3;
@property (strong, nonatomic) IBOutlet UILabel *messageView4;
@property (strong, nonatomic) IBOutlet UILabel *messageView5;

@property (strong, nonatomic) IBOutlet UIView *orView;
@property (strong, nonatomic) IBOutlet UILabel *alreadyHaveAccountLabel;

@end

@implementation SYNiPadIntroViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationController.delegate = self;
    
    
    CGRect tmpFrame = self.logoImageView.frame;
    
    
    if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation]) ) {
        tmpFrame = CGRectMake(self.view.center.x-(self.logoImageView.frame.size.width/2), self.view.center.y-(self.logoImageView.frame.size.height/2), tmpFrame.size.width, tmpFrame.size.height);
    } else {
        
        tmpFrame = CGRectMake(self.view.frame.size.height/2-(self.logoImageView.frame.size.width/2), self.view.frame.size.height/2-(self.logoImageView.frame.size.height)*2, tmpFrame.size.width, tmpFrame.size.height);
    }

    
    self.loginButton.layer.borderColor = [[UIColor clearColor] CGColor];
    self.signupButton.layer.borderColor = [[UIColor clearColor] CGColor];
    
    [self.messageView setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView2 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView3 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView4 setFont:[UIFont regularCustomFontOfSize:24]];
    [self.messageView5 setFont:[UIFont regularCustomFontOfSize:24]];
    
    [self.alreadyHaveAccountLabel setFont:[UIFont regularCustomFontOfSize:14]];
    
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
        
        CGRect frame = self.logoImageView.frame;
        frame.origin.y -= 30;
        self.logoImageView.frame = frame;

        [UIView animateWithDuration:1.0 animations:^{
            
            CGRect frame = self.logoImageView.frame;
            frame.origin.y += 30;
            self.logoImageView.frame = frame;
            
            self.logoImageView.alpha = 1.0;
            
        } completion: getNextAnimation()];
    }];

    [animationBlocks addObject:^(BOOL finished){;
        CGRect frame = self.messageView.frame;
        frame.origin.y -= 30;
        self.messageView.frame = frame;

        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.messageView.frame;
            frame.origin.y += 30;
            self.messageView.frame = frame;
            self.messageView.alpha = 1.0;
        } completion: getNextAnimation()];
    }];

    [animationBlocks addObject:^(BOOL finished){;
        
        CGRect frame = self.facebookButton.frame;
        frame.origin.y += 50;
        self.facebookButton.frame = frame;
        
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = self.facebookButton.frame;
            frame.origin.y -= 50;
            self.facebookButton.frame = frame;
            self.facebookButton.alpha = 1.0;
            self.orView.alpha = 1.0;
        } completion: getNextAnimation()];
    }];
    
    [animationBlocks addObject:^(BOOL finished){;
        
        CGRect frame = self.loginButton.frame;
        frame.origin.y -= 50;
        self.loginButton.frame = frame;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.loginButton.frame;
            frame.origin.y += 50;
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
        CGRect frame = self.messageView2.frame;
        frame.origin.y -= 60;
        self.messageView2.frame = frame;

        [UIView animateWithDuration:1.5 delay:TransitionPause options:
         UIViewAnimationCurveEaseInOut animations:^{
            CGRect frame = self.backgroundFood.frame;
            
            frame.size = CGSizeMake(frame.size.width*2, frame.size.height*2);
            frame.origin = CGPointMake(-frame.size.width/3, -frame.size.height/3);
            
            self.backgroundFood.frame = frame;
            self.backgroundFood.alpha = 0.0;
            
            self.messageView.alpha = 0.0;

            
            frame = self.messageView2.frame;
            frame.origin.y += 60;
            
            self.messageView2.frame = frame;
            self.messageView2.alpha = 1.0;
            
        } completion:getNextAnimation()];
   
    
    }];
    
    [animationBlocks addObject:^(BOOL finished){;
        
        CGRect frame = self.backgroundChurch.frame;
        frame.origin.x -= self.backgroundChurch.frame.size.width/2;
        frame.origin.y -= self.backgroundChurch.frame.size.height/2;
        
        self.backgroundChurch.frame = frame;

        self.backgroundChurch.translatesAutoresizingMaskIntoConstraints = YES;
        self.backgroundChurch.layer.anchorPoint = CGPointMake(0, 0);

        [UIView animateWithDuration:1.5 delay:3.0 options:UIViewAnimationCurveEaseInOut animations:^{

                self.backgroundChurch.alpha = 0.0;
	            self.backgroundChurch.transform = CGAffineTransformMakeRotation(DEGREES_RADIANS(45));

                self.messageView2.alpha = 0.0;
                self.messageView3.alpha = 1.0;

        } completion:getNextAnimation()];
        
    }];

    [animationBlocks addObject:^(BOOL finished){;
        self.backgroundChurch.transform = CGAffineTransformIdentity;

        [UIView animateWithDuration:1.0 delay:TransitionPause options:UIViewAnimationCurveEaseInOut animations:^{
            CGRect frame = self.backgroundBeach.frame;
            frame.origin.x -= frame.size.width;
            self.backgroundBeach.frame = frame;
            self.backgroundBeach.alpha = 0.0;
            
            frame = self.messageView3.frame;
            frame.origin.x -= self.messageView3.frame.size.width;
			self.messageView3.frame = frame;
            self.messageView3.alpha = 0.0;
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

        [UIView animateWithDuration:1.5 delay:TransitionPause options:UIViewAnimationCurveEaseInOut animations:^{
            
            self.backgroundMountain.layer.transform = CATransform3DMakeRotation(M_PI/2, 0.0, 1.0, 0.0);
                self.backgroundMountain.alpha = 0.0;
                self.messageView4.alpha = 0.0;
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

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								  animationControllerForOperation:(UINavigationControllerOperation)operation
											   fromViewController:(UIViewController *)fromVC
												 toViewController:(UIViewController *)toVC {
	if ([fromVC isKindOfClass:[SYNiPadIntroViewController class]] && [toVC isKindOfClass:[SYNiPadLoginViewController class]]) {
		return [[SYNiPadIntroToLoginAnimator alloc] init];
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
		return [[SYNiPadIntroToSignupAnimator alloc] init];
	}
	return nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (IBAction)facebookButtonPressed:(UIButton *)button {
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

@end
