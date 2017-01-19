//
//  ManagedObject.h
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "NSArray+Additions.h"
#import "NSManagedObject+ActiveRecord.h"

typedef NS_ENUM(NSInteger, StorageSynchType) {
    StorageSynchContinue  = 1 << 28,
    StorageSynchTail      = 1 << 29,
    StorageSynchMask      = 0x0f000000
};

/**
 * @class ManagedObject
 *
 * @brief
 *
 * 被管理的数据记录
 *
 * TODO:通过Category实现
 */
@interface ManagedObject : NSManagedObject

+ (id)createObject;

+ (id)createObjectWithDictionary:(NSDictionary *)dict;

+ (id)createOrUpdateObjectWithDictionary:(NSDictionary *)dict completion:(void (^)(ManagedObject *object))completion;
+ (id)createOrUpdateObjectAndSaveWithDictionary:(NSDictionary *)dict completion:(void (^)(ManagedObject *object))completion;

+ (NSMutableArray *)createOrUpdateObjectsFromDictionaries:(NSArray *)dicts step:(void (^)(ManagedObject *object))step completion:(void (^)(NSArray *objects))completion;
+ (NSMutableArray *)createOrUpdateObjectsAndSaveFromDictionaries:(NSArray *)dicts step:(void (^)(ManagedObject *object))step completion:(void (^)(NSArray *objects))completion;

+ (NSArray *)getObjects;
+ (NSArray *)getObjectsWithPredicate:(NSPredicate *)predicate;

+ (NSArray *)getObjectsWithSort:(NSSortDescriptor *)sort;
+ (NSArray *)getObjectsWithSorts:(NSArray *)sorts;

+ (NSArray *)getObjectsWithSort:(NSSortDescriptor *)sort predicate:(NSPredicate *)predicate;
+ (NSArray *)getObjectsWithSorts:(NSArray *)sorts predicate:(NSPredicate *)predicate;

+ (NSArray *)getObjectsWithSort:(NSSortDescriptor *)sort predicate:(NSPredicate *)predicate offset:(NSInteger)offset limit:(NSInteger)limit;
+ (NSArray *)getObjectsWithSorts:(NSArray *)sorts predicate:(NSPredicate *)predicate offset:(NSInteger)offset limit:(NSInteger)limit;

+ (NSArray *)deleteObjectsWithPredicate:(NSPredicate *)predicate;

//数据请求
+ (NSFetchRequest *)fetchRequest;

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest;

+ (void)clean;

+ (NSArray *)identityPropertyNames;

- (NSDictionary *)dictionaryWithValuesForAllKeys;

@end
