//
//  NSString+Utils.h
//  rockpack
//
//  Created by Nick Banks on 15/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@interface NSString (Utils)

- (NSString *) stringByReplacingOccurrencesOfStrings: (NSDictionary *) dictionary;

+ (NSString *) ageCategoryStringFromInt: (int) age;

- (NSString *)apostrophisedString;

@end
