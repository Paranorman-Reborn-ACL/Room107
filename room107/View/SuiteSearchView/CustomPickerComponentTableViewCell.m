//
//  CustomPickerComponentTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/22.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "CustomPickerComponentTableViewCell.h"
#import "NYPickerComponent.h"
#import "SearchTipLabel.h"

@interface CustomPickerComponentTableViewCell ()

@property (nonatomic, strong) NYPickerComponent *pickerComponent;
@property (nonatomic, strong) void (^selectedIndexDidChangeHandlerBlock)(NSInteger index);

@end

@implementation CustomPickerComponentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, customPickerComponentTableViewCellHeight);
}

- (void)setStringsArray:(NSArray *)strings withOffsetY:(CGFloat)offsetY withUnit:(NSString *)unit {
    CGFloat originY = [self originTopY] + [self titleHeight] + 5 + offsetY;
    CGFloat pickerWidth = 130.0f;
    CGFloat pickerHeight = 90;
    CGFloat tipsWidth = 16;
    if (!_pickerComponent) {
        _pickerComponent = [[NYPickerComponent alloc] initWithFrame:(CGRect){(CGRectGetWidth([self cellFrame]) - pickerWidth) / 2 - 5, originY, pickerWidth, pickerHeight} andStringsArray:strings];
        [self.contentView addSubview:_pickerComponent];
        WEAK_SELF weakSelf = self;
        [_pickerComponent setIndexDidChangeHandler:^(NSInteger index) {
            if (weakSelf.selectedIndexDidChangeHandlerBlock) {
                weakSelf.selectedIndexDidChangeHandlerBlock(index);
            }
        }];
        
        if (unit && ![unit isEqualToString:@""]) {
            SearchTipLabel *unitTips = [[SearchTipLabel alloc] initWithFrame:(CGRect){_pickerComponent.center.x + 25, _pickerComponent.center.y - tipsWidth / 2 + 2, tipsWidth, tipsWidth}];
            [unitTips setText:lang(@"Room")];
            [self.contentView addSubview:unitTips];
        }
    }
}

- (void)setSelectedIndex:(NSInteger)index {
    [_pickerComponent setSelectedIndex:index];
}

- (void)setSelectedIndexDidChangeHandler:(void(^)(NSInteger index))handler {
    _selectedIndexDidChangeHandlerBlock = handler;
}

- (NSInteger)selectedIndex {
    return _pickerComponent.selectedIndex;
}

@end
