#import <Kiwi.h>
#import "SYNProfileViewController.h"
#import "SYNTrackingManager.h"

@interface SYNProfileViewController () <SYNProfileHeaderDelegate>

@end

SPEC_BEGIN(SYNProfileViewControllerSpec)

describe(@"SYNProfileViewController", ^{

	__block SYNProfileViewController *viewController;
	__block SYNTrackingManager *mockManager;

	beforeEach(^{
		viewController = [[SYNProfileViewController alloc] init];
		[[viewController should] beNonNil];
		mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];

	});

	
	it(@"should track screen view", ^{        
        [viewController stub:@selector(isUserProfile) andReturn:theValue(NO)];
		[[mockManager should]receive:@selector(trackOtherUserProfileScreenView)];
		[viewController viewDidAppear:YES];;
		
	});
	
    it(@"should track screen view", ^{
        
        [viewController stub:@selector(isUserProfile) andReturn:theValue(YES)];
        [[mockManager should]receive:@selector(trackOwnProfileScreenView)];
		[viewController viewDidAppear:YES];;
		
	});

	it(@"should track the followings tab button own user", ^{
        [viewController stub:@selector(isFollowingsCollectionViewShowing) andReturn:theValue(NO)];
        [viewController stub:@selector(isUserProfile) andReturn:theValue(YES)];
		[[mockManager should]receive:@selector(trackOwnProfileFollowingScreenView)];
        [[mockManager should]receive:@selector(trackTabSelection:forChannelOwnerName:)];
        [[mockManager should]receive:@selector(trackOwnProfileFollowingScreenView)];

        [viewController followingsTabTapped];

	});

    it(@"should track the followings tab button", ^{
        [viewController stub:@selector(isFollowingsCollectionViewShowing) andReturn:theValue(NO)];
        [viewController stub:@selector(isUserProfile) andReturn:theValue(NO)];
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