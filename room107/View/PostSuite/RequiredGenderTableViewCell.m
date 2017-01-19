//
//  RequiredGenderTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/1.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RequiredGenderTableViewCell.h"
#import "CustomSwitch.h"

@interface RequiredGenderTableViewCell ()

@property (nonatomic, strong) CustomSwitch *requiredGenderSwitch;

@end

@implementation RequiredGenderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originY = [self originTopY] + [self titleHeight] + 5;
        CGFloat switchHeight = 40;
        
        _requiredGenderSwitch = [[CustomSwitch alloc] initWithFrame:(CGRect){[self originLeftX], originY, CGRectGetWidth([self cellFrame]) - 2 * [self originLeftX], switchHeight} stringsArray:@[lang(@"NoLimitGender"), lang(@"FemaleLimit"), lang(@"MaleLimit")]];
        [self addSubview:_requiredGenderSwitch];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, requiredGenderTableViewCellHeight);
}

- (void)setRequiredGender:(NSInteger)requiredGender {
    switch (requiredGender) {
        case 1:
            [_requiredGenderSwitch setSelectedIndex:2];
            break;
        case 2:
            [_requiredGenderSwitch setSelectedIndex:1];
            break;
        default:
            [_requiredGenderSwitch setSelectedIndex:0];
            break;
    }
}

- (NSInteger)requiredGender {
    switch (_requiredGenderSwitch.selectedIndex) {
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        default:
            return 3;
            break;
    }
}

@end
