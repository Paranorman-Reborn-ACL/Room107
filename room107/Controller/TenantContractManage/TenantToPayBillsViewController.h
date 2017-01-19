//
//  TenantToPayBillsViewController.h
//  room107
//
//  Created by ningxia on 15/9/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RentedHouseItemModel.h"

@interface TenantToPayBillsViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;
- (void)setRentedHouseItem:(RentedHouseItemModel *)rentedHouseItem;
- (void)setSubmitPaymentButtonDidClickHandler:(void(^)(NSNumber *amount, NSString *ordersString))handler; //提交最新订单（支付第一步）block回调
- (void)setPayPaymentButtonDidClickHandler:(void(^)(NSNumber *paymentType))handler; //支付（支付第二步）block回调
- (void)setCancelPaymentButtonDidClickHandler:(void(^)())handler; //取消支付（支付第二步）block回调
- (void)setViewLatestBillButtonDidClickHandler:(void(^)())handler;
- (void)showSuccessView;

@end
