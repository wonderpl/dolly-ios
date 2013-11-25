//
//  CIFilter+Monochrome.m
//  dolly
//
//  Created by Sherman Lo on 25/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "CIFilter+Monochrome.h"

@implementation CIFilter (Monochrome)

+ (CIFilter *)monochromeFilter {
	CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
	[filter setValue:@1.0 forKey:kCIInputIntensityKey];
	[filter setValue:[[CIColor alloc] initWithColor:[UIColor whiteColor]] forKey:kCIInputColorKey];
	
	return filter;
}

@end
