//
//  BalanceAccountView.h
//  room107
//
//  Created by Naitong Yu on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//
//  包括待收款结算和待付款结算两个view，每个view里面有几个大项，大项下有小项，最后一个合计。
//

#import <UIKit/UIKit.h>

@interface BalanceAccountView : UIView

//payMoney: true表示待付款结算，false表示待收款结算

//每个category是一个NSDictionary，每个NSDictionary有两个key，一个是description，对应字符串，表示大项的名称
//另一个key是details，对应一个NSArray，NSArray中每个元素是NSDictionary，有两个key，descripiton表示小项名称，amount表示钱数。

//dueTime: 表示付款到期日或者是预计到款日

- (instancetype)initWithFrame:(CGRect)frame payMoney:(BOOL)payMoney categories:(NSArray *)categories andDueTime:(NSDate *)dueTime;

@end
