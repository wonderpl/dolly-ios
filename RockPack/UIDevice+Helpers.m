//
//  UIDevice+Helpers.m
//  dolly
//
//  Created by Sherman Lo on 24/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "UIDevice+Helpers.h"

@implementation UIDevice (Helpers)

- (BOOL)isPad {
	return ([self userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (BOOL)isPhone {
	return ([self userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

@end
