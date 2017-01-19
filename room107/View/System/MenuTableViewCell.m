//
//  MenuTableViewCell.m
//  room107
//
//  Created by ningxia on 15/9/19.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "MenuTableViewCell.h"
#import "IconLabel.h"
#import "SearchTipLabel.h"
#import "ReddieView.h"

@interface MenuTableViewCell ()

@property (nonatomic, strong) IconLabel *iconLabel;
@property (nonatomic, strong) SearchTipLabel *nameLabel;
@property (nonatomic, strong) ReddieView *flagView;

@end

@implementation MenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 22;
        _iconLabel = [[IconLabel alloc] initWithFrame:(CGRect){originX, 2, 16, menuTableViewCellHeight - 4}];
        [_iconLabel setFont:[UIFont room107FontTwo]];
        [self addSubview:_iconLabel];
        
        originX += CGRectGetWidth(_iconLabel.bounds) + originX / 2;
        CGFloat labelWidth = 200;
        _nameLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, 0, labelWidth, menuTableViewCellHeight}];
        [_nameLabel setTextColor:[UIColor room107GrayColorD]];
        [self addSubview:_nameLabel];
        
        //未读标示
        _flagView = [[ReddieView alloc] initWithOrigin:CGPointMake(originX + 65, 10)];
        [self addSubview:_flagView];
    }
    
    return self;
}

- (void)setMenuInfo:(NSDictionary *)menu {
    [_iconLabel setText:[CommonFuncs iconCodeByHexStr:menu[@"icon"]]];
    [_iconLabel setTextColor:[UIColor colorFromHexString:[@"#" stringByAppendingString: menu[@"iconColor"] ? menu[@"iconColor"] : @""]]];
    
    [_nameLabel setText:menu[@"title"]];
    //计算文字的宽度
    CGRect contentRect = [menu[@"title"] boundingRectWithSize:(CGSize){CGRectGetWidth(_nameLabel.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_nameLabel.font} context:nil];
    _flagView.hidden = ![menu[@"newUpdate"] boolValue];
    CGRect frame = _flagView.frame;
    frame.origin.x = _nameLabel.frame.origin.x + 5 + contentRect.size.width;
    [_flagView setFrame:frame];
}

@end
