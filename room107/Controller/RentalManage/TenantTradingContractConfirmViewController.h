//
//  TenantTradingContractConfirmViewController.h
//  room107
//
//  Created by ningxia on 15/9/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContractInfoModel.h"

@interface TenantTradingContractConfirmViewController : Room107ViewController

- (void)setContractInfo:(ContractInfoModel *)contractInfo andDifferent:(NSArray *)diff;
- (void)setConfirmContractButtonDidClickHandler:(void(^)())handler;
- (void)setChangeContractButtonDidClickHandler:(void(^)())handler;

@end
