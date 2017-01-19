//
//  HouseInfoFillInViewController.h
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HouseInfoFillInViewController : Room107ViewController

- (void)setDistrict2UserCount:(NSDictionary *)district2UserCount andTelephone:(NSString *)telephone andImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON andHouseKeysArray:(NSArray *)houseKeysArray;
- (void)setVerifyInfoButtonDidClickHandler:(void(^)())handler;

@end
