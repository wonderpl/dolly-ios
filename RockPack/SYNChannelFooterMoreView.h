//
//  SYNChannelFooterMoreView.h
//  rockpack
//
//  Created by Michael Michailidis on 04/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNChannelFooterMoreView : UICollectionReusableView

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic) BOOL showsLoading;

@end
