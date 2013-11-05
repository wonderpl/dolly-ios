//
//  UIImage+Resize.h
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface UIImage (Resize)

// TODO: Remove this category once we have replaced avatar capture
+ (UIImage*) scaleAndRotateImage: (UIImage*) image
                     withMaxSize: (int) newSize;

@end
