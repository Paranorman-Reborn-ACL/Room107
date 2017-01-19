//
//  WalletView.h
//  room107
//
//  Created by 107间 on 16/3/29.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    WalletType= 2000, // 钱包页
    CouponType, //红包页
    BalanceType,//余额页
} WalletViewType;

@interface WalletView : UIView

- (void)setAmount:(NSNumber *)amount; //设置钱包总额
- (void)setCouponBag:(NSNumber *)coupon;//红包总额
- (void)setcouponNewUpdate:(NSNumber *)couponNewUpdate;//红包小红点
- (void)setBalance:(NSNumber *)balance;//余额总额
- (void)setbalanceNewUpdate:(NSNumber *)balanceNewUpdate;//余额小红点
- (void)settapCouponHandler:(void (^)(void))tapCouponHandler;
- (void)settapBalanceHandler:(void (^)(void))tapBalanceHandler;
//若为余额页 则重新刷新UI 俩模块变成3模块
- (void)setTotalBalance:(NSNumber *)totalBalance;  //历史总额
- (void)setexpenses:(NSNumber *)expenses;          //已用金额
- (void)setwithdrawal:(NSNumber *)withdrawal;      //提现金额
@property (nonatomic, assign) WalletViewType walletViewType;
@end
