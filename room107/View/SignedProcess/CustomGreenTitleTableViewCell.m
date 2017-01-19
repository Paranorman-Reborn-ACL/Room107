//
//  CustomGreenTitleTableViewCell.m
//  room107
//
//  Created by 107间 on 16/3/16.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "CustomGreenTitleTableViewCell.h"

@interface CustomGreenTitleTableViewCell()

@property (nonatomic, strong)UILabel *titleLabel;
@end

@implementation CustomGreenTitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont room107SystemFontThree]];
        [_titleLabel setTextColor:[UIColor room107GreenColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *)title {
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    [_titleLabel setText:title];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel setFrame:self.contentView.frame];
}

@end
