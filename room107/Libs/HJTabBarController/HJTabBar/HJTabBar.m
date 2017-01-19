//
//  HJTabBar.h
//
//
//  Created by http://weibo.com/hanjunzhao  on 16/01/04.
//  Copyright (c) 2016年  https://github.com/CoderHJZhao . All rights reserved.
//

#import "HJTabBar.h"
#import "HJTabBarController.h"
#import "UIView+Extension.h"

#define IphoneWidth [UIScreen mainScreen].bounds.size.width
#define IphoneHeight [UIScreen mainScreen].bounds.size.height
#define plusButtonWidth 50
#define plusButtonHeight 50

@interface HJTabBar()

@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UILabel *plusLabel;

@end

@implementation HJTabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 添加一个按钮到tabbar中
        _plusButton = [[UIButton alloc] init];
        _plusButton.size = CGSizeMake(plusButtonWidth, plusButtonHeight);
        [_plusButton addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_plusButton];
        
        CGFloat labelHeight = 12;
        _plusLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, plusButtonWidth, labelHeight}];
        [_plusLabel setTextAlignment:NSTextAlignmentCenter];
        [_plusLabel setFont:[UIFont room107SystemFontOne]];
        [self addSubview:_plusLabel];
    }
    
    return self;
}

- (void)addImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    [self.plusButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.plusButton setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateHighlighted];
}

- (void)setPlusLabelText:(NSString *)text andTextColor:(UIColor *)textColor {
    [_plusLabel setText:text];
    [_plusLabel setTextColor:textColor];
}

/**
 *  加号按钮点击
 */
- (void)plusClick {
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(tabBarDidClickPlusButton:)]) {
        [self.delegate tabBarDidClickPlusButton:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 1.设置加号按钮的位置
    self.plusButton.centerX = self.width * 0.5;
    self.plusButton.centerY = 6;
    
    _plusLabel.centerX = self.width * 0.5;
    _plusLabel.centerY = self.height - CGRectGetHeight(_plusLabel.bounds);
    
    // 2.设置其他tabbarButton的位置和尺寸
    CGFloat tabbarButtonW = self.width / 5;
    CGFloat tabbarButtonIndex = 0;
    for (UIView *child in self.subviews) {
        Class class = NSClassFromString(@"UITabBarButton");
        if ([child isKindOfClass:class]) {
            // 设置宽度
            child.width = tabbarButtonW;
            // 设置x
            child.x = tabbarButtonIndex * tabbarButtonW;
            
            // 增加索引
            tabbarButtonIndex++;
            if (tabbarButtonIndex == 2) {
                tabbarButtonIndex++;
            }
        }
    }
    
    //将_plusButton置顶，遮挡黑色边框
    [self bringSubviewToFront:_plusButton];
}

@end
