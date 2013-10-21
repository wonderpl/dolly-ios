//
//  SYNChannelCoverImageSelectorViewController.m
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "ChannelCover.h"
#import "CoverArt.h"
#import "GKImageCropViewController.h"
#import "GKImagePicker.h"
#import "SYNAppDelegate.h"
#import "SYNChannelCoverImageCell.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>

enum ChannelCoverSelectorState {
    kChannelCoverDefault = 0,
    kChannelCoverCameraOptions = 1,
    kChannelCoverLocalAlbum = 2
};


@interface SYNChannelCoverImageSelectorViewController () <UICollectionViewDataSource,
                                                          UICollectionViewDelegate,
                                                          GKImageCropControllerDelegate,
                                                          GKImagePickerDelegate,
                                                          NSFetchedResultsControllerDelegate>

@property (nonatomic) NSInteger dataItemsAvailable;
@property (nonatomic) NSRange dataRequestRange;
@property (nonatomic, assign) BOOL supportsCamera;
@property (nonatomic, assign) enum ChannelCoverSelectorState currentState;
@property (nonatomic, strong) ALAssetsLibrary* library;
@property (nonatomic, strong) GKImagePicker* picker;
@property (nonatomic, strong) NSArray* sortedKeys;
@property (nonatomic, strong) NSMutableDictionary* userAssetGroups;
@property (nonatomic, strong) NSString* selectedAlbumKey;
@property (nonatomic, strong) NSString* selectedImageURL;
@property (nonatomic, strong) SYNChannelFooterMoreView* footerView;
@property (strong,nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) SYNAppDelegate* appDelegate;

@end


@implementation SYNChannelCoverImageSelectorViewController

#pragma mark - Object lifecycle

- (id) initWithSelectedImageURL: (NSString *) selectedImageURL
{
    if ((self = [super init]))
    {
        self.selectedImageURL = selectedImageURL;
    }
    
    return self;
}


- (void) dealloc
{
    // Defensive programming
    self.fetchedResultsController.delegate = nil;
    self.picker.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"CoverArt"
                                      inManagedObjectContext: self.appDelegate.mainManagedObjectContext];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(userUpload == FALSE) OR (thumbnailURL == %@)", self.selectedImageURL];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"userUpload" ascending: NO],
                                     [[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                    managedObjectContext: self.appDelegate.mainManagedObjectContext
                                                                                      sectionNameKeyPath: @"userUpload"
                                                                                               cacheName: nil];
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![self.fetchedResultsController performFetch: &error])
    {
        AssertOrLog(@"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
//    DebugLog (@"Count %d", self.fetchedResultsController.fetchedObjects.count);
    
    // If we already have itmes in the database, start after the last one of those
    self.dataItemsAvailable = self.fetchedResultsController.fetchedObjects.count;
    
    // Initialise the span and size of the first data request
    self.dataRequestRange = NSMakeRange(self.dataItemsAvailable, STANDARD_REQUEST_LENGTH);
    
    [self updateCoverArt];
    
    self.supportsCamera = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    self.userAssetGroups = [NSMutableDictionary dictionary];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        self.library = library;
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock: ^(ALAssetsGroup *group, BOOL *stop) {
            if (!group)
            {
                // nil indicates end of iterator.
                self.sortedKeys = [[self.userAssetGroups allKeys] sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshLocalImageData];
                });
                
                return;
            }
            
            [group setAssetsFilter: [ALAssetsFilter allPhotos]];
            NSString* groupName = [group valueForProperty: ALAssetsGroupPropertyName];
            
            if ([group numberOfAssets] > 0)
            {
                [group enumerateAssetsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
                                        options: 0
                                     usingBlock: ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result)
                    {
                        (self.userAssetGroups)[groupName] = @{@"group":group, @"coverAsset":result};
                    }
                }];
            }
            else
            {
                (self.userAssetGroups)[groupName] = @{@"group":group};
            }
        } failureBlock: ^(NSError *error) {
        }];
        
    });
    
    UINib* cellNib = [UINib nibWithNibName: @"SYNChannelCoverImageCell"
                                    bundle: [NSBundle mainBundle]];
    
    [self.collectionView registerNib: cellNib
          forCellWithReuseIdentifier: @"SYNChannelCoverImageCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.collectionView registerNib: footerViewNib
          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                 withReuseIdentifier: @"SYNChannelFooterMoreView"];
}


