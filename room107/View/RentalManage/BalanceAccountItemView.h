//
//  BalanceAccountItemView.h
//  room107
//
//  Created by Naitong Yu on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BalanceAccountItemView : UIView

@property (nonatomic, readonly) NSInteger totalMoney;

- (instancetype)initWithFrame:(CGRect)frame categoryName:(NSString *)name details:(NSArray *)details collapse:(BOOL)collapse;

@end
