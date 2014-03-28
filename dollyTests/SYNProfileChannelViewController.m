#import <Kiwi.h>
#import "SYNProfileChannelViewController.h"
#import "SYNTrackingManager.h"
#import "SYNChannelCreateNewCell.h"

@interface SYNProfileChannelViewController () <SYNChannelCreateNewCelllDelegate>

@end

SPEC_BEGIN(SYNProfileChannelViewControllerSpec)

describe(@"SYNProfileChannelViewController", ^{
	
	it(@"should track screen view", ^{
		SYNTrackingManager *mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];

		SYNProfileChannelViewController *viewController = [[SYNProfileChannelViewController alloc] init];
		
//		[[mockManager should]receive:@selector(trackCollectionCreatedWithName) withArguments:@"name of channel"];
//
//		[viewController createNewButtonPressed];
		
	});
	
});

SPEC_END