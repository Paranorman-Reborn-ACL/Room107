//
//  SuiteBottomView.h
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuiteBottomView : UIView

- (id)initWithFrame:(CGRect)frame andBeSignedOnlineButtonTitle:(NSString *)title;
- (void)setBeSignedOnlineButtonDidClickHandler:(void(^)())handler;
- (void)setContactOwnerButtonDidClickHandler:(void(^)())handler;

@end
