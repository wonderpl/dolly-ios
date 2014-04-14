#import <Kiwi.h>
#import "SYNProfileViewController.h"
#import "SYNTrackingManager.h"

@interface SYNProfileViewController ()

@end

SPEC_BEGIN(SYNProfileViewControllerSpec)

describe(@"SYNProfileViewController", ^{
	
	it(@"should track screen view", ^{
		SYNTrackingManager *mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];
	
		[mockManager stub:@selector(trackOtherUserProfileScreenView)];
		
		SYNProfileViewController *viewController = [[SYNProfileViewController alloc] init];
		
		[[mockManager should]receive:@selector(trackOtherUserProfileScreenView)];
		[viewController viewDidAppear:YES];;

	});
	
});

SPEC_END