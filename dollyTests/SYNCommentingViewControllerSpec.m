#import <Kiwi.h>
#import "SYNCommentingViewController.h"
#import "SYNTrackingManager.h"

@interface SYNCommentingViewController () <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *sendMessageTextView;
@property (nonatomic, strong) IBOutlet UIButton *sendMessageButton;

@end

SPEC_BEGIN(SYNCommentingViewControllerSpec)

describe(@"SYNCommentingViewController", ^{
	
	__block SYNCommentingViewController *viewController;
	
	beforeEach(^{
		viewController = [[SYNCommentingViewController alloc] init];
		UIView *view = viewController.view;
		
		[[view should] beNonNil];
	});
	
	it(@"should track screen view", ^{
		SYNTrackingManager *mockManager = [SYNTrackingManager mock];
		[SYNTrackingManager stub:@selector(sharedManager) andReturn:mockManager];
		
		[mockManager stub:@selector(trackCommentingScreenView)];
		
		[viewController viewDidAppear:YES];
	});
	
	context(@"when loading the view", ^{
		
		it(@"the send button should be disabled", ^{
			[[theValue(viewController.sendMessageButton.enabled) should] equal:theValue(NO)];
		});
		
	});
	
	context(@"when editing a comment is started", ^{
		
		it(@"the send button should be enabled", ^{
			[viewController textViewDidBeginEditing:viewController.sendMessageTextView];
			[[theValue(viewController.sendMessageButton.enabled) should] equal:theValue(YES)];
		});
		
	});
	
});

SPEC_END