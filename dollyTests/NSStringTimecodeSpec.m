#import <Kiwi.h>
#import "NSString+Timecode.h"

SPEC_BEGIN(NSStringTimecodeSpec)

describe(@"The NSString Timecode category", ^{
	
	it(@"should round the number of seconds down", ^{
		[[[NSString timecodeStringFromSeconds:60.9] should] equal:@"1:00"];
	});
	
	it(@"should show no minutes correctly", ^{
		[[[NSString timecodeStringFromSeconds:59] should] equal:@"0:59"];
		[[[NSString timecodeStringFromSeconds:0] should] equal:@"0:00"];
	});
	
	it(@"should show minutes correctly", ^{
		[[[NSString timecodeStringFromSeconds:60] should] equal:@"1:00"];
		[[[NSString timecodeStringFromSeconds:62] should] equal:@"1:02"];
		[[[NSString timecodeStringFromSeconds:662] should] equal:@"11:02"];
	});
	
	it(@"should show hours correctly", ^{
		[[[NSString timecodeStringFromSeconds:3600] should] equal:@"1:00:00"];
		[[[NSString timecodeStringFromSeconds:36000] should] equal:@"10:00:00"];
		[[[NSString timecodeStringFromSeconds:3662] should] equal:@"1:01:02"];
	});
	
});

SPEC_END