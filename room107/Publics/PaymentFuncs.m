//
//  PaymentFuncs.m
//  room107
//
//  Created by ningxia on 16/3/24.
//  Copyright (c) 2016年 107room. All rights reserved.
//

#import "PaymentFuncs.h"
#import "SystemAgent.h"

@implementation PaymentFuncs

+ (NSMutableArray *)recommendedPaymentTypes {
    NSMutableArray *recommendedPaymentTypes = [[NSMutableArray alloc] init];
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    if (appProperties) {
        for (NSNumber *paymentType in [appProperties iosRecommendPaymentTypes]) {
            NSMutableDictionary *payment = nil;
            switch ([paymentType intValue]) {
                case WechatPaymentType:
                    payment = [self wechatPayPayment];
                    break;
                case AlipayPaymentType:
                    payment = [self alipayPayPayment];
                    break;
                case CMBNetPaymentType:
                    payment = [self CMBPayment];
                    break;
                default:
                    break;
            }
            
            if (payment) {
                [recommendedPaymentTypes addObject:payment];
            }
        }
    }
    
    if (recommendedPaymentTypes.count == 0) {
        [recommendedPaymentTypes addObject:[self wechatPayPayment]];
    }
    [recommendedPaymentTypes[0] setObject:@YES forKey:@"selected"];
    
    return recommendedPaymentTypes;
}

+ (NSMutableArray *)allPaymentTypes {
    NSMutableArray *allPaymentTypes = [[NSMutableArray alloc] init];
    AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
    if (appProperties) {
        for (NSNumber *paymentType in [appProperties iosPaymentTypes]) {
            NSMutableDictionary *payment = nil;
            switch ([paymentType intValue]) {
                case WechatPaymentType:
                    payment = [self wechatPayPayment];
                    break;
                case AlipayPaymentType:
                    payment = [self alipayPayPayment];
                    break;
                case CMBNetPaymentType:
                    payment = [self CMBPayment];
                    break;
                default:
                    break;
            }
            
            if (payment) {
                NSArray *iosRecommendPaymentTypes = [appProperties iosRecommendPaymentTypes];
                if (iosRecommendPaymentTypes && [iosRecommendPaymentTypes count] > 0) {
                    if ([iosRecommendPaymentTypes[0] isEqual:payment[@"paymentType"]]) {
                        [payment setObject:@YES forKey:@"selected"];
                    }
                }
                [allPaymentTypes addObject:payment];
            }
        }
    }
    
    if (allPaymentTypes.count == 0) {
        [allPaymentTypes addObject:[self wechatPayPayment]];
        [allPaymentTypes addObject:[self alipayPayPayment]];
        [allPaymentTypes addObject:[self CMBPayment]];
        [allPaymentTypes[0] setObject:@YES forKey:@"selected"];
    }
    
    return allPaymentTypes;
}

+ (NSMutableDictionary *)wechatPayPayment {
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:WechatPaymentType], @"paymentType", @"weChat.png", @"imageName", lang(@"WechatPay"), @"title", @NO, @"selected", nil];
}

+ (NSMutableDictionary *)alipayPayPayment {
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:AlipayPaymentType], @"paymentType", @"Alipay.png", @"imageName", lang(@"AlipayPay"), @"title", @NO, @"selected", nil];
}

+ (NSMutableDictionary *)CMBPayment {
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:CMBNetPaymentType], @"paymentType", @"CMB.png", @"imageName", lang(@"CMPPay"), @"title", @NO, @"selected", nil];
}

@end
