//
//  SelectOtherTypeTableViewCell.m
//  room107
//
//  Created by ningxia on 16/3/24.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SelectOtherTypeTableViewCell.h"
#import "SearchTipLabel.h"

@interface SelectOtherTypeTableViewCell ()

@property (nonatomic, strong) SearchTipLabel *displayLabel;

@end

@implementation SelectOtherTypeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        
        _displayLabel = [[SearchTipLabel alloc] initWithFrame:[self cellFrame]];
        [_displayLabel setFont:[UIFont room107FontTwo]];
        [_displayLabel setTextColor:[UIColor room107GrayColorD]];
        [_displayLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_displayLabel];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, selectOtherTypeTableViewCellHeight);
}

- (void)setDisplayText:(NSString *)text {
    [_displayLabel setText:text];
}

@end
