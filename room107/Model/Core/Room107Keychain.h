//
//  Room107Keychain.h
//  room107
//
//  Created by ningxia on 15/7/13.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

//用户登录态
//static NSString * const KEY_AUTHENTICATIONINFO = @"com.107room.app.authentication";
//static NSString * const KEY_USERNAME = @"com.107room.app.username";
//static NSString * const KEY_TOKEN = @"com.107room.app.token";
//static NSString * const KEY_ENCRYPTTOKEN = @"com.107room.app.encrypttoken";
//static NSString * const KEY_EXPIRES = @"com.107room.app.expires";
//static NSInteger periodOfExpires = 7 * 24 * 60 * 60;

@interface Room107Keychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (BOOL)setObject:(id<NSCoding>)object ForKey:(id)key;
+ (void)delete:(NSString *)service;
+ (BOOL)isLogin;
+ (BOOL)isAuthenticated;
+ (NSString *)getPublicKeyString;
+ (NSString *)encryptToken;
+ (NSString *)username;

@end
