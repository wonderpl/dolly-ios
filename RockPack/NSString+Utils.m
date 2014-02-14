//
//  NSString+Utils.m
//  rockpack
//
//  Created by Nick Banks on 15/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *) stringByReplacingOccurrencesOfStrings: (NSDictionary *) dictionary
{
    NSString *newString = [self copy];
    
    for (NSString *key in dictionary.allKeys)
    {
        newString = [newString stringByReplacingOccurrencesOfString: key
                                                         withString: dictionary[key]];
    }
    
    return newString;
}


+ (NSString *) ageCategoryStringFromInt: (int) age
{
    NSString *ageString = @"55+";
    
    if (age < 13)
    {
        ageString = @"-13";
    }
    else if (age >= 13 && age <= 17)
    {
        ageString = @"13-17";
    }
    else if (age >= 18 && age <= 24)
    {
        ageString = @"18-24";
    }
    else if (age >= 25 && age <= 34)
    {
        ageString = @"25-34";
    }
    else if (age >= 35 && age <= 44)
    {
        ageString = @"35-44";
    }
    else if (age >= 45 && age <= 54)
    {
        ageString = @"45-54";
    }
    
    return ageString;
}

- (NSString *)apostrophisedString {
	if (![self length]) {
		return self;
	}
	if ([[self lowercaseString] hasSuffix:@"s"]) {
		return [NSString stringWithFormat:@"%@ʼ", self];
	} else {
		return [NSString stringWithFormat:@"%@ʼs", self];
	}
}

@end
