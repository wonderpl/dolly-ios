//
//  UIImage+Blur.m
//  dolly
//
//  Created by Sherman Lo on 16/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "UIImage+Blur.h"

@implementation UIImage (Blur)

+ (UIImage *)blurredImageFromImage:(UIImage *)inputImage {
	CIContext *context = [CIContext contextWithOptions:nil];
	CIImage *image = [CIImage imageWithCGImage:[inputImage CGImage]];
	
	CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur"];
	[filter setValue:@15.0 forKey:kCIInputRadiusKey];
	[filter setValue:image forKey:kCIInputImageKey];
	
	CGImageRef cgImage = [context createCGImage:[filter outputImage] fromRect:[image extent]];
	UIImage *outputImage = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	
	return outputImage;
}

+ (UIImage *)blurredImageFromImage:(UIImage *)inputImage blurValue:(NSNumber*) value {
	CIContext *context = [CIContext contextWithOptions:nil];
	CIImage *image = [CIImage imageWithCGImage:[inputImage CGImage]];
	
	CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur"];
	[filter setValue:value forKey:kCIInputRadiusKey];
	[filter setValue:image forKey:kCIInputImageKey];
	
	CGImageRef cgImage = [context createCGImage:[filter outputImage] fromRect:[image extent]];
	UIImage *outputImage = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	
	return outputImage;
}

@end
