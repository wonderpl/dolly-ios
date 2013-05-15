//
//  SYNChannelCoverImageSelectorViewController.m
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNChannelCoverImageCell.h"
#import "CoverArt.h"
#import "UIImageView+ImageProcessing.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "UIFont+SYNFont.h"
#import "ChannelCover.h"
#import "GKImageCropViewController.h"
#import "GKImagePicker.h"
#import "SYNChannelCoverImageCell.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

enum ChannelCoverSelectorState {
    kChannelCoverDefault = 0,
    kChannelCoverCameraOptions = 1,
    kChannelCoverLocalAlbum = 2
};

@interface SYNChannelCoverImageSelectorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, GKImageCropControllerDelegate, GKImagePickerDelegate>
{
    enum ChannelCoverSelectorState currentState;
    BOOL supportsCamera;
}
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (nonatomic, strong) NSMutableDictionary* userAssetGroups;
@property (nonatomic, strong) NSArray* sortedKeys;
@property (nonatomic, strong) NSString* selectedAlbumKey;
@property (nonatomic, strong) ALAssetsLibrary* library;
@property (nonatomic, strong) GKImagePicker* picker;
@end

@implementation SYNChannelCoverImageSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    supportsCamera = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize:self.titleLabel.font.pointSize];
    
    self.userAssetGroups = [NSMutableDictionary dictionary];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        self.library = library;
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(!group)
            {
                // nil indicates end of iterator.
                self.sortedKeys = [[self.userAssetGroups allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshLocalImageData];
                });
                return;
            }
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            NSString* groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            if( [group numberOfAssets] > 0)
            {
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(result)
                    {
                        [self.userAssetGroups setObject:@{@"group":group, @"coverAsset":result} forKey:groupName];
                    }
                }];
            }
            else
            {
                [self.userAssetGroups setObject:@{@"group":group} forKey:groupName];
            }
        } failureBlock:^(NSError *error) {
        }];
        
    });
    UINib* cellNib = [UINib nibWithNibName:@"SYNChannelCoverImageCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SYNChannelCoverImageCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection view delegate and data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (currentState) {
        case kChannelCoverDefault:
        {
            ;
            id <NSFetchedResultsSectionInfo> userSectionInfo = self.userChannelCoverFetchedResultsController.sections [0];
            id <NSFetchedResultsSectionInfo> channelSectionInfo = self.channelCoverFetchedResultsController.sections [0];
            return [userSectionInfo numberOfObjects] + [channelSectionInfo numberOfObjects] + 1;
            break;
        }
        case kChannelCoverCameraOptions:
            return supportsCamera? [self.sortedKeys count] + 1 : [self.sortedKeys count] ;
        case kChannelCoverLocalAlbum:
        {
            ;
            ALAssetsGroup* group = [[self.userAssetGroups objectForKey:self.selectedAlbumKey] objectForKey:@"group"];
            return [group numberOfAssets];
        }
        default:
            return 0;
            break;
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block SYNChannelCoverImageCell* cell =(SYNChannelCoverImageCell*) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"SYNChannelCoverImageCell" forIndexPath:indexPath];
    NSString* title = @"";
    if(currentState == kChannelCoverDefault)
    {
        id <NSFetchedResultsSectionInfo> channelSectionInfo = self.channelCoverFetchedResultsController.sections [0];
        if(indexPath.row == 0)
        {
            cell.channelCoverImageView.image = [UIImage imageNamed:@"ChannelCreationCoverNone.png"];
            cell.glossImage.hidden = YES;
        }
        else if (indexPath.row - 1 < [channelSectionInfo numberOfObjects])
        {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
            CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                          inSection: 0]];


            [cell.channelCoverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCover.png"]
                                                options: SDWebImageRetryFailed];

            cell.glossImage.hidden = NO;
        }
        else
        {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 - [channelSectionInfo numberOfObjects] inSection:0];
            CoverArt *coverArt = [self.userChannelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                              inSection: 0]];
            

            [cell.channelCoverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCover.png"]
                                                options: SDWebImageRetryFailed];
            

            cell.glossImage.hidden = NO;
        }
    }
    else if (currentState == kChannelCoverCameraOptions)
    {
        if(indexPath.row == 0 && supportsCamera)
        {
            cell.channelCoverImageView.image = [UIImage imageNamed:@"PanelTakePhoto"];
            cell.glossImage.hidden = YES;
        }
        else
        {
            if(supportsCamera)
            {
                indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
            }
            title = [self.sortedKeys objectAtIndex:indexPath.row];
            ALAsset* imageAsset = [[self.userAssetGroups objectForKey:title] objectForKey:@"coverAsset"];
            [cell setimageFromAsset:imageAsset];
            cell.glossImage.hidden = NO;
        }
        
    }
    else
    {
        ALAssetsGroup* group = [[self.userAssetGroups objectForKey:self.selectedAlbumKey] objectForKey:@"group"];
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]  options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                [cell setimageFromAsset:result];
            }
        }];
        cell.glossImage.hidden = NO;
    }
    [cell setTitleText:title];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (currentState) {
        case kChannelCoverCameraOptions:
            if(indexPath.row == 0 && supportsCamera)
            {
                GKImagePicker* picker = [[GKImagePicker alloc] init];
                picker = [[GKImagePicker alloc] init];
                picker.cropSize = CGSizeMake(280, 280);
                picker.delegate = self;
                picker.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.picker = picker;
                [self presentViewController:picker.imagePickerController animated:YES completion:nil];
            }
            else
            {
                int row = (supportsCamera ? indexPath.row-1 : indexPath.row);
                self.selectedAlbumKey = [self.sortedKeys objectAtIndex:row];
                CATransition *animation = [CATransition animation];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromRight];
                [animation setDuration:0.30];
                [animation setTimingFunction:
                 [CAMediaTimingFunction functionWithName:
                  kCAMediaTimingFunctionEaseInEaseOut]];
                
                currentState = kChannelCoverLocalAlbum;
                [self.collectionView reloadData];
                self.titleLabel.text = NSLocalizedString([self.selectedAlbumKey uppercaseString], nil);
                [self.contentContainerView.layer addAnimation:animation forKey:nil];
            }
            break;
        case kChannelCoverLocalAlbum:
        {
            ;
            ALAssetsGroup* group = [[self.userAssetGroups objectForKey:self.selectedAlbumKey] objectForKey:@"group"];
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]  options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    ALAssetRepresentation* representation = [result defaultRepresentation];
                    GKImageCropViewController* cropViewController = [[GKImageCropViewController alloc]init];
                    UIImage* selectedImage = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                    cropViewController.sourceImage = selectedImage;
                    cropViewController.cropSize = CGSizeMake(280,280);
                    cropViewController.delegate = self;
                    cropViewController.view.clipsToBounds = YES;
                    [self presentViewController:cropViewController animated:YES completion:nil];
                }
            }];
            break;
        }
        case kChannelCoverDefault:
        {
            ;
            NSString* returnStringURL = nil;
            NSString* returnCoverId = @"";
            if(indexPath.row != 0)
            {
                id <NSFetchedResultsSectionInfo> channelSectionInfo = self.channelCoverFetchedResultsController.sections [0];
                if (indexPath.row - 1 < [channelSectionInfo numberOfObjects])
                {
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
                    CoverArt *coverArt = [self.channelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                                  inSection: 0]];
                    returnStringURL = coverArt.thumbnailURL;
                    returnCoverId = coverArt.coverRef;
                }
                else
                {
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 - [channelSectionInfo numberOfObjects] inSection:0];
                    CoverArt *coverArt = [self.userChannelCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                                      inSection: 0]];
                    returnStringURL = coverArt.thumbnailURL;
                    returnCoverId = coverArt.coverRef;
                }
                
            }
            if([self.imageSelectorDelegate respondsToSelector:@selector(imageSelector:didSelectImage:withRemoteId:)])
            {
                [self.imageSelectorDelegate imageSelector:self didSelectImage:returnStringURL withRemoteId:returnCoverId];
            }
            break;
        }
        default:
            break;
    }
}

