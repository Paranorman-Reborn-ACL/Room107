//
//  ManagedObject.m
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ManagedObject.h"

@implementation ManagedObject

+ (id)createObject {
    return [self createInContext:[App managedObjectContext]];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [self setValue:obj forKey:[NSString stringByReplacingSnakeCaseWithCamelCase:key]];
        [self setValue:obj forKey:key];
    }];
}

+ (id)createObjectWithDictionary:(NSDictionary *)dict {
    return dict ? [self createOrUpdateObjectAndSaveWithDictionary:dict completion:nil] : nil;

//     id retObject = nil;
//     NSDictionary *keysForNames = [self dictionaryKeyPathsForPropertyNames];
//     NSArray *identityPropertyNames = [self identityPropertyNames];
//     NSFetchRequest *fetchRequest = [self fetchRequest];
//     for (NSString *identityName in identityPropertyNames) {
//         id identityValue = dict[keysForNames[identityName]];
//         NSString *predictFormat = nil;
//         if ([[identityValue class] isSubclassOfClass:[NSString class]]) {
//             predictFormat = [NSString stringWithFormat:@"%@=\"%@\"", identityName, identityValue];
//         } else {
//             predictFormat = [NSString stringWithFormat:@"%@=%@", identityName, identityValue];
//         }
//         [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predictFormat]];
//     }
//    
//     NSError *error = nil;
//     NSArray *results = [[App managedObjectContext] executeFetchRequest:fetchRequest error:&error];
//     if ([results count] > 0) {
//         retObject = [results firstObject];
//         retObject = [retObject initWithDictionary:dict];
//     } else {
//         retObject = [[self createObject] initWithDictionary:dict];
//     }
//    
//     return retObject;
}

+ (id)createOrUpdateObjectWithDictionary:(NSDictionary *)dict completion:(void (^)(ManagedObject *))completion {
    NSMutableArray *predicts = [NSMutableArray array];
    for (NSString *identityName in [self identityPropertyNames]) {
//        id identityValue = dict[[NSString stringByReplacingCamelCaseWithSnakeCase:identityName]];
        id identityValue = dict[identityName];
        if (identityValue == nil) {
            LogWarn(@"NO query value for indentity %@", identityName);
            continue;
        }
        [predicts addObject:[NSPredicate predicateWithFormat:@"%K == %@", identityName, identityValue]];
    }
    NSPredicate *predict = [NSCompoundPredicate andPredicateWithSubpredicates:predicts];
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    [fetchRequest setPredicate:predict];
    //避免data:<fault>
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *results = [self executeFetchRequest:fetchRequest];
    
    ManagedObject *object = [results firstObject];
    if (object == nil) {
        object = [self createObject];
    }
    [object updateFromDictionary:dict];
    
    return object;
}

+ (id)createOrUpdateObjectAndSaveWithDictionary:(NSDictionary *)dict completion:(void (^)(ManagedObject *))completion {
    ManagedObject *object = [self createOrUpdateObjectWithDictionary:dict completion:completion];
    BOOL success = [object save];
    if (!success) {
        LogError(@"save error");
    }
    
    return object;
}

+ (NSMutableArray *)createOrUpdateObjectsFromDictionaries:(NSArray *)dicts step:(void (^)(ManagedObject *))step completion:(void (^)(NSArray *))completion {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[dicts count]];
    for (NSDictionary *dict in dicts) {
        ManagedObject *object = [self createOrUpdateObjectWithDictionary:dict completion:step];
        [result addObject:object];
    }
    
    if (completion) {
        completion(result);
    }
    
    return result;
}

+ (NSMutableArray *)createOrUpdateObjectsAndSaveFromDictionaries:(NSArray *)dicts step:(void (^)(ManagedObject *))step completion:(void (^)(NSArray *))completion {
    NSMutableArray *result = [self createOrUpdateObjectsFromDictionaries:dicts step:step completion:completion];
    [ManagedObject saveCoreData];
    
    return result;
}

