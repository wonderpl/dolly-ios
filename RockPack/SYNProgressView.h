//
//  SYNProgressView.h
//  rockpack
//
//  Created by Nick Banks on 10/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;

@interface SYNProgressView : UIImageView

- (void) setProgress: (float) progress;
- (void) setTrackImage: (UIImage *) trackImage;
- (void) setProgressImage: (UIImage *) progressImage;

@end