-(void)refreshChannelCoverData
{
    if(currentState == kChannelCoverDefault)
    {
        [self.collectionView reloadData];
    }
}

-(void)refreshLocalImageData
{
    if(currentState == kChannelCoverCameraOptions)
    {
        [self.collectionView reloadData];
    }
}

#pragma mark - button actions
- (IBAction)cameraButtonTapped:(id)sender
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    
    self.cameraButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.backButton.hidden = NO;
    currentState = kChannelCoverCameraOptions;
    [self.collectionView reloadData];
    self.titleLabel.text = NSLocalizedString(@"UPLOAD IMAGE", nil);
    
    [self.contentContainerView.layer addAnimation:animation forKey:nil];
}
- (IBAction)backButtonTapped:(id)sender
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:
      kCAMediaTimingFunctionEaseInEaseOut]];
    switch (currentState) {
        case kChannelCoverCameraOptions:
            self.cameraButton.hidden = NO;
            self.closeButton.hidden = NO;
            self.backButton.hidden = YES;
            currentState = kChannelCoverDefault;
            self.titleLabel.text = NSLocalizedString(@"ADD A COVER", nil);
            break;
        case kChannelCoverLocalAlbum:
            currentState = kChannelCoverCameraOptions;
            self.titleLabel.text = NSLocalizedString(@"UPLOAD IMAGE", nil);
            break;
        default:
            break;
    }
    [self.collectionView reloadData];
    
    [self.contentContainerView.layer addAnimation:animation forKey:nil];
    
}

- (IBAction)closeButtonTapped:(id)sender
{
    if([self.imageSelectorDelegate respondsToSelector:@selector(closeImageSelector:)])
    {
        [self.imageSelectorDelegate closeImageSelector:self];
    }
}

#pragma mark - GK image picker and cropper delegate methods
-(void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.imageSelectorDelegate respondsToSelector:@selector(imageSelector:didSelectUIImage:)])
        {
            [self.imageSelectorDelegate imageSelector:self didSelectUIImage:image];
        }
    }];
    self.picker = nil;
}

-(void)imagePickerDidCancel:(GKImagePicker *)imagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.picker = nil;
}

-(void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage
{
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.imageSelectorDelegate respondsToSelector:@selector(imageSelector:didSelectUIImage:)])
        {
            if(croppedImage)
            [self.imageSelectorDelegate imageSelector:self didSelectUIImage:croppedImage];
        }
    }];
}

@end
