//
//  TenantPendingChargesViewController.h
//  room107
//
//  Created by ningxia on 15/9/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RentedHouseItemModel.h"

@interface TenantPendingChargesViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;
- (id)initWithRentedHouseItem:(RentedHouseItemModel *)rentedHouseItem;

@end
