//
//  ExpenseOrderLargeItemView.h
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchTipLabel;

@interface ExpenseOrderLargeItemView : UIView

@property (nonatomic, strong) SearchTipLabel *titleLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;

- (id)initWithFrame:(CGRect)frame withButton:(BOOL)hasButton;
- (void)setTitle:(NSString *)title;
- (void)setContent:(NSString *)content;
- (void)setShrinkHandler:(void(^)())handler;
- (void)setShrink:(BOOL)shrink; //0:收起，1:展开
- (void)setTextColor:(UIColor *)color;
- (void)setAttributedTitle:(NSMutableAttributedString *)title;
@end
