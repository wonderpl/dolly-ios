//
//  UIImage+Blur.h
//  dolly
//
//  Created by Sherman Lo on 16/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

+ (UIImage *)blurredImageFromImage:(UIImage *)inputImage;
+ (UIImage *)blurredImageFromImage:(UIImage *)inputImage blurValue:(NSNumber*) value;

@end
