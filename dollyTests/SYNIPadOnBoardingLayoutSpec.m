#import <Kiwi.h>
#import "SYNIPadOnBoardingLayout.h"

@interface SYNIPadOnBoardingLayout ()

- (NSArray *)rowLayoutForItemCount:(NSInteger)itemCount columnCount:(NSInteger)columnCount;

@end

SPEC_BEGIN(SYNIPadOnBoardingLayoutSpec)

describe(@"SYNIPadOnBoardingLayout", ^{
	
	context(@"when calculating the row layout", ^{
		
		it(@"should return the correct row layout when there are three columns", ^{
			SYNIPadOnBoardingLayout *layout = [[SYNIPadOnBoardingLayout alloc] init];
			[[[layout rowLayoutForItemCount:1 columnCount:3] should] equal:@[ @1 ]];
			[[[layout rowLayoutForItemCount:2 columnCount:3] should] equal:@[ @2 ]];
			[[[layout rowLayoutForItemCount:3 columnCount:3] should] equal:@[ @3 ]];
			[[[layout rowLayoutForItemCount:4 columnCount:3] should] equal:@[ @2, @2 ]];
			[[[layout rowLayoutForItemCount:5 columnCount:3] should] equal:@[ @3, @2 ]];
			[[[layout rowLayoutForItemCount:6 columnCount:3] should] equal:@[ @3, @3 ]];
			[[[layout rowLayoutForItemCount:7 columnCount:3] should] equal:@[ @3, @2, @2 ]];
			[[[layout rowLayoutForItemCount:8 columnCount:3] should] equal:@[ @3, @3, @2 ]];
			[[[layout rowLayoutForItemCount:9 columnCount:3] should] equal:@[ @3, @3, @3 ]];
		});
		
		it(@"should return the correct row layout when there are four columns", ^{
			SYNIPadOnBoardingLayout *layout = [[SYNIPadOnBoardingLayout alloc] init];
			[[[layout rowLayoutForItemCount:1 columnCount:4] should] equal:@[ @1 ]];
			[[[layout rowLayoutForItemCount:2 columnCount:4] should] equal:@[ @2 ]];
			[[[layout rowLayoutForItemCount:3 columnCount:4] should] equal:@[ @3 ]];
			[[[layout rowLayoutForItemCount:4 columnCount:4] should] equal:@[ @4 ]];
			[[[layout rowLayoutForItemCount:5 columnCount:4] should] equal:@[ @3, @2 ]];
			[[[layout rowLayoutForItemCount:6 columnCount:4] should] equal:@[ @4, @2 ]];
			[[[layout rowLayoutForItemCount:7 columnCount:4] should] equal:@[ @4, @3 ]];
			[[[layout rowLayoutForItemCount:8 columnCount:4] should] equal:@[ @4, @4 ]];
			[[[layout rowLayoutForItemCount:9 columnCount:4] should] equal:@[ @4, @3, @2 ]];
			[[[layout rowLayoutForItemCount:10 columnCount:4] should] equal:@[ @4, @4, @2 ]];
			[[[layout rowLayoutForItemCount:11 columnCount:4] should] equal:@[ @4, @4, @3 ]];
			[[[layout rowLayoutForItemCount:12 columnCount:4] should] equal:@[ @4, @4, @4 ]];
		});
		
	});
	
});

SPEC_END