#import <Kiwi.h>
#import "SYNProfileViewController.h"
#import "SYNTrackingManager.h"

@interface SYNProfileViewController () <SYNProfileDelegate>

@end

SPEC_BEGIN(SYNProfileViewControllerSpec)

describe(@"SYNProfileViewController", ^{
	SYNTrackingManager *mockManager = [SYNTrackingManager mock];
	[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];
	
	SYNProfileViewController *viewController = [[SYNProfileViewController alloc] init];

	it(@"should track screen view", ^{
		
//		[[mockManager should]receive:@selector(trackOwnProfileScreenView)];
//		[[mockManager should]receive:@selector(trackOwnProfileFollowingScreenView)];
//		[[mockManager should]receive:@selector(trackOwnProfileFollowingScreenView)];
//		[[mockManager should]receive:@selector(trackAvatarPhotoUploadCompleted)];
//		[[mockManager should]receive:@selector(trackCoverPhotoUploadCompleted)];
//		[[mockManager should]receive:@selector(trackCreateChannelScreenView)];
//		[[mockManager should]receive:@selector(trackUserCollectionsFollowFromScreenName) withArguments:[viewController trackingScreenName]];

		[[mockManager should]receive:@selector(trackOtherUserProfileScreenView)];
		[viewController viewDidAppear:YES];;
		
	});
	
	
	it(@"should track the followings tab button", ^{
		[[mockManager should]receive:@selector(trackOtherUserCollectionFollowingScreenView)];
		[viewController followingsTabTapped];

	});
	
	it(@"should track cover photo upload", ^{
		[[mockManager should]receive:@selector(trackCoverPhotoUpload)];
		[viewController updateCoverImage:nil];
	});
	
	it(@"should track avatar photo upload", ^{
		[[mockManager should]receive:@selector(trackAvatarUploadFromScreen:) withArguments:[viewController trackingScreenName]];
		[viewController updateAvatarImage:nil];

	});
	
	it(@"should track avatar photo upload", ^{

		
	});
	
});

SPEC_END