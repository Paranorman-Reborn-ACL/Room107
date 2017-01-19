//
//  LAGsecondGuide.h
//  LanuchImageTest
//
//  Created by 刘安国 on 15/10/27.
//  Copyright (c) 2015年 刘安国. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAGSameView.h"

@interface LAGsecondGuide : UIView
@property (nonatomic, strong) LAGSameView *sameView;          //共用View

- (void)animationOfView ;
//设置渐变颜色
- (void)setStepColor:(UIColor *)color;
@end
