//
//  TitleGreenColorTextLabel.m
//  room107
//
//  Created by 107间 on 16/3/16.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "TitleGreenColorTextLabel.h"

@interface TitleGreenColorTextLabel()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation TitleGreenColorTextLabel

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withContent:(NSString *)content {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat spaceX = 11;
        [self addSubview:self.titleLabel];
        [_titleLabel setFrame:CGRectMake(0, 0, frame.size.width, 20)];
        [_titleLabel setText:title];
        
        [self addSubview:self.contentLabel];
        CGFloat congtentLabelWidth = 265;
        [_contentLabel setFrame:CGRectMake(frame.size.width / 2 - congtentLabelWidth / 2, CGRectGetMaxY(_titleLabel.frame) + spaceX, congtentLabelWidth, frame.size.height - _titleLabel.frame.size.height)];
        [_contentLabel setText:content];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withTitleColor:(UIColor *)titleColor withContent:(NSString *)content withContentColor:(UIColor *)contentColor {
    self = [self initWithFrame:frame withTitle:title withContent:content];
    [_titleLabel setTextColor:titleColor];
    [_contentLabel setTextColor:contentColor];
    return self;
}

- (UILabel *)titleLabel {
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont room107SystemFontThree]];
        [_titleLabel setTextColor:[UIColor room107GreenColor]];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (nil == _contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setNumberOfLines:0];
        [_contentLabel setTextAlignment:NSTextAlignmentLeft];
        [_contentLabel setTextColor:[UIColor room107GreenColor]];
        [_contentLabel setFont:[UIFont room107SystemFontOne]];
    }
    return _contentLabel;
}
@end
