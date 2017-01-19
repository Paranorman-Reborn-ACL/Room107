//
//  ContactOwnerButton.h
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRoundButton.h"

typedef enum {
    ContactOwnerButtonStyleRetract = 0, //
    ContactOwnerButtonStyleNormal, //
    ContactOwnerButtonStyleExpand, //
} ContactOwnerButtonStyle;

typedef enum {
    ContactOwnerButtonExpandDirectionLeft = 0, //
    ContactOwnerButtonExpandDirectionRight, //
} ContactOwnerButtonExpandDirection;

@protocol ContactOwnerButtonDelegate;

@interface ContactOwnerButton : CustomRoundButton

@property (nonatomic, strong) CustomButton *weChatButton;
@property (nonatomic, strong) CustomButton *phoneButton;
@property (nonatomic, strong) CustomButton *qqButton;
@property (nonatomic) NSUInteger buttonStyle;
@property (nonatomic, strong) id<ContactOwnerButtonDelegate> delegate;

- (void)changeContactOwnerButtonStyle;
- (void)setContactOwnerButtonStyle:(ContactOwnerButtonStyle)style;
- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets;
- (void)setContactOwnerButtonExpandDirection:(ContactOwnerButtonExpandDirection)direction;

@end

@protocol ContactOwnerButtonDelegate <NSObject>

- (void)contactOwnerButtonDidClick:(CustomButton *)button;
- (void)contactInfoButtonDidClick:(NSUInteger)buttonStyle;

@end
