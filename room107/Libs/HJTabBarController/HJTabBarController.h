//
//  HJTabBarController.h
//
//
//  Created by http://weibo.com/hanjunzhao  on 16/01/04.
//  Copyright (c) 2016年  https://github.com/CoderHJZhao . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJTabBarController : UITabBarController

#warning 如果设置中间的加号按钮，则这一个属性千万不要忘记设置
/** 设置点击加号按钮 present 出来的控制器*/
@property (nonatomic, strong) UIViewController *presentVc;

/** tabBar背景图片，没有则不用设置*/
@property (nonatomic, strong) UIImage *tabBarBackRoundImage;

/** 添加控制器，设置tabbar的属性 */
- (void)addChildViewControllers:(NSArray *)childViewControllers titles:(NSArray *)titles titleColor:(UIColor *)titleColor selectedTitleColor:(UIColor *)selectedTitleColor imageNames:(NSArray *)imageNames selectedImageNames:(NSArray *)selectedImageNames haveNavigationBar:(BOOL)haveNavigationBar;

/** 添加中间加号按钮（可按需求定义成其他功能的按钮）） */
- (void)tabBarPlusButtonImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName;
/** 添加中间加号按钮（可按需求定义成其他功能的按钮））的说明text */
- (void)tabBarPlusLabelText:(NSString *)text andTextColor:(UIColor *)textColor;

/** 设置中间按钮点击的Block，交由AppDelegate处理 */
- (void)setCenterButtonDidClickHandler:(void(^)())handler;

@end
