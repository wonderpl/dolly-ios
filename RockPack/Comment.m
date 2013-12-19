#import "Comment.h"
#import "NSDictionary+Validation.h"


@interface Comment ()


@end


@implementation Comment


+ (Comment *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;
    
    
    NSNumber *uniqueId = dictionary[@"id"];
    
    if (![uniqueId isKindOfClass: [NSNumber class]])
        return nil;
    
    
    Comment *instance = [Comment insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = [uniqueId stringValue];
    
    
    [instance setAttributesFromDictionary: dictionary];
    
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @(0)];
    
    
    self.commentText = [dictionary objectForKey: @"comment"
                                    withDefault: @""];
    
    // comments comming from the server do not have with value so they will default to YES which is correct, comments created on the fly will have it set to NO
    self.validated = [dictionary objectForKey: @"validated"
                                  withDefault: @(YES)];
    
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"date_added"
                                                 withDefault: [NSDate date]];
    
    self.recentValue = NO; // if it is coming from the server then it is NOT recent, otherwise we need to set the recentValue by hand after the creation of the comment
    
    NSDictionary* userDictionary = [dictionary objectForKey: @"user"];
    
    /* NOTE: Comments might be later linked to a real ChannelOwner Object, but for now we store the data in separate fields */
    
    // we at least want an id
    if([userDictionary isKindOfClass:[NSDictionary class]] && [[userDictionary objectForKey: @"id"] isKindOfClass:[NSString class]])
    {
        self.displayName = [userDictionary objectForKey: @"display_name"
                                            withDefault: @""];
        
        self.userId = [userDictionary objectForKey: @"id"
                                       withDefault: @""];
        
        self.thumbnailUrl = [userDictionary objectForKey: @"avatar_thumbnail_url"
                                             withDefault: @""];
    }
    
    
    
    self.videoInstanceId = nil; // this is filled by the view controller or registry which knows which one it is in associated with...
    
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"[Comment %p (displayName:'%@', comment:'%@')]", self, self.displayName, self.commentText];
}


@end
