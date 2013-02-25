//
//  SYNVideoQueueView.h
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNVideoQueueDelegate.h"
#import "SYNAbstractViewController.h"

@interface SYNVideoQueueView : UIView {
    
    UIImageView* backgroundImageView;
    
    UIButton* deleteButton;
    UIButton* newButton;
    UIButton* existingButton;
    
    UIImageView* messageView;
    
    UIView* dropZoneView;
    
    UICollectionView* videoQueueCollectionView;
}

@property (nonatomic, weak) id <SYNVideoQueueDelegate, UICollectionViewDataSource, UICollectionViewDelegate> delegate;
@property (nonatomic, strong) UICollectionView* videoQueueCollectionView;

@end
