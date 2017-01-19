//
//  TitleGreenColorTextLabel.h
//  room107
//
//  Created by 107间 on 16/3/16.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleGreenColorTextLabel : UIView

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withContent:(NSString *)content;
- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withTitleColor:(UIColor *)titleColor withContent:(NSString *)content withContentColor:(UIColor *)contentColor;

@end
