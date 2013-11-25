//
//  SYNOnBoardingViewController.m
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingViewController.h"
#import "SYNOnBoardingCell.h"
#import "SYNOnBoardingHeader.h"
#import "ChannelOwner.h"

@interface SYNOnBoardingViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray* data;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@end

@implementation SYNOnBoardingViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Welcome";
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYNOnBoardingCell" bundle:nil]
          forCellWithReuseIdentifier:@"SYNOnBoardingCells"];
    
    self.data = @[]; // so as not to throw error when accessed
    
}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.data.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOnBoardingCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNOnBoardingCells"
                                                                        forIndexPath: indexPath];
    
    ChannelOwner* co = (ChannelOwner*)self.data[indexPath.row];
    
    cell.titleLabel.text = co.displayName;
    
    
    cell.delegate = self;
    
    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    
}

#pragma mark - Social Delegate

- (void) followControlPressed: (SYNSocialButton *) socialButton
{
    
    
    
}


- (void) shareControlPressed: (SYNSocialButton *) socialButton
{;}
- (void) likeControlPressed: (SYNSocialButton *) socialButton
{;}
- (void) addControlPressed: (SYNSocialButton *) socialButton
{;}



@end
