//
//  QuickEditView.m
//  room107
//
//  Created by ningxia on 16/4/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "QuickEditView.h"
#import "CustomButton.h"

@interface QuickEditView ()

@property (nonatomic, strong) void (^buttonDidClickHandlerBlock)();

@end

@implementation QuickEditView

- (id)initWithFrame:(CGRect)frame withButtonTitle:(NSString *)title {
    frame.size.height = 44;
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat originX = 11;
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){originX, 0, CGRectGetWidth(frame) - originX, 0.5}];
        [lineView setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:lineView];
        
        CGFloat buttonWidth = 100;
        CGFloat buttonHeight = 30;
        CustomButton *quickEditButton = [[CustomButton alloc] initWithFrame:(CGRect){originX, (CGRectGetHeight(frame) - buttonHeight) / 2, buttonWidth, buttonHeight}];
        CGPoint center = quickEditButton.center;
        center.x = CGRectGetWidth(frame) / 2;
        [quickEditButton setCenter:center];
        //描边
        quickEditButton.layer.borderWidth = 0.5f;
        quickEditButton.layer.borderColor = [UIColor room107GreenColor].CGColor;
        quickEditButton.layer.cornerRadius = 2;
        quickEditButton.layer.masksToBounds = YES;
        [quickEditButton setTitle:title forState:UIControlStateNormal];
        [quickEditButton setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
        [quickEditButton.titleLabel setFont:[UIFont room107FontTwo]];
        [quickEditButton addTarget:self action:@selector(quickEditButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:quickEditButton];
    }
    
    return self;
}

- (void)setButtonDidClickHandler:(void(^)())handler {
    _buttonDidClickHandlerBlock = handler;
}

- (IBAction)quickEditButtonDidClick:(id)sender {
    if (_buttonDidClickHandlerBlock) {
        _buttonDidClickHandlerBlock();
    }
}

@end
