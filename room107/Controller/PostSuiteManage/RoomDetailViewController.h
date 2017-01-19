//
//  RoomDetailViewController.h
//  room107
//
//  Created by ningxia on 15/8/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107ViewController.h"

typedef enum {
    RoomDetailViewTypeNew = 2000, //
    RoomDetailViewTypeManage, //
} RoomDetailViewType;

@interface RoomDetailViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;

- (void)setImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseID:(NSNumber *)houseID andRoom:(NSMutableDictionary *)room andType:(RoomDetailViewType)type;
- (void)setSaveInfoButtonDidClickHandler:(void(^)(NSMutableDictionary *room))handler;
- (void)setCancelButtonDidClickHandler:(void(^)())handler;
- (void)setViewControllerDismissHandler:(void(^)())handler;

@end
