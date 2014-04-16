#import <Kiwi.h>
#import "NSString+Timecode.h"

#define HOURS(h) (h * 60 * 60)
#define MINS(m) (m * 60)

SPEC_BEGIN(NSStringTimecodeSpec)

describe(@"The NSString Timecode category", ^{
	
	context(@"when creating the timecode string", ^{
		
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
			[[[NSString timecodeStringFromSeconds:HOURS(1)] should] equal:@"1:00:00"];
			[[[NSString timecodeStringFromSeconds:HOURS(10)] should] equal:@"10:00:00"];
			[[[NSString timecodeStringFromSeconds:HOURS(1) + MINS(1) + 2] should] equal:@"1:01:02"];
		});
		
	});
	
	context(@"when creating the friendly time string", ^{
		
		it(@"should round time less than a minute up to a minute", ^{
			[[[NSString friendlyLengthFromTimeInterval:1] should] equal:@"1 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:29] should] equal:@"1 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:59] should] equal:@"1 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:60] should] equal:@"1 MIN WATCH"];
		});
		
		it(@"should round time to the nearest minute", ^{
			[[[NSString friendlyLengthFromTimeInterval:61] should] equal:@"1 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:90] should] equal:@"2 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:91] should] equal:@"2 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:119] should] equal:@"2 MIN WATCH"];
		});
		
		it(@"should round times greater than an hour to the nearest 15 minutes", ^{
			[[[NSString friendlyLengthFromTimeInterval:HOURS(1)] should] equal:@"1 HR WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:HOURS(1) + MINS(5)] should] equal:@"1 HR WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:HOURS(1) + MINS(10)] should] equal:@"1 HR 15 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:HOURS(1) + MINS(20)] should] equal:@"1 HR 15 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:HOURS(1) + MINS(50)] should] equal:@"1 HR 45 MIN WATCH"];
			[[[NSString friendlyLengthFromTimeInterval:HOURS(1) + MINS(55)] should] equal:@"2 HR WATCH"];
		});
		
	});
	
});

SPEC_END