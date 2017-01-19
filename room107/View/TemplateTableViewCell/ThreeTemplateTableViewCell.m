//
//  ThreeTemplateTableViewCell.m
//  room107
//
//  Created by ningxia on 16/4/11.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "ThreeTemplateTableViewCell.h"
#import "SDCycleScrollView.h"
#import "NSString+Encoded.h"

@interface ThreeTemplateTableViewCell () <SDCycleScrollViewDelegate>

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) void (^imageViewDidClickHandlerBlock)(NSArray *targetURLs);
@property (nonatomic, strong) NSArray *holdTargetURLs;
@property (nonatomic, strong) void (^viewDidLongPressHandlerBlock)(NSArray *holdTargetURLs);

@end

@implementation ThreeTemplateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:self.contentView.frame imagesGroup:nil];
        self.cycleScrollView.delegate = self;
        self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        self.cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        self.cycleScrollView.dotColor = [UIColor room107GrayColorC];
        self.cycleScrollView.placeholderImage = [UIImage imageNamed:@"cycleScrollPlaceHolder.jpg"];
        [self.contentView addSubview:self.cycleScrollView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cycleScrollView.frame = self.contentView.frame;
}

- (void)setTemplateDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    for (NSDictionary *dataDic in _dataArray) {
        [imageURLs addObject:dataDic[@"imageUrl"]];
    }
    self.cycleScrollView.imageURLStringsGroup = imageURLs;
    self.cycleScrollView.autoScroll = !(imageURLs.count == 1);
}

- (void)setImageViewDidClickHandler:(void(^)(NSArray *targetURLs))handler {
    _imageViewDidClickHandlerBlock = handler;
}

#pragma mark - cycleScrollViewDelegate
//轮播图点击事件监听
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
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
    UILongPressGestureRecognizer *longPressGestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewDidLongPress:)];
    longPressGestureRec.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPressGestureRec];
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
