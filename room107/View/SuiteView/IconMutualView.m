//
//  IconMutualView.m
//  room107
//
//  Created by ningxia on 15/11/25.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "IconMutualView.h"
#import "CustomButton.h"

@interface IconMutualView ()

@property (nonatomic, strong) void (^iconButtonHandlerBlock)(NSInteger index);

@end

@implementation IconMutualView

- (instancetype)initWithIcons:(NSArray *)icons {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)];
        [self addGestureRecognizer:tapGesture];
        
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [[App window] addSubview:self]; //铺满整个屏幕
        
        CGFloat viewWidth = 253;
        CGFloat viewHeight = 63;
        UIView *contentView = [[UIView alloc] initWithFrame:(CGRect){self.center.x - viewWidth / 2, self.center.y - viewHeight / 2, viewWidth, viewHeight}];
        [contentView setBackgroundColor:[UIColor whiteColor]];
        contentView.layer.cornerRadius = [CommonFuncs cornerRadius];
        contentView.layer.masksToBounds = YES;
        [self addSubview:contentView];
        
        CGFloat buttonWidth = 33;
        CGFloat originX = 33;
        CGFloat originY = 15;
        CGFloat distanceX = 44;
        for (NSDictionary *iconDic in icons) {
            CustomButton *iconButton = [[CustomButton alloc] initWithFrame:(CGRect){originX + (buttonWidth + distanceX) * [icons indexOfObject:iconDic], originY, buttonWidth, buttonWidth}];
            [iconButton.titleLabel setFont:[UIFont room107FontSix]];
            iconButton.tag = [icons indexOfObject:iconDic];
            [iconButton setTitle:iconDic[@"title"] forState:UIControlStateNormal];
            [iconButton setTitleColor:iconDic[@"color"] forState:UIControlStateNormal];
            [iconButton addTarget:self action:@selector(iconButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:iconButton];
        }
    }
    
    return self;
}

- (void)hideSelf {
    [self removeFromSuperview];
}

- (IBAction)iconButtonDidClick:(id)sender {
    [self removeFromSuperview];
    if (_iconButtonHandlerBlock) {
        _iconButtonHandlerBlock([(CustomButton *)sender tag]);
        
    }
}

- (void)setIconButtonDidClickHandler:(void(^)(NSInteger index))handler {
    _iconButtonHandlerBlock = handler;
}

@end
