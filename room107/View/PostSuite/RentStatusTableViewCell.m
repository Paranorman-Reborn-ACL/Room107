//
//  RentStatusTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RentStatusTableViewCell.h"
#import "CustomSwitch.h"

@interface RentStatusTableViewCell () <DVSwitchDelegate>

@property (nonatomic, strong) CustomSwitch *rentStatusSwitch;
@property (nonatomic, strong) void (^selectRentStatusHandlerBlock)(NSInteger type);

@end

@implementation RentStatusTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        _rentStatusSwitch = [[CustomSwitch alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], CGRectGetHeight([self cellFrame]) - originY - [self originBottomY]} stringsArray:@[[lang(@"Open") stringByAppendingString:lang(@"Rent")], [lang(@"Closed") stringByAppendingString:lang(@"Rent")]]];
        _rentStatusSwitch.delegate = self;
        [self addSubview:_rentStatusSwitch];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, rentStatusTableViewCellHeight);
}

- (void)setSelectRentStatusHandler:(void (^)(NSInteger))handler {
    _selectRentStatusHandlerBlock = handler;
}

- (void)setRentStatus:(NSInteger)status {
    [_rentStatusSwitch selectIndex:status animated:NO];
    
    [self selectedIndexChanged:_rentStatusSwitch];
}

- (NSInteger)rentStatus {
    return _rentStatusSwitch.selectedIndex;
}

#pragma mark - DVSwitchDelegate
- (void)selectedIndexChanged:(DVSwitch *)DVSwitch {
    if ([DVSwitch isEqual:_rentStatusSwitch]) {
        if (self.selectRentStatusHandlerBlock) {
            self.selectRentStatusHandlerBlock(DVSwitch.selectedIndex);
        }
    }
}

@end
