//
//  RoomInfoManageViewController.h
//  room107
//
//  Created by ningxia on 15/8/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107ViewController.h"

@interface RoomInfoManageViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;
- (id)initWithImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON;
- (void)setViewControllerDismissHandler:(void(^)())handler;

@end
