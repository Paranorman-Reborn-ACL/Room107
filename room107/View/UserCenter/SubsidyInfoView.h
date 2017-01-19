//
//  SubsidyInfoView.h
//  room107
//
//  Created by Naitong Yu on 15/8/21.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubsidyInfoView : UIView

@property (nonatomic) double redBagNumber;
@property (nonatomic) double accountBalanceNumber;
@property (nonatomic) BOOL redBagNewUpdate;
@property (nonatomic) BOOL accountBalanceNewUpdate;

- (void)setRedBagActionHandler:(void (^)(void))redBagActionHandler;
- (void)setBalanceActionHandler:(void (^)(void))balanceActionHandler;

@end
