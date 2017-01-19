//
//  SuiteTypeTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteTypeTableViewCell.h"
#import "SearchTipLabel.h"
#import "NYPickerComponent.h"

static NSInteger maxPickerNum = 4;
static NSInteger maxRoomNum = 9;

@interface SuiteTypeTableViewCell ()

@property (nonatomic, strong) NYPickerComponent *hallPickerComponent;
@property (nonatomic, strong) NYPickerComponent *roomPickerComponent;
@property (nonatomic, strong) NYPickerComponent *kitchenPickerComponent;
@property (nonatomic, strong) NYPickerComponent *toiletPickerComponent;

@end

@implementation SuiteTypeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGFloat pickerHeight = CGRectGetHeight([self cellFrame]) - originY - [self originBottomY];
        CGFloat pickerWidth = (CGRectGetWidth([self cellFrame]) - [self originLeftX] * 2 * 2) / 4;
        CGFloat tipsWidth = pickerHeight / 4;
        NSMutableArray *roomPickerArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < maxRoomNum; i++) {
            [roomPickerArray addObject:[NSString stringWithFormat:@"%ld", (long)i + 1]];
        }
        _roomPickerComponent = [[NYPickerComponent alloc] initWithFrame:(CGRect){[self originLeftX] * 2, originY, pickerWidth, pickerHeight} andStringsArray:roomPickerArray];
        [self addSubview:_roomPickerComponent];
        SearchTipLabel *roomTips = [[SearchTipLabel alloc] initWithFrame:(CGRect){_roomPickerComponent.center.x + 15, _roomPickerComponent.center.y - tipsWidth / 2, tipsWidth, tipsWidth}];
        [roomTips setText:lang(@"Room")];
        [self addSubview:roomTips];
        
        NSMutableArray *pickerArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < maxPickerNum; i++) {
            [pickerArray addObject:[NSString stringWithFormat:@"%ld", (long)i]];
        }
        _hallPickerComponent = [[NYPickerComponent alloc] initWithFrame:(CGRect){[self originLeftX] * 2 + pickerWidth, originY, pickerWidth, pickerHeight} andStringsArray:pickerArray];
        [self addSubview:_hallPickerComponent];
        SearchTipLabel *hallTips = [[SearchTipLabel alloc] initWithFrame:(CGRect){_hallPickerComponent.center.x + 15, _hallPickerComponent.center.y - tipsWidth / 2, tipsWidth, tipsWidth}];
        [hallTips setText:[lang(@"LivingRoom") substringFromIndex:1]];
        [self addSubview:hallTips];
        
        _kitchenPickerComponent = [[NYPickerComponent alloc] initWithFrame:(CGRect){[self originLeftX] * 2 + pickerWidth * 2, originY, pickerWidth, pickerHeight} andStringsArray:pickerArray];
        [self addSubview:_kitchenPickerComponent];
        SearchTipLabel *kitchenTips = [[SearchTipLabel alloc] initWithFrame:(CGRect){_kitchenPickerComponent.center.x + 15, _kitchenPickerComponent.center.y - tipsWidth / 2, tipsWidth, tipsWidth}];
        [kitchenTips setText:[lang(@"Kitchen") substringToIndex:1]];
        [self addSubview:kitchenTips];
        
        _toiletPickerComponent = [[NYPickerComponent alloc] initWithFrame:(CGRect){[self originLeftX] * 2 + pickerWidth * 3, originY, pickerWidth, pickerHeight} andStringsArray:pickerArray];
        [self addSubview:_toiletPickerComponent];
        SearchTipLabel *toiletTips = [[SearchTipLabel alloc] initWithFrame:(CGRect){_toiletPickerComponent.center.x + 15, _toiletPickerComponent.center.y - tipsWidth / 2, tipsWidth, tipsWidth}];
        [toiletTips setText:[lang(@"Toilet") substringToIndex:1]];
        [self addSubview:toiletTips];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, suiteTypeTableViewCellHeight);
}

- (void)setHallNumber:(NSNumber *)number {
    if ([number integerValue] - 1 < 0) {
        [_hallPickerComponent setSelectedIndex:0];
    } else {
        [_hallPickerComponent setSelectedIndex:MIN([number integerValue], maxPickerNum - 1)];
    }
}

- (void)setRoomNumber:(NSNumber *)number {
    if ([number integerValue] - 1 < 0) {
        [_roomPickerComponent setSelectedIndex:0];
    } else {
        [_roomPickerComponent setSelectedIndex:MIN([number integerValue] - 1, maxRoomNum - 1)];
    }
}

- (void)setKitchenNumber:(NSNumber *)number {
    if ([number integerValue] - 1 < 0) {
        [_kitchenPickerComponent setSelectedIndex:0];
    } else {
        [_kitchenPickerComponent setSelectedIndex:MIN([number integerValue], maxPickerNum - 1)];
    }
}

- (void)setToiletNumber:(NSNumber *)number {
    if ([number integerValue] - 1 < 0) {
        [_toiletPickerComponent setSelectedIndex:0];
    } else {
        [_toiletPickerComponent setSelectedIndex:MIN([number integerValue], maxPickerNum - 1)];
    }
}

- (NSNumber *)hallNumber {
    return [NSNumber numberWithInteger:_hallPickerComponent.selectedIndex];
}

- (NSNumber *)roomNumber {
    return [NSNumber numberWithInteger:_roomPickerComponent.selectedIndex + 1];
}

- (NSNumber *)kitchenNumber {
    return [NSNumber numberWithInteger:_kitchenPickerComponent.selectedIndex];
}

- (NSNumber *)toiletNumber {
    return [NSNumber numberWithInteger:_toiletPickerComponent.selectedIndex];
}

@end
