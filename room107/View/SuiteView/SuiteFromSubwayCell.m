//
//  SuiteFromSubwayCell.m
//  room107
//
//  Created by 107间 on 16/1/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuiteFromSubwayCell.h"

@interface SuiteFromSubwayCell()


@end

@implementation SuiteFromSubwayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.subwayLabel = [[UILabel alloc] init];
        [_subwayLabel setFont:[UIFont room107SystemFontThree]];
        [_subwayLabel setTextColor:[UIColor room107GrayColorD]];
        [_subwayLabel setFrame:self.frame];
//        [_subwayLabel setBackgroundColor:[UIColor redColor]];
        [_subwayLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_subwayLabel];
        _subwayLabel.highlightedTextColor = [UIColor room107GreenColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_subwayLabel setFrame:self.contentView.frame];
}

- (void)setSubwayName:(NSString *)title {
    [self.subwayLabel setText:title];
}

@end
