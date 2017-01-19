//
//  PopupView.m
//  room107
//
//  Created by ningxia on 15/7/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "PopupView.h"
#import "UIView+Nib.h"

static CGFloat viewHeight = statusBarHeight + 44;
static CGFloat originY = -(statusBarHeight + 44);

@interface PopupView()

@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (assign, nonatomic) BOOL isHidden;

@end

@implementation PopupView

+ (void)showMessage:(NSString *) message {
//    PopupView *popup = [PopupView createViewFromNib];
//    [popup showMessage:message];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:lang(@"OK"), nil];
    [alert show];

}

+ (void)showTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:lang(@"OK"), nil];
    [alert show];
}

- (void)showMessage:(NSString *)message {
    [self.messageLabel setText:message];
    [self animationInWindow];
}

- (void)animationInWindow {
    self.alpha = 0.0f;
    [App.window addSubview:self];
    self.frame = (CGRect) {0, originY, App.window.frame.size.width, viewHeight};
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = (CGRect) {0, 0, App.window.frame.size.width, viewHeight};
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:1.5];
        [self gesture];
        self.isHidden = NO;
    }];
    
//    [App.window addSubview:self];
//    self.frame = (CGRect) {0, originY, App.window.frame.size.width, 0};
////    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [UIView animateWithDuration:1.0f animations:^{
//        self.frame = (CGRect) {0, originY, App.window.frame.size.width, viewHeight};
////        self.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//        [self performSelector:@selector(hide) withObject:nil afterDelay:1.0];
//        [self gesture];
////        self.isHidden = NO;
//    }];
}

- (void)gesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:pan];
}

- (void)hide {
    if (self.isHidden) {
        return;
    }
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.isHidden = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.frame = (CGRect) {0, originY, App.window.frame.size.width, viewHeight};
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
//    self.frame = (CGRect) {0, originY, App.window.frame.size.width, viewHeight};
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [UIView animateWithDuration:1.0f animations:^{
//        self.frame = (CGRect) {0, originY, App.window.frame.size.width, viewHeight};
//        //        self.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//        self.frame = (CGRect) {0, originY, App.window.frame.size.width, 0};
//        [self removeFromSuperview];
//    }];
}

- (void)dealloc {
}

@end
