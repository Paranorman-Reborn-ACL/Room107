//
//  FloorTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "FloorTableViewCell.h"
#import "NYPickerComponent.h"

static NSInteger maxFloorNum = 30;

@interface FloorTableViewCell ()

@property (nonatomic, strong) NYPickerComponent *floorPickerComponent;

@end

@implementation FloorTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        NSMutableArray *floorArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < maxFloorNum; i++) {
            [floorArray addObject:[NSString stringWithFormat:@"%ld", (long)i + 1]];
        }
        CGFloat pickerWidth = 50.0f;
        _floorPickerComponent = [[NYPickerComponent alloc] initWithFrame:(CGRect){(CGRectGetWidth([self cellFrame]) - pickerWidth) / 2, originY, pickerWidth, CGRectGetHeight([self cellFrame]) - originY - [self originBottomY]} andStringsArray:floorArray];
        [self addSubview:_floorPickerComponent];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, floorTableViewCellHeight);
}

- (void)setFloor:(NSNumber *)floor {
    if ([floor integerValue] - 1 < 0) {
        [_floorPickerComponent setSelectedIndex:0];
    } else {
        [_floorPickerComponent setSelectedIndex:MIN([floor integerValue] - 1, maxFloorNum - 1)];
    }
}

- (NSNumber *)floor {
    return [NSNumber numberWithInteger:_floorPickerComponent.selectedIndex + 1];
}

@end
