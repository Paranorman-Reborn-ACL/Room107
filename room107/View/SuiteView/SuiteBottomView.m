//
//  SuiteBottomView.m
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteBottomView.h"
#import "CustomButton.h"

@interface SuiteBottomView ()

@property (nonatomic, strong) void (^beSignedOnlineHandlerBlock)();
@property (nonatomic, strong) void (^contactOwnerHandlerBlock)();

@end

@implementation SuiteBottomView

- (id)initWithFrame:(CGRect)frame andBeSignedOnlineButtonTitle:(NSString *)title {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGFloat originX = 0;
        CGFloat originY = 0;
    
        CustomButton *contactOwnerButton = [[CustomButton alloc] initWithFrame:(CGRect){originX, originY, 55, CGRectGetHeight(frame)}];
        [contactOwnerButton setBackgroundColor:[UIColor whiteColor]];
        [contactOwnerButton setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
        [contactOwnerButton setTitle:lang(@"\ue618") forState:UIControlStateNormal];
        [contactOwnerButton.titleLabel setFont:[UIFont room107FontFour]];
        [contactOwnerButton addTarget:self action:@selector(contactOwnerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:contactOwnerButton];
        
        CustomButton *beSignedOnlineButton = [[CustomButton alloc] initWithFrame:(CGRect){CGRectGetWidth(contactOwnerButton.bounds), originY, CGRectGetWidth(frame) - CGRectGetWidth(contactOwnerButton.bounds), CGRectGetHeight(frame)}];
        [beSignedOnlineButton setBackgroundColor:[UIColor room107GreenColor]];
        [beSignedOnlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [beSignedOnlineButton setTitle:title forState:UIControlStateNormal];
        [beSignedOnlineButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        [beSignedOnlineButton addTarget:self action:@selector(beSignedOnlineButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:beSignedOnlineButton];
        
        UIView *seperateView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(frame), 0.5}];
        [seperateView setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:seperateView];
    }
    
    return self;
}

- (void)setContactOwnerButtonDidClickHandler:(void(^)())handler {
    _contactOwnerHandlerBlock = handler;
}

- (void)setBeSignedOnlineButtonDidClickHandler:(void (^)())handler {
    _beSignedOnlineHandlerBlock = handler;
}

- (IBAction)contactOwnerButtonDidClick:(id)sender {
    if (_contactOwnerHandlerBlock) {
        _contactOwnerHandlerBlock();
    }
}

- (IBAction)beSignedOnlineButtonDidClick:(id)sender {
    if (_beSignedOnlineHandlerBlock) {
        _beSignedOnlineHandlerBlock();
    }
}

@end