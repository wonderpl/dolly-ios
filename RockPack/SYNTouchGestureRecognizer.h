//
//  SYNTouchGestureRecognizer.h
//  rockpack
//
//  Created by Nick Banks on 20/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import <UIKit/UIKit.h>

@interface SYNTouchGestureRecognizer : UIGestureRecognizer

- (void) reset;

- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event;

- (void) touchesMoved: (NSSet *) touches
            withEvent: (UIEvent *) event;

- (void) touchesEnded: (NSSet *) touches
            withEvent: (UIEvent *) event;

- (void) touchesCancelled: (NSSet *) touches
                withEvent: (UIEvent *) event;

@end
