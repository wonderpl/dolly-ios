//
//  NSObject+Blocks.h
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//


@import Foundation;

@interface NSObject (Blocks)

- (void) performBlock: (void (^)(void)) block
           afterDelay: (NSTimeInterval) delay;

- (void) performBlock: (void (^)(void)) block
           afterDelay: (NSTimeInterval) delay
cancelPreviousRequest: (BOOL) cancel;

@end
