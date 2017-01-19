//
//  RoomInfoFillInViewController.h
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107ViewController.h"

@interface RoomInfoFillInViewController : Room107ViewController

- (void)setImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON andHouseKeysArray:(NSArray *)houseKeysArray;
- (void)setPrevStepButtonDidClickHandler:(void(^)())handler;
- (void)setPostSuiteButtonDidClickHandler:(void(^)())handler;

@end
