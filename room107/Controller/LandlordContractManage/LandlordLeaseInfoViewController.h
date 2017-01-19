//
//  LandlordLeaseInfoViewController.h
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LandlordHouseItemModel.h"

@interface LandlordLeaseInfoViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;
- (id)initWithLandlordHouseItem:(LandlordHouseItemModel *)landlordHouseItem;

@end
