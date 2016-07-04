//
//  CoreData.h
//  Petunia
//
//  Created by Christopher Prince on 6/11/13.
//  Copyright (c) 2013 Christopher Prince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#ifdef SMCOMMONLIB
#import <SMCommon/NSObject+TargetsAndSelectors.h>
#else
#import "NSObject+TargetsAndSelectors.h"
#endif

@protocol CoreDataModel <NSObject>

@required

// This doesn't make assumptions about uuid's.
+ (NSManagedObject *) newObject;
+ (NSString *) entityName;

@optional

// Creates a UUID for the object iff makeUUID = YES; object must have an NSManagedObject field/property named "uuid", of type NSString.
+ (NSManagedObject *) newObjectAndMakeUUID: (BOOL) makeUUID;

+ (NSArray*) fetchAllObjectsInContext:(NSManagedObjectContext *) context;
+ (NSArray *) fetchObjectsInContext:(NSManagedObjectContext *) context modifyingFetchRequestWith: (void (^)(NSFetchRequest *)) fetchRequestModifier;

// This is relatively efficient: It doesn't fetch all objects into an array.
+ (NSUInteger) countOfObjectsInContext:(NSManagedObjectContext *) context;

@end

@interface CoreData : NSObject

// Call setupNamesWithDictionary before session is called/used for the first time.
// Keys for the following dictionary

// File names
extern const NSString *CoreDataBundleModelName;
extern const NSString *CoreDataSqlliteFileName;
extern const NSString *CoreDataSqlliteBackupFileName;

#define COREDATA_BUNDLE_MODEL_NAME                      CoreDataBundleModelName
#define COREDATA_SQLITE_FILE_NAME                       CoreDataSqlliteFileName
#define COREDATA_SQLITE_BACKUP_FILE_NAME                CoreDataSqlliteBackupFileName

+ (void) setupNamesWithDictionary: (NSDictionary *) dictionary;

+ (instancetype) session;
- (void) setupCustomAlert: (void (^)(UIAlertView *alert)) alert;

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
// Same thing; just shorter name! :).
@property (strong, nonatomic, readonly) NSManagedObjectContext *context;

// Get callbacks when managed objects are deleted, updated, or inserted. Based on NSManagedObjectContextObjectsDidChangeNotification. The keys used in the associated NSMutableDictionary's are: NSDeletedObjectsKey, NSUpdatedObjectsKey, NSInsertedObjectsKey
@property (strong, nonatomic, readonly) NSObject<TargetsAndSelectors> *didDeleteObjects;
@property (strong, nonatomic, readonly) NSObject<TargetsAndSelectors> *didUpdateObjects;
@property (strong, nonatomic, readonly) NSObject<TargetsAndSelectors> *didInsertObjects;

// Allow or disallow undo. Default is off.
- (void) undoIsOn: (BOOL) onOff;

// No effect if undo is off.
- (void) undo;

// We need a saveContext that returns void for the cases where we are doing a performSelector
- (void) saveContextVoidReturn;
- (BOOL) saveContext;

// For subclasses only.
- (id) init;

// Pass a nil context in these to use the default context. i.e., the managedObjectContext property of this class. These methods can return nil.
+ (NSManagedObject *) newObjectInContext:(NSManagedObjectContext *)context withEntityName: (NSString *) entityName;

// If there is an error, error is returned non-nil. In this case, a UIAlertView will have been given to the user. Nil is returned in this case. With no error, and no objects found, nil is returned.
+ (NSArray *) fetchAllObjectsInContext:(NSManagedObjectContext*) context withEntityName: (NSString *) entityName andError: (NSError **) error;
+ (NSArray *) fetchObjectsInContext:(NSManagedObjectContext *) context withEntityName: (NSString *) entityName error: (NSError **) error modifyingFetchRequestWith: (void (^)(NSFetchRequest *)) fetchRequestModifier;

+ (NSFetchRequest *) fetchRequestInContext:(NSManagedObjectContext *) context withEntityName: (NSString *) entityName modifyingFetchRequestWith: (void (^)(NSFetchRequest *)) fetchRequestModifier;

// Get the total number of objects, with that entity name, in the context.
// If there is an error, error is returned non-nil. In this case, a UIAlertView will have been given to the user. Returns 0 on an error.
+ (NSUInteger) countOfObjectsInContext:(NSManagedObjectContext *) context withEntityName: (NSString *) entityName andError: (NSError **) error;

+ (void) removeObject: (NSManagedObject *) managedObject inContext: (NSManagedObjectContext *) context;
+ (void) removeObject: (NSManagedObject *) managedObject;

@end
