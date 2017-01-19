//
//  WithdrawDebitCardView.h
//  room107
//
//  Created by Naitong Yu on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WithdrawDebitCardewDelegate <NSObject>

- (void)withdrawDebitCardViewClickConfirmButton;

@end
@interface WithdrawDebitCardView : UIView

@property (nonatomic, weak) Room107ViewController *controller; //该view所在的controller

@property (nonatomic) double maxWithdrawAmount; //最多提现金额
@property (nonatomic) BOOL hasCreditCard; //是否有银行卡

@property (nonatomic) NSString *name; //姓名
@property (nonatomic) NSString *idCard; //身份证号
@property (nonatomic) NSString *debitCard; //银行卡号
@property (nonatomic) NSString *bankImage; //银行卡图标
@property (nonatomic) NSString *bankName; //银行名称

@property (nonatomic,weak) id<WithdrawDebitCardewDelegate>delegate;

@property (nonatomic, copy) void (^clickDebit)(void);
@end
