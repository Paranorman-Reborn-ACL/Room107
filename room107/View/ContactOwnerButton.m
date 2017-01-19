//
//  ContactOwnerButton.m
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "ContactOwnerButton.h"

@interface ContactOwnerButton ()

@property (nonatomic) CGRect normalFrame;
@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic) NSUInteger expandDirection;

@end

@implementation ContactOwnerButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _normalFrame = frame;
    
    if (self) {
        [self setBackgroundColor:[UIColor room107GreenColor]];
        [self setTitle:lang(@"ContactLandlord") forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        _buttonStyle = ContactOwnerButtonStyleNormal;
    }
    
    return self;
}

- (IBAction)buttonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactInfoButtonDidClick:)]) {
        [self.delegate contactInfoButtonDidClick:_buttonStyle];
    }
}

- (void)changeContactOwnerButtonStyle {
    switch (_buttonStyle) {
        case ContactOwnerButtonStyleRetract:
        case ContactOwnerButtonStyleNormal:
            [self setContactOwnerButtonStyle:ContactOwnerButtonStyleExpand];
            break;
        case ContactOwnerButtonStyleExpand:
            [self setContactOwnerButtonStyle:ContactOwnerButtonStyleNormal];
            break;
        default:
            break;
    }
}

- (void)setContactOwnerButtonStyle:(ContactOwnerButtonStyle)style {
    _buttonStyle = style;
    CGRect frame = _normalFrame;
    switch (style) {
        case ContactOwnerButtonStyleRetract:
            frame.origin.x = _normalFrame.origin.x + (_normalFrame.size.width - _normalFrame.size.height);
            frame.size.width = _normalFrame.size.height;
            [self setTitle:@"" forState:UIControlStateNormal];
            break;
        case ContactOwnerButtonStyleExpand:
        {
            if (_expandDirection == ContactOwnerButtonExpandDirectionLeft) {
                frame.origin.x = _normalFrame.origin.x - CGRectGetWidth(_normalFrame) / 2;
            }
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
        case ContactOwnerButtonStyleNormal:
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
            case ContactOwnerButtonStyleRetract:
            case ContactOwnerButtonStyleExpand:
                [self.titleLabel setFont:[UIFont room107FontFour]];
                [self changeSubButtonsStyle:style];
                break;
            default:
                [self.titleLabel setFont:[UIFont room107SystemFontFour]];
                [self setTitle:lang(@"ContactLandlord") forState:UIControlStateNormal];
                break;
        }
    }];
}

- (void)setContactOwnerButtonExpandDirection:(ContactOwnerButtonExpandDirection)direction {
    _expandDirection = direction;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets; {
    _edgeInsets = edgeInsets;
    
    [self changeSubButtonsStyle:_buttonStyle];
}

- (void)changeSubButtonsStyle:(ContactOwnerButtonStyle)style {
    CGFloat buttonWidth = CGRectGetHeight(_normalFrame) - _edgeInsets.top - _edgeInsets.bottom;
    CGFloat lineSpacing = (CGRectGetWidth(_normalFrame) * 3 / 2 - buttonWidth * 3 - _edgeInsets.left - _edgeInsets.right) / 2;
    if (!_phoneButton) {
        _phoneButton = [[CustomButton alloc] initWithFrame:(CGRect){_edgeInsets.left, _edgeInsets.top, buttonWidth, buttonWidth}];
        [_phoneButton setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        [_phoneButton setTitle:@"\ue618" forState:UIControlStateNormal];
        [_phoneButton addTarget:self action:@selector(contactOwnerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_phoneButton];
    }
    if (!_qqButton) {
        _qqButton = [[CustomButton alloc] initWithFrame:(CGRect){_edgeInsets.left + buttonWidth + lineSpacing, _edgeInsets.top, buttonWidth, buttonWidth}];
        [_qqButton setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        [_qqButton setTitle:@"\ue616" forState:UIControlStateNormal];
        [_qqButton addTarget:self action:@selector(contactOwnerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_qqButton];
    }
    if (!_weChatButton) {
        _weChatButton = [[CustomButton alloc] initWithFrame:(CGRect){_edgeInsets.left + 2 * buttonWidth + 2 * lineSpacing, _edgeInsets.top, buttonWidth, buttonWidth}];
        [_weChatButton setEnlargeEdgeWithTop:0 right:0 bottom:0 left:0];
        [_weChatButton setTitle:@"\ue612" forState:UIControlStateNormal];
        [_weChatButton addTarget:self action:@selector(contactOwnerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_weChatButton];
    }
    
    switch (style) {
        case ContactOwnerButtonStyleRetract:
        case ContactOwnerButtonStyleNormal:
            _weChatButton.hidden = YES;
            _phoneButton.hidden = YES;
            if (style == ContactOwnerButtonStyleRetract) {
                [self setTitle:@"\ue618" forState:UIControlStateNormal];
                [self setImageEdgeInsets:UIEdgeInsetsMake(_edgeInsets.top, _edgeInsets.top, _edgeInsets.top, _edgeInsets.top)];
            }
            _qqButton.hidden = YES;
            break;
        case ContactOwnerButtonStyleExpand:
            _weChatButton.hidden = NO;
            _phoneButton.hidden = NO;
            _qqButton.hidden = NO;
            break;
        default:
            break;
    }
}

- (IBAction)contactOwnerButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactOwnerButtonDidClick:)]) {
        [self.delegate contactOwnerButtonDidClick:sender];
    }
}

@end
