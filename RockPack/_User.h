// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "ChannelOwner.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *current;
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *emailAddress;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *fullNameIsPublic;
	__unsafe_unretained NSString *gender;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *locale;
	__unsafe_unretained NSString *loginOrigin;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *externalAccounts;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class ExternalAccount;











@interface UserID : NSManagedObjectID {}
@end

@interface _User : ChannelOwner {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSNumber* current;



@property BOOL currentValue;
- (BOOL)currentValue;
- (void)setCurrentValue:(BOOL)value_;

//- (BOOL)validateCurrent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateOfBirth;



//- (BOOL)validateDateOfBirth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* emailAddress;



//- (BOOL)validateEmailAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* fullNameIsPublic;



@property BOOL fullNameIsPublicValue;
- (BOOL)fullNameIsPublicValue;
- (void)setFullNameIsPublicValue:(BOOL)value_;

//- (BOOL)validateFullNameIsPublic:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* gender;



@property int32_t genderValue;
- (int32_t)genderValue;
- (void)setGenderValue:(int32_t)value_;

//- (BOOL)validateGender:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* locale;



//- (BOOL)validateLocale:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* loginOrigin;



@property int16_t loginOriginValue;
- (int16_t)loginOriginValue;
- (void)setLoginOriginValue:(int16_t)value_;

//- (BOOL)validateLoginOrigin:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *externalAccounts;

- (NSMutableSet*)externalAccountsSet;





@end

@interface _User (CoreDataGeneratedAccessors)

- (void)addExternalAccounts:(NSSet*)value_;
- (void)removeExternalAccounts:(NSSet*)value_;
- (void)addExternalAccountsObject:(ExternalAccount*)value_;
- (void)removeExternalAccountsObject:(ExternalAccount*)value_;

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCurrent;
- (void)setPrimitiveCurrent:(NSNumber*)value;

- (BOOL)primitiveCurrentValue;
- (void)setPrimitiveCurrentValue:(BOOL)value_;




- (NSDate*)primitiveDateOfBirth;
- (void)setPrimitiveDateOfBirth:(NSDate*)value;




- (NSString*)primitiveEmailAddress;
- (void)setPrimitiveEmailAddress:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSNumber*)primitiveFullNameIsPublic;
- (void)setPrimitiveFullNameIsPublic:(NSNumber*)value;

- (BOOL)primitiveFullNameIsPublicValue;
- (void)setPrimitiveFullNameIsPublicValue:(BOOL)value_;




- (NSNumber*)primitiveGender;
- (void)setPrimitiveGender:(NSNumber*)value;

- (int32_t)primitiveGenderValue;
- (void)setPrimitiveGenderValue:(int32_t)value_;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveLocale;
- (void)setPrimitiveLocale:(NSString*)value;




- (NSNumber*)primitiveLoginOrigin;
- (void)setPrimitiveLoginOrigin:(NSNumber*)value;

- (int16_t)primitiveLoginOriginValue;
- (void)setPrimitiveLoginOriginValue:(int16_t)value_;





- (NSMutableSet*)primitiveExternalAccounts;
- (void)setPrimitiveExternalAccounts:(NSMutableSet*)value;


@end
