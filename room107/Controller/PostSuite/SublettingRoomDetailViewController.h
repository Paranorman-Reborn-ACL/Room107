//
//  SublettingRoomDetailViewController.h
//  room107
//
//  Created by ningxia on 15/9/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107ViewController.h"

typedef enum {
    SublettingRoomDetailViewTypeNew = 2000, //发房页面
    SublettingRoomDetailViewTypeManage, //房子管理页面
} SublettingRoomDetailViewType;

// 分租
@interface SublettingRoomDetailViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;

- (void)setImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseID:(NSNumber *)houseID andRoom:(NSMutableDictionary *)room andType:(SublettingRoomDetailViewType)type;
- (void)setSaveInfoButtonDidClickHandler:(void(^)(NSMutableDictionary *room))handler;
- (void)setCancelButtonDidClickHandler:(void(^)())handler;
- (void)setViewControllerDismissHandler:(void(^)())handler;

@end
