//
//  FourteenTemplateTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/19.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "FourteenTemplateTableViewCell.h"
#import "CustomLabel.h"

@interface FourteenTemplateTableViewCell()

@property (nonatomic, strong) CustomLabel *textTitleLabel;
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation FourteenTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setLineViewHidden:YES];
    if (self) {
        self.textTitleLabel = [[CustomLabel alloc] init];
        [_textTitleLabel setCornerRadius:2];
        [_textTitleLabel setTextColor:[UIColor whiteColor]];
        [_textTitleLabel setFont:[UIFont room107SystemFontOne]];
        [_textTitleLabel setBackgroundColor:[UIColor room107GrayColorC]];
        [_textTitleLabel setNumberOfLines:1];
        [_textTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_textTitleLabel];
    }
    return self;
}

- (void)setFourteenTemplateInfo:(NSDictionary *)info {
    NSString *text = info[@"text"];
    _holdTargetURLs = info[@"holdTargetUrl"];
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 22;
    CGRect contentRect = [text boundingRectWithSize:(CGSize){maxWidth, 24} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textTitleLabel.font} context:nil];
    CGFloat width = contentRect.size.width + 15;
    CGFloat originX = ([UIScreen mainScreen].bounds.size.width - width) / 2 ;
    [_textTitleLabel setFrame:CGRectMake(originX, 11, width, 24)];
    [_textTitleLabel setText:text];
    
    UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
    longPressGestureRec.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPressGestureRec];
}

- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler {
    _viewDidLongPressHandlerBlock = handler;
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan) {
        //避免长按事件执行两次
        if (_viewDidLongPressHandlerBlock) {
            _viewDidLongPressHandlerBlock(_holdTargetURLs);
        }
    }
}

@end
