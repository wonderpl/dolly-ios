//
//  SYNIPhoneCreateChannelLayout.m
//  dolly
//
//  Created by Cong Le on 11/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNiPhoneCreateChannelLayout.h"
#import "SYNDeviceManager.h"

@implementation SYNIPhoneCreateChannelLayout


-(id)init {
    if (!(self = [super init])) return nil;
    
    self.sectionInset = UIEdgeInsetsMake(0, 0, 300, 0);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 0.0f;
    self.itemSize = CGSizeMake(320.0f, 71);
    self.headerReferenceSize = CGSizeZero;
    
    
    return self;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
