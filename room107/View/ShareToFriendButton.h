//
//  ShareToFriendButton.h
//  room107
//
//  Created by ningxia on 15/6/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRoundButton.h"

typedef enum {
    ShareToFriendButtonStyleRetract = 0, //
    ShareToFriendButtonStyleNormal, //
    ShareToFriendButtonStyleExpand, //
} ShareToFriendButtonStyle;

@protocol ShareToFriendButtonDelegate;

@interface ShareToFriendButton : CustomRoundButton

@property (nonatomic) NSUInteger buttonStyle;
@property (nonatomic, strong) CustomButton *weChatButton;
@property (nonatomic, strong) CustomButton *wechatMomentsButton;
@property (nonatomic, strong) CustomButton *qqButton;
@property (nonatomic, strong) id<ShareToFriendButtonDelegate> delegate;

- (void)setShareToFriendButtonStyle:(ShareToFriendButtonStyle)style;
- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets;

@end

@protocol ShareToFriendButtonDelegate <NSObject>

- (void)shareToButtonDidClick:(CustomButton *)button;

@end