#pragma mark Collection view delegate and data source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    switch (self.currentState)
    {
        case kChannelCoverDefault:
        {
            return [[self.fetchedResultsController fetchedObjects] count] + 2;
            break;
        }
            
        case kChannelCoverCameraOptions:
            return self.supportsCamera? [self.sortedKeys count] + 1 : [self.sortedKeys count] ;
            
        case kChannelCoverLocalAlbum:
        {
            ALAssetsGroup* group = (self.userAssetGroups)[self.selectedAlbumKey][@"group"];
            return [group numberOfAssets];
        }
            
        default:
            return 0;
            break;
    }
}


- (UICollectionViewCell*) collectionView: (UICollectionView *) collectionView
                  cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    __block SYNChannelCoverImageCell* cell =(SYNChannelCoverImageCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"SYNChannelCoverImageCell" forIndexPath:indexPath];
    NSString* title = @"";
    
    if (self.currentState == kChannelCoverDefault)
    {
        if (indexPath.row == 0)
        {
            cell.channelCoverImageView.image = [UIImage imageNamed: @"ButtonCamera@2x.png"];
            cell.glossImage.hidden = YES;
        }
        else if (indexPath.row == 1)
        {
            cell.channelCoverImageView.image = [UIImage imageNamed: @"ChannelCreationCoverNone.png"];
            cell.glossImage.hidden = YES;
        }
        else
        {
            indexPath = [NSIndexPath indexPathForRow: indexPath.row - 2 inSection:0];
            CoverArt *coverArt = self.fetchedResultsController.fetchedObjects[indexPath.row];

            [cell.channelCoverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                                options: SDWebImageRetryFailed];
            
            // And we are not on the 'no cover' placeholder
            if ([coverArt.thumbnailURL isEqualToString: self.selectedImageURL])
            {
                [cell selectWithoutAnimation];
            }

            cell.glossImage.hidden = NO;
        }
    }
    else if (self.currentState == kChannelCoverCameraOptions)
    {
        if (indexPath.row == 0 && self.supportsCamera)
        {
            cell.channelCoverImageView.image = [UIImage imageNamed :@"PanelTakePhoto"];
            cell.glossImage.hidden = YES;
        }
        else
        {
            if (self.supportsCamera)
            {
                indexPath = [NSIndexPath indexPathForRow: indexPath.row - 1 inSection:0];
            }
            title = self.sortedKeys[indexPath.row];
            ALAsset* imageAsset = (self.userAssetGroups)[title][@"coverAsset"];
            [cell setimageFromAsset:imageAsset];
            cell.glossImage.hidden = NO;
        }
    }
    else
    {
        ALAssetsGroup* group = (self.userAssetGroups)[self.selectedAlbumKey][@"group"];
        
        [group enumerateAssetsAtIndexes: [NSIndexSet indexSetWithIndex:indexPath.row]
                                options: 0
                             usingBlock: ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                 if (result)
                                 {
                                     [cell setimageFromAsset: result];
                                 }
                             }];
        
        cell.glossImage.hidden = NO;
    }
    
    [cell setTitleText: title];
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    switch (self.currentState)
    {
        case kChannelCoverCameraOptions:
            if (indexPath.row == 0 && self.supportsCamera)
            {
                [collectionView deselectItemAtIndexPath:indexPath animated:NO];
                GKImagePicker* picker = [[GKImagePicker alloc] init];
                picker.cropSize = CGSizeMake(280, 280);
                picker.delegate = self;
                picker.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.picker = picker;
                
                [self presentViewController: picker.imagePickerController
                                   animated: YES
                                 completion: nil];
            }
            else
            {
                int row = (self.supportsCamera ? indexPath.row-1 : indexPath.row);
                self.selectedAlbumKey = (self.sortedKeys)[row];
                
                CATransition *animation = [CATransition animation];
                [animation setType: kCATransitionPush];
                [animation setSubtype: kCATransitionFromRight];
                [animation setDuration: 0.30];
                [animation setTimingFunction:
                 [CAMediaTimingFunction functionWithName:
                  kCAMediaTimingFunctionEaseInEaseOut]];
                
                self.currentState = kChannelCoverLocalAlbum;
                [self.collectionView reloadData];
                self.titleLabel.text = NSLocalizedString([self.selectedAlbumKey uppercaseString], nil);
                
                [self.contentContainerView.layer addAnimation: animation
                                                       forKey: nil];
            }
            break;
            
        case kChannelCoverLocalAlbum:
        {
            ALAssetsGroup* group = (self.userAssetGroups)[self.selectedAlbumKey][@"group"];
            
            [group enumerateAssetsAtIndexes: [NSIndexSet indexSetWithIndex: indexPath.row]
                                    options: 0
                                 usingBlock: ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                     if (result)
                                     {
                                         ALAssetRepresentation* representation = [result defaultRepresentation];
                                         GKImageCropViewController* cropViewController = [[GKImageCropViewController alloc] init];
                                         CGFloat scale = representation.scale;
                                         ALAssetOrientation orientation = representation.orientation;
                                         UIImage* selectedImage = nil;
                                         CGFloat maxDimension = MAX(representation.dimensions.height,representation.dimensions.height);
                                         if(maxDimension > kMaxSuportedImageSize)
                                         {
                                             //Image too large
                                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"This image is too large", nil) message:[NSString stringWithFormat:NSLocalizedString(@"The maximum image resolution allowed for images is %dpx * %dpx.", nil), kMaxSuportedImageSize, kMaxSuportedImageSize] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                             [alert show];
                                             return;
                                         }
                                         else
                                         {
                                             selectedImage = [UIImage imageWithCGImage: [representation fullResolutionImage] scale:scale orientation:(UIImageOrientation)orientation];
                                         }
                                         cropViewController.sourceImage = selectedImage;
                                         cropViewController.cropSize = CGSizeMake(280,280);
                                         cropViewController.delegate = self;
                                         cropViewController.view.clipsToBounds = YES;
                                         
                                         [self presentViewController: cropViewController
                                                            animated: YES
                                                          completion: nil];
                                     }
                                 }];
            break;
        }
            
        case kChannelCoverDefault:
        {
            if(indexPath.row ==0)
            {
                [self cameraButtonTapped];
                return;
            }
            NSString* returnStringURL = nil;
            NSString* returnCoverId = kCoverSetNoCover;
            if (indexPath.row != 1)
            {
                indexPath = [NSIndexPath indexPathForRow:indexPath.row - 2 inSection:0];
                CoverArt *coverArt = self.fetchedResultsController.fetchedObjects[indexPath.row];
                    returnStringURL = coverArt.thumbnailURL;
                    returnCoverId = coverArt.coverRef;
                
                
            }
            if ([self.imageSelectorDelegate respondsToSelector: @selector(imageSelector:didSelectImage:withRemoteId:)])
            {
                [self.imageSelectorDelegate imageSelector: self
                                           didSelectImage: returnStringURL
                                             withRemoteId: returnCoverId];
            }
            break;
        }
            
        default:
            break;
    }
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize = CGSizeZero;

    if (section == 0 || section < self.fetchedResultsController.sections.count - 1)
    {
        return footerSize;
    }
    
    if  (self.fetchedResultsController.fetchedObjects.count  != 0 && // only the last section can have a loader
         (self.dataRequestRange.location + self.dataRequestRange.length < self.dataItemsAvailable))
    {
        
        footerSize = IS_IPHONE ? CGSizeMake(320.0f, 64.0f) : CGSizeMake(1024.0, 64.0);
    }
    
    return footerSize;
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    
    if (self.currentState !=kChannelCoverDefault)
    {
        return nil;
    }
    
    UICollectionReusableView *supplementaryView = nil;

    // TODO: We might want to optimise this instead of creating a new date formatter each time
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        if (indexPath.section < self.fetchedResultsController.sections.count - 1)
            return supplementaryView;
        
        if (self.fetchedResultsController.fetchedObjects.count == 0 ||
           (self.dataRequestRange.location + self.dataRequestRange.length) >= self.dataItemsAvailable)
        {
            return supplementaryView;
        }
        
        self.footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                       forIndexPath: indexPath];

        supplementaryView = self.footerView;
    }
    
    return supplementaryView;
}


