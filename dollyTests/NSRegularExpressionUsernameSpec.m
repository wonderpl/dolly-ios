#import <Kiwi.h>
#import "NSRegularExpression+Username.h"

SPEC_BEGIN(NSRegularExpressionUsernameSpec)

describe(@"The NSRegularExpression Username category", ^{
	
	NSRegularExpression *regex = [NSRegularExpression usernameRegex];
	
	it(@"should not match email addresses", ^{
		NSString *testString = @"I am here@exaple.com";
		NSArray *matches = [regex matchesInString:testString options:0 range:NSMakeRange(0, [testString length])];
		[[theValue([matches count]) should] equal:@0];
	});
	
	it(@"should match usernames are beginning of the string", ^{
		NSString *testString = @"@username is here";
		NSArray *matches = [regex matchesInString:testString options:0 range:NSMakeRange(0, [testString length])];
		[[theValue([matches count]) should] equal:@1];
		NSTextCheckingResult *match = matches[0];
		[[testString substringWithRange:match.range] isEqualToString:@"@username"];
		
		[[theValue(match.numberOfRanges) should] equal:@2];
		
		[[testString substringWithRange:[match rangeAtIndex:1]] isEqualToString:@"username"];
	});
	
	it(@"should match usernames are in the middle of the string", ^{
		NSString *testString = @"Now @username is here";
		NSArray *matches = [regex matchesInString:testString options:0 range:NSMakeRange(0, [testString length])];
		[[theValue([matches count]) should] equal:@1];
		NSTextCheckingResult *match = matches[0];
		[[testString substringWithRange:match.range] isEqualToString:@"@username"];
		
		[[theValue(match.numberOfRanges) should] equal:@2];
		
		[[testString substringWithRange:[match rangeAtIndex:1]] isEqualToString:@"username"];
	});
	
	it(@"should match multiple usernames in the string", ^{
		NSString *testString = @"@username1 is here while there is also a @username2 here";
		NSArray *matches = [regex matchesInString:testString options:0 range:NSMakeRange(0, [testString length])];
		[[theValue([matches count]) should] equal:@2];
		
		NSTextCheckingResult *firstMatch = matches[0];
		[[testString substringWithRange:firstMatch.range] isEqualToString:@"@username1"];
		
		[[theValue(firstMatch.numberOfRanges) should] equal:@2];
		
		[[testString substringWithRange:[firstMatch rangeAtIndex:1]] isEqualToString:@"username1"];
		
		NSTextCheckingResult *secondMatch = matches[1];
		[[testString substringWithRange:secondMatch.range] isEqualToString:@"@username2"];
		
		[[theValue(secondMatch.numberOfRanges) should] equal:@2];
		
		[[testString substringWithRange:[secondMatch rangeAtIndex:1]] isEqualToString:@"username2"];
	});
});

SPEC_END