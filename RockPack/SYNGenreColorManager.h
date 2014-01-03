//
//  SYNGenreColorManager.h
//  dolly
//
//  Created by Cong on 02/01/2014.
//  Copyright (c) 2014 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNGenreColorManager : NSObject


+ (instancetype) sharedInstance;

-(void)registerGenreColorsFromCoreData;
-(UIColor *) colorFromID : (NSString *) genreId;

@end
