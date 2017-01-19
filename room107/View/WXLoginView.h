//
//  WXLoginView.h
//  room107
//
//  Created by 107间 on 16/3/24.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXLoginView : UIView

@property (nonatomic, copy) void(^wechatLogin)(void);

@end
