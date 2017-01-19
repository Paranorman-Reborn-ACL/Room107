//
//  RedBagBalanceItem.h
//  room107
//
//  Created by Naitong Yu on 15/9/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryItemView : UIView

- (instancetype)initWithTitle:(NSString *)title date:(NSString *)date amount:(double)amount;
- (CGFloat)getHeight;
- (CGFloat)getOriginY;

@end
