//
//  SYNChannelCoverImageSelectorViewController.h
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import CoreData;
@import UIKit;

@class SYNChannelCoverImageSelectorViewController;
@class AVURLAsset;

@protocol SYNChannelCoverImageSelectorDelegate <NSObject>

@optional

- (void) imageSelector: (SYNChannelCoverImageSelectorViewController*) imageSelector
        didSelectImage: (NSString*)imageUrlString
          withRemoteId: (NSString*) remoteId;

- (void) imageSelector: (SYNChannelCoverImageSelectorViewController *) imageSelector
      didSelectUIImage: (UIImage*) image;

- (void) closeImageSelector: (SYNChannelCoverImageSelectorViewController*) imageSelector;

@end


@interface SYNChannelCoverImageSelectorViewController : UIViewController

@property (nonatomic, weak) id<SYNChannelCoverImageSelectorDelegate> imageSelectorDelegate;

- (id) initWithSelectedImageURL: (NSString *) selectedImageURL;

@end
