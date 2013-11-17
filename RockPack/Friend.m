#import "Friend.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"

@interface Friend ()

// Private interface goes here.

@end


@implementation Friend

@synthesize isOnRockpack;

+ (Friend *) friendFromFriend:(Friend *)friendToCopy
      forManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    Friend *instance = [Friend insertInManagedObjectContext: managedObjectContext];
    
    if(!instance || !friendToCopy)
        return nil;
    
    instance.uniqueId = friendToCopy.uniqueId;
    
    instance.thumbnailURL = friendToCopy.thumbnailURL;
    
    instance.displayName = friendToCopy.displayName;
    
    instance.externalSystem = friendToCopy.externalSystem;
    
    instance.externalUID = friendToCopy.externalUID;
    
    instance.resourceURL = friendToCopy.resourceURL;
    
    instance.hasIOSDevice = friendToCopy.hasIOSDevice;
    
    instance.email = friendToCopy.email;
    
    instance.lastShareDate = friendToCopy.lastShareDate;
    
    return instance;
    
}

+ (Friend *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    Friend *instance = [Friend insertInManagedObjectContext: managedObjectContext];
    
    
    [instance setAttributesFromDictionary: dictionary];
    
    if([instance.uniqueId isEqualToString:@""]) // if no id OR external system id was found
        return nil;
    
    return instance;
}

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    // call to ChannelOwner
    [super setAttributesFromDictionary:dictionary
                   ignoringObjectTypes:kIgnoreChannelObjects];
    
    self.uniqueId = [dictionary objectForKey:@"id"
                                 withDefault:@""];
    
    self.externalSystem =
    [dictionary[@"external_system"] isKindOfClass:[NSString class]] ? dictionary[@"external_system"] : nil;
    
    
    self.externalUID =
    [dictionary[@"external_uid"] isKindOfClass:[NSString class]] ? dictionary[@"external_uid"] : nil;
    
    if([self.uniqueId isEqualToString:@""]) // in the case of FB friends we are not returned a UID, use the FB one.
        self.uniqueId = self.externalUID;
    
    self.resourceURL =
    [dictionary[@"resource_url"]  isKindOfClass:[NSString class]] ? dictionary[@"resource_url"] : nil;
    
    
    self.hasIOSDevice = [dictionary objectForKey: @"has_ios_device"
                                     withDefault: @NO];
    
    self.email = [dictionary[@"email"] isKindOfClass:[NSString class]] ? dictionary[@"email"] : nil;
    
    
    self.lastShareDate = [dictionary dateFromISO6801StringForKey:@"last_shared_date"
                                                     withDefault:nil];
    
    self.localOriginValue = NO;
    
}

-(NSString*)firstName
{
    NSArray* dNameArray = [self.displayName componentsSeparatedByString:@" "];
    return (dNameArray.count > 0 ? dNameArray[0] : @"");
}

-(NSString*)lastName
{
    NSArray* dNameArray = [self.displayName componentsSeparatedByString:@" "];
    return (dNameArray.count > 1 ? dNameArray[dNameArray.count - 1] : @"");
}

-(BOOL)isOnRockpack
{
    return (self.resourceURL != nil);
}

-(BOOL)isFromFacebook
{
    return [self.externalSystem isEqualToString:kFacebook];
}
-(BOOL)isFromTwitter
{
    return [self.externalSystem isEqualToString:kTwitter];
}
-(BOOL)isFromGooglePlus
{
    return [self.externalSystem isEqualToString:kGooglePlus];
}
-(BOOL)isFromAddressBook
{
    return self.localOriginValue;
}
-(NSString*)description
{
    NSString* from;
    if(self.localOriginValue)
        from = @"Loc";
    else if (self.isFromFacebook)
        from = @"FB";
    else if (self.isOnRockpack)
        from = @"RP";
    else
        from = @"?";
    
    return [NSString stringWithFormat:@"[Friend [%@] (name:'%@', email:'%@')]", from, self.displayName, self.email];
}

@end
