//
//  SYNDeviceManager.h
//  rockpack
//
//  Created by Michael Michailidis on 09/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@interface SYNDeviceManager : NSObject

@property (nonatomic, readonly) UIUserInterfaceIdiom idiom;

+ (SYNDeviceManager *) sharedInstance;


- (BOOL) isIPad;
- (BOOL) isIPhone;

- (BOOL) isLandscape;
- (BOOL) isPortrait;

- (BOOL) isRetina;

- (UIDeviceOrientation) orientation;

- (CGFloat) currentScreenWidth;
- (CGFloat) currentScreenHeight;
- (CGRect) currentScreenRect;
- (CGSize) currentScreenSize;

- (CGPoint) currentScreenMiddlePoint;

- (UIInterfaceOrientation) currentOrientation;

@end
