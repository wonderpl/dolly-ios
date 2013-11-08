// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Friend.h instead.

#import <CoreData/CoreData.h>
#import "ChannelOwner.h"

extern const struct FriendAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *externalSystem;
	__unsafe_unretained NSString *externalUID;
	__unsafe_unretained NSString *hasIOSDevice;
	__unsafe_unretained NSString *lastShareDate;
	__unsafe_unretained NSString *localOrigin;
	__unsafe_unretained NSString *resourceURL;
} FriendAttributes;

extern const struct FriendRelationships {
} FriendRelationships;

extern const struct FriendFetchedProperties {
} FriendFetchedProperties;










@interface FriendID : NSManagedObjectID {}
@end

@interface _Friend : ChannelOwner {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FriendID*)objectID;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* externalSystem;



//- (BOOL)validateExternalSystem:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* externalUID;



//- (BOOL)validateExternalUID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* hasIOSDevice;



@property BOOL hasIOSDeviceValue;
- (BOOL)hasIOSDeviceValue;
- (void)setHasIOSDeviceValue:(BOOL)value_;

//- (BOOL)validateHasIOSDevice:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastShareDate;



//- (BOOL)validateLastShareDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* localOrigin;



@property BOOL localOriginValue;
- (BOOL)localOriginValue;
- (void)setLocalOriginValue:(BOOL)value_;

//- (BOOL)validateLocalOrigin:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceURL;



//- (BOOL)validateResourceURL:(id*)value_ error:(NSError**)error_;






@end

@interface _Friend (CoreDataGeneratedAccessors)

@end

@interface _Friend (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveExternalSystem;
- (void)setPrimitiveExternalSystem:(NSString*)value;




- (NSString*)primitiveExternalUID;
- (void)setPrimitiveExternalUID:(NSString*)value;




- (NSNumber*)primitiveHasIOSDevice;
- (void)setPrimitiveHasIOSDevice:(NSNumber*)value;

- (BOOL)primitiveHasIOSDeviceValue;
- (void)setPrimitiveHasIOSDeviceValue:(BOOL)value_;




- (NSDate*)primitiveLastShareDate;
- (void)setPrimitiveLastShareDate:(NSDate*)value;




- (NSNumber*)primitiveLocalOrigin;
- (void)setPrimitiveLocalOrigin:(NSNumber*)value;

- (BOOL)primitiveLocalOriginValue;
- (void)setPrimitiveLocalOriginValue:(BOOL)value_;




- (NSString*)primitiveResourceURL;
- (void)setPrimitiveResourceURL:(NSString*)value;




@end
