//
//  AuthenticationAgent.m
//  room107
//
//  Created by ningxia on 15/7/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "AuthenticationAgent.h"
#import "RSA.h"
#import "SystemAgent.h"
#import "Room107UserDefaults.h"
#import "HouseListItemModel+CoreData.h"

@implementation AuthenticationAgent

+ (instancetype)sharedInstance {
    static AuthenticationAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)rebindGrantWithOauthPlatform:(NSNumber *)oauthPlatform andUsername:(NSString *)username andTelePhone:(NSNumber *)telephone andToken:(NSString *)token andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *username))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (telephone) {
        [parameters setObject:telephone forKey:@"telephone"];
    }
    if (verifyCode) {
        [parameters setObject:verifyCode forKey:@"verifyCode"];
    }
    if (username) {
        [parameters setObject:username forKey:@"username"];
    }
    if (token) {
        NSString *encryptToken = [token stringByAppendingFormat:@"_%.f000", [NSDate date].timeIntervalSince1970];
        encryptToken = [RSA encryptString:encryptToken publicKey:[Room107UserDefaults getPublicKeyString]];
        [parameters setObject:encryptToken forKey:@"token"];
    }
    if (oauthPlatform) {
        [parameters setObject:oauthPlatform forKey:@"oauthPlatform"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/oauth/rebind") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"token"], response.body[@"username"]);
                    if ([response.body[@"hasTelephone"] isEqual:@0]) {
                        
                    } else {
                        [self saveAccountInfoWithUsername:response.body[@"username"] andTelephone:nil andToken:response.body[@"token"]];
                    }
                }
            }
        }
    }];
}

- (void)grantLoginWithOauthPlatform:(NSNumber *)oauthPlatform andCode:(NSString *)code comlpetion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSNumber *hasTelephone, NSString *username))completion {
    NSDictionary *parameters = @{@"oauthPlatform":oauthPlatform, @"code":code};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/oauth/login") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"token"], response.body[@"hasTelephone"], response.body[@"username"]);
                    if ([response.body[@"hasTelephone"] isEqual:@0]) {
                        
                    } else {
                        [self saveAccountInfoWithUsername:response.body[@"username"] andTelephone:nil andToken:response.body[@"token"]];
                    }
                }
            }
        }
    }];
}


- (void)getGrantParamsWithOauthPlatform:(NSNumber *)oauthPlatform comlpetion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *params, NSNumber *oauthPlatform))completion {
    //oauthPlatform表示第三方登录类型，qq(0), weibo(1), douban(2), wechat(3)
    NSDictionary *parameters = @{@"oauthPlatform":oauthPlatform};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/oauth/params") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"params"], response.body[@"oauthPlatform"]);
                }
            }
        }
    }];
}

- (void)grantBindWithOauthPlatform:(NSNumber *)oauthPlatform andCode:(NSString *)code comlpetion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSDictionary *parameters = @{@"oauthPlatform":oauthPlatform, @"code":code};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/oauth/bind") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                }
            }
        }
    }];
}

- (void)detectAccountByPhoneNumber:(NSNumber *)number completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *type, NSString *name))completion {
    NSDictionary *parameters = @{@"telephone":number};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/detect") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"type"], response.body[@"name"]);
                }
            }
        }
    }];
}

- (void)loginByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSString *encryptPassword = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (number) {
        [parameters setObject:number forKey:@"username"];
    }
    if (encryptPassword) {
        [parameters setObject:encryptPassword forKey:@"password"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/login") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                    
                    [self saveAccountInfoWithUsername:nil andTelephone:[number stringValue] andToken:response.body[@"token"]];
                    
                    [[AuthenticationAgent sharedInstance] getUserInfoWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe) {
                        if (errorTitle || errorMsg) {
                            [PopupView showTitle:errorTitle message:errorMsg];
                        }
                
                        if (!errorCode) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:ClientAuthenticationStateDidChangeNotification object:self];
                        }
                    }];
                }
            }
        }
    }];
}

- (void)getUserInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserInfoModel *userInfo, SubscribeModel *subscribe))completion {    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/getInfo") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
                } else {
                    [UserInfoModel deleteUserInfo];
                    UserInfoModel *userInfo = [UserInfoModel createObjectWithDictionary:response.body[@"user"]];
                    [Room107UserDefaults saveUserDefaultsWithKey:KEY_USERNAME andValue:userInfo.username];
                    [Room107UserDefaults saveUserDefaultsWithKey:KEY_TELEPHONE andValue:userInfo.telephone];
                    
                    SubscribeModel *subscribe;
                    if (response.body[@"subscribe"]) {
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:response.body[@"subscribe"]];
                        [dic setValue:platformKey forKey:@"username"];
                        subscribe = [SubscribeModel createObjectWithDictionary:dic];
                    } else {
                        subscribe = [SubscribeModel createObjectWithDictionary:response.body[@"subscribe"]];
                    }
                    
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], userInfo, subscribe);
                }
            }
        }
    }];
}

- (UserInfoModel *)getUserInfoFromLocal {
    return [UserInfoModel findUserInfo];
}

- (void)updateUserSetFaviconURL:(NSString *)url {
    UserInfoModel *userInfo = [self getUserInfoFromLocal];
    if (userInfo) {
        [UserInfoModel updateUserSetFaviconURL:url byID:[userInfo.id longLongValue]];
    }
}

