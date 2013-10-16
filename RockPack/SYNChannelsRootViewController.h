//
//  SYNChannelsTopTabViewController.h
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNChannelFooterMoreView.h"

@interface SYNChannelsRootViewController : SYNAbstractViewController
{
    @protected
    NSMutableArray* channels;
}

@property (nonatomic, strong) UICollectionView *channelThumbnailCollectionView;
@property (nonatomic, assign) BOOL enableCategoryTable;

@end
