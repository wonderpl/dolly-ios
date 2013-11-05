//
//  NSDictionary+Validation.h
//  rockpack
//
//  Created by Nick Banks on 09/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@interface NSDictionary (Validation)

- (id) objectForKey: (id) key
        withDefault: (id) defaultValue;

- (NSDate *) dateFromISO6801StringForKey: (id) key
                             withDefault: (NSDate *) defaultDate;

- (NSString *) upperCaseStringForKey: (id) key
                         withDefault: (id) defaultValue;

@end
