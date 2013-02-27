//
//  SYNSearchRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchRegistry.h"
#import "Video.h"
#import "VideoInstance.h"

@implementation SYNSearchRegistry

-(id)init
{
    if (self = [super init])
    {
        appDelegate = UIApplication.sharedApplication.delegate;
        importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
        importManagedObjectContext.parentContext = appDelegate.searchManagedObjectContext;
    }
    return self;
}


-(BOOL)registerVideosFromDictionary:(NSDictionary *)dictionary forViewId:(NSString*)viewId
{
    
    // == Check for Validity == //
    
    [self clearImportContextFromEntityName:@"Video"];
    
    NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    
    NSArray *itemArray = [videosDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    
    // === Main Processing === //
    
    for (NSDictionary *itemDictionary in itemArray) {
        
        if ([itemDictionary isKindOfClass: [NSDictionary class]]) {
            
            NSMutableDictionary* fullItemDictionary = [NSMutableDictionary dictionaryWithDictionary:itemDictionary];
            
            [VideoInstance instanceFromDictionary: fullItemDictionary
                        usingManagedObjectContext: importManagedObjectContext
                              ignoringObjectTypes: kIgnoreChannelObjects
                                        andViewId: viewId];
        }
            
    }
        
    
    
    
    
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    
    
    return YES;
}


@end
