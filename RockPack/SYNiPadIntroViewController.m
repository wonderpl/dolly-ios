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
@property (strong, nonatomic) IBOutlet UILabel *messageView;

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

    //add a block to our queue
    [animationBlocks addObject:^(BOOL finished){;
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
            CGRect frame = self.backgroundFood.frame;
            
            frame.size = CGSizeMake(frame.size.width*2, frame.size.height*2);
            frame.origin = CGPointMake(-frame.size.width/3, -frame.size.height/3);
            
            self.backgroundFood.frame = frame;
            self.backgroundFood.alpha = 0.0;
            
            frame = self.messageView.frame;
            self.messageView.alpha = 0.0;
//
//            
//            frame = self.messageView2.frame;
//            
//            frame.origin.y += 60;
//            
//            self.messageView2.frame = frame;
//            self.messageView2.alpha = 1.0;
            
        } completion:getNextAnimation()];
   
    
    }];
    
//    [animationBlocks addObject:^(BOOL finished){;
//        
//        CGRect frame = self.backgroundChurch.frame;
//        frame.origin.x -= self.backgroundChurch.frame.size.width/2;
//        frame.origin.y -= self.backgroundChurch.frame.size.height/2;
//        
//        self.backgroundChurch.frame = frame;
//        
////        self.logoImageView.translatesAutoresizingMaskIntoConstraints = YES;
////        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
//        self.backgroundChurch.translatesAutoresizingMaskIntoConstraints = YES;
////        self.messageView2.translatesAutoresizingMaskIntoConstraints = YES;
//
//        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
//
//            self.backgroundChurch.layer.anchorPoint = CGPointMake(0, 0);
//            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
//                self.backgroundChurch.transform = CGAffineTransformMakeRotation(DEGREES_RADIANS(45));
//                self.backgroundChurch.alpha = 0.0;
////                self.messageView2.alpha = 0.0;
////                self.messageView3.alpha = 1.0;
//                
//            } completion:getNextAnimation()];
//            
//            
//        } completion:getNextAnimation()];
//        
//        
//    }];
//
//    
//    [animationBlocks addObject:^(BOOL finished){;
//        
//        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
//            CGRect frame = self.backgroundBeach.frame;
//            frame.origin.x -= frame.size.width;
//            self.backgroundBeach.frame = frame;
//            self.backgroundBeach.alpha = 0.0;
//            
//        } completion:getNextAnimation()];
//        
//    }];
//    
//    [animationBlocks addObject:^(BOOL finished){;
//        self.backgroundMountain.translatesAutoresizingMaskIntoConstraints = YES;
//        
//        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
//            self.backgroundMountain.layer.transform = CATransform3DMakeRotation(M_PI/2, 0.0, 1.0, 0.0);
//            self.backgroundMountain.alpha = 0.0;
//            
//        } completion:getNextAnimation()];
//        
//    }];

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
