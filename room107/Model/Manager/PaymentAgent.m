//
//  PaymentAgent.m
//  room107
//
//  Created by ningxia on 15/9/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "PaymentAgent.h"

@implementation PaymentAgent

+ (instancetype)sharedInstance {
    static PaymentAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)submitAccountPaymentWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/payment/submit") parameters:info completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    [PaymentInfoModel deletePaymentInfos];
                    PaymentInfoModel *paymentInfo = [PaymentInfoModel createObjectWithDictionary:response.body[@"payment"]];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], paymentInfo);
                }
            }
        }
    }];
}

- (void)payAccountPaymentWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSDictionary *params, NSNumber *paymentType))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/payment/pay") parameters:info completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil);
                } else {
                    [PaymentInfoModel deletePaymentInfos];
                    PaymentInfoModel *paymentInfo = [PaymentInfoModel createObjectWithDictionary:response.body[@"payment"]];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], paymentInfo, response.body[@"params"], response.body[@"paymentType"]);
                }
            }
        }
    }];
}

/// 取消付款单
- (void)cancelAccountPaymentWithPaymentID:(NSNumber *)paymentId completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo))completion {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:paymentId, @"paymentId", nil];
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/payment/cancel") parameters:info completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    [PaymentInfoModel deletePaymentInfos];
                    PaymentInfoModel *paymentInfo = [PaymentInfoModel createObjectWithDictionary:response.body[@"payment"]];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], paymentInfo);
                }
            }
        }
    }];
}

/// 查询付款状态(付款页面点付款完成/遇到问题时使用)
- (void)statusAccountPaymentWithPaymentID:(NSNumber *)paymentId andPaymentType:(NSNumber *)paymentType completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSNumber *paymentType))completion {
    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:paymentId, @"paymentId", nil];
    [info setObject:paymentType forKey:@"paymentType"];
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/payment/status") parameters:info completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
                } else {
                    [PaymentInfoModel deletePaymentInfos];
                    PaymentInfoModel *paymentInfo = [PaymentInfoModel createObjectWithDictionary:response.body[@"payment"]];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], paymentInfo, response.body[@"paymentType"]);
                }
            }
        }
    }];
}

- (void)payRapidVerifyWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, PaymentInfoModel *paymentInfo, NSDictionary *params, NSNumber *paymentType))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/payment/payRapidVerify") parameters:info completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil);
                } else {
                    [PaymentInfoModel deletePaymentInfos];
                    PaymentInfoModel *paymentInfo = [PaymentInfoModel createObjectWithDictionary:response.body[@"payment"]];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], paymentInfo, response.body[@"params"], response.body[@"paymentType"]);
                }
            }
        }
    }];
}

@end
