//
//  HJTabBarController.h
//
//
//  Created by http://weibo.com/hanjunzhao  on 16/01/04.
//  Copyright (c) 2016年  https://github.com/CoderHJZhao . All rights reserved.
//

#import "HJTabBarController.h"
#import "HJTabBar.h"
#import <objc/runtime.h>

#define CFColor(r,g,b)  [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
@interface HJTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, strong) HJTabBar *customTabBar;
@property (nonatomic, strong) void (^centerButtonClickHandlerBlock)();

@end

@implementation HJTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
}

- (void)setTabBarBackRoundImage:(UIImage *)tabBarBackRoundImage {
    _tabBarBackRoundImage = tabBarBackRoundImage;
    self.tabBar.backgroundImage = [_tabBarBackRoundImage resizableImageWithCapInsets:UIEdgeInsetsMake(_tabBarBackRoundImage.size.height/2, _tabBarBackRoundImage.size.width/2, _tabBarBackRoundImage.size.height/2 - 1 , _tabBarBackRoundImage.size.width/2 - 1)];
}

- (void)setPresentVc:(UIViewController *)presentVc {
    objc_setAssociatedObject(self, @selector(presentVc), presentVc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)presentVc {
    return objc_getAssociatedObject(self, @selector(presentVc));
}

- (void)tabBarPlusButtonImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    //更换系统自带的tabbar
    if (!_customTabBar) {
        _customTabBar = [[HJTabBar alloc] init];
        [self setValue:_customTabBar forKeyPath:@"tabBar"];
    }
    [_customTabBar addImageName:imageName selectedImageName:selectedImageName];
}

- (void)tabBarPlusLabelText:(NSString *)text andTextColor:(UIColor *)textColor {
    //更换系统自带的tabbar
    if (!_customTabBar) {
        _customTabBar = [[HJTabBar alloc] init];
        [self setValue:_customTabBar forKeyPath:@"tabBar"];
    }
    [_customTabBar setPlusLabelText:text andTextColor:textColor];
}

/** 添加控制器，设置tabbar的属性 */
- (void)addChildViewControllers:(NSArray *)childViewControllers titles:(NSArray *)titles titleColor:(UIColor *)titleColor selectedTitleColor:(UIColor *)selectedTitleColor imageNames:(NSArray *)imageNames selectedImageNames:(NSArray *)selectedImageNames haveNavigationBar:(BOOL)haveNavigationBar {
    CGFloat itemImageWidth = 22;
    for (NSInteger i = 0; i < titles.count; i++) {
        UIViewController *childViewController = childViewControllers[i];
        // 设置子控制器的图片，需要至少2x的图片，避免单倍图片被拉伸
        childViewController.tabBarItem.image = [UIImage imageNamed:imageNames[i]];
        childViewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageNames[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]; //避免色值变动
        
        // 设置文字的样式
        NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
        textAttrs[NSForegroundColorAttributeName] = titleColor;
        textAttrs[NSFontAttributeName] = [UIFont room107SystemFontOne];
        NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
        selectTextAttrs[NSForegroundColorAttributeName] = selectedTitleColor;
        selectTextAttrs[NSFontAttributeName] = [UIFont room107SystemFontOne];
        [childViewController.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
        [childViewController.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
        
        [childViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
        
        // 设置子控制器的文字
        if (haveNavigationBar) {
            childViewController.title = titles[i];

            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childViewController];
            [self addChildViewController:nav];

        } else {
            childViewController.tabBarItem.title = titles[i];
            [self addChildViewController:childViewController];
        }
    }
}

- (void)setCenterButtonDidClickHandler:(void(^)())handler {
    _centerButtonClickHandlerBlock = handler;
}

#pragma mark - HJTabBarDelegate代理方法

- (void)tabBarDidClickPlusButton:(HJTabBar *)tabBar {
    if (_centerButtonClickHandlerBlock) {
        _centerButtonClickHandlerBlock();
    }
//    if (self.presentVc) {
//        [self presentViewController:self.presentVc animated:YES completion:nil];
//    }
}


@end
