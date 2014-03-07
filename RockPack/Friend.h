#import "_Friend.h"
@import AddressBook;
@interface Friend : _Friend {}


+ (Friend *) instanceFromDictionary: (NSDictionary *) dictionary
          usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (Friend *) friendFromFriend:(Friend *)friendToCopy
      forManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

- (void) setAttributesFromAddressBook :(ABRecordRef) currentPerson email:(NSString*) email;
- (void) setAttributesFromDictionary: (NSDictionary *) dictionary;

@property (nonatomic, readonly) BOOL isOnRockpack;


@property (nonatomic, readonly) BOOL isFromFacebook;
@property (nonatomic, readonly) BOOL isFromTwitter;
@property (nonatomic, readonly) BOOL isFromGooglePlus;
@property (nonatomic, readonly) BOOL isFromAddressBook;



@end
