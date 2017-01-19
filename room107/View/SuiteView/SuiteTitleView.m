//
//  SuiteTitleView.m
//  room107
//
//  Created by ningxia on 16/3/28.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuiteTitleView.h"
#import "SearchTipLabel.h"

@interface SuiteTitleView ()

@property (nonatomic, strong) SearchTipLabel *titleLabel;

@end

@implementation SuiteTitleView

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        CGFloat originX = 22;
        CGFloat seperateViewHeight = 0.5;
        _titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, CGRectGetWidth(frame) - 2 * originX, CGRectGetHeight(frame) - seperateViewHeight}];
        [_titleLabel setTextColor:[UIColor room107GrayColorC]];
        [_titleLabel setText:title];
        [_titleLabel setFont:[UIFont room107SystemFontTwo]];
        [self addSubview:_titleLabel];
        
        UIView *seperateView = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(_titleLabel.bounds), CGRectGetWidth(frame), seperateViewHeight}];
        [seperateView setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:seperateView];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    [_titleLabel setText:title];
}

@end
