//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"

@implementation SYNRegistry


-(id)init
{
    if (self = [super init])
    {
        appDelegate = UIApplication.sharedApplication.delegate;
        importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
        importManagedObjectContext.parentContext = appDelegate.mainManagedObjectContext;
    }
    return self;
}

+(id)registry
{
    return [[self alloc] init];
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    if (self = [self init])
    {
        
        if(moc)
        {
            importManagedObjectContext.parentContext = moc;
        }
        
        
    }
    
    return self;
}



#pragma mark - Import Context Management

-(BOOL)saveImportContext
{
    NSError* error;
    
    if([importManagedObjectContext save:&error])
        return YES;
    
    // else...
    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    if ([detailedErrors count] > 0)
        for(NSError* detailedError in detailedErrors)
            DebugLog(@"Import MOC Save Error (Detailed): %@", [detailedError userInfo]);
    
    
    return NO;
}

-(BOOL)clearImportContextFromEntityName:(NSString*)entityName
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:importManagedObjectContext]];
    
    NSError* error = nil;
    NSArray * result = [importManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error != nil)
        return NO;
    
    for (id basket in result)
        [importManagedObjectContext deleteObject:basket];
    
    return YES;
    
    
}

@end
