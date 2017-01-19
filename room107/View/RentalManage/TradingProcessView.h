//
//  TradingProcessView.h
//  room107
//
//  Created by ningxia on 15/8/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TradingProcessView : UIView

- (id)initWithFrame:(CGRect)frame processesArray:(NSArray *)processes;
- (void)setCurrentStep:(NSNumber *)step;

@end
