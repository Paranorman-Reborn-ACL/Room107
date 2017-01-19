//
//  WalletItemView.h
//  room107
//
//  Created by Naitong Yu on 15/8/21.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletItemView : UIView

@property (nonatomic) NSString *iconCode;
@property (nonatomic) NSString *name;
@property (nonatomic) double amount;
@property (nonatomic) BOOL newUpdate;

@property (nonatomic) UIColor *fontColor;

- (void)setTapWalletItemHandler:(void (^)(void))tapWalletItemHandler;

@end
