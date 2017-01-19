//
//  NXTextSwitch.h
//  room107
//
//  Created by ningxia on 15/7/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXTextSwitch : UIView

- (void)setTitle:(NSString *)title;
- (BOOL)isOn;
- (void)setOn:(BOOL)isOn;
- (void)setSwitchActionHandler:(void(^)(BOOL isOn))handler;

@end
