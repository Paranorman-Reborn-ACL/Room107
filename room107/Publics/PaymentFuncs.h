//
//  PaymentFuncs.h
//  room107
//
//  Created by ningxia on 16/3/24.
//  Copyright (c) 2016年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WechatPaymentType = 0, //微信支付
    AlipayPaymentType, //支付宝支付
    CMBNetPaymentType = 5, //招行快捷支付
} PaymentType;

@interface PaymentFuncs : NSObject

+ (NSMutableArray *)recommendedPaymentTypes;
+ (NSMutableArray *)allPaymentTypes;

@end