//
//  NSString+Validation.h
//  dolly
//
//  Created by Sherman Lo on 27/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

- (BOOL)isValidFullName;
- (BOOL)isValidUsername;
- (BOOL)isValidEmail;
- (BOOL)isValidPassword;

@end
