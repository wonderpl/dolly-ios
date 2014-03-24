#import <Kiwi.h>
#import "SYNOnBoardingViewController.h"
#import "SYNTrackingManager.h"
#import "SYNOnBoardingFooter.h"

@interface SYNOnBoardingViewController () <UIBarPositioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SYNOnboardingFooterDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, assign) NSInteger followedCount;

@property (nonatomic, copy) NSArray *groupedRecommendations;

- (void)followControlPressed:(SYNSocialButton *)socialButton;

@end

SPEC_BEGIN(SYNOnboardingViewControllerSpec)

describe(@"SYNOnboardingViewController", ^{
	
	it(@"should track screen view", ^{
		SYNTrackingManager *mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];
		
		[mockManager stub:@selector(trackOnboardingScreenView)];
		
		UIViewController *viewController = [[SYNOnBoardingViewController alloc] init];
		[viewController viewDidAppear:YES];
	});
	
	context(@"when tracking followed count", ^{
		
		it(@"should increment when someone is followed", ^{
			
			SYNSocialButton *mockButton = [SYNSocialButton nullMock];
			[mockButton stub:@selector(isSelected) andReturn:theValue(NO)];
			
			SYNOnBoardingViewController *viewController = [[SYNOnBoardingViewController alloc] init];
			[viewController followControlPressed:mockButton];
			
			[[theValue(viewController.followedCount) should] equal:theValue(1)];
			
		});
		
		it(@"should decrement when someone is unfollowed", ^{
			
			SYNSocialButton *mockButton = [SYNSocialButton nullMock];
			[mockButton stub:@selector(isSelected) andReturn:theValue(YES)];
			
			SYNOnBoardingViewController *viewController = [[SYNOnBoardingViewController alloc] init];
			
			viewController.followedCount = 1;
			[viewController followControlPressed:mockButton];
			
			[[theValue(viewController.followedCount) should] equal:theValue(0)];
			
		});
		
		it(@"should track the number of follows when continue is pressed", ^{
			SYNTrackingManager *trackingManager = [SYNTrackingManager mock];
			[SYNTrackingManager stub:@selector(sharedManager) andReturn:trackingManager];
			
			[trackingManager stub:@selector(trackOnboardingCompletedWithFollowedCount:) withArguments:theValue(2)];
			
			SYNOnBoardingViewController *viewController = [[SYNOnBoardingViewController alloc] init];
			
			viewController.followedCount = 2;
			[viewController continueButtonPressed:nil];
			
		});
		
	});
	
});

SPEC_END