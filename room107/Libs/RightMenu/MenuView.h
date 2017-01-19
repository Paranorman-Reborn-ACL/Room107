//
//  MenuView.h
//  downTableView
//
//  Created by 107间 on 15/11/18.
//  Copyright © 2015年 107间. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuView;

@protocol MenuViewDelegate <NSObject>

@optional
- (void)menuView:(MenuView *)menuView didSelectedItemAtline:(NSInteger)line;

@end

@interface MenuView : UIView

@property (nonatomic, assign) CGFloat itemHeight; //每一个item的高度 默认48
@property (nonatomic, assign) CGFloat lineHeight; //每一个item之间的间隔  默认2
@property (nonatomic, assign) CGFloat itemCount ; //当前可以显示的最大按钮 默认6
@property (nonatomic, strong) UIColor *lineColor ; //缝隙颜色 默认白色
@property (nonatomic, assign) CGFloat itemwidth  ;

@property (nonatomic, weak) id<MenuViewDelegate> delegate;

- (void)showMenuView ;  //下拉菜单
- (void)disapperView ;  //回收菜单

- (void)addButtonTitleArray:(NSArray *)titleArray buttonColor:(UIColor *)color textFont:(UIFont *)font;

@end
