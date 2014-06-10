#import "AppConstants.h"
#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "User.h"
#import "ExternalAccount.h"
#import "SYNActivityManager.h"

@implementation User

@synthesize facebookAccount;
@synthesize twitterAccount;
@synthesize googlePlusAccount;

#pragma mark - Object factory


+ (User *) instanceFromUser: (User *) oldUser
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    User *instance = [User insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = oldUser.uniqueId;
    instance.username = oldUser.username;
    instance.emailAddress = oldUser.emailAddress;
    instance.firstName = oldUser.firstName;
    instance.lastName = oldUser.lastName;
    instance.genderValue = oldUser.genderValue;
    instance.dateOfBirth = oldUser.dateOfBirth;
    instance.locale = oldUser.locale;
    
    return instance;
}


+ (User *) instanceFromDictionary: (NSDictionary *) dictionary
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    NSString *uniqueId = dictionary[@"id"];
    
    if (!uniqueId)
    {
        return nil;
    }
    
    User *instance = [User insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    [instance setAttributesFromDictionary: dictionary
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    // Sets attributes for ChannelOwner (superclass) AND adds Channels
    [super setAttributesFromDictionary: dictionary
                   ignoringObjectTypes: ignoringObjects];
    
    // Then set the rest
    NSString *n_username = dictionary[@"username"];
    self.username = n_username ? n_username : self.username;
    
    
    NSString *n_emailAddress = dictionary[@"email"];
    self.emailAddress = n_emailAddress ? n_emailAddress : self.emailAddress;
    
    NSString *n_firstName = dictionary[@"first_name"];
    self.firstName = n_firstName ? n_firstName : self.firstName;
    
    NSString *n_lastName = dictionary[@"last_name"];
    self.lastName = n_lastName ? n_lastName : self.lastName;
    
    NSNumber *n_display_fullName = dictionary[@"display_fullname"];
    self.fullNameIsPublicValue = n_display_fullName ? [n_display_fullName boolValue] : NO;
    
    if([dictionary[@"external_accounts"] isKindOfClass:[NSDictionary class]])
        [self setExternalAccountsFromDictionary:dictionary[@"external_accounts"]];
    
    if([dictionary[@"flags"] isKindOfClass:[NSDictionary class]])
        [self setExternalAccountFlagsFromDictionary:dictionary[@"flags"]];
    
    
    NSDictionary *activity_dict = dictionary[@"activity"];
    
    if (activity_dict)
    {
        if(activity_dict[@"recently_starred"])
        {
            // if this is set it means we have activity data with the response, usually by setting '&data=activity' in the request
            // the objects contained are 'recently_starred', 'recently_viewed' and 'subscribed' and 'user_subscribed'
            [SYNActivityManager.sharedInstance registerActivityFromDictionary:activity_dict];
        }
    }
    
    // == Gender == //
    NSString *genderString = dictionary[@"gender"];
    
    if (!genderString || [genderString isEqual: [NSNull null]])
    {
        self.genderValue = GenderUndecided;
    }
    else if ([[genderString uppercaseString] isEqual: @"M"])
    {
        self.genderValue = GenderMale;
    }
    else if ([[genderString uppercaseString] isEqual: @"F"])
    {
        self.genderValue = GenderFemale;
    }
    
    // == Date of Birth == //
    
    NSString *dateOfBirthString = dictionary[@"date_of_birth"];
    
    if ([dateOfBirthString isKindOfClass: [NSNull class]])
    {
        self.dateOfBirth = nil;
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
        NSDate *dateOfBirthDate = [dateFormatter dateFromString: dateOfBirthString];
        
        self.dateOfBirth = dateOfBirthDate;
    }
    
    // == Locale == //
    NSString *localeFromDict = [dictionary objectForKey: @"locale"
                                            withDefault: @""];

    NSString *localeFromDevice = [(NSString *) CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
    
    if ([localeFromDict isEqualToString: @""])
    {
        self.locale = localeFromDevice;
    }
    else
    {
        self.locale = localeFromDict;
    }
}


#pragma mark - Accessors

- (void) addSubscriptionsObject: (Channel *) value_
{
    [self.subscriptionsSet addObject: value_];
//    value_.subscribedByUserValue = YES;
//    value_.subscribersCountValue++;
}


- (void) removeSubscriptionsObject: (Channel *) value_
{
//    value_.subscribedByUserValue = NO;
//    value_.subscribersCountValue--;
    [self.subscriptionsSet removeObject: value_];
}


- (NSString *) fullName
{
    NSMutableString *fullNameString = [[NSMutableString alloc] initWithCapacity: (self.firstName.length + 1 + self.lastName.length)];
    
    if (![self.firstName isEqualToString: @""])
    {
        [fullNameString appendString: self.firstName];
    }
    
    if (![self.lastName isEqualToString: @""])
    {
        [fullNameString appendFormat: @" %@", self.lastName];
    }
    
    return [NSString stringWithString: (NSString *) fullNameString];
}


- (NSString *) description
{
    NSMutableString *userDescription = [NSMutableString stringWithFormat: @"User (id:'%@') - username: '%@'", self.uniqueId, self.username];
    
    [userDescription appendFormat: @"\n=== Own Channels (%@): ===", @([self.channels count])];
    
    
    Channel *channel;
    for (channel in self.channels)
    {
        [userDescription appendFormat: @"\n * %@", channel.title];
    }
    
    [userDescription appendFormat: @"\n=== Subscribed Channels (%@): ===", @([self.subscriptions count])];
    
    
    for (channel in self.subscriptions)
    {
        [userDescription appendFormat: @"\n - %@", channel.title];
    }
    
    [userDescription appendFormat: @"\n=== External Accounts (%@): ===", @([self.externalAccounts count])];
    
    
    for (ExternalAccount *account in self.externalAccounts)
    {
        [userDescription appendFormat: @"\n + %@ %@", account.system, account.permissionFlagsString];
    }
    
    return userDescription;
}

#pragma mark - External Accounts

-(void)setExternalAccountsFromDictionary:(NSDictionary*)dictionary
{
   
    if(!dictionary)
        return;
    
    NSArray* items = dictionary[@"items"];
    if(![items isKindOfClass:[NSArray class]])
        return;
    
    ExternalAccount* externalAccount;
    
    NSMutableDictionary* externalAccountBySystemName = [NSMutableDictionary dictionaryWithCapacity:self.externalAccounts.count];
    for (externalAccount in self.externalAccounts)
    {
        [externalAccountBySystemName setObject:externalAccount forKey:externalAccount.system];
    }
    
    NSString* systemKey;
    for (NSDictionary* item in items)
    {
      
        if(!(systemKey = item[@"external_system"]))
            continue;
        
        if(!(externalAccount = externalAccountBySystemName[systemKey]))
        {
            if(!(externalAccount = [ExternalAccount instanceFromDictionary:item
                                                usingManagedObjectContext:self.managedObjectContext]))
            {
                continue;
            }
            else
            {
                [self.externalAccountsSet addObject:externalAccount];
            }
        }
        else
        {
            [externalAccountBySystemName removeObjectForKey:systemKey];
            [externalAccount setAttributesFromDictionary:item];
        }
        
    }
    
    // delete old
    for (systemKey in externalAccountBySystemName)
    {
        
        externalAccount = externalAccountBySystemName[systemKey];
        
        if(!externalAccount)
            continue;
        
        [externalAccount.managedObjectContext deleteObject:externalAccount];
    }
}

-(void)setFlag:(ExternalAccountFlag)flag toExternalAccount:(NSString*)accountName
{
    ExternalAccount* accountToSetFlag = [self externalAccountForSystem:accountName];
    
    if(!accountToSetFlag)
        return;
    
    accountToSetFlag.flagsValue |= flag;
    
}

-(void)unsetFlag:(ExternalAccountFlag)flag toExternalAccount:(NSString*)accountName
{
    ExternalAccount* accountToSetFlag = [self externalAccountForSystem:accountName];
    
    if(!accountToSetFlag)
        return;
    
    accountToSetFlag.flagsValue &= !flag;
    
}

-(void)setExternalAccountFlagsFromDictionary:(NSDictionary*)dictionary
{
    
    if(!dictionary)
        return;
    
    NSArray* items = dictionary[@"items"];
    if(![items isKindOfClass:[NSArray class]])
        return;
    
    for (NSDictionary* item in items)
    {
        if(![item[@"flag"] isKindOfClass:[NSString class]])
            continue;
        
        if([item[@"flag"] isEqualToString:@"facebook_autopost_add"])
            [self setFlag:ExternalAccountFlagAutopostAdd toExternalAccount:@"facebook"];
        else if([item[@"flag"] isEqualToString:@"facebook_autopost_star"])
            [self setFlag:ExternalAccountFlagAutopostStar toExternalAccount:@"facebook"];
    }
    
}

-(ExternalAccount*)facebookAccount
{
    return [self externalAccountForSystem:@"facebook"];
}


-(ExternalAccount*)twitterAccount
{
    return [self externalAccountForSystem:@"twitter"];
}

-(ExternalAccount*)googlePlusAccount
{
    return [self externalAccountForSystem:@"google"];
}

-(ExternalAccount*)apnsAccount
{
    return [self externalAccountForSystem:@"apns"];
}

-(ExternalAccount*)externalAccountForSystem:(NSString*)systemName
{
    for (ExternalAccount* externalAccount in self.externalAccounts)
    {
        if([externalAccount.system isEqualToString:systemName])
            return externalAccount;
        
    }
    return nil;
}
@end
