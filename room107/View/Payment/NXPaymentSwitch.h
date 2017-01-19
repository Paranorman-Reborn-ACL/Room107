//
//  NXPaymentSwitch.h
//  room107
//
//  Created by ningxia on 16/3/29.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXPaymentSwitch : UIView

- (id)initWithFrame:(CGRect)frame withSwitch:(BOOL)hasSwitch;
- (void)setIconText:(NSString *)text;
- (void)setTitle:(NSString *)title;
- (void)setContent:(NSString *)content;
- (BOOL)isOn;
- (void)setOn:(BOOL)isOn;
- (void)setSwitchActionHandler:(void(^)(BOOL isOn))handler;
- (void)setIconColor:(UIColor *)color;

@end
