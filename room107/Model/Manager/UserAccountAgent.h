//
//  UserAccountAgent.h
//  room107
//
//  Created by Naitong Yu on 15/8/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserAccountInfoModel.h"

@interface UserAccountAgent : NSObject

+ (instancetype)sharedInstance;

/// 获取账户信息
- (void)getAccountInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, UserAccountInfoModel *accountInfoModel))completion;

/// 获取红包信息
- (void)getCouponInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *couponInfo))completion;

/// 获取余额信息
- (void)getBalanceInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *balanceInfo))completion;

/// 获取历史收支
- (void)getHistoryBillsInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *historyBillsInfo))completion;

/// 获取合同历史账单
- (void)getContractHistoryBillsInfoWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *historyBillsInfo))completion;

/// 获取提现信息
- (void)getWithdrawInfoWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *withdrawInfo))completion;

/// 更新用户信息
- (void)updateUserAccountInfoWithName:(NSString *)name
                               idCard:(NSString *)idCard
                            debitCard:(NSString *)debitCard
                         alipayNumber:(NSString *)alipayNumber
                         andPassword:(NSString *)password
                        andCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success))completion;

/// 获取银行信息
- (void)getBankInfoWithBankCardNumber:(NSString *)bankCardNumber completion:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *bankInfo))completion;

/// 提现
- (void)withdrawWithType:(NSInteger)withdrawalType amount:(double)amount password:(NSString *)password completion:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success))completion;

/// 上传头像获取七牛图片token
- (void)getUploadAvatarTokenWithCompletion:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *faviconKey))completion;

/// 上传头像图片上传
- (void)uploadAvatarWithFaviconKey:(NSString *)faviconKey completion:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *faviconImage))completion;

/// 寄送纸质合同
- (void)sendContractWithContractId:(NSNumber *)contractId address:(NSString *)address receiverName:(NSString *)name receiverPhone:(NSString *)phone completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, BOOL success))completion;

@end
