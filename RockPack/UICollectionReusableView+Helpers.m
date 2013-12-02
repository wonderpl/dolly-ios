//
//  UICollectionReusableView+Helpers.m
//  dolly
//
//  Created by Sherman Lo on 2/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UICollectionReusableView+Helpers.h"

@implementation UICollectionReusableView (Helpers)

+ (UINib *)nib {
	return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

+ (NSString *)reuseIdentifier {
	return NSStringFromClass(self);
}

@end
