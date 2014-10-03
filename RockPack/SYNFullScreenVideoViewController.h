//
//  SYNFullScreenVideoViewController.h
//  dolly
//
//  Created by Sherman Lo on 20/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

/* This class may not be required. This is used to display the video player in fullscreen. 
	A more simpler solution would be to streach the video player to full screen and be gone with
	this view controller.
 
 	I've got no idea for the reason fot having a seperate VC for fullscreen. 
 */

#import <UIKit/UIKit.h>

@class SYNVideoPlayerViewController;

@interface SYNFullScreenVideoViewController : UIViewController

@property (nonatomic, strong, readonly) UIView *backgroundView;

@property (nonatomic, strong, readonly) UIView *videoContainerView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) SYNVideoPlayerViewController *videoPlayerViewController;

@property (nonatomic, assign, readonly) UIDeviceOrientation videoOrientation;

@end