#pragma mark - Load More Footer

- (void) incrementRangeForNextRequest
{
    // (UIButton*) sender can be nil when called directly //
    self.footerView.showsLoading = YES;
    
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    if (nextStart >= self.dataItemsAvailable)
        return;
    
    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= self.dataItemsAvailable ? (self.dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
    
//    DebugLog (@"Range %d:%d    ", self.dataRequestRange.location, self.dataRequestRange.length);
}


- (void) loadMoreCovers: (UIButton*) sender
{
    [self incrementRangeForNextRequest];
    
    [self updateCoverArt];
}


#pragma mark - Paging

- (void) refreshChannelCoverData
{
    if (self.currentState == kChannelCoverDefault)
    {
        [self.collectionView reloadData];
    }
}


- (void) refreshLocalImageData
{
    if (self.currentState == kChannelCoverCameraOptions)
    {
        [self.collectionView reloadData];
    }
}


#pragma mark - button actions

- (void) cameraButtonTapped
{
    CATransition *animation = [CATransition animation];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromRight];
    [animation setDuration: 0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    
    self.cameraButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.backButton.hidden = NO;
    self.currentState = kChannelCoverCameraOptions;
    [self.collectionView reloadData];
    self.titleLabel.text = NSLocalizedString(@"UPLOAD IMAGE", nil);
    
    [self.contentContainerView.layer addAnimation: animation
                                           forKey: nil];
}


- (IBAction) backButtonTapped: (id) sender
{
    CATransition *animation = [CATransition animation];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromLeft];
    [animation setDuration: 0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    
    switch (self.currentState)
    {
        case kChannelCoverCameraOptions:
            self.cameraButton.hidden = NO;
            self.closeButton.hidden = NO;
            self.backButton.hidden = YES;
            self.currentState = kChannelCoverDefault;
            self.titleLabel.text = NSLocalizedString(@"CHOOSE A COVER", nil);
            break;
            
        case kChannelCoverLocalAlbum:
            self.currentState = kChannelCoverCameraOptions;
            self.titleLabel.text = NSLocalizedString(@"UPLOAD IMAGE", nil);
            break;
            
        default:
            break;
    }
    
    [self.collectionView reloadData];
    
    [self.contentContainerView.layer addAnimation: animation
                                           forKey: nil];
}


- (IBAction) closeButtonTapped: (id) sender
{
    if ([self.imageSelectorDelegate respondsToSelector: @selector(closeImageSelector:)])
    {
        [self.imageSelectorDelegate closeImageSelector: self];
    }
}


#pragma mark - GK image picker and cropper delegate methods

- (void) imagePicker: (GKImagePicker *) imagePicker
         pickedImage: (UIImage *) image
{
    [self dismissViewControllerAnimated: YES
                             completion: ^{
                                 if ([self.imageSelectorDelegate respondsToSelector: @selector(imageSelector:didSelectUIImage:)])
                                 {
                                     [self.imageSelectorDelegate imageSelector: self
                                                              didSelectUIImage: image];
                                 }
                             }];
    
    self.picker = nil;
}


- (void) imagePickerDidCancel: (GKImagePicker *) imagePicker
{
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
    self.picker = nil;
}


- (void) imageCropController: (GKImageCropViewController *) imageCropController
   didFinishWithCroppedImage: (UIImage *) croppedImage
{
    [self dismissViewControllerAnimated: YES
                             completion: ^{
                                 if ([self.imageSelectorDelegate respondsToSelector: @selector(imageSelector:didSelectUIImage:)])
                                 {
                                     if (croppedImage)
                                     {
                                         [self.imageSelectorDelegate imageSelector: self
                                                                  didSelectUIImage: croppedImage];
                                     }
                                 }
                             }];
}


- (void) updateCoverArt
{
//    DebugLog(@"Updating range %d:%d", self.dataRequestRange.location, self.dataRequestRange.length);
    
    // Update the list of cover art
    [self.appDelegate.networkEngine updateCoverArtWithWithStart: self.dataRequestRange.location
                                                           size: self.dataRequestRange.length
                                              completionHandler: ^(NSDictionary *dictionary){
//                                                  DebugLog(@"Success");
                                                  self.footerView.showsLoading = NO;
                                                  NSNumber* totalNumber = dictionary[@"cover_art"][@"total"];
                                                  if (totalNumber && ![totalNumber isKindOfClass: [NSNull class]])
                                                      self.dataItemsAvailable = [totalNumber integerValue];
                                                  else
                                                      self.dataItemsAvailable = self.dataRequestRange.length;
                                                  
//                                                  DebugLog (@"Count %d", self.fetchedResultsController.fetchedObjects.count);
//                                                  if ((self.dataRequestRange.location + self.dataRequestRange.length) >= self.dataItemsAvailable)
                                                  {
//                                                      self.noMoreCovers = TRUE;
                                                      [self.collectionView reloadData];
                                                      return;
                                                  }
                                                  
//                                                  [self displayLoadMoreMessage];
                                              }
                                                   errorHandler: ^(NSError* error) {
                                                                                                             self.footerView.showsLoading = NO;
                                                       DebugLog(@"Update cover art failed: %@", [error debugDescription]);
//                                                       [self displayLoadMoreMessage];
                                                   }];
    
    [self.appDelegate.oAuthNetworkEngine updateCoverArtForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                                    onCompletion: ^{
//                                                        DebugLog(@"Success");
                                                    }
                                                         onError: ^(NSError* error) {
                                                             DebugLog(@"Update user cover art failed:%@", [error debugDescription]);
                                                         }];
}


#pragma mark - fetched result controller delegate

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    [self refreshChannelCoverData];
    
}

@end
