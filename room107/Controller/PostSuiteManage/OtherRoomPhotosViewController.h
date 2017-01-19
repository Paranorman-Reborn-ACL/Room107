//
//  OtherRoomPhotosViewController.h
//  room107
//
//  Created by ningxia on 15/8/29.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Room107ViewController.h"

typedef enum {
    OtherRoomPhotosViewTypeNew = 2000, //
    OtherRoomPhotosViewTypeManage, //
} OtherRoomPhotosViewType;

@interface OtherRoomPhotosViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;

- (void)setImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON andType:(OtherRoomPhotosViewType)type;
- (void)setSaveInfoButtonDidClickHandler:(void(^)())handler;
- (void)setCancelButtonDidClickHandler:(void(^)())handler;
- (void)setViewControllerDismissHandler:(void(^)())handler;

@end
