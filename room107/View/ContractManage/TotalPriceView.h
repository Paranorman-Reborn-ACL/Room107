//
//  TotalPriceView.h
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TotalPriceView : UIView

- (void)setAttributedTitle:(NSMutableAttributedString *)title;
- (void)setAttributedContent:(NSMutableAttributedString *)content;
- (void)setContentAlignment:(NSTextAlignment)alignment;
- (void)setTitle:(NSString *)title;
- (void)setContent:(NSString *)content;

@end
