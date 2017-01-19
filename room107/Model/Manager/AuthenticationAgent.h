//
//  AuthenticationAgent.h
//  room107
//
//  Created by ningxia on 15/7/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel+CoreData.h"
#import "SubscribeModel+CoreData.h"

@interface AuthenticationAgent : NSObject

+ (instancetype)sharedInstance;

/// 通过手机号检测账户
- (void)detectAccountByPhoneNumber:(NSNumber *)number completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *type, NSString *name))completion;

/// 通过手机号和密码登录
- (void)loginByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 获取当前用户信息
- (void)getUserInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe))completion;
- (UserInfoModel *)getUserInfoFromLocal;
//更新用户的头像URL
- (void)updateUserSetFaviconURL:(NSString *)url;

/// 通过手机号获取验证码
- (void)getVerifyCodeByPhoneNumber:(NSNumber *)number completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 通过手机号、密码和验证码注册
- (void)registerByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 通过手机号、密码和验证码实现第三方登录
- (void)grantByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 通过手机号、密码和验证码设置新密码
- (void)resetPasswordByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 通过新旧手机号、验证码重置新电话号码
- (void)resetPhoneNumberByPhoneNumber:(NSNumber *)newPhoneNumber andUsername:(NSString *)username andToken:(NSString *)token andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *telephoneNumber))completion;

/// 通过邮箱认证
- (void)verifyByEmail:(NSString *)email completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

/// 获取七牛的文件上传token
- (void)getUploadTokenAndCardKeyWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *idCardKey, NSString *workCardKey))completion;

/// 上传证件认证的Key给服务器
- (void)uploadImageWithIDCardKey:(NSString *)idCardKey andWorkCardKey:(NSString *)workCardKey completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *idCardImage, NSString *workCardImage))completion;

///第三方登录参数获取
- (void)getGrantParamsWithOauthPlatform:(NSNumber *)oauthPlatform comlpetion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *params, NSNumber *oauthPlatform)) completion;

///第三方登录
- (void)grantLoginWithOauthPlatform:(NSNumber *)oauthPlatform andCode:(NSString *)code comlpetion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSNumber *hasTelephone, NSString *username)) completion;

///修改第三方绑定
- (void)rebindGrantWithOauthPlatform:(NSNumber *)oauthPlatform andUsername:(NSString *)username andTelePhone:(NSNumber *)telephone andToken:(NSString *)token andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *username))completion;

//绑定第三方账号
- (void)grantBindWithOauthPlatform:(NSNumber *)oauthPlatform andCode:(NSString *)code comlpetion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

@end
