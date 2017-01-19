//
//  SearchTextField.m
//  room107
//
//  Created by ningxia on 16/2/17.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor room107GrayColorB]];
        [self setTintColor:[UIColor room107GreenColor]];
        [self setLeftViewWidth:5];
        [self setTextColor:[UIColor room107GrayColorD]];
        [self setBorderStyle:UITextBorderStyleRoundedRect];
        [self setFont:[UIFont room107FontTwo]];
    }
    
    return self;
}

- (void)setPlaceholder:(NSString *)placeholder textColor:(UIColor *)textColor textFont:(UIFont *)textFont {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:placeholder ? placeholder : @""];
    [str setAttributes:@{NSFontAttributeName:textFont ? textFont : [UIFont room107FontTwo], NSForegroundColorAttributeName: textColor ? textColor : [UIColor room107GrayColorD]} range:NSMakeRange(0, str.length)];
    [self setAttributedPlaceholder:str];
}

@end
