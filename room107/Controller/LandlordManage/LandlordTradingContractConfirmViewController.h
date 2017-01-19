//
//  LandlordTradingContractConfirmViewController.h
//  room107
//
//  Created by ningxia on 15/9/9.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserIdentityModel.h"
#import "ContractInfoModel.h"
#import "Room107ViewController.h"

@interface LandlordTradingContractConfirmViewController : Room107ViewController

- (void)setContractInfo:(ContractInfoModel *)contractInfo andDifferent:(NSArray *)diff;
- (void)setConfirmContractButtonDidClickHandler:(void(^)(UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSNumber *contractStatus))handler;
- (void)setChangeContractButtonDidClickHandler:(void(^)())handler;

@end
