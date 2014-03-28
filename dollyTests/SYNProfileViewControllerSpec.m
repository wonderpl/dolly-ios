#import <Kiwi.h>
#import "SYNProfileViewController.h"
#import "SYNTrackingManager.h"

@interface SYNProfileViewController () <SYNProfileDelegate>

@end

SPEC_BEGIN(SYNProfileViewControllerSpec)

describe(@"SYNProfileViewController", ^{
	
	it(@"should track screen view", ^{
		SYNTrackingManager *mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];
		
		SYNProfileViewController *viewController = [[SYNProfileViewController alloc] init];
		
//		[[mockManager should]receive:@selector(trackOwnProfileScreenView)];
//		[[mockManager should]receive:@selector(trackOwnProfileFollowingScreenView)];
//		[[mockManager should]receive:@selector(trackOwnProfileFollowingScreenView)];
//		[[mockManager should]receive:@selector(trackCollectionCreatedWithName) withArguments:@"name of channel"];
//		[[mockManager should]receive:@selector(trackAvatarPhotoUploadCompleted)];
//		[[mockManager should]receive:@selector(trackCoverPhotoUploadCompleted)];
//		[[mockManager should]receive:@selector(trackCreateChannelScreenView)];
//		[[mockManager should]receive:@selector(trackUserCollectionsFollowFromScreenName) withArguments:[viewController trackingScreenName]];

		
		
		[[mockManager should]receive:@selector(trackOtherUserProfileScreenView)];
		[viewController viewDidAppear:YES];;
		
		
		[[mockManager should]receive:@selector(trackEditProfileScreenView)];
		[viewController editButtonTapped];

		[[mockManager should]receive:@selector(trackOtherUserCollectionFollowingScreenView)];
		[viewController followingsTabTapped];
		
		[[mockManager should]receive:@selector(trackCoverPhotoUpload)];
		[viewController updateCoverImage:nil];
		
		
		[viewController updateAvatarImage:nil];
		[[mockManager should]receive:@selector(trackAvatarUploadFromScreen) withArguments:[viewController trackingScreenName]];		
		
	});
	
});

SPEC_END