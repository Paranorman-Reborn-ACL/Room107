//
//  NXPaymentSwitch.m
//  room107
//
//  Created by ningxia on 16/3/29.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "NXPaymentSwitch.h"
#import "SearchTipLabel.h"
#import "NXSwitch.h"

@interface NXPaymentSwitch ()

@property (nonatomic, strong) SearchTipLabel *iconLabel;
@property (nonatomic, strong) SearchTipLabel *titleLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;
@property (nonatomic, strong) NXSwitch *onOffSwitch;
@property (nonatomic, strong) void (^switchActionHandlerBlock)(BOOL isOn);

@end

@implementation NXPaymentSwitch

- (id)initWithFrame:(CGRect)frame withSwitch:(BOOL)hasSwitch {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat spaceX = 22;
        CGFloat labelWidth = 22;
        _iconLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){spaceX, 0, labelWidth, CGRectGetHeight(self.bounds)}];
        [_iconLabel setFont:[UIFont room107FontFour]];
        [self addSubview:_iconLabel];

        labelWidth = 50;
        _titleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){2 * spaceX + CGRectGetWidth(_iconLabel.bounds), 0, labelWidth, CGRectGetHeight(self.bounds)}];
        [self addSubview:_titleLabel];
        
        CGFloat switchWidth = 51;
        CGFloat switchHeight = 31;
        if (hasSwitch) {
            //原生UISwitch的宽和高固定为51、31
            _onOffSwitch = [[NXSwitch alloc] initWithFrame:(CGRect){CGRectGetWidth(self.bounds) - spaceX - switchWidth, (CGRectGetHeight(frame) - switchHeight) / 2, switchWidth, switchHeight}];
            [_onOffSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:_onOffSwitch];
        }
        
        CGFloat contentWidth = 150;
        CGFloat seperateViewHeight = 0.5;
        CGRect frame = (CGRect){CGRectGetWidth(self.bounds) - contentWidth, 0, contentWidth, CGRectGetHeight(self.bounds)};
        if (hasSwitch) {
            frame.origin.x -= spaceX + switchWidth + 10;
        }
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:frame];
        [_contentLabel setTextAlignment:NSTextAlignmentRight];
        [_contentLabel setFont:[UIFont room107SystemFontTwo]];
        [_contentLabel setTextColor:[UIColor room107GrayColorD]];
        [self addSubview:_contentLabel];
        
        UIView *seperateView = [[UIView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(_titleLabel.bounds) - seperateViewHeight, CGRectGetWidth(self.bounds), seperateViewHeight}];
        [seperateView setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:seperateView];
    }
    
    return self;
}

- (void)setIconText:(NSString *)text {
    [_iconLabel setText:text];
}

- (void)setTitle:(NSString *)title {
    [_titleLabel setText:title];
}

- (void)setContent:(NSString *)content {
    [_contentLabel setText:content];
}

- (BOOL)isOn {
    return [_onOffSwitch isOn];
}

- (void)setOn:(BOOL)isOn {
    [_onOffSwitch setOn:isOn];
    [_iconLabel setTextColor:isOn ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
    [_titleLabel setTextColor:isOn ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
    [_contentLabel setTextColor:isOn ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
}

- (IBAction)switchAction:(id)sender {
    UISwitch *onOffSwitch = (UISwitch *)sender;
    [_iconLabel setTextColor:[onOffSwitch isOn] ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
    [_titleLabel setTextColor:[onOffSwitch isOn] ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
    [_contentLabel setTextColor:[onOffSwitch isOn] ? [UIColor room107GrayColorD] : [UIColor room107GrayColorC]];
    if (self.switchActionHandlerBlock) {
        self.switchActionHandlerBlock([onOffSwitch isOn]);
    }
}

- (void)setSwitchActionHandler:(void (^)(BOOL isOn))handler {
    self.switchActionHandlerBlock = handler;
}

- (void)setIconColor:(UIColor *)color {
    [_iconLabel setTextColor:color];
}

@end
