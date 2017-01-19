//
//  FourTemplateTableViewCell.m
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "FourTemplateTableViewCell.h"
#import "FourSubTemplateView.h"

@interface FourTemplateTableViewCell ()

@property (nonatomic, strong) FourSubTemplateView *leftView;
@property (nonatomic, strong) FourSubTemplateView *rightView;
@property (nonatomic, strong) void (^viewDidClickHandlerBlock)(NSArray *targetURLs);
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation FourTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        CGFloat originX = 0;
        CGFloat viewWidth = CGRectGetWidth([self cellFrame]) / 2;
        CGFloat viewHeight = CGRectGetHeight([self cellFrame]);
        _leftView = [[FourSubTemplateView alloc] initWithFrame:(CGRect){originX, 0, viewWidth, viewHeight}];
        WEAK_SELF weakSelf = self;
        [_leftView setViewDidClickHandler:^(NSArray *targetURLs) {
            if (weakSelf.viewDidClickHandlerBlock) {
                weakSelf.viewDidClickHandlerBlock(targetURLs);
            }
        }];
        [self.contentView addSubview:_leftView];
        
        originX += CGRectGetWidth(_leftView.bounds);
        CGFloat originY = 11;
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, 0.5, CGRectGetHeight([self cellFrame]) - 2 * originY}];
        [lineView setBackgroundColor:[UIColor room107GrayColorB]];
        [self.contentView addSubview:lineView];
        
        _rightView = [[FourSubTemplateView alloc] initWithFrame:(CGRect){originX, 0, viewWidth, viewHeight}];
        [_rightView setViewDidClickHandler:^(NSArray *targetURLs) {
            if (weakSelf.viewDidClickHandlerBlock) {
                weakSelf.viewDidClickHandlerBlock(targetURLs);
            }
        }];
        [self.contentView addSubview:_rightView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, fourTemplateTableViewCellHeight);
}

- (void)setTemplateDataArray:(NSArray *)dataArray {
    if (dataArray.count > 1) {
        [_leftView setTemplateDataDictionary:dataArray[0]];
        [_rightView setTemplateDataDictionary:dataArray[1]];
    }
}

- (void)setViewDidClickHandler:(void(^)(NSArray *targetURLs))handler {
    _viewDidClickHandlerBlock = handler;
}

- (void)setHoldTargetURL:(NSArray *)holdTargetURLs {
    _holdTargetURLs = holdTargetURLs;
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
