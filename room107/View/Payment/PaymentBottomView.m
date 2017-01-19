//
//  PaymentBottomView.m
//  room107
//
//  Created by ningxia on 16/3/30.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "PaymentBottomView.h"
#import "CustomButton.h"

@interface PaymentBottomView ()

@property (nonatomic, strong) CustomButton *leftButton;
@property (nonatomic, strong) CustomButton *rightButton;
@property (nonatomic, strong) void (^leftButtonHandlerBlock)();
@property (nonatomic, strong) void (^rightButtonHandlerBlock)();

@end

@implementation PaymentBottomView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originX = 0;
        CGFloat originY = 0;
        CGFloat buttonWidth = CGRectGetWidth(frame) / 2;
        _leftButton = [[CustomButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, CGRectGetHeight(frame)}];
        [_leftButton setBackgroundColor:[UIColor whiteColor]];
        [_leftButton.titleLabel setNumberOfLines:0];
        [_leftButton addTarget:self action:@selector(leftButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
        
        _rightButton = [[CustomButton alloc] initWithFrame:(CGRect){CGRectGetWidth(_leftButton.bounds), originY, CGRectGetWidth(frame) - CGRectGetWidth(_leftButton.bounds), CGRectGetHeight(frame)}];
        [_rightButton setBackgroundColor:[UIColor room107GreenColor]];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        [_rightButton addTarget:self action:@selector(rightButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightButton];
        
        UIView *seperateView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(frame), 0.5}];
        [seperateView setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:seperateView];
    }
    
    return self;
}

- (void)setLeftButtonAttributedTitle:(NSMutableAttributedString *)title {
    [_leftButton setAttributedTitle:title forState:UIControlStateNormal];
}

- (void)setRightButtonTitle:(NSString *)title {
    [_rightButton setTitle:title forState:UIControlStateNormal];
}

- (void)setLeftButtonDidClickHandler:(void(^)())handler {
    _leftButtonHandlerBlock = handler;
}

- (void)setRightButtonDidClickHandler:(void (^)())handler {
    _rightButtonHandlerBlock = handler;
}

- (IBAction)leftButtonDidClick:(id)sender {
    if (_leftButtonHandlerBlock) {
        _leftButtonHandlerBlock();
    }
}

- (IBAction)rightButtonDidClick:(id)sender {
    if (_rightButtonHandlerBlock) {
        _rightButtonHandlerBlock();
    }
}

@end
