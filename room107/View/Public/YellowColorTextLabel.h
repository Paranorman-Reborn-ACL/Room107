//
//  YellowColorTextLabel.h
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YellowColorTextLabel : UILabel

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title withTitleColor:(UIColor *)color;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title withTitleColor:(UIColor *)color withAlignment:(NSTextAlignment)alignment;
- (void)setTitle:(NSString *)title withTitleColor:(UIColor *)color;
- (void)setTitle:(NSString *)title withTitleColor:(UIColor *)color withAlignment:(NSTextAlignment)alignment;

@end
