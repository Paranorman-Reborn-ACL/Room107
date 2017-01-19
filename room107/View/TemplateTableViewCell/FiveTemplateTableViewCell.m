//
//  FiveTemplateTableViewCell.m
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "FiveTemplateTableViewCell.h"
#import "SDCycleScrollView.h"
#import "SearchTipLabel.h"
#import "NSString+Encoded.h"

@interface FiveTemplateTableViewCell ()

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) SearchTipLabel *titleTextLabel;
@property (nonatomic, strong) SearchTipLabel *subtextLabel;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) void (^imageViewDidClickHandlerBlock)(NSArray *targetURLs);
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation FiveTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:self.contentView.frame imagesGroup:nil];
        _cycleScrollView.autoScroll = NO;
        self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        self.cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        self.cycleScrollView.dotColor = [UIColor room107GrayColorC];
        self.cycleScrollView.placeholderImage = [UIImage imageNamed:@"cycleScrollPlaceHolder.jpg"];
        [self.contentView addSubview:self.cycleScrollView];
        WEAK_SELF weakSelf = self;
        [self.cycleScrollView setViewDidScrollHandler:^(NSInteger index) {
            if (weakSelf.dataArray.count > index) {
                [weakSelf.titleTextLabel setText:weakSelf.dataArray[index][@"text"]];
                [weakSelf.subtextLabel setText:weakSelf.dataArray[index][@"subtext"]];
                [weakSelf.titleTextLabel setAlpha:0];
                [weakSelf.subtextLabel setAlpha:0];
                [UIView animateWithDuration:0.5 animations:^{
                    [weakSelf.titleTextLabel setAlpha:1];
                    [weakSelf.subtextLabel setAlpha:1];
                }];
            }
        }];
        
        _titleTextLabel = [[SearchTipLabel alloc] init];
        [_titleTextLabel setTextColor:[UIColor room107GrayColorE]];
        [_titleTextLabel setNumberOfLines:1];
        [self.contentView addSubview:_titleTextLabel];

        _subtextLabel = [[SearchTipLabel alloc] init];
        [_subtextLabel setFont:[UIFont room107SystemFontOne]];
        [_subtextLabel setNumberOfLines:1];
        [self.contentView addSubview:_subtextLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidClick:)];
        [self.contentView addGestureRecognizer:tapGesture];
        
        UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
        longPressGestureRec.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:longPressGestureRec];
    }
    
    return self;
}

- (void)setTemplateDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    for (NSDictionary *dataDic in _dataArray) {
        [imageURLs addObject:dataDic[@"imageUrl"]];
    }
    self.cycleScrollView.imageURLStringsGroup = imageURLs;
    if (dataArray.count > 0) {
        [_titleTextLabel setText:_dataArray[0][@"text"]];
        [_subtextLabel setText:_dataArray[0][@"subtext"]];
    }
}

- (void)setScrollImageViewFrame:(CGRect)frame {
    self.cycleScrollView.frame = frame;
    
    CGFloat originX = 11;
    CGFloat originY = CGRectGetHeight(_cycleScrollView.bounds) + 11;
    CGFloat labelWidth = CGRectGetWidth(frame) - 2 * originX;
    CGFloat labelHeight = 16;
    [_titleTextLabel setFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
    
    originY += CGRectGetHeight(_titleTextLabel.bounds) + 8;
    labelHeight = 12;
    [_subtextLabel setFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
}

- (void)setImageViewDidClickHandler:(void(^)(NSArray *targetURLs))handler {
    _imageViewDidClickHandlerBlock = handler;
}

- (void)viewDidClick:(UIGestureRecognizer *)rec {
    NSUInteger index = _cycleScrollView.indexOnPageControl;
    if (_dataArray.count > index) {
        NSArray *targetURLs = @[];
        if (_dataArray[index][@"targetUrl"] != NSNull.null) {
            //对象不为<null>
            targetURLs = _dataArray[index][@"targetUrl"];
        }
        if (_imageViewDidClickHandlerBlock) {
            _imageViewDidClickHandlerBlock(targetURLs);
        }
    }
}

- (void)setHoldTargetURL:(NSArray *)holdTargetURLs {
    _holdTargetURLs = holdTargetURLs;

}

- (void)setViewDidLongPressHandler:(void(^)(NSArray *holdTargetURLs))handler {
    _viewDidLongPressHandlerBlock = handler;
}

- (void)containerViewDidLongPress:(UILongPressGestureRecognizer *)rec {
    NSUInteger index = _cycleScrollView.indexOnPageControl;
    if (_dataArray.count > index) {
        NSArray *targetURLs = @[];
        if (_dataArray[index][@"holdTargetUrl"] != NSNull.null) {
            //对象不为<null>
            targetURLs = _dataArray[index][@"holdTargetUrl"];
        }
        if (rec.state == UIGestureRecognizerStateBegan) {
            //避免长按事件执行两次
            if (_viewDidLongPressHandlerBlock) {
                _viewDidLongPressHandlerBlock(_holdTargetURLs);
            }
        }
    }
}

@end
