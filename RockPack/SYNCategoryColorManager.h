//
//  SYNCategoryColorManager.h
//  dolly
//
//  Created by Cong on 02/01/2014.
//  Copyright (c) 2014 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNCategoryColorManager : NSObject


+ (instancetype) sharedInstance;

-(void)registerCategoryColorsFromDictionary:(NSDictionary*)dictionary;
-(UIColor *) colorFromID : (NSString *) categoryId;


@end
