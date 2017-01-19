//
//  LandlordTradingFillInViewController.h
//  room107
//
//  Created by ningxia on 15/9/9.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContractInfoModel.h"

@interface LandlordTradingFillInViewController : Room107ViewController

- (void)setContractInfo:(ContractInfoModel *)contractInfo;
- (void)setVerifyButtonDidClickHandler:(void(^)())handler;

@end
