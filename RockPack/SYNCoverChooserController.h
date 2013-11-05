//
//  SYNCoverChooserController.h
//  rockpack
//
//  Created by Michael Michailidis on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import CoreData;
@import UIKit;

@interface SYNCoverChooserController : UIViewController <UICollectionViewDataSource,
                                                         UICollectionViewDelegate ,
                                                         NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) UICollectionView* collectionView;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) NSString* selectedImageURL;

- (id) initWithSelectedImageURL: (NSString *) selectedImageURL;
- (void) updateCoverArt;
- (void) createCoverPlaceholder: (UIImage *) image;

@end
