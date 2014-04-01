


#import <Kiwi.h>
#import "SYNProfileEditViewController.h"
#import "SYNTrackingManager.h"
#import "SYNChannelCreateNewCell.h"

@interface SYNProfileEditViewController () <SYNChannelCreateNewCelllDelegate>

@end

SPEC_BEGIN(SYNProfileEditViewControllerSpec)

describe(@"SYNProfileEditViewController", ^{
	
	__block SYNTrackingManager *mockManager;
	__block SYNProfileEditViewController *viewController;
	
	beforeEach(^{
		mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];
		viewController = [[SYNProfileEditViewController alloc]init];
	});
	
	it(@"should track edit tapped button in the profile screen", ^{
		
		[[mockManager should]receive:@selector(trackEditProfileScreenView)];
		[viewController viewDidAppear:YES];
		
	});

});

SPEC_END

