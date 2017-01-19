//
//  RoomTypeTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RoomTypeTableViewCell.h"
#import "CustomSwitch.h"

@interface RoomTypeTableViewCell ()

@property (nonatomic, strong) CustomSwitch *roomTypeSwitch;

@end

@implementation RoomTypeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        _roomTypeSwitch = [[CustomSwitch alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], CGRectGetHeight([self cellFrame]) - originY - [self originBottomY]} stringsArray:@[lang(@"MasterBedroom"), lang(@"SecondaryBedroom")]];
        [self addSubview:_roomTypeSwitch];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, roomTypeTableViewCellHeight);
}

- (void)setRoomType:(NSInteger)type {
    if (type >= 1 && type <= 3) {
        [_roomTypeSwitch selectIndex:type - 1 animated:NO];
    } else {
        [_roomTypeSwitch selectIndex:0 animated:NO];
    }
}

- (NSInteger)roomType {
    //UNKNOWN, 主卧, 次卧, 客厅, 厨房, 卫生间, 其他;
    return _roomTypeSwitch.selectedIndex + 1;
}

@end
