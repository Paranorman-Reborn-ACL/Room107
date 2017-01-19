//
//  MessageListTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "MessageListTableViewCell.h"
#import "SearchTipLabel.h"
#import "ReddieView.h"

@interface MessageListTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *messageTitleLabel;
@property (nonatomic, strong) SearchTipLabel *contentLabel;
@property (nonatomic, strong) ReddieView *reddieView;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)();

@end

@implementation MessageListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11.0f;
        CGFloat originY = 10;
        
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
        _messageTitleLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
        [_messageTitleLabel setTextColor:[UIColor room107GrayColorD]];
        [containerView addSubview:_messageTitleLabel];
        
        //未读标示
        _reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(originX + 65, originY + 5)];
        [containerView addSubview:_reddieView];
        
        originY += CGRectGetHeight(_messageTitleLabel.bounds);
        _contentLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth - 2 * originX, labelHeight / 2}];
        [_contentLabel setFont:[UIFont room107FontTwo]];
        [containerView addSubview:_contentLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, messageListTableViewCellHeight);
}

- (void)setMessageListItem:(MessageListItemModel *)item {
    [_messageTitleLabel setText:item.title];
    //计算文字的宽度
    CGRect contentRect = [item.title boundingRectWithSize:(CGSize){CGRectGetWidth(_messageTitleLabel.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_messageTitleLabel.font} context:nil];
    _reddieView.hidden = ![item.hasNewUpdate boolValue];
    CGRect frame = _reddieView.frame;
    frame.origin.x = _messageTitleLabel.frame.origin.x + contentRect.size.width;
    [_reddieView setFrame:frame];
    [_contentLabel setText:item.content];
}

- (void)setViewDidLongPressHandler:(void(^)())handler {
    self.viewDidLongPressHandlerBlock = handler;
}

- (void)setFlagHidden:(BOOL)hidden {
    _reddieView.hidden = hidden;
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (self.viewDidLongPressHandlerBlock) {
            self.viewDidLongPressHandlerBlock();
        }
    }
}

@end
