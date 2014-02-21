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

- (instancetype)initWithItems:(NSArray *)items {
	return [super initWithItems:items totalItemCount:[items count]];
}

@end
