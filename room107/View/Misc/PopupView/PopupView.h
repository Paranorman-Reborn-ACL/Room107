//
//  PopupView.h
//  room107
//
//  Created by ningxia on 15/7/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView

+ (void)showMessage:(NSString *)message;
+ (void)showTitle:(NSString *)title message:(NSString *)message;

@end
