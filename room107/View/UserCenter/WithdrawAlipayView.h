//
//  WithdrawAlipayView.h
//  room107
//
//  Created by Naitong Yu on 15/9/23.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WithdrawAlipayViewDelegate <NSObject>

- (void)withdrawAlipayViewClickConfirmButton;

@end
@interface WithdrawAlipayView : UIView

@property (nonatomic, weak) Room107ViewController *controller; //该view所在的controller

@property (nonatomic) double maxWithdrawAmount; //最多提现金额
@property (nonatomic) BOOL hasAlipay; //是否有支付宝

@property (nonatomic) NSString *name; //姓名
@property (nonatomic) NSString *idCard; //身份证号
@property (nonatomic) NSString *alipayNumber; //支付宝帐号

@property (nonatomic,weak) id<WithdrawAlipayViewDelegate> delegate;

@property (nonatomic, copy) void(^clickAliPay)(void);

@end
