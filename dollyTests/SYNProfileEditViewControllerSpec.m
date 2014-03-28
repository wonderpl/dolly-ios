


#import <Kiwi.h>
#import "SYNProfileEditViewController.h"
#import "SYNTrackingManager.h"
#import "SYNChannelCreateNewCell.h"

@interface SYNProfileEditViewController () <SYNChannelCreateNewCelllDelegate>

@end

SPEC_BEGIN(SYNProfileEditViewControllerSpec)

describe(@"SYNProfileEditViewController", ^{
	
	
	it(@"should track edit tapped button in the profile screen", ^{
		
		SYNTrackingManager *mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];
	
		SYNProfileEditViewController *viewController = [[SYNProfileEditViewController alloc]init];
		
		[[mockManager should]receive:@selector(trackEditProfileScreenView)];
		[viewController viewDidAppear:YES];
		
	});

});

SPEC_END

