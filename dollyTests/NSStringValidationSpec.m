#import <Kiwi.h>
#import "NSString+Validation.h"

SPEC_BEGIN(NSStringValidationSpec)

describe(@"The NSString Validation category", ^{
	
	context(@"when validating usernames", ^{
		
		it(@"should return yes for valid ones", ^{
			[[theValue([@"username" isValidUsername]) should] beYes];
			[[theValue([@"JohnBlog" isValidUsername]) should] beYes];
			[[theValue([@"synchromation2" isValidUsername]) should] beYes];
			[[theValue([@"_" isValidUsername]) should] beYes];
			[[theValue([@"." isValidUsername]) should] beYes];
			[[theValue([@"4.bunch_0f.l33t3r5_4nd.numb3r5" isValidUsername]) should] beYes];
		});
		
		it(@"should return no for invalid ones", ^{
			[[theValue([@"" isValidUsername]) should] beNo];
			[[theValue([@"JohnBlog;" isValidUsername]) should] beNo];
			[[theValue([@"Two Words" isValidUsername]) should] beNo];
			[[theValue([@"Blah?" isValidUsername]) should] beNo];
		});
		
	});
	
	context(@"when validating emails", ^{
		
		it(@"should return yes for valid ones", ^{
			[[theValue([@"username@email.com" isValidEmail]) should] beYes];
			[[theValue([@"john.smith@hotmail.co.uk" isValidEmail]) should] beYes];
			[[theValue([@"email@gmail.com" isValidEmail]) should] beYes];
		});
		
		it(@"should return no for invalid ones", ^{
			[[theValue([@"" isValidEmail]) should] beNo];
			[[theValue([@"JohnBlog;" isValidEmail]) should] beNo];
			[[theValue([@"Two Words" isValidEmail]) should] beNo];
			[[theValue([@"Blah?" isValidEmail]) should] beNo];
		});
		
	});
	
	context(@"when validating passwords", ^{
		
		it(@"should return yes for valid ones", ^{
			[[theValue([@"username" isValidPassword]) should] beYes];
			[[theValue([@"JohnBlog" isValidPassword]) should] beYes];
			[[theValue([@"synchromation2" isValidPassword]) should] beYes];
			[[theValue([@"_" isValidPassword]) should] beYes];
			[[theValue([@"." isValidPassword]) should] beYes];
			[[theValue([@"4.bunch_0f.l33t3r5_4nd.numb3r5" isValidPassword]) should] beYes];
		});
		
		it(@"should return no for invalid ones", ^{
			[[theValue([@"" isValidPassword]) should] beNo];
			[[theValue([@"JohnBlog;" isValidPassword]) should] beNo];
			[[theValue([@"Two Words" isValidPassword]) should] beNo];
			[[theValue([@"Blah?" isValidPassword]) should] beNo];
		});
		
	});
});

SPEC_END