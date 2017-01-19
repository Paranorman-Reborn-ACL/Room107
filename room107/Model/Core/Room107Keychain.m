//
//  Room107Keychain.m
//  room107
//
//  Created by ningxia on 15/7/13.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107Keychain.h"
#import "RSA.h"
#import "UserInfoModel+CoreData.h"

static NSString * const KEY_PUBLIC = @"com.107room.app.publickey";

@implementation Room107Keychain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:CFBridgingRelease(keyData)];
        } @catch (NSException *e) {
            LogDebug(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    
    //避免释放了一个nil对象的崩溃：[CFData release]: message sent to deallocated instance 0x1c4c37cd0
//    if (keyData)
//        CFRelease(keyData);
    
    return ret;
}

+ (BOOL)setObject:(id<NSCoding>)object ForKey:(id)key {
    NSParameterAssert(key);
    
    BOOL success = YES;

    NSMutableDictionary *authenticationInfo = (NSMutableDictionary *)[self load:KEY_AUTHENTICATIONINFO];
    
    OSStatus status = errSecSuccess;
    if (object) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        NSDictionary *dataDict = @{ (__bridge NSString *)kSecValueData: data};
        
        if ([self objectForKey:key]) {
            // Item already exists, update it
            status = SecItemUpdate((__bridge CFDictionaryRef)(authenticationInfo), (__bridge CFDictionaryRef)(dataDict));
            
            if (status != errSecSuccess) {
                success = NO;
                LogDebug(@"Failed to update existing Keychain item with status: %@", @(status));
            }
        } else {
            // Add a new item
            NSMutableDictionary *mutQuery = [authenticationInfo mutableCopy];
            [mutQuery addEntriesFromDictionary:dataDict];
            authenticationInfo = [mutQuery copy];
            
            status = SecItemAdd((__bridge CFDictionaryRef)(authenticationInfo), NULL);
            
            if (status != errSecSuccess) {
                success = NO;
                LogDebug(@"Failed to add Keychain item with status: %@", @(status));
            }
        }
    } else if ([self objectForKey:key]) {
        // Delete existing item
        SecItemDelete((__bridge CFDictionaryRef)(authenticationInfo));
        
        if (status != errSecSuccess) {
            success = NO;
            LogDebug(@"Failed to delete Keychain item with status: %@", @(status));
        }
    }
    
    return success;
}

#pragma mark - Keychain access

+ (id)objectForKey:(id)key {
    NSParameterAssert(key);
    
    NSMutableDictionary *authenticationInfo = (NSMutableDictionary *)[self load:KEY_AUTHENTICATIONINFO];
    
    OSStatus status = errSecSuccess;
    CFDataRef dataRef = NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)(authenticationInfo), (CFTypeRef *)&dataRef);
    
    id object = nil;
    if (status == errSecItemNotFound) {
        LogDebug(@"Count not find Keychain item for key '%@'", [key description]);
    } else if (status != errSecSuccess) {
        LogDebug(@"Failed to retrieve Keychain item for key '%@'", [key description]);
    } else if (dataRef != NULL) {
        // Item found
        NSData *data = CFBridgingRelease(dataRef);
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return object;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
}

+ (BOOL)isLogin {
    NSMutableDictionary *authenticationInfo = (NSMutableDictionary *)[self load:KEY_AUTHENTICATIONINFO];
    
    return authenticationInfo[KEY_EXPIRES] ? YES : NO;
}

+ (BOOL)isAuthenticated {
    UserInfoModel *userInfo = [UserInfoModel findUserInfo];
    
    return ![userInfo.verifyStatus isEqual:@0];
}

+ (NSString *)encryptToken {
    NSMutableDictionary *authenticationInfo = (NSMutableDictionary *)[self load:KEY_AUTHENTICATIONINFO];
    NSDate *expires = (NSDate *)authenticationInfo[KEY_EXPIRES];
    if ([expires compare:[NSDate date]] == NSOrderedAscending) {
        //有效期已早于当前日期
        NSString *encryptToken = [authenticationInfo[KEY_TOKEN] stringByAppendingFormat:@"_%.f000", [NSDate date].timeIntervalSince1970];
        encryptToken = [RSA encryptString:encryptToken publicKey:[self getPublicKeyString]];
        [self setObject:encryptToken ForKey:KEY_ENCRYPTTOKEN];
        
        return encryptToken;
    }
    
    return authenticationInfo[KEY_ENCRYPTTOKEN];
}

+ (NSString *)username {
    NSMutableDictionary *authenticationInfo = (NSMutableDictionary *)[self load:KEY_AUTHENTICATIONINFO];

    return authenticationInfo[KEY_USERNAME];
}

+ (NSString *)getPublicKeyString {
//    return @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCJzjkg17+kKo4TNED+RM6hdS5whhgEh4RHwkJ0LtYaCJf4ggF0QjjRYkuNyWha3lvkHX36suImYjyB+rTcYHn6HV7BnEw2BCZAP7GS2sSiupDTWw2kcPb1S7refjfHaEwAYXVZpdjQeNePSCWaSxupkOI/QfuazpcTot9PtMVdBwIDAQAB";
    //必须有头尾信息
    return @"-----BEGIN PUBLIC KEY-----\n"
    "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCJzjkg17+kKo4TNED+RM6hdS5w\n"
    "hhgEh4RHwkJ0LtYaCJf4ggF0QjjRYkuNyWha3lvkHX36suImYjyB+rTcYHn6HV7B\n"
    "nEw2BCZAP7GS2sSiupDTWw2kcPb1S7refjfHaEwAYXVZpdjQeNePSCWaSxupkOI/\n"
    "QfuazpcTot9PtMVdBwIDAQAB\n"
    "-----END PUBLIC KEY-----\n";
}

@end
