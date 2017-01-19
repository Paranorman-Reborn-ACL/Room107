//
//  SystemMutualBottomView.h
//  room107
//
//  Created by ningxia on 15/10/16.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SystemMutualBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame andMainButtonTitle:(NSString *)mainTitle andAssistantButtonTitle:(NSString *)assistantTitle;

- (void)setMainButtonDidClickHandler:(void(^)())handler;
- (void)setAssistantButtonDidClickHandler:(void(^)())handler;

@end
