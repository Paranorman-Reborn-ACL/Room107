//
//  PaymentAgent.h
//  room107
//
//  Created by ningxia on 15/9/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentInfoModel+CoreData.h"

@interface PaymentAgent : NSObject

+ (instancetype)sharedInstance;

/// 提交订单，生成付款单
- (void)submitAccountPaymentWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo))completion;

/// 支付付款单  PaymentType : WECHAT_MOBILE_PAY, ALI_MOBILE_PAY, EMPTY, ALI_WEB_PAY, ALI_EBANK_PAY;
- (void)payAccountPaymentWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSDictionary *params, NSNumber *paymentType))completion;

/// 取消付款单
- (void)cancelAccountPaymentWithPaymentID:(NSNumber *)paymentId completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo))completion;

/// 查询付款状态(付款页面点付款完成/遇到问题时使用)
- (void)statusAccountPaymentWithPaymentID:(NSNumber *)paymentId andPaymentType:(NSNumber *)paymentType completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSNumber *paymentType))completion;

/*
极速认证支付
amount， 付款金额，必填
paymentType，支付类型，见PaymentType，必填
ip，必填
*/
- (void)payRapidVerifyWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSDictionary *params, NSNumber *paymentType))completion;

@end
