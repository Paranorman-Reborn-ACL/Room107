//
//  TradingAuditStatusViewController.h
//  room107
//
//  Created by ningxia on 15/9/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TradingAuditStatusViewController : Room107ViewController

@property (nonatomic) NSInteger status; //审核状态：0、正在审核中；1、审核成功；2、审核失败，3、审核彻底失败
@property (nonatomic, getter=isRent) BOOL rent; // YES:该页面展示给租户； NO: 该页面展示给房东
- (void)setAuditNote:(NSString *)auditNote;
- (void)setManageButtonDidClickHandler:(void(^)())handler;
- (void)setChangeContractButtonDidClickHandler:(void(^)())handler;
- (void)setSendContractButtonDidClickHandler:(void (^)())handler;

@end
