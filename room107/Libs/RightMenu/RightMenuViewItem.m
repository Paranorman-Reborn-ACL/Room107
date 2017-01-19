//
//  RightMenuViewItem.m
//  room107
//
//  Created by 107间 on 16/3/10.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "RightMenuViewItem.h"

@interface RightMenuViewItem()

@property (nonatomic, copy) void (^clickComplete)();
@property (nonatomic, strong) UIButton *clickButton;

@end

@implementation RightMenuViewItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIButton *)clickButton {
    if (nil == _clickButton) {
        _clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickButton setFrame:self.frame];
        [_clickButton addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        _clickButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _clickButton.tintColor = [UIColor whiteColor];
        [_clickButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
    }
    return _clickButton;
}

- (instancetype)initWithTitle:(NSString *)title clickComplete:(void(^)())complete {
    return [self initWithSize:CGSizeMake(100, 44) title:title clickComplete:complete];
}

- (instancetype)initWithSize:(CGSize)size title:(NSString *)title clickComplete:(void (^)())complete {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _clickComplete = complete;
        [self addSubview:self.clickButton];
        [_clickButton setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (void)click {
    if ([self.delegate respondsToSelector:@selector(rightMenudidSelectedItem:)]) {
        [self.delegate rightMenudidSelectedItem:self];
    }
    if (_clickComplete) {
        _clickComplete();
    }
}
@end
