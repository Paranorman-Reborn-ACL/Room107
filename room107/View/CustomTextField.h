//
//  CustomTextField.h
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTextFieldDelegate <NSObject>

@optional
- (void)textFieldResignFirstResponder;

@end

@interface CustomTextField : UITextField

- (void)setFontSize:(CGFloat)size;
- (void)setLeftViewWidth:(CGFloat)width;
@property (nonatomic, weak) id<CustomTextFieldDelegate> responderDelegate;
@end
