//
//  CustomSwitchTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/22.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "CustomSwitchTableViewCell.h"
#import "CustomSwitch.h"

@interface CustomSwitchTableViewCell () <DVSwitchDelegate>

@property (nonatomic, strong) CustomSwitch *customSwitch;
@property (nonatomic, strong) void (^switchIndexDidChangeHandlerBlock)(NSInteger index);

@end

@implementation CustomSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, customSwitchTableViewCellHeight);
}

- (void)setStringsArray:(NSArray *)strings withOffsetY:(CGFloat)offsetY {
    if (!_customSwitch) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5 + offsetY;
        CGFloat switchHeight = 40;
        
        _customSwitch = [[CustomSwitch alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], switchHeight} stringsArray:strings];
        _customSwitch.delegate = self;
        [self.contentView addSubview:_customSwitch];
    }
}

- (void)setSwitchIndex:(NSInteger)index {
    [_customSwitch setSelectedIndex:index];
    [_customSwitch layoutSubviews];
}

- (void)setSwitchIndexDidChangeHandler:(void(^)(NSInteger index))handler {
    _switchIndexDidChangeHandlerBlock = handler;
}

- (NSInteger)switchIndex {
    return _customSwitch.selectedIndex;
}

#pragma mark - DVSwitchDelegate
- (void)selectedIndexChanged:(DVSwitch *)DVSwitch {
    if ([_customSwitch isEqual:DVSwitch]) {
        if (_switchIndexDidChangeHandlerBlock) {
            _switchIndexDidChangeHandlerBlock(_customSwitch.selectedIndex);
        }
    }
}

@end
