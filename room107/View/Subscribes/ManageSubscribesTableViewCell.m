//
//  ManageSubscribesTableViewCell.m
//  room107
//
//  Created by ningxia on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ManageSubscribesTableViewCell.h"

@interface ManageSubscribesTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *subscribePositonLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)();

@end

@implementation ManageSubscribesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11.0f;
        CGFloat originY = 11;
        
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - originY;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        containerView.layer.cornerRadius = [CommonFuncs cornerRadius];
        containerView.layer.masksToBounds = YES;
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:containerView];
        
        UILongPressGestureRecognizer *containerViewRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        containerViewRec.minimumPressDuration = 0.5f;
        [containerView addGestureRecognizer:containerViewRec];
        
        originY = 5;
        CGFloat labelWidth = containerViewWidth - 2 * originX;
        CGFloat labelHeight = 30;
        _subscribePositonLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_subscribePositonLabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:_subscribePositonLabel];
        
        originY += CGRectGetHeight(_subscribePositonLabel.bounds);
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth - 2 * originX, labelHeight / 2}];
        [_contentLabel setFont:[UIFont room107SystemFontTwo]];
        [containerView addSubview:_contentLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, manageSubscribesTableViewCellHeight);
}

- (void)setPosition:(NSString *)position {
    [_subscribePositonLabel setText:position];
}

- (void)setContent:(NSString *)content {
    [_contentLabel setText:content];
}

- (void)setViewDidLongPressHandler:(void(^)())handler {
    _viewDidLongPressHandlerBlock = handler;
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (_viewDidLongPressHandlerBlock) {
            _viewDidLongPressHandlerBlock();
        }
    }
}

@end
