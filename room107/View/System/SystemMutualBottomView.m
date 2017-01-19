//
//  SystemMutualBottomView.m
//  room107
//
//  Created by ningxia on 15/10/16.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "SystemMutualBottomView.h"
#import "RoundedGreenButton.h"
#import "GreenTextButton.h"

@interface SystemMutualBottomView ()

@property (nonatomic, strong) void (^mainButtonClickBlock)();
@property (nonatomic, strong) void (^assistantButtonClickBlock)();

@end

@implementation SystemMutualBottomView

- (instancetype)initWithFrame:(CGRect)frame andMainButtonTitle:(NSString *)mainTitle andAssistantButtonTitle:(NSString *)assistantTitle {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originX = 22.0f;
        CGFloat buttonWidth = CGRectGetWidth(frame) - 2 * originX;
        CGFloat buttonHeight = 53.0f;
        CGFloat originY = CGRectGetHeight(frame) - 44 - buttonHeight;
        
        if (mainTitle && ![mainTitle isEqualToString:@""]) {
            RoundedGreenButton *roundedGreenButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, buttonHeight}];
            [roundedGreenButton setTitle:mainTitle forState:UIControlStateNormal];
            if (mainTitle.length == 1) {
                //icon字体
                [roundedGreenButton.titleLabel setFont:[UIFont room107FontFour]];
            }
            [self addSubview:roundedGreenButton];
            [roundedGreenButton addTarget:self action:@selector(roundedGreenButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (assistantTitle && ![assistantTitle isEqualToString:@""]) {
            originY = CGRectGetHeight(frame) - 34;
            GreenTextButton *greenTextButton = [[GreenTextButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, 25}];
            [greenTextButton setTitle:assistantTitle forState:UIControlStateNormal];
            [self addSubview:greenTextButton];
            [greenTextButton addTarget:self action:@selector(greenTextButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return self;
}

- (void)setMainButtonDidClickHandler:(void(^)())handler {
    _mainButtonClickBlock = handler;
}

- (void)setAssistantButtonDidClickHandler:(void(^)())handler {
    _assistantButtonClickBlock = handler;
}

- (IBAction)roundedGreenButtonDidClick:(id)sender {
    if (_mainButtonClickBlock) {
        _mainButtonClickBlock();
    }
}

- (IBAction)greenTextButtonDidClick:(id)sender {
    if (_assistantButtonClickBlock) {
        _assistantButtonClickBlock();
    }
}

@end
