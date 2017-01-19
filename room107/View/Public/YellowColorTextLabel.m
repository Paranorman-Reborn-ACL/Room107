//
//  YellowColorTextLabel.m
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "YellowColorTextLabel.h"

@implementation YellowColorTextLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTextColor:[UIColor room107YellowColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setFont:[UIFont room107FontThree]];
        [self setNumberOfLines:0];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title {
    return [self initWithFrame:frame withTitle:title withTitleColor:[UIColor room107YellowColor]];
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title withTitleColor:(UIColor *)color {
    return [self initWithFrame:frame withTitle:title withTitleColor:color withAlignment:NSTextAlignmentCenter];
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title withTitleColor:(UIColor *)color withAlignment:(NSTextAlignment)alignment {
    self = [self initWithFrame:frame];
    
    if (self) {
        [self setTitle:title withTitleColor:color withAlignment:alignment];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title withTitleColor:(UIColor *)color {
    [self setTitle:title withTitleColor:color withAlignment:NSTextAlignmentCenter];
}

- (void)setTitle:(NSString *)title withTitleColor:(UIColor *)color withAlignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    paragraphStyle.alignment = alignment;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title ? title : @""];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, attributedString.length)];
    [self setAttributedText:attributedString];
}

@end
