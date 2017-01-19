//
//  PaymentBottomView.h
//  room107
//
//  Created by ningxia on 16/3/30.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentBottomView : UIView

- (void)setLeftButtonAttributedTitle:(NSMutableAttributedString *)title;
- (void)setRightButtonTitle:(NSString *)title;
- (void)setLeftButtonDidClickHandler:(void(^)())handler;
- (void)setRightButtonDidClickHandler:(void(^)())handler;

@end
