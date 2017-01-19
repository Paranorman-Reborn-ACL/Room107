//
//  RightMenuView.m
//  room107
//
//  Created by 107间 on 16/3/10.
//  Copyright © 2016年 107room. All rights reserved.
//

#define ScreenFrame [UIScreen mainScreen].bounds
#import "RightMenuView.h"
#import "RightMenuViewItem.h"

static const CGFloat itemWidth = 100.f; //menu宽度
static const CGFloat itemSpace = 11.f; //menu距离右侧屏幕距离

@interface RightMenuView()<RightMenuViewItemDelegate>

@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) UIImageView *backGroundView;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, strong) UIScrollView *backGroundScrollView;
@end

@implementation RightMenuView

- (instancetype)initWithItems:(NSArray *)itemsArray {
    return [self initWithItems:itemsArray itemHeight:40];
}

- (instancetype)initWithItems:(NSArray *)itemsArray itemHeight:(CGFloat)itemHeight{
    self = [super init];
    if (self) {
        _itemArray = itemsArray;
        _itemHeight = itemHeight;
        [self setMenuItem];
    }
    return self;
}

- (void)setMenuItem {
    [self setFrame:CGRectMake(0, 0, ScreenFrame.size.width, ScreenFrame.size.height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenuView)];
    [self addGestureRecognizer:tap];
    
    self.backGroundView = [[UIImageView alloc] init];
    [self.backGroundView setImage:[UIImage imageNamed:@"menuView"]];
    [self addSubview:_backGroundView];
    self.backGroundView.userInteractionEnabled = YES;
    [self setItemInfoWithArray:_itemArray];
}

- (void)dismissMenuView {
    [UIView animateWithDuration:0.3 animations:^{
//        [_backGroundView setFrame:CGRectMake(ScreenFrame.size.width - itemSpace - itemWidth , 0, itemWidth, 0)];
        [_backGroundView setAlpha:0];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];

}

- (void)showMenuView {
    self.hidden = NO;
    [_backGroundScrollView scrollsToTop];
    [UIView animateWithDuration:0.3 animations:^{
//        [_backGroundView setFrame:CGRectMake(ScreenFrame.size.width - itemSpace - itemWidth, 0, itemWidth, _itemArray.count * _itemHeight)];
        [_backGroundView setAlpha:1];
    } completion:^(BOOL finished) {
        [self.superview bringSubviewToFront:self];
    }];
}

- (void)rightMenudidSelectedItem:(RightMenuViewItem *)rightMenuViewItem {
    self.hidden = YES;
}

- (void)refreshWithItems:(NSArray *)itemsArray {
    for (UIView *subItem in _backGroundView.subviews) {
        [subItem removeFromSuperview];
    }
    [self setItemInfoWithArray:itemsArray];
}

- (void)setItemInfoWithArray:(NSArray *)itemsArray {
    if (itemsArray.count > 5) {
        //item数量大于5个
        [_backGroundView setFrame:CGRectMake(ScreenFrame.size.width - itemSpace - itemWidth, 0, itemWidth, 5.5 * _itemHeight)];
        //设置滚动区域
        _backGroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, _itemHeight * 5.5)];
        [_backGroundScrollView setContentSize:CGSizeMake(0, itemsArray.count * _itemHeight)];
        _backGroundScrollView.showsVerticalScrollIndicator = NO;
        [self.backGroundView addSubview:_backGroundScrollView];
        
        for (int i = 0 ; i < itemsArray.count; i++) {
            RightMenuViewItem *menuItem = itemsArray[i];
            menuItem.delegate = self;
            [menuItem setFrame:CGRectMake(0, i * _itemHeight , menuItem.frame.size.width, menuItem.frame.size.height)];
            [_backGroundScrollView addSubview:menuItem];
            //灰线
            if (i < itemsArray.count - 1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(11, i * _itemHeight + _itemHeight, itemWidth - 22, 1)];
                [lineView setBackgroundColor:[UIColor room107GrayColorD]];
                [_backGroundScrollView addSubview:lineView];
            }
        }
    } else {
        //item数量小于等于5个
        [_backGroundView setFrame:CGRectMake(ScreenFrame.size.width - itemSpace - itemWidth, 0, itemWidth, itemsArray.count * _itemHeight)];
        for (int i = 0; i < itemsArray.count; i++) {
            RightMenuViewItem *menuItem = itemsArray[i];
            menuItem.delegate = self;
            [menuItem setFrame:CGRectMake(0, i * _itemHeight , menuItem.frame.size.width, menuItem.frame.size.height)];
            [self.backGroundView addSubview:menuItem];
            //灰线
            if (i < itemsArray.count - 1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(11, i * _itemHeight + _itemHeight, itemWidth - 22, 1)];
                [lineView setBackgroundColor:[UIColor room107GrayColorD]];
                [self.backGroundView addSubview:lineView];
            }
        }
    }
    

}
@end
