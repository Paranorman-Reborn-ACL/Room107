//
//  LandlordToPayBillsViewController.h
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LandlordHouseItemModel.h"

@interface LandlordToPayBillsViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;
- (void)setLandlordHouseItem:(LandlordHouseItemModel *)landlordHouseItem;
- (void)setSubmitPaymentButtonDidClickHandler:(void(^)(NSNumber *amount, NSString *ordersString))handler;
- (void)setPayPaymentButtonDidClickHandler:(void(^)(NSNumber *paymentType))handler;
- (void)setCancelPaymentButtonDidClickHandler:(void(^)())handler;
- (void)setViewLatestBillButtonDidClickHandler:(void(^)())handler;
- (void)showSuccessView;

@end
