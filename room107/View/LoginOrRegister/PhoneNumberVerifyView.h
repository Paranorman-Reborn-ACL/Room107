//
//  PhoneNumberVerifyView.h
//  room107
//
//  Created by ningxia on 15/7/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhoneNumberVerifyViewDelegate;

@interface PhoneNumberVerifyView : UIView

@property (nonatomic, weak) id<PhoneNumberVerifyViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (NSNumber *)phoneNumber;
- (void)showTips:(NSString *)tips;

@end

@protocol PhoneNumberVerifyViewDelegate <NSObject>

- (void)nextStepButtonDidClick:(PhoneNumberVerifyView *)phoneNumberVerifyView;

@end
