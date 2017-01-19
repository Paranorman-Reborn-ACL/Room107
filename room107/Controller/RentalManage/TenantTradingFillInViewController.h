//
//  TenantTradingFillInViewController.h
//  room107
//
//  Created by ningxia on 15/9/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContractInfoModel.h"
#import "Room107ViewController.h"

@interface TenantTradingFillInViewController : Room107ViewController

- (void)setContractInfo:(ContractInfoModel *)contractInfo;
- (void)setVerifyButtonDidClickHandler:(void(^)())handler;

@end
