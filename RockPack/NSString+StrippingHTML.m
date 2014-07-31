//
//  NSString+StrippingHTML.m
//  dolly
//
//  Created by Cong on 30/07/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "NSString+StrippingHTML.h"

@implementation NSString (StrippingHTML)

-(NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
