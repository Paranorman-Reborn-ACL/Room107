//
//  OrientationSelectTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "OrientationSelectTableViewCell.h"
#import "EFCircularSlider.h"
#import "SearchTipLabel.h"

@interface OrientationSelectTableViewCell ()

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray *orientations;
@property (nonatomic, strong) EFCircularSlider *orientationSelectCircularSlider;
@property (nonatomic, strong) SearchTipLabel *centerLabel;

@end

@implementation OrientationSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGFloat sliderWidth = 132;
        _orientationSelectCircularSlider = [[EFCircularSlider alloc] initWithFrame:(CGRect){(CGRectGetWidth([self cellFrame]) - sliderWidth) / 2, originY, sliderWidth, sliderWidth}];
        
        CGFloat labelWidth = sliderWidth / 2;
        CGFloat labelHeight = 30;
        _centerLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){(sliderWidth - labelWidth) / 2, (sliderWidth - labelHeight) / 2, labelWidth, labelHeight}];
        [_centerLabel setTextColor:[UIColor room107GreenColor]];
        [_centerLabel setFont:[UIFont room107FontThree]];
        [_centerLabel setTextAlignment:NSTextAlignmentCenter];
        [_orientationSelectCircularSlider addSubview:_centerLabel];
        
        _orientations = @[@"东北", @"东", @"东南", @"南", @"西南", @"西", @"西北", @"北"];
        WEAK_SELF weakSelf = self;
        [_orientationSelectCircularSlider setSelectHandler:^(NSInteger index) {
            weakSelf.selectedIndex = index < 0 ? _orientations.count - 1 : index;
            [weakSelf.centerLabel setText:weakSelf.orientations[weakSelf.selectedIndex]];
        }];
        
        [_orientationSelectCircularSlider setFilledColor:[UIColor room107GrayColorB]];
        [_orientationSelectCircularSlider setUnfilledColor:[UIColor room107GrayColorB]];
        
        [_orientationSelectCircularSlider setHandleColor:[UIColor whiteColor]];
        
        [_orientationSelectCircularSlider setInnerMarkingLabels:@[@"", @"", @"", @"", @"", @"", @"", @""]];
        _orientationSelectCircularSlider.snapToLabels = YES;
        _orientationSelectCircularSlider.lineWidth = sliderWidth / 4;
        [self addSubview:_orientationSelectCircularSlider];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, orientationSelectTableViewCellHeight);
}

- (void)setOrientation:(NSString *)orientation {
    if (orientation && ![orientation isEqualToString:@""]) {
        //增加空串判断，避免数组越界
        _selectedIndex = [_orientations indexOfObject:orientation ? orientation : @"北"];
        [_centerLabel setText:_orientations[_selectedIndex]];
        [_orientationSelectCircularSlider setSelectedIndex:_selectedIndex == _orientations.count - 1 ? 0 : _selectedIndex + 1];
    }
}

- (NSString *)orientation {
    return _orientations[_selectedIndex];
}

@end
