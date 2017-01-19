//
//  OneTemplateTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/15.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "OneTemplateTableViewCell.h"
#import "OneSubTemplateView.h"

@interface OneTemplateTableViewCell()

@property (nonatomic, strong) OneSubTemplateView *subOneTemplateViewLeft;
@property (nonatomic, strong) OneSubTemplateView *subOneTemplateViewCenter;
@property (nonatomic, strong) OneSubTemplateView *subOneTemplateViewRight;
@property (nonatomic, copy) buttonClickHandler buttonClickHandler;
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation OneTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 3;
        WEAK_SELF weakSelf = self;
        self.subOneTemplateViewLeft = [[OneSubTemplateView alloc] initWithFrame:CGRectMake(0, 0, width, oneTemplateTableViewCellheight)];
        _subOneTemplateViewLeft.buttonClickHandlerBlock = ^(NSArray *targetURLs) {
            if (weakSelf.buttonClickHandler) {
                weakSelf.buttonClickHandler(targetURLs);
            }
        };

        _subOneTemplateViewLeft.buttonDidLongPressHandlerBlock = ^(NSArray *holdTargetURLs) {
            if (weakSelf.viewDidLongPressHandlerBlock) {
                weakSelf.viewDidLongPressHandlerBlock(holdTargetURLs);
            }
        };
        [self.contentView addSubview:_subOneTemplateViewLeft];
        
        self.subOneTemplateViewCenter = [[OneSubTemplateView alloc] initWithFrame:CGRectMake(width, 0, width, oneTemplateTableViewCellheight)];
        _subOneTemplateViewCenter.buttonClickHandlerBlock = ^(NSArray *targetURLs) {
            if (weakSelf.buttonClickHandler) {
                weakSelf.buttonClickHandler(targetURLs);
            }
        };
        _subOneTemplateViewCenter.buttonDidLongPressHandlerBlock = ^(NSArray *holdTargetURLs) {
            if (weakSelf.viewDidLongPressHandlerBlock) {
                weakSelf.viewDidLongPressHandlerBlock(holdTargetURLs);
            }
        };
        [self.contentView addSubview:_subOneTemplateViewCenter];
        
        self.subOneTemplateViewRight = [[OneSubTemplateView alloc] initWithFrame:CGRectMake(width * 2, 0, width, oneTemplateTableViewCellheight)];
        _subOneTemplateViewRight.buttonClickHandlerBlock = ^(NSArray *targetURLs) {
            if (weakSelf.buttonClickHandler) {
                weakSelf.buttonClickHandler(targetURLs);
            }
        };
        _subOneTemplateViewRight.buttonDidLongPressHandlerBlock = ^(NSArray *holdTargetURLs) {
            if (weakSelf.viewDidLongPressHandlerBlock) {
                weakSelf.viewDidLongPressHandlerBlock(holdTargetURLs);
            }
        };
        [self.contentView addSubview:_subOneTemplateViewRight];
        
        UIView *leftLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_subOneTemplateViewLeft.frame) - 0.5, 11, 1, 42)];
        [leftLineView setBackgroundColor:[UIColor room107GrayColorB]];
        [self.contentView addSubview:leftLineView];
        
        UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_subOneTemplateViewCenter.frame) - 0.5, 11, 1, 42)];
        [rightLineView  setBackgroundColor:[UIColor room107GrayColorB]];
        [self.contentView addSubview:rightLineView];

    };
    return self;
}

- (void)setTemplateDataArray:(NSArray *)dataArray {
    if (0 < dataArray.count) {
        [_subOneTemplateViewLeft setSubTemplateInfo:dataArray[0]];
    }
    if (1 < dataArray.count) {
        [_subOneTemplateViewCenter setSubTemplateInfo:dataArray[1]];
    }
    if (2 < dataArray.count) {
        [_subOneTemplateViewRight setSubTemplateInfo:dataArray[2]];
    }
}

- (void)setViewDidClickHandler:(buttonClickHandler)buttonClickHandler {
    _buttonClickHandler = buttonClickHandler;
}

- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler {
    _viewDidLongPressHandlerBlock = handler;
}


@end
