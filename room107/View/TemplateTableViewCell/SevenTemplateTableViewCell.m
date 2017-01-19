//
//  SevenTemplateTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SevenTemplateTableViewCell.h"
#import "ReddieView.h"
#import "CustomImageView.h"

@interface SevenTemplateTableViewCell()

@property (nonatomic, strong) CustomImageView *iconImageView; //图标
@property (nonatomic, strong) UILabel *textTitleLabel; //文字
@property (nonatomic, strong) ReddieView *reddieView;
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation SevenTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    if (self) {
        self.iconImageView = [[CustomImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        
        self.textTitleLabel = [[UILabel alloc] init];
        [_textTitleLabel setFont:[UIFont room107SystemFontThree]];
        [_textTitleLabel setTextColor:[UIColor room107GrayColorC]];
        [self.contentView addSubview:_textTitleLabel];
        
        self.reddieView = [[ReddieView alloc] initWithOrigin:CGPointMake(0, 0)];
        [_reddieView setHidden:YES];
        [self.contentView addSubview:_reddieView];
    }
    return self;
}

- (void)setSevenTemplateInfo:(NSDictionary *)info {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat diameter = 22.0f;
    CGFloat space = 11.0f;
    CGFloat originX;
    CGFloat originY;
    
    NSString *text = info[@"text"];
    NSString *imageUrl = info[@"imageUrl"];
    NSNumber *imageType = info[@"imageType"];
    NSNumber *reddie = info[@"reddie"];
    _holdTargetURLs = info[@"holdTargetUrl"];

    if (nil == text || [text isEqualToString:@""] ) {
        //缺少文字
        originX = (width - diameter) / 2 ;
        originY = 22;
        [_iconImageView setFrame:CGRectMake(originX, originY, diameter, diameter)];
        [_iconImageView setImageWithURL:imageUrl];
    } else if ( nil == imageUrl || [text isEqualToString:@""]) {
        //缺少图片
        CGRect contentRect = [text boundingRectWithSize:(CGSize){MAXFLOAT, sevenTemplateTableViewCellHeight} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107FontThree]} context:nil];
        originX = (width - contentRect.size.width) / 2;
        [_textTitleLabel setFrame:CGRectMake(originX, 0, contentRect.size.width, sevenTemplateTableViewCellHeight)];
        [_textTitleLabel setText:text];
        
    } else {
        //有图有文字
        CGRect contentRect = [text boundingRectWithSize:(CGSize){MAXFLOAT, sevenTemplateTableViewCellHeight} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107FontThree]} context:nil];
        originX = (width - diameter - space - contentRect.size.width) / 2;
        [_iconImageView setFrame:CGRectMake(originX, originY, diameter, diameter)];
        [_iconImageView setImageWithURL:imageUrl];
        
        [_textTitleLabel setFrame:CGRectMake(CGRectGetMaxX(_iconImageView.frame) + space, 0, contentRect.size.width, sevenTemplateTableViewCellHeight)];
        [_textTitleLabel setText:text];
    }
    
    if (imageType &&[imageType isEqual:@1]) {
        [_iconImageView setCornerRadius:_iconImageView.frame.size.width / 2];
    } else {
        [_iconImageView setCornerRadius:0];
    }
    
    if (reddie && [reddie isEqual:@1]) {
        [_reddieView setHidden:NO];
        [_reddieView resetOrigin:CGPointMake(CGRectGetMaxX(_textTitleLabel.frame) + 2, CGRectGetMinY(_textTitleLabel.frame) + 10)];
    } else {
        [_reddieView setHidden:YES];
    }
    UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
    longPressGestureRec.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPressGestureRec];
}

- (void)settTitleColor:(UIColor *)color {
    [_textTitleLabel setTextColor:color];
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
