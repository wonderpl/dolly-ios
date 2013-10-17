//
//  SYNSubscribersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNSubscribersViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNSubscribersViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *infoLabel;

@end


@implementation SYNSubscribersViewController


- (id) initWithChannel: (Channel *) channel
{
    if (self = [super initWithViewId: kSubscribersListViewId])
    {
        
        self.channel = channel;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        
        
        
        
        titleLabel.textColor = [UIColor colorWithRed: (28.0 / 255.0)
                                               green: (31.0 / 255.0)
                                                blue: (33.0 / 255.0)
                                               alpha: (1.0)];
        
        titleLabel.text = NSLocalizedString(@"SUBSCRIBERS", nil);
        titleLabel.font = [UIFont lightCustomFontOfSize: 19.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        titleLabel.textColor = [UIColor blackColor];
        [titleLabel sizeToFit];
        
        
        CGRect tFrame = titleLabel.frame;
        tFrame.origin.x -= tFrame.size.width * 0.5f;
        tFrame.origin.y -= tFrame.size.height * 0.5f;
        titleLabel.frame = tFrame;
        
        UIView *labelContentView = [[UIView alloc]init];
        [labelContentView addSubview: titleLabel];
        
        self.navigationItem.titleView = labelContentView;
        
        self.infoLabel = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 0.0f, self.preferredContentSize.width, 0.0f)];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        
        self.infoLabel.textColor = [UIColor colorWithRed: (28.0 / 255.0)
                                                   green: (31.0 / 255.0)
                                                    blue: (33.0 / 255.0)
                                                   alpha: (1.0)];
        
        self.infoLabel.font = [UIFont regularCustomFontOfSize: 15.0];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.shadowColor = [UIColor whiteColor];
        self.infoLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.infoLabel.numberOfLines = 0;
    }
    
    return self;
}


- (void) setInfoLabelText: (NSString *) text
{
    CGFloat width = self.infoLabel.frame.size.width;
    
    if (!text) // clear
    {
        [self.infoLabel removeFromSuperview];
        return;
    }
    
    self.infoLabel.text = text;
    [self.infoLabel sizeToFit];
    CGRect newFrame = self.infoLabel.frame;
    newFrame.size.width = width;
    self.infoLabel.frame = newFrame;
    CGPoint position = CGPointMake(self.view.center.x, 200.0);
    self.infoLabel.center = position;
    self.infoLabel.frame = CGRectIntegral(self.infoLabel.frame);
    
    [self.view
     addSubview: self.infoLabel];
    
    position.y += 40.0;
    self.activityView.center = position;
}


- (void) viewDidAppear: (BOOL) animated
{
    if (IS_IPHONE)
    {
        self.usersThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.usersThumbnailCollectionView.backgroundColor = [UIColor whiteColor];
    }
    
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    
    self.activityView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    
    [self.activityView hidesWhenStopped];
    
    [self.activityView startAnimating];
    
    [self setInfoLabelText: @"LOADING"];
    
    [self.view addSubview: self.activityView];
    
    [appDelegate.networkEngine subscribersForUserId: appDelegate.currentUser.uniqueId
                                          channelId: self.channel.uniqueId
                                           forRange: self.dataRequestRange
                                        byAppending: NO
                                  completionHandler: ^(int count) {
                                      self.dataItemsAvailable = count;
                                      
                                      [self displayUsers];
                                      
                                      [self.activityView stopAnimating];
                                  }
                                       errorHandler: ^{
                                           [self.activityView stopAnimating];
                                       }];
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView* supplementaryView;
    
    if (collectionView == self.usersThumbnailCollectionView)
    {
        if (kind == UICollectionElementKindSectionFooter)
        {
            self.footerView = [self.usersThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                    withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                           forIndexPath: indexPath];
            supplementaryView = self.footerView;
            
            if (self.users.count > 0)
            {
                self.footerView.showsLoading = self.isLoadingMoreContent;
            }
        }
    }
    
    return supplementaryView;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
           referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize;
    
    if (collectionView == self.usersThumbnailCollectionView && self.users.count != 0)
    {
        footerSize = [self footerSize];
        
        // Now set to zero anyway if we have already read in all the items
        NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
        
        // FIXME: Is this comparison correct?  Should it just be self.dataRequestRange.location >= self.dataItemsAvailable?
        if (nextStart >= self.dataItemsAvailable)
        {
            footerSize = CGSizeZero;
        }
    }
    else
    {
        footerSize = CGSizeZero;
    }
    
    return footerSize;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (IS_IPHONE)
    {
        [appDelegate.viewStackManager hideModalController];
    }
    
    [super collectionView: collectionView
           didSelectItemAtIndexPath: indexPath];
}


- (void) displayUsers
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName: @"ChannelOwner"
                                 inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    request.predicate = [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"position"
                                                              ascending: YES]];
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext
                             executeFetchRequest: request
                             error: &error];
    
    if (!resultsArray)
    {
        return;
    }
    
    self.users = [NSMutableArray arrayWithArray: resultsArray];
    
    if (self.users.count == 0)
    {
        [self setInfoLabelText: @"No one has subscribed\nto this pack yet"];
    }
    else
    {
        [self setInfoLabelText: nil];
    }
    
    [self.usersThumbnailCollectionView reloadData];
}


- (CGSize) footerSize
{
    return CGSizeMake(100.0, 40.0);
}

- (void) loadMoreUsers
{
    // Check to see if we have loaded all items already
    if (self.moreItemsToLoad == TRUE)
    {
        self.loadingMoreContent = YES;
        
        [self incrementRangeForNextRequest];
        
        [appDelegate.networkEngine subscribersForUserId: appDelegate.currentUser.uniqueId
                                              channelId: self.channel.uniqueId
                                               forRange: self.dataRequestRange
                                            byAppending: YES
                                      completionHandler: ^(int count) {
                                          self.dataItemsAvailable = count;
                                          self.loadingMoreContent = NO;
                                          [self displayUsers];
                                      }
                                           errorHandler: ^{
                                           }];
    }
}

@end
