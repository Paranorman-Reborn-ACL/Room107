//
//  SuiteRegionTableViewCell.m
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteRegionTableViewCell.h"
#import "SearchTipLabel.h"
#import "NYPickerComponent.h"

//朝阳, 海淀, 东城, 西城, 通州, 昌平, 丰台, 房山, 延庆, 门头沟, 石景山, 平谷, 怀柔, 大兴, 密云, 顺义;
//NSArray *serverRegionArray = @[@"朝阳", @"海淀", @"东城", @"西城", @"通州", @"昌平", @"丰台", @"房山", @"延庆", @"门头沟", @"石景山", @"平谷", @"怀柔", @"大兴", @"密云", @"顺义"];

@interface SuiteRegionTableViewCell ()

@property (nonatomic, strong) NYPickerComponent *regionPickerComponent;
@property (nonatomic, strong) SearchTipLabel *countOfRenterLabel;
@property (nonatomic, strong) NSArray *regionArray;
@property (nonatomic, strong) NSArray *serverRegionArray;
@property (nonatomic, strong) void (^handlerBlock)(NSInteger index);

@end

@implementation SuiteRegionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        _serverRegionArray = @[@"朝阳", @"海淀", @"东城", @"西城", @"通州", @"昌平", @"丰台", @"房山", @"延庆", @"门头沟", @"石景山", @"平谷", @"怀柔", @"大兴", @"密云", @"顺义"];
        CGFloat pickerWidth = 100.0f;
        _regionArray = @[@"朝阳", @"海淀", @"丰台", @"西城", @"东城", @"石景山", @"昌平", @"大兴", @"通州", @"顺义", @"房山", @"门头沟", @"怀柔", @"平谷", @"密云", @"延庆"];
        _regionPickerComponent = [[NYPickerComponent alloc] initWithFrame:(CGRect){(CGRectGetWidth([self cellFrame]) - pickerWidth) / 2, originY, pickerWidth, 100} andStringsArray:_regionArray];
        [self addSubview:_regionPickerComponent];
        
        originY += CGRectGetHeight(_regionPickerComponent.bounds) + 10;
        _countOfRenterLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth([self cellFrame]), CGRectGetHeight([self cellFrame]) - [self originBottomY] - originY}];
        [_countOfRenterLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_countOfRenterLabel];
        
        WEAK_SELF weakSelf = self;
        [_regionPickerComponent setIndexDidChangeHandler:^(NSInteger index) {
            if (weakSelf.handlerBlock) {
                if (index < weakSelf.regionArray.count) {
                    weakSelf.handlerBlock([weakSelf.serverRegionArray indexOfObject:weakSelf.regionArray[index]]);
                }
            }
        }];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, suiteRegionTableViewCellHeight);
}

- (void)setRegionIndexDidChangeHandler:(void (^)(NSInteger))handler {
    self.handlerBlock = handler;
    if (self.handlerBlock) {
        self.handlerBlock([self.serverRegionArray indexOfObject:self.regionArray[0]]);
    }
}

- (void)setCountOfRenter:(NSString *)count {
    NSString *countOfRenter = [count ? count : @"0" stringByAppendingString:lang(@"CountOfRenter")];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:countOfRenter];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFive] range:NSMakeRange(0, countOfRenter.length - lang(@"CountOfRenter").length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107YellowColor] range:NSMakeRange(0, countOfRenter.length - lang(@"CountOfRenter").length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontTwo] range:NSMakeRange(countOfRenter.length - lang(@"CountOfRenter").length, lang(@"CountOfRenter").length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor room107GrayColorD] range:NSMakeRange(countOfRenter.length - lang(@"CountOfRenter").length, lang(@"CountOfRenter").length)];
    [_countOfRenterLabel setAttributedText:attributedString];
}

- (void)setDistrict:(NSNumber *)district {
    if ([district integerValue] < self.serverRegionArray.count) {
        [_regionPickerComponent setSelectedIndex:[self.regionArray indexOfObject:self.serverRegionArray[[district integerValue]]]];
    }
}

- (NSNumber *)district {
    if (_regionPickerComponent.selectedIndex < self.regionArray.count) {
        return [NSNumber numberWithUnsignedInteger:[self.serverRegionArray indexOfObject:self.regionArray[_regionPickerComponent.selectedIndex]]];
    }
    
    return @0;
}

@end
