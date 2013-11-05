// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ExternalAccount.h instead.

@import CoreData;


extern const struct ExternalAccountAttributes {
	__unsafe_unretained NSString *expiration;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *noautopost;
	__unsafe_unretained NSString *permissions;
	__unsafe_unretained NSString *system;
	__unsafe_unretained NSString *token;
	__unsafe_unretained NSString *uid;
	__unsafe_unretained NSString *url;
} ExternalAccountAttributes;

extern const struct ExternalAccountRelationships {
	__unsafe_unretained NSString *accountOwner;
} ExternalAccountRelationships;

extern const struct ExternalAccountFetchedProperties {
} ExternalAccountFetchedProperties;

@class User;










@interface ExternalAccountID : NSManagedObjectID {}
@end

@interface _ExternalAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ExternalAccountID*)objectID;





@property (nonatomic, strong) NSDate* expiration;



//- (BOOL)validateExpiration:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* noautopost;



@property BOOL noautopostValue;
- (BOOL)noautopostValue;
- (void)setNoautopostValue:(BOOL)value_;

//- (BOOL)validateNoautopost:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* permissions;



//- (BOOL)validatePermissions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* system;



//- (BOOL)validateSystem:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* token;



//- (BOOL)validateToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uid;



//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *accountOwner;

//- (BOOL)validateAccountOwner:(id*)value_ error:(NSError**)error_;





@end

@interface _ExternalAccount (CoreDataGeneratedAccessors)

@end

@interface _ExternalAccount (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveExpiration;
- (void)setPrimitiveExpiration:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveNoautopost;
- (void)setPrimitiveNoautopost:(NSNumber*)value;

- (BOOL)primitiveNoautopostValue;
- (void)setPrimitiveNoautopostValue:(BOOL)value_;




- (NSString*)primitivePermissions;
- (void)setPrimitivePermissions:(NSString*)value;




- (NSString*)primitiveSystem;
- (void)setPrimitiveSystem:(NSString*)value;




- (NSString*)primitiveToken;
- (void)setPrimitiveToken:(NSString*)value;




- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (User*)primitiveAccountOwner;
- (void)setPrimitiveAccountOwner:(User*)value;


@end
