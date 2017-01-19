//
//  DetailedAddressMapTableViewCell.m
//  room107
//
//  Created by 107间 on 16/4/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "DetailedAddressMapTableViewCell.h"
#import "CustomImageView.h"

@interface DetailedAddressMapTableViewCell()

@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) CustomImageView *mapImageView;
@property (nonatomic, strong) UILabel *tenantLabel;
@property (nonatomic, strong) UIButton *changePositionButton;

@end

@implementation DetailedAddressMapTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setBackgroundColor:[UIColor clearColor]];
    
    if (self) {
        CGFloat originY = [self originTopY] + 5;
        CGFloat originX = 22.0f;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 2 * originX;
        
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, 13)];
        [_subtitleLabel setFont:[UIFont room107SystemFontOne]];
        [_subtitleLabel setTextColor:[UIColor room107GrayColorC]];
        [_subtitleLabel setText:@"● 根据输入地址自动定位"];
        [self.contentView addSubview:_subtitleLabel];
        
        originY = CGRectGetMaxY(_subtitleLabel.frame) + 11;
        self.mapImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(originX, originY, width, width * 9 / 16)];
        [_mapImageView setBorderWidth:1 borderColor:[UIColor whiteColor]];
        [_mapImageView setContentMode:UIViewContentModeCenter];
        [_mapImageView setImageWithName:@"imageLoading"];
        [_mapImageView setBackgroundColor:[UIColor room107GrayColorB]];
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTap:)];
        [_mapImageView addGestureRecognizer:imageTap];
        _mapImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_mapImageView];
        
        originY = CGRectGetMaxY(_mapImageView.frame) + 15;
        self.tenantLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, 25)];
        [_tenantLabel setTextAlignment:NSTextAlignmentCenter];
        [_tenantLabel setTextColor:[UIColor room107GrayColorC]];
        [_tenantLabel setFont:[UIFont room107SystemFontThree]];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"107位附近找房的人将即刻收到推送"];
        [str setAttributes:@{NSFontAttributeName:[UIFont room107SystemFontFive], NSForegroundColorAttributeName:[UIColor room107YellowColor]} range:NSMakeRange(0, 3)];
        [_tenantLabel setAttributedText:str];
        [self.contentView addSubview:_tenantLabel];
        
        originY = CGRectGetMaxY(_tenantLabel.frame) + 22;
        self.changePositionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changePositionButton setFrame:CGRectMake(0, 0, 120, 30)];
        [_changePositionButton setCenter:CGPointMake((width + 2 * originX) / 2, originY + 15)];
        [_changePositionButton setTitleColor:[UIColor room107GreenColor] forState:UIControlStateNormal];
        [_changePositionButton setTitle:@"手动修正位置" forState:UIControlStateNormal];
        [_changePositionButton.titleLabel setFont:[UIFont room107SystemFontTwo]];
        [_changePositionButton setContentEdgeInsets:UIEdgeInsetsMake(7.5, 11, 7.5, 11)];
        [_changePositionButton.layer setBorderWidth:1];
        [_changePositionButton.layer setBorderColor:[UIColor room107GreenColor].CGColor];
        _changePositionButton.layer.masksToBounds = YES;
        [_changePositionButton.layer setCornerRadius:4];
        [_changePositionButton addTarget:self action:@selector(resetPosition:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_changePositionButton];
        
    }
    return self;
}

- (IBAction)mapTap:(id)sender {
    
}

- (IBAction)resetPosition:(id)sender {
    if (_resetPositionClickHandler) {
        _resetPositionClickHandler();
    }
}
@end
