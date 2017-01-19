//
//  SignedProcessAgent.h
//  room107
//
//  Created by ningxia on 15/8/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserIdentityModel+CoreData.h"
#import "ContractInfoModel+CoreData.h"

/**
 enum ContractStatus {
 * EDITING: before contract signed
 * EXECUTING: contract signed, not finished
 * TERMINATED: contract finished, including terminated time passed and orders finished.
 * CLOSE_BY_LANDLORD: contract refused by landlord
 * CLOSE_BY_TENANT: contract refused by tenant
 * CLOSE_BY_ADMIN: contract refused by 107room admin
 * BREAK: contract broke, can transform to TERMINATED after paid all orders.
 EDITING, //签约中
 EXECUTING, //签约生效
 TERMINATED,
 CLOSE_BY_LANDLORD, //房东终止流程
 CLOSE_BY_TENANT, //租客终止流程
 CLOSE_BY_ADMIN, //审核彻底失败
 BROKE;
}
*/

/**
 enum ContractEditStatus {
 
 FILLING, CONFIRMING, AUDITING, AUDIT_ACCEPT, AUDIT_REFUSED, DELETED
 
 }
*/

/**
 * @class SignedProcessAgent
 *
 * @brief 签约流程Agent类
 *
 *
 */
@interface SignedProcessAgent : NSObject

+ (instancetype)sharedInstance;

///获取租客租住日期
- (void)tenantGetContractPeriodWithCheckTime:(NSString *)checkTime andExitTime:(NSString *)exitTime completion:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode,NSNumber *contractStatus, NSNumber *year, NSNumber *month, NSNumber *day, NSString *finishDate, NSString *title, NSString *content))completion;

/// 租客获取合同状态
- (void)tenantGetContractStatusWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID andContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSArray *diff, NSString *auditNote))completion;

/// 租客上传合同信息
- (void)tenantUpdateContractWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion;

/// 租客确认合同信息
- (void)tenantConfirmContractWithContractID:(NSNumber *)contractID andPassword:(NSString *)password completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion;

/// 租客续租（跳转到租客签约流程中）
- (void)tenantReletContractWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion;

/// 房东获取合同状态
- (void)landlordGetContractStatusWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSArray *diff, NSString *auditNote))completion;

/// 房东上传合同信息
- (void)landlordUpdateContractWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion;

/// 房东确认合同信息
- (void)landlordConfirmContractWithContractID:(NSNumber *)contractID andPassword:(NSString *)password andInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion;

/// 房东拒绝签约请求
- (void)landlordDiscardContractWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion;

@end
