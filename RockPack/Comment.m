#import "Comment.h"
#import "NSDictionary+Validation.h"


@interface Comment ()


@end


@implementation Comment


+ (Comment *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;
{
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;
    
    
    NSString *uniqueId = dictionary[@"id"];
    
    if ([uniqueId isKindOfClass: [NSNull class]])
        return nil;
    
    
    Comment *instance = [Comment insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    
    [instance setAttributesFromDictionary: dictionary
                      ignoringObjectTypes: ignoringObjects];
    
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    self.thumbnailUrl = [dictionary objectForKey: @"avatar_thumbnail_url"
                                     withDefault: @""];
    
    self.displayName = [dictionary objectForKey: @"display_name"
                                    withDefault: @""];
    
    self.commentText = [dictionary objectForKey: @"comment_text"
                                    withDefault: @""];
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"token_expires"
                                                 withDefault: [NSDate distantPast]];
    
    
    
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"[Comment %p (displayName:'%@', comment:'%@')]", self, self.displayName, self.commentText];
}


@end
