//
//  SYNAddToChannelFlowLayout.m
//  dolly
//
//  Created by Michael Michailidis on 11/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddToChannelFlowLayout.h"

@implementation SYNAddToChannelFlowLayout

-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 10.0f;
    self.itemSize = CGSizeMake(310.0f, kChannelCellDefaultHeight );
    self.headerReferenceSize = CGSizeZero;
    
    
    return self;
}

@end
