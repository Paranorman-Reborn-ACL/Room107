//
//  BasicInfoView.h
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BasicInfoViewTypeName = 0, //名称
    BasicInfoViewTypeArea = 1, //面积
    BasicInfoViewTypeFloor = 2, //楼层
    BasicInfoViewTypeOrientation = 3  //朝向
} BasicInfoViewType;

@interface BasicInfoView : UIView

- (void)setContent:(NSString *)content withType:(BasicInfoViewType)type;

@end
