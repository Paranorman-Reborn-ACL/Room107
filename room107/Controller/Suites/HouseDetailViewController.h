//
//  HouseDetailViewController.h
//  room107
//
//  Created by ningxia on 15/12/28.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107ViewController.h"
#import "ItemModel.h"

@interface HouseDetailViewController : Room107ViewController

- (void)setItem:(ItemModel *)item;
- (void)setHouseInterestHandler:(void(^)(NSNumber *isInterest))handler;

@end
