//
//  CustomTextView.h
//  room107
//
//  Created by ningxia on 15/7/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextView : UITextView

- (id)initWithFrame:(CGRect)frame hasDoneButton:(BOOL)has;
- (void)setPlaceholder:(NSString *)placeholder;
- (void)showPlaceholder:(BOOL)isShow;
- (void)setFontSize:(CGFloat)size;
- (void)setCornerRadius:(CGFloat)cornerRadius;
- (NSDictionary *)attributes;
- (CGRect)getContentRectWithText:(NSString *)text;

@end
