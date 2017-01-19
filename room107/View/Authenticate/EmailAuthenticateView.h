//
//  EmailAuthenticateView.h
//  room107
//
//  Created by ningxia on 15/7/22.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmailAuthenticateViewDelegate;

@interface EmailAuthenticateView : UIView

@property (nonatomic, weak) id<EmailAuthenticateViewDelegate> delegate;
- (NSString *)authenticateEmail;
- (void)showStep:(NSUInteger)step;
- (void)setAuthenticateEmail:(NSString *)email;

@end

@protocol EmailAuthenticateViewDelegate <NSObject>

- (void)sendAuthenticateEmailButtonDidClick:(EmailAuthenticateView *)emailAuthenticateView;
- (void)changeEmailButtonDidClick:(EmailAuthenticateView *)emailAuthenticateView;

@end
