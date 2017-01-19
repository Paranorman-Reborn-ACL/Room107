//
//  ShareToFriendButton.m
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ShareToFriendButton.h"

@interface ShareToFriendButton ()

@property (nonatomic) CGRect normalFrame;
@property (nonatomic) UIEdgeInsets edgeInsets;

@end

@implementation ShareToFriendButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _normalFrame = frame;

    if (self) {
        UIColor *buttonColor = [UIColor room107YellowColor];
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = buttonColor.CGColor;
        [self setTitle:lang(@"ShareToFriend") forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont room107SystemFontFour]];
        [self setTitleColor:buttonColor forState:UIControlStateNormal];
        [self setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        _buttonStyle = ShareToFriendButtonStyleNormal;
    }
    
    return self;
}

- (IBAction)buttonDidClick:(id)sender {
    [self setValue:[NSNumber numberWithUnsignedLong:_buttonStyle] forKeyPath:@"click"];
    
    switch (_buttonStyle) {
        case ShareToFriendButtonStyleRetract:
        case ShareToFriendButtonStyleNormal:
            [self setShareToFriendButtonStyle:ShareToFriendButtonStyleExpand];
            break;
        case ShareToFriendButtonStyleExpand:
            [self setShareToFriendButtonStyle:ShareToFriendButtonStyleNormal];
            break;
        default:
            break;
    }
}

- (void)setShareToFriendButtonStyle:(ShareToFriendButtonStyle)style {
    _buttonStyle = style;
    CGRect frame = _normalFrame;
    switch (style) {
        case ShareToFriendButtonStyleRetract:
            frame.size.width = _normalFrame.size.height;
            [self setTitle:@"" forState:UIControlStateNormal];
            break;
        case ShareToFriendButtonStyleExpand:
        {
            frame.size.width = CGRectGetWidth(_normalFrame) * 3 / 2;
            UIView *superview = [self superview];
            CGRect superviewFrame = superview.frame;
            if (superviewFrame.size.width < frame.size.width) {
                //调整父View的宽度，避免部分区域点击无效
                superviewFrame.size.width = frame.size.width;
                superview.frame = superviewFrame;
            }
            [self setTitle:@"" forState:UIControlStateNormal];
        }
            break;
        case ShareToFriendButtonStyleNormal:
            [self changeSubButtonsStyle:style];
            break;
        default:
            break;
    }
    
    [self setImage:nil forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self setFrame:frame];
    } completion:^(BOOL finished) {
        switch (style) {
            case ShareToFriendButtonStyleRetract:
            case ShareToFriendButtonStyleExpand:
                [self.titleLabel setFont:[UIFont room107FontFour]];
                [self changeSubButtonsStyle:style];
                break;
            default:
                [self.titleLabel setFont:[UIFont room107SystemFontFour]];
                [self setTitle:lang(@"ShareToFriend") forState:UIControlStateNormal];
                break;
        }
    }];
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets; {
    _edgeInsets = edgeInsets;
}

- (void)changeSubButtonsStyle:(ShareToFriendButtonStyle)style {
    CGFloat buttonWidth = CGRectGetHeight(_normalFrame) - _edgeInsets.top - _edgeInsets.bottom;
    CGFloat lineSpacing = (CGRectGetWidth(_normalFrame) * 3 / 2 - buttonWidth * 3 - _edgeInsets.left - _edgeInsets.right) / 2;
    if (!_weChatButton) {
        _weChatButton = [[CustomButton alloc] initWithFrame:(CGRect){_edgeInsets.left, _edgeInsets.top, buttonWidth, buttonWidth}];
        [_weChatButton setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        [_weChatButton setTitle:@"\ue612" forState:UIControlStateNormal];
        [_weChatButton setTitleColor:[UIColor room107YellowColor] forState:UIControlStateNormal];
        [_weChatButton addTarget:self action:@selector(shareToButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_weChatButton];
    }
    if (!_wechatMomentsButton) {
        _wechatMomentsButton = [[CustomButton alloc] initWithFrame:(CGRect){_edgeInsets.left + buttonWidth + lineSpacing, _edgeInsets.top, buttonWidth, buttonWidth}];
        [_wechatMomentsButton setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        [_wechatMomentsButton setTitle:@"\ue615" forState:UIControlStateNormal];
        [_wechatMomentsButton setTitleColor:[UIColor room107YellowColor] forState:UIControlStateNormal];
        [_wechatMomentsButton addTarget:self action:@selector(shareToButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_wechatMomentsButton];
    }
    if (!_qqButton) {
        _qqButton = [[CustomButton alloc] initWithFrame:(CGRect){_edgeInsets.left + 2 * buttonWidth + 2 * lineSpacing, _edgeInsets.top, buttonWidth, buttonWidth}];
        [_qqButton setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        [_qqButton setTitle:@"\ue616" forState:UIControlStateNormal];
        [_qqButton setTitleColor:[UIColor room107YellowColor] forState:UIControlStateNormal];
        [_qqButton addTarget:self action:@selector(shareToButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_qqButton];
    }
    
    switch (style) {
        case ShareToFriendButtonStyleRetract:
        case ShareToFriendButtonStyleNormal:
            _weChatButton.hidden = YES;
            _wechatMomentsButton.hidden = YES;
            _qqButton.hidden = YES;
            if (style == ShareToFriendButtonStyleRetract) {
                [self setTitle:lang(@"Share") forState:UIControlStateNormal];
                [self setTitleColor:[UIColor room107YellowColor] forState:UIControlStateNormal];
                [self setImageEdgeInsets:UIEdgeInsetsMake(_edgeInsets.top, _edgeInsets.top, _edgeInsets.top, _edgeInsets.top )];
            }
            break;
        case ShareToFriendButtonStyleExpand:
            _weChatButton.hidden = NO;
            _wechatMomentsButton.hidden = NO;
            _qqButton.hidden = NO;
            break;
        default:
            break;
    }
}

- (IBAction)shareToButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(shareToButtonDidClick:)]) {
        [self.delegate shareToButtonDidClick:sender];
    }
}

@end
