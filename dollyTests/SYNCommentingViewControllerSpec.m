#import <Kiwi.h>
#import "SYNCommentingViewController.h"
#import "SYNTrackingManager.h"
#import "NSString+TestHelpers.h"

@interface SYNCommentingViewController () <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *sendMessageTextView;
@property (nonatomic, strong) IBOutlet UIButton *sendMessageButton;

@property (nonatomic, strong) IBOutlet UILabel *charactersLeftLabel;

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
			[[theValue(viewController.sendMessageButton.enabled) should] beNo];
		});
		
	});
	
	context(@"when editing a comment is started", ^{
		
		it(@"should enable the send message button", ^{
			[viewController textViewDidBeginEditing:viewController.sendMessageTextView];
			[[theValue(viewController.sendMessageButton.enabled) should] beYes];
		});
		
	});
	
	context(@"when editing a comment", ^{
		
		it(@"should allow entering one character and update character count", ^{
			UITextView *textView = viewController.sendMessageTextView;
			[viewController textViewDidBeginEditing:textView];
			
			BOOL shouldChangeText = [viewController textView:textView
									 shouldChangeTextInRange:NSMakeRange(0, 0)
											 replacementText:@"0"];
			[[theValue(shouldChangeText) should] beYes];
			[[viewController.charactersLeftLabel.text should] equal:@"119"];
		});
		
		it(@"should allow entering 120 characters", ^{
			UITextView *textView = viewController.sendMessageTextView;
			[viewController textViewDidBeginEditing:textView];
			
			textView.text = [NSString testStringWithLength:119];
			
			BOOL shouldChangeText = [viewController textView:textView
									 shouldChangeTextInRange:NSMakeRange(0, 0)
											 replacementText:@"0"];
			[[theValue(shouldChangeText) should] beYes];
			[[viewController.charactersLeftLabel.text should] equal:@"0"];
		});
		
		it(@"should disallow entering 121 characters", ^{
			UITextView *textView = viewController.sendMessageTextView;
			[viewController textViewDidBeginEditing:textView];
			
			textView.text = [NSString testStringWithLength:120];
			
			BOOL shouldChangeText = [viewController textView:textView
									 shouldChangeTextInRange:NSMakeRange([textView.text length], 0)
											 replacementText:@"0"];
			[[theValue(shouldChangeText) should] beNo];
		});
		
		it(@"should send the comment when the return key is pressed", ^{
			UITextView *textView = viewController.sendMessageTextView;
			
			[viewController textViewDidBeginEditing:textView];
			textView.text = @"This is a test message";
			
			[[viewController should] receive:@selector(sendComment)];
			
			BOOL shouldChangeText = [viewController textView:textView
									 shouldChangeTextInRange:NSMakeRange([textView.text length], 0)
											 replacementText:@"\n"];
			
			[[theValue(shouldChangeText) should] beNo];
		});
		
	});
	
	context(@"when finishing editing a comment", ^{
		
		it(@"should disable the send message button", ^{
			[viewController textViewDidBeginEditing:viewController.sendMessageTextView];
			[viewController textViewDidEndEditing:viewController.sendMessageTextView];
			[[theValue(viewController.sendMessageButton.enabled) should] beNo];
		});
		
	});
	
});

SPEC_END