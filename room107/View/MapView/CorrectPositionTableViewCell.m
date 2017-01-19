//
//  CorrectPositionTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/19.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "CorrectPositionTableViewCell.h"

@interface CorrectPositionTableViewCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation CorrectPositionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat space = 7.5;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat originY = (correctPositionTableViewCellHeight - 18 - 13 - space) / 2;
        CGFloat originX = 22.0f;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width - 2 * originX, 18)];
        [_nameLabel setTextColor:[UIColor room107GrayColorE]];
        [_nameLabel setFont:[UIFont room107SystemFontThree]];
        [self.contentView addSubview:_nameLabel];
        
        originY = CGRectGetMaxY(_nameLabel.frame) + space;
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY,  width - 2 * originX, 13)];
        [_addressLabel setTextColor:[UIColor room107GrayColorC]];
        [_addressLabel setFont:[UIFont room107SystemFontOne]];
        [self.contentView addSubview:_addressLabel];
    }
    return self;
}

-(void)setName:(NSString *)name andAddress:(NSString *)address {
    [_nameLabel setText:name];
    [_addressLabel setText:address];
}

@end
