//
//  SYNUsersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelFooterMoreView.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNUserThumbnailCell.h"
#import "SYNUsersViewController.h"


@implementation SYNUsersViewController

- (void) dealloc
{
    // Defensive programming
    self.usersThumbnailCollectionView.delegate = nil;
    self.usersThumbnailCollectionView.dataSource = nil;
}


- (void) loadView
{
    SYNIntegralCollectionViewFlowLayout *flowLayout;
    
    if (IS_IPHONE)
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(320.0f, 72.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 6.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(5.0, 2.0, 0.0, 2.0)];
    }
    else
    {
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(120.0f, 180.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 2.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(6.0, 6.0, 5.0, 8.0)];
    }
    
    flowLayout.footerReferenceSize = [self footerSize];
    
    
    self.usersThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: CGRectZero
                                                           collectionViewLayout: flowLayout];
    
    self.usersThumbnailCollectionView.dataSource = self;
    self.usersThumbnailCollectionView.delegate = self;
    self.usersThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.usersThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    
    self.usersThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.usersThumbnailCollectionView.scrollsToTop = NO;
    
    
    self.view = self.usersThumbnailCollectionView;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.usersThumbnailCollectionView.showsVerticalScrollIndicator = YES;
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNUserThumbnailCell"
                                             bundle: nil];
    
    [self.usersThumbnailCollectionView
     registerNib: thumbnailCellNib
     forCellWithReuseIdentifier: @"SYNUserThumbnailCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.usersThumbnailCollectionView
     registerNib: footerViewNib
     forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
     withReuseIdentifier: @"SYNChannelFooterMoreView"];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.users = [NSMutableArray array];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self setOffsetTop: 0.0f];
}


#pragma mark - UICollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.users.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    ChannelOwner *user = self.users[indexPath.row];
    
    SYNUserThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNUserThumbnailCell"
                                                                                        forIndexPath: indexPath];
    
    userThumbnailCell.nameLabel.text = user.displayName;
    
    userThumbnailCell.imageUrlString = user.thumbnailLargeUrl;
    
    
    [userThumbnailCell setDisplayName: user.displayName
                          andUsername: user.username];
    
    return userThumbnailCell;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    ChannelOwner *channelOwner = self.users[indexPath.row];
    
    [self viewProfileDetails:channelOwner];
}


#pragma mark - Getters/Setters

- (void) setOffsetTop: (CGFloat) offsetTop
{
    CGRect collectionViewFrame = CGRectMake(0.0f, offsetTop,
                                            self.view.superview.frame.size.width,
                                            [SYNDeviceManager.sharedInstance currentScreenHeight] - offsetTop);
    
    self.usersThumbnailCollectionView.frame = collectionViewFrame;
}


#pragma mark - Footer support

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        [self loadMoreUsers];
    }
}


- (void) loadMoreUsers
{
    AssertOrLog(@"Shouldn't be calling abstract view controller");
}


@end
