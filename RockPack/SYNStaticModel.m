//
//  SYNStaticModel.m
//  dolly
//
//  Created by Sherman Lo on 9/12/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNStaticModel.h"
#import "SYNPagingModel+Protected.h"

@implementation SYNStaticModel

- (instancetype)initWithLoadedItems:(NSArray *)loadedItems {
	if (self = [super init]) {
		self.loadedItems = loadedItems;
		self.loadedRange = NSMakeRange(0, [loadedItems count]);
		self.totalItemCount = [loadedItems count];
	}
	return self;
}

@end
