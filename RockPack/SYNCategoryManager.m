//
//  SYNCategoryManager.m
//  dolly
//
//  Created by Cong on 02/01/2014.
//  Copyright (c) 2014 Nick Banks. All rights reserved.
//

#import "SYNCategoryManager.h"

@implementation SYNCategoryManager

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceQueue;
    static SYNCategoryManager *categoryManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      categoryManager = [[self alloc] init];
                      
                  });
    
    return categoryManager;
}


-(void)setColorSetFromDictionary:(NSDictionary*)dictionary
{
    
    
}



-(UIColor*) colorId :(NSString*)uniqueId
{
    return [UIColor colorWithWhite:1.0f alpha:1.0f];
}


@end
