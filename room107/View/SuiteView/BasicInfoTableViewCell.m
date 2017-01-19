//
//  BasicInfoTableViewCell.m
//  room107
//
//  Created by ningxia on 15/6/25.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "BasicInfoTableViewCell.h"
#import "ThirteenTemplateView.h"
#import "BasicInfoView.h"
#import "SearchTipLabel.h"

static CGFloat spaceY = 11;

@interface BasicInfoTableViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) BasicInfoView *nameView;
@property (nonatomic, strong) BasicInfoView *areaView;
@property (nonatomic, strong) BasicInfoView *floorView;
@property (nonatomic, strong) BasicInfoView *orientationView;
@property (nonatomic) CGFloat viewHeight;
@property (nonatomic) CGFloat originY;

@end

@implementation BasicInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorA]];
        _originY = spaceY;
        CGFloat viewWidth = CGRectGetWidth([self cellFrame]);
        _containerView = [[UIView alloc] initWithFrame:(CGRect){0, _originY, viewWidth, basicInfoViewMinHeight - _originY}];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_containerView];
        
        ThirteenTemplateView *titleView = [[ThirteenTemplateView alloc] initWithFrame:(CGRect){0, 0, viewWidth, 36} andTemplateDataDictionary:@{@"image":@"trim.png", @"text":lang(@"BasicInfo")}];
        [_containerView addSubview:titleView];
        
        CGFloat originX = 11;
        CGFloat basicInfoViewWidth = viewWidth - 2 * originX;
        _originY += CGRectGetHeight(titleView.bounds);
        _nameView = [[BasicInfoView alloc] initWithFrame:(CGRect){originX * 2, _originY, basicInfoViewWidth, basicInfoItemHeight}];
        [_containerView addSubview:_nameView];
        
        _areaView = [[BasicInfoView alloc] initWithFrame:(CGRect){originX * 2, 0, basicInfoViewWidth, basicInfoItemHeight}];
        [_containerView addSubview:_areaView];
        
        _floorView = [[BasicInfoView alloc] initWithFrame:(CGRect){originX * 2, 0, basicInfoViewWidth, basicInfoItemHeight}];
        [_containerView addSubview:_floorView];
        
        _orientationView = [[BasicInfoView alloc] initWithFrame:(CGRect){originX * 2, 0, basicInfoViewWidth, basicInfoItemHeight}];
        [_containerView addSubview:_orientationView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, basicInfoViewMinHeight);
}

- (void)setName:(NSString *)name {
    [_nameView setContent:name withType:BasicInfoViewTypeName];
    _viewHeight = basicInfoViewMinHeight;
    _originY = _nameView.frame.origin.y + basicInfoItemHeight;
}

- (void)setAreaContent:(NSString *)area {
    _areaView.hidden = !(area.length > 0);
    if (!_areaView.hidden) {
        CGRect viewFrame = _areaView.frame;
        viewFrame.origin.y = _originY;
        [_areaView setFrame:viewFrame];
        _viewHeight += basicInfoItemHeight;
        _originY += basicInfoItemHeight;
    }
    [_areaView setContent:area withType:BasicInfoViewTypeArea];
}

- (void)setFloor:(NSNumber *)floor {
    _floorView.hidden = floor ? [floor isEqual:@0] ? YES : NO : YES;
    if (!_floorView.hidden) {
        CGRect viewFrame = _floorView.frame;
        viewFrame.origin.y = _originY;
        [_floorView setFrame:viewFrame];
        _viewHeight += basicInfoItemHeight;
        _originY += basicInfoItemHeight;
    }
    [_floorView setContent:[NSString stringWithFormat:@"%@%@", floor, lang(@"Floor")] withType:BasicInfoViewTypeFloor];
}

- (void)setOrientation:(NSString *)orientation {
    CGRect frame = _containerView.frame;
    if (orientation.length > 0) {
        CGRect viewFrame = _orientationView.frame;
        viewFrame.origin.y = _originY;
        [_orientationView setFrame:viewFrame];
        _orientationView.hidden = NO;
        [_orientationView setContent:[NSString stringWithFormat:@"%@%@", [lang(@"Orientation") substringToIndex:1], orientation] withType:BasicInfoViewTypeOrientation];
        _viewHeight += basicInfoItemHeight;
    } else {
        _orientationView.hidden = YES;
    }
    frame.size.height = _viewHeight - spaceY;
    [_containerView setFrame:frame];
}

@end
