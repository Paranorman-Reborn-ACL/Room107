//
//  WithdrawInfo.h
//  room107
//
//  Created by 107间 on 15/12/14.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WithdrawInfo : NSObject

@property (nonatomic, copy) NSNumber *balance; //余额
@property (nonatomic, copy) NSString *debitCard; //银行卡号
@property (nonatomic, copy) NSString *alipayNumber; //支付宝帐号
@property (nonatomic, copy) NSString *name;  //姓名
@property (nonatomic, copy) NSString *idCard; //身份证号
@property (nonatomic, copy) NSString *bankImage; //银行icon
@property (nonatomic, copy) NSString *bankName; //银行名称

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key ;

@end
