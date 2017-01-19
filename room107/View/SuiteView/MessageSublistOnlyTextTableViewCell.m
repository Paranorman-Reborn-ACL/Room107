//
//  MessageSublistOnlyTextTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/21.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "MessageSublistOnlyTextTableViewCell.h"

@interface MessageSublistOnlyTextTableViewCell()

@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UIButton *noMessageBtn;

@end

@implementation MessageSublistOnlyTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(NSNumber *)type {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat originY = 235 / 2;
        CGFloat originX = (cellWidth - 60) / 2;
        self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 60, 60)];
        _iconLabel.layer.cornerRadius = 30;
        _iconLabel.layer.masksToBounds = YES;
        [_iconLabel setBackgroundColor:[UIColor room107GrayColorC]];
        [_iconLabel setFont:[UIFont room107FontFive]];
        [_iconLabel setTextColor:[UIColor whiteColor]];
        [_iconLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_iconLabel];
        
        originY = CGRectGetMaxY(_iconLabel.frame) + 22;

        self.noMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_noMessageBtn setFrame:CGRectMake(0, originY, cellWidth, 60)];
        [_noMessageBtn.titleLabel setNumberOfLines:0];
        [_noMessageBtn.titleLabel setFont:[UIFont room107SystemFontTwo]];
        [_noMessageBtn setTitleColor:[UIColor room107GrayColorD] forState:UIControlStateNormal];
        [_noMessageBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [self.contentView addSubview:_noMessageBtn];
        
        NSInteger num = type ? [type integerValue] : 999;
        switch (num) {
            case 0:
                //系统
                [_iconLabel setText:@"\ue687"];
                [_noMessageBtn setTitle:lang(@"NoSystemMessage") forState:UIControlStateNormal];
                break;
            case 1:
                //签约
                [_iconLabel setText:@"\ue651"];
                [_noMessageBtn setTitle:lang(@"NoContractMessage") forState:UIControlStateNormal];
                break;
            case 2:
                //活动
                [_iconLabel setText:@"\ue688"];
                [_noMessageBtn setTitle:lang(@"NoActivityMessage") forState:UIControlStateNormal];
                break;
            default:
                //其他
                [_iconLabel setHidden:YES];
                [_noMessageBtn setTitle:lang(@"HasNoMessage") forState:UIControlStateNormal];
                break;
        }
        
    }
    return self;
}

@end
