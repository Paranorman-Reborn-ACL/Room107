//
//  UserAccountAgent.m
//  room107
//
//  Created by Naitong Yu on 15/8/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserAccountAgent.h"
#import "Client.h"

@implementation UserAccountAgent

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)getAccountInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserAccountInfoModel *))completion {
    __block UserAccountInfoModel *accountInfoModel = [[UserAccountInfoModel getObjects] firstObject];
//    if (completion && accountInfoModel) {
//        completion(nil, nil, accountInfoModel);
//    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/info") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            LogError(@"错误原因：%@", error);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            } else {
                [accountInfoModel deleteObject];
                accountInfoModel = [UserAccountInfoModel createObjectWithDictionary:response.body[@"accountInfo"]];
            }
            if (completion) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], accountInfoModel);
            }
        }

    }];
    
}

- (void)getCouponInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/coupon") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            LogError(@"错误原因：%@", error);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            }
            if (completion) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body);
            }
        }
    }];
}

- (void)getBalanceInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/balance") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            LogError(@"错误原因：%@", error);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            }
            if (completion) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body);
            }
        }
    }];
}

- (void)getHistoryBillsInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/history") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            LogError(@"错误原因：%@", error);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            }
            if (completion) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body);
            }
        }
    }];
}

/// 获取合同历史账单
- (void)getContractHistoryBillsInfoWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *historyBillsInfo))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (contractID) {
        [parameters setValue:contractID forKey:@"contractId"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/contractHistory") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            LogError(@"错误原因：%@", error);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            }
            if (completion) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body);
            }
        }
    }];
}

- (void)getWithdrawInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/withdrawal") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            LogError(@"错误原因：%@", error);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            }
            if (completion) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body);
            }
        }
    }];
}

- (void)updateUserAccountInfoWithName:(NSString *)name
                               idCard:(NSString *)idCard
                            debitCard:(NSString *)debitCard
                         alipayNumber:(NSString *)alipayNumber
                        andPassword:(NSString *)password
                        andCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success))completion{
    
    password = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:name forKey:@"name"];
    [parameters setValue:idCard forKey:@"idCard"];
    [parameters setValue:debitCard forKey:@"debitCard"];
    [parameters setValue:alipayNumber forKey:@"alipayNumber"];
    [parameters  setValue:password forKey:@"password"];

    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/updateAccountInfo") parameters:parameters completion:^(Response *response, NSError *error) {
        BOOL success = NO;
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], success);
            LogError(@"错误原因：%@", error);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            } else {
                success = YES;
            }
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], success);
        }
    }];
}

- (void)getBankInfoWithBankCardNumber:(NSString *)bankCardNumber completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *))completion {
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:bankCardNumber, @"debitCard", nil];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/getBankInfo") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            LogError(@"错误原因：%@", error);
        } else {
            if (![response.body[@"status"] isEqualToNumber:@0]) {
                LogError(@"未知银行卡识别错误");
            }
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body);
        }
    }];
}

- (void)withdrawWithType:(NSInteger)withdrawalType amount:(double)amount password:(NSString *)password completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL))completion {
    password = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    NSDictionary *parameteters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:withdrawalType], @"type", [NSNumber numberWithDouble:amount], @"amount", password, @"password", nil];
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/withdrawal/submit") parameters:parameteters completion:^(Response *response, NSError *error) {
        BOOL success = NO;
        if (error) {
            LogError(@"%@", error);
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], success);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                LogError(@"错误%@: %@", response.body[@"errorCode"], response.body[@"errorMsg"]);
            } else {
                success = YES;
            }
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], success);
        }
        
    }];
}

- (void)getUploadAvatarTokenWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *faviconKey))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/favicon/getToken") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            LogError(@"%@", error);
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
        } else {
            if (![response.body[@"status"] isEqualToNumber:@0]) {
                LogError(@"获取头像上传token失败！");
            }
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"token"], response.body[@"faviconKey"]);
        }
    }];
}

- (void)uploadAvatarWithFaviconKey:(NSString *)faviconKey completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *faviconImage))completion {
    NSDictionary *parameters = @{@"faviconKey": faviconKey};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/user/favicon/uploadImage") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            LogError(@"%@", error);
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if (![response.body[@"status"] isEqualToNumber:@0]) {
                LogError(@"上传头像写入faviconKey失败！");
            }
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"faviconImage"]);
        }
    }];
}

- (void)sendContractWithContractId:(NSNumber *)contractId address:(NSString *)address receiverName:(NSString *)name receiverPhone:(NSString *)phone completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success))completion {
    if (!contractId) { //contractId为nil时直接失败返回
        completion(nil, nil, nil, NO);
        return;
    }
    NSDictionary *parameters = @{@"contractId": contractId, @"address": address, @"name": name, @"telephone": phone};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/sendContract") parameters:parameters completion:^(Response *response, NSError *error) {
        BOOL success = NO;
        if (error) {
            LogError(@"%@", error);
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], success);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@0]) {
                success = YES;
            }
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], success);
        }
    }];
}

@end
