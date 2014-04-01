#import <Kiwi.h>
#import "SYNProfileChannelViewController.h"
#import "SYNTrackingManager.h"
#import "SYNChannelCreateNewCell.h"

@interface SYNProfileChannelViewController () <SYNChannelCreateNewCelllDelegate>

@end

SPEC_BEGIN(SYNProfileChannelViewControllerSpec)

describe(@"SYNProfileChannelViewControllerSpec", ^{
	
	__block SYNProfileChannelViewController *viewController;
	__block SYNTrackingManager *mockManager;

	beforeEach(^{
		viewController = [[SYNProfileChannelViewController alloc] init];
		mockManager = [SYNTrackingManager mock];
	});

	it(@"should track clicking tocreate a new collection", ^{
		[[mockManager should]receive:@selector(trackCreateChannelScreenView)];
		[viewController createNewButtonPressed];
	});
	
	it(@"should track clicking tocreate a new collection", ^{
		[[SYNTrackingManager sharedManager] trackCollectionCreatedWithName:nil];
	});

	
});

SPEC_END