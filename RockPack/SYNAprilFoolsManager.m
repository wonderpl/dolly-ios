//
//  SYNAprilFoolsManager.m
//  dolly
//
//  Created by Sherman Lo on 28/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAprilFoolsManager.h"
#import "SYNAppDelegate.h"

@implementation SYNAprilFoolsManager

+ (NSCalendar *)calendar {
	static dispatch_once_t onceToken;
	static NSCalendar *calendar;
	dispatch_once(&onceToken, ^{
		calendar = [NSCalendar currentCalendar];
	});
	return calendar;
}

+ (BOOL)shouldTriggerAprilFools {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSString *emailAddress = appDelegate.currentUser.emailAddress;
	BOOL isWonderPLEmail = ([emailAddress rangeOfString:@"wonderpl.com"].location != NSNotFound);
	BOOL isRockpackEmail = ([emailAddress rangeOfString:@"rockpack.com"].location != NSNotFound);
	BOOL isPatricia = [emailAddress isEqualToString:@"pjaderocco@live.co.uk"];
	
	NSDate *now = [NSDate date];
	NSDateComponents *components = [[self calendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:now];
	BOOL isAprilFoolsDay = (components.day == 1 && components.month == 4);
	
	return ((isWonderPLEmail || isRockpackEmail || isPatricia) && isAprilFoolsDay);
}

@end