+ (NSArray *)getObjects {
    return [self getObjectsWithSort:nil predicate:nil];
}

+ (NSArray *)getObjectsWithPredicate:(NSPredicate *)predicate {
    return [self getObjectsWithSort:nil predicate:predicate];
}

+ (NSArray *)getObjectsWithSort:(NSSortDescriptor *)sort {
    return [self getObjectsWithSort:sort predicate:nil];
}

+ (NSArray *)getObjectsWithSorts:(NSArray *)sorts {
    return [self getObjectsWithSorts:sorts predicate:nil];
}

+ (NSArray *)getObjectsWithSort:(NSSortDescriptor *)sort predicate:(NSPredicate *)predicate {
    return [self getObjectsWithSort:sort predicate:predicate offset:-1 limit:-1];
}

+ (NSArray *)getObjectsWithSorts:(NSArray *)sorts predicate:(NSPredicate *)predicate {
    return [self getObjectsWithSorts:sorts predicate:predicate offset:-1 limit:-1];
}

+ (NSArray *)getObjectsWithSort:(NSSortDescriptor *)sort predicate:(NSPredicate *)predicate offset:(NSInteger)offset limit:(NSInteger)limit {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    if (sort != nil) {
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    }
    
    if (predicate != nil) {
        [fetchRequest setPredicate:predicate];
    }
    
    if (offset != -1) {
        [fetchRequest setFetchOffset:offset];
    }
    
    if (limit != -1) {
        [fetchRequest setFetchLimit:limit];
    }
    
    //避免data:<fault>
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSError *error = nil;
    NSArray *results = [[App managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error == nil) {
        return results;
    } else {
        return nil;
    }
}

+ (NSArray *)getObjectsWithSorts:(NSArray *)sorts predicate:(NSPredicate *)predicate offset:(NSInteger)offset limit:(NSInteger)limit {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    
    if (sorts != nil) {
        [fetchRequest setSortDescriptors:sorts];
    }
    
    if (predicate != nil) {
        [fetchRequest setPredicate:predicate];
    }
    
    if (offset != -1) {
        [fetchRequest setFetchOffset:offset];
    }
    
    if (limit != -1) {
        [fetchRequest setFetchLimit:limit];
    }
    
    //避免data:<fault>
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSError *error = nil;
    NSArray *results = [[App managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error == nil) {
        return results;
    } else {
        return nil;
    }
}

+ (NSArray *)deleteObjectsWithPredicate:(NSPredicate *)predicate {
    NSArray *results = [self getObjectsWithSort:nil predicate:predicate];
    for (ManagedObject *mo in results) {
        [mo deleteObject];
    }
    
    return results;
}

+ (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //表格实体结构
    NSEntityDescription *entify = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:App.managedObjectContext];
    [fetchRequest setEntity:entify];
    
    return fetchRequest;
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest {
    //避免data:<fault>
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSError *error = nil;
    NSArray *result = [[App managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        LogError(@"failed to execute fetch request, %@", error);
    }
    
    return result;
}

+ (void)clean {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    //避免data:<fault>
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSArray *results = [[App managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    for (ManagedObject *mo in results) {
        [mo deleteObject];
    }
}

+ (NSArray *)identityPropertyNames {
    return nil;
}

+ (NSDictionary *)dictionaryKeyPathsForPropertyNames {
    return nil;
}

+ (void)saveCoreData {
    NSError *error = nil;
    [[App managedObjectContext] save:&error];
    if (error) {
        LogError(@"failed to save core data, %@", error);
    }
}


#pragma mark - Overrides

//将Model对象转换为JSON对象
- (NSDictionary *)dictionaryWithValuesForAllKeys {
    NSEntityDescription *entify = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:App.managedObjectContext];
    NSDictionary *attributes = [entify attributesByName];
    
    return [self dictionaryWithValuesForKeys:attributes.allKeys];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    LogWarn(@"setValue:[...] forUndefinedKey:%@", key);
}

@end
