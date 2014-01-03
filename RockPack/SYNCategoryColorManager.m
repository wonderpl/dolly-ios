//
//  SYNCategoryColorManager.m
//  dolly
//
//  Created by Cong on 02/01/2014.
//  Copyright (c) 2014 Nick Banks. All rights reserved.
//

#import "SYNCategoryColorManager.h"
#import "UIColor+SYNColor.h"


@interface SYNCategoryColorManager ()


@property (nonatomic, strong) NSMutableDictionary *colorsDictionary;

@end


@implementation SYNCategoryColorManager

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceQueue;
    static SYNCategoryColorManager *categoryColorManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      categoryColorManager = [[self alloc] init];
                      
                  });
    
    return categoryColorManager;
}

-(id)init
{
	if (self = [super init]) {
		self.colorsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)registerCategoryColorsFromDictionary:(NSDictionary*)dictionary
{
    
    NSDictionary *categories = [dictionary objectForKey:@"categories"];
    NSArray *items = [categories objectForKey:@"items"];
        
    for (NSDictionary *tmpDict in items)
    {
        NSNumber *color = [self numberFromColor:[tmpDict objectForKey:@"colour"]];
        [self.colorsDictionary setObject:color forKey: [tmpDict objectForKey:@"id"]];
        
        for (NSDictionary *subcategories in [tmpDict objectForKey:@"sub_categories"]) {
            [self.colorsDictionary setObject:color forKey: [subcategories objectForKey:@"id"]];

        }
    }
}

-(NSNumber*) numberFromColor : (NSString *) colourHash
{
    if(![colourHash hasPrefix:@"#"])
        colourHash = [NSString stringWithFormat:@"0x%@", colourHash];
    else
        colourHash = [colourHash stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
    
    NSScanner* scanner = [NSScanner scannerWithString:colourHash];
    
    unsigned int intValue;
    [scanner scanHexInt:&intValue];
    
    return [NSNumber numberWithInt:intValue];
}


-(UIColor *) colorFromID : (NSString *) categoryId
{
    
    if ([categoryId isEqualToString:@""]) {
        return [UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f];
    }
    
    return [UIColor colorWithHex: [((NSNumber*)[self.colorsDictionary objectForKey:categoryId]) integerValue]];
}



@end