- (void)getVerifyCodeByPhoneNumber:(NSNumber *)number completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSDictionary *parameters = @{@"telephone":number};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/verifyCode") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                }
            }
        }
    }];
}

- (void)registerByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    password = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (number) {
        [parameters setObject:number forKey:@"username"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    if (verifyCode) {
        [parameters setObject:verifyCode forKey:@"verifyCode"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/register") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    NSArray *invalidInputs = response.body[@"invalidInputs"];
                    [invalidInputs containsObject:@"verifyCode"];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                    
                    [self saveAccountInfoWithUsername:nil andTelephone:[number stringValue]  andToken:response.body[@"token"]];
                }
            }
        }
    }];
}

- (void)grantByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    password = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (number) {
        [parameters setObject:number forKey:@"username"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    if (verifyCode) {
        [parameters setObject:verifyCode forKey:@"verifyCode"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/grant") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    NSArray *invalidInputs = response.body[@"invalidInputs"];
                    [invalidInputs containsObject:@"verifyCode"];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                    
                    [self saveAccountInfoWithUsername:nil andTelephone:[number stringValue] andToken:response.body[@"token"]];
                }
            }
        }
    }];
}

- (void)resetPasswordByPhoneNumber:(NSNumber *)number andPassword:(NSString *)password andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    password = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (number) {
        [parameters setObject:number forKey:@"username"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    if (verifyCode) {
        [parameters setObject:verifyCode forKey:@"verifyCode"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/resetPassword") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    NSArray *invalidInputs = response.body[@"invalidInputs"];
                    [invalidInputs containsObject:@"verifyCode"];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                    
                    [self saveAccountInfoWithUsername:nil andTelephone:[number stringValue] andToken:response.body[@"token"]];
                }
            }
        }
    }];
}

- (void)resetPhoneNumberByPhoneNumber:(NSNumber *)newPhoneNumber andUsername:(NSString *)username andToken:(NSString *)token andVerifyCode:(NSString *)verifyCode completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *telephoneNumber))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (newPhoneNumber) {
        [parameters setObject:newPhoneNumber forKey:@"telephone"];
    }
    if (verifyCode) {
        [parameters setObject:verifyCode forKey:@"verifyCode"];
    }
    if (username) {
        [parameters setObject:username forKey:@"username"];
    }
    if (token) {
        NSString *encryptToken = [token stringByAppendingFormat:@"_%.f000", [NSDate date].timeIntervalSince1970];
        encryptToken = [RSA encryptString:encryptToken publicKey:[Room107UserDefaults getPublicKeyString]];
        [parameters setObject:encryptToken forKey:@"token"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/resetTelephone") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    NSArray *invalidInputs = response.body[@"invalidInputs"];
                    [invalidInputs containsObject:@"verifyCode"];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"telephone"]);
                    
                    [Room107UserDefaults saveUserDefaultsWithKey:KEY_TELEPHONE andValue:response.body[@"telephone"]];
                    if (token) {
                        [self saveAccountInfoWithUsername:nil andTelephone:response.body[@"telephone"] andToken:token];
                    }
                }
            }
        }
    }];
}

- (void)saveAccountInfoWithUsername:(NSString *)username andTelephone:(NSString *)telephone andToken:(NSString *)token {
    [Room107UserDefaults clearUserDefaults];
    [[SystemAgent sharedInstance] getPropertiesFromServer];
    [[SystemAgent sharedInstance] getTextPropertiesFromServer];
    [[SystemAgent sharedInstance] getPopupPropertiesFromServer];
    
    NSString *encryptToken = [token stringByAppendingFormat:@"_%.f000", [NSDate date].timeIntervalSince1970];
    encryptToken = [RSA encryptString:encryptToken publicKey:[Room107UserDefaults getPublicKeyString]];
    [Room107UserDefaults saveUserDefaultsWithKey:KEY_TOKEN andValue:token];
    [Room107UserDefaults saveUserDefaultsWithKey:KEY_ENCRYPTTOKEN andValue:encryptToken];
    if (username) {
        [Room107UserDefaults saveUserDefaultsWithKey:KEY_USERNAME andValue:username];
    }
    if (telephone) {
        [Room107UserDefaults saveUserDefaultsWithKey:KEY_TELEPHONE andValue:telephone];
    }
    [Room107UserDefaults saveUserDefaultsWithKey:KEY_EXPIRES andValue:[NSDate dateWithTimeIntervalSinceNow:periodOfExpires]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ClientDidLoginNotification object:self];
}

- (void)verifyByEmail:(NSString *)email completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSDictionary *parameters = @{@"email":email};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/verify/email") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            }
        }
    }];
}

- (void)getUploadTokenAndCardKeyWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *idCardKey, NSString *workCardKey))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/verify/getToken") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"token"], response.body[@"idCardKey"], response.body[@"workCardKey"]);
                }
            }
        }
    }];
}

- (void)uploadImageWithIDCardKey:(NSString *)idCardKey andWorkCardKey:(NSString *)workCardKey completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *idCardImage, NSString *workCardImage))completion {
    NSDictionary *parameters = @{@"idCardKey":idCardKey, @"workCardKey":workCardKey};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/verify/uploadImage") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"idCardImage"], response.body[@"workCardImage"]);
                }
            }
        }
    }];
}

@end
