//
//  ElevenTemplateTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/19.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ElevenTemplateTableViewCell.h"
#import "CustomImageView.h"

@interface ElevenTemplateTableViewCell()

@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UILabel *textTitleLabel;
@property (nonatomic, strong) UILabel *subtextTitleLabel;
@property (nonatomic, strong) CustomImageView *contenImageView;
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation ElevenTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self step];
    }
    return self;
}

/*
 public String text;
 
 public String subtext;
 
 public String imageUrl;
 
 public Integer imageWidth;
 
 public Integer imageHeight;
 
 public List<String> targetUrl;
 
 */

- (void)step {
    self.backGroundView = [[UIView alloc] init];
    [_backGroundView setBackgroundColor:[UIColor whiteColor]];
    _backGroundView.layer.cornerRadius = 4;
    _backGroundView.layer.masksToBounds = YES;
    [self.contentView addSubview:_backGroundView];
    
    self.textTitleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_textTitleLabel];
    [_textTitleLabel setNumberOfLines:0];
    [_textTitleLabel setFont:[UIFont room107SystemFontThree]];
    [_textTitleLabel setTextColor:[UIColor room107GrayColorD]];
    [self.backGroundView addSubview:_textTitleLabel];
    
    self.contenImageView = [[CustomImageView alloc] init];
    [self.backGroundView addSubview:_contenImageView];
    
    self.subtextTitleLabel = [[UILabel alloc] init];
    [_subtextTitleLabel setNumberOfLines:0];
    [_subtextTitleLabel setFont:[UIFont room107SystemFontOne]];
    [_subtextTitleLabel setTextColor:[UIColor room107GrayColorC]];
    [self.backGroundView addSubview:_subtextTitleLabel];

}
- (void)setElevenTemplateInfo:(NSDictionary *)info {
    NSString *text = info[@"text"];
    NSString *subtext = info[@"subtext"];
    NSString *imageUrl = info[@"imageUrl"];
    CGFloat imageWidth = [info[@"imageWidth"] floatValue];
    CGFloat imageHeight = [info[@"imageHeight"] floatValue];

    CGFloat originX = 11.0f;
    CGFloat originY = 11.0f;
    CGFloat backGroundWidth = [UIScreen mainScreen].bounds.size.width - 2 * originX;
    CGFloat elementWidth = [UIScreen mainScreen].bounds.size.width - 4 * originX;

    if (text && ![text isEqualToString:@""]) {
        //有标题
        CGRect contentRect = [text boundingRectWithSize:CGSizeMake(elementWidth, 38.5) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontThree]} context:nil];
        [_textTitleLabel setFrame:CGRectMake(originX, originY, elementWidth, contentRect.size.height)];
        [_textTitleLabel setText:text];
        originY = CGRectGetMaxY(_textTitleLabel.frame) + 11;
    }
    
    if (imageUrl && ![imageUrl isEqualToString:@""]) {
        if (0 == imageWidth || 0 == imageHeight) {
            [_contenImageView setFrame:CGRectMake(originX, originY, elementWidth, elementWidth * 200 / 400)];
        } else {
            [_contenImageView setFrame:CGRectMake(originX, originY, elementWidth, elementWidth * imageHeight / imageWidth)];
        }
        [_contenImageView setImageWithURL:imageUrl];
        originY = CGRectGetMaxY(_contenImageView.frame) + 11;
    }
    
    if (subtext && ![subtext isEqualToString:@""]) {
        CGRect contentRect = [subtext boundingRectWithSize:CGSizeMake(elementWidth, 43) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontOne]} context:nil];
        [_subtextTitleLabel setFrame:CGRectMake(originX, originY, elementWidth, contentRect.size.height)];
        [_subtextTitleLabel setText:subtext];
        originY = CGRectGetMaxY(_subtextTitleLabel.frame) + 11;
    }
    
    [_backGroundView setFrame:CGRectMake(originX, 0, backGroundWidth, originY)];
}

- (void)setHoldTargetURL:(NSArray *)holdTargetURLs {
    if (holdTargetURLs && holdTargetURLs.count > 0) {
        _holdTargetURLs = holdTargetURLs;
        UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        longPressGestureRec.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:longPressGestureRec];
    }
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
