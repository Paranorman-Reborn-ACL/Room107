//
//  RentalManageTableViewCell.m
//  room107
//
//  Created by ningxia on 15/7/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RentalManageTableViewCell.h"
#import "SuiteProfileView.h"
#import "SearchTipLabel.h"
#import "RoundedGreenButton.h"
#import "NSString+AttributedString.h"
#import "ReddieView.h"

@interface RentalManageTableViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) SuiteProfileView *suiteProfileView;
@property (nonatomic, strong) RoundedGreenButton *rentalManageButton;
@property (nonatomic, strong) ReddieView *flagView;
@property (nonatomic, strong) SearchTipLabel *nextPaymentInfoLabel;

@end

@implementation RentalManageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11.0f;
        CGFloat originY = 11.0f;
        CGFloat cornerRadius = [CommonFuncs cornerRadius];
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - originY;
        _containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        _containerView.layer.cornerRadius = cornerRadius;
        _containerView.layer.masksToBounds = YES;
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_containerView];
        
        //添加阴影效果
        _shadowView = [[UIView alloc] initWithFrame:_containerView.frame];
        _shadowView.layer.cornerRadius = cornerRadius;
        [_shadowView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_shadowView];
        [self sendSubviewToBack:_shadowView];
        _shadowView.layer.shadowColor = [CommonFuncs shadowColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake([CommonFuncs shadowRadius], [CommonFuncs shadowRadius]);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3)
        _shadowView.layer.shadowOpacity = [CommonFuncs shadowOpacity];//阴影透明度，默认0
        _shadowView.layer.shadowRadius = [CommonFuncs shadowRadius];//阴影半径，默认3
        
        _suiteProfileView = [[SuiteProfileView alloc] initWithFrame:(CGRect){0, 0, containerViewWidth, [CommonFuncs houseCardHeight]}];
        [_containerView addSubview:_suiteProfileView];
        
        _nextPaymentInfoLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, CGRectGetHeight(_suiteProfileView.bounds), containerViewWidth, 25}];
        [_nextPaymentInfoLabel setTextAlignment:NSTextAlignmentLeft];
        [_containerView addSubview:_nextPaymentInfoLabel];

        CGFloat buttonWidth = containerViewWidth - 2 * originX;
        CGFloat buttonHeight = 33;
        _rentalManageButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){originX, CGRectGetHeight(_containerView.bounds) - originY - buttonHeight, buttonWidth, buttonHeight}];
        [_rentalManageButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        [_containerView addSubview:_rentalManageButton];
        [_rentalManageButton addTarget:self action:@selector(rentalManageButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        //未读标示
        _flagView = [[ReddieView alloc] initWithOrigin:CGPointMake(_rentalManageButton.frame.origin.x + buttonWidth / 2, _rentalManageButton.frame.origin.y + 5)];
        [_containerView addSubview:_flagView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [CommonFuncs houseCardHeight] + 11 + 22 + 11 + 33 + 11);
}

- (IBAction)rentalManageButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(rentalManageButtonDidClick:)]) {
        [self.delegate rentalManageButtonDidClick:self];
    }
}

- (void)setItemDic:(NSDictionary *)itemDic {
    [_suiteProfileView setRoomImageURL:itemDic[@"cover"][@"url"]];
    [_suiteProfileView setAvatarImageURL:itemDic[@"faviconUrl"]];
    [_suiteProfileView setRoomType:[itemDic[@"houseName"] stringByAppendingFormat:@" %@", itemDic[@"roomName"]]];
    if (![itemDic[@"checkinTime"] isEqualToString:@""] && ![itemDic[@"exitTime"] isEqualToString:@""]) {
        [_suiteProfileView setDateString:[[TimeUtil friendlyDateTimeFromDateTime:itemDic[@"checkinTime"] withFormat:@"%Y/%m/%d"] stringByAppendingFormat:@"--%@", [TimeUtil friendlyDateTimeFromDateTime:itemDic[@"exitTime"] withFormat:@"%Y/%m/%d"]]];
    } else {
        [_suiteProfileView setDateString:@""];
    }
    [_suiteProfileView setPosition:itemDic[@"address"]]; //合同签约的地址
    [_suiteProfileView setPrice:itemDic[@"monthlyPrice"]]; //合同签约的价格
}

- (void)setNextPaymentMoney:(NSNumber *)money andDate:(NSString *)date {
    _nextPaymentInfoLabel.hidden = YES;
    CGRect containerFrame = _containerView.frame;
    if ([money doubleValue] > 0 && date) {
        _nextPaymentInfoLabel.hidden = NO;
        containerFrame.size.height = [CommonFuncs houseCardHeight]+ 22 + 11 + 33 + 11;
        
        NSString *content = [CommonFuncs moneyStrByDouble:[money doubleValue] / 100];
        content = [[content stringByAppendingString:@" "] stringByAppendingFormat:lang(@"CompletePaymentBefore%@"), [TimeUtil friendlyDateTimeFromDateTime:date withFormat:@"%Y/%m/%d"]];
        NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
        NSArray *components = [content componentsSeparatedByString:@" "];
        NSDictionary *attrs = @{NSFontAttributeName:[UIFont room107SystemFontOne]};
        [attributedContent addAttributes:attrs range:NSMakeRange(0, 1)];
        attrs = @{NSFontAttributeName:[UIFont room107SystemFontFive]};
        [attributedContent addAttributes:attrs range:NSMakeRange(1, [components[0] length] - 1)];
        
        attrs = @{NSFontAttributeName:[UIFont room107FontOne]};
        [attributedContent addAttributes:attrs range:NSMakeRange([components[0] length], attributedContent.length - [components[0] length])];
        
        attrs = @{NSForegroundColorAttributeName:[UIColor room107YellowColor]};
        [attributedContent addAttributes:attrs range:NSMakeRange(0, attributedContent.length)];
        [_nextPaymentInfoLabel setAttributedText:attributedContent];
    } else {
        containerFrame.size.height = [CommonFuncs houseCardHeight] + 33 + 11;
    }
    [_containerView setFrame:containerFrame];
    [_shadowView setFrame:_containerView.frame];
}

- (void)setRentedHouseStatus:(NSNumber *)status {
    switch ([status intValue]) {
        case 0:
            [_rentalManageButton setTitle:lang(@"RentManage") forState:UIControlStateNormal];
            break;
        default:
            [_rentalManageButton setTitle:lang(@"RentalCompleted") forState:UIControlStateNormal];
            break;
    }
    CGRect rentalManageButtonFrame = _rentalManageButton.frame;
    rentalManageButtonFrame.origin.y = CGRectGetHeight(_containerView.bounds) - 11 - CGRectGetHeight(rentalManageButtonFrame);
    [_rentalManageButton setFrame:rentalManageButtonFrame];
    
    //计算文字的宽度
    CGRect contentRect = [_rentalManageButton.titleLabel.text boundingRectWithSize:(CGSize){CGRectGetWidth(_rentalManageButton.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_rentalManageButton.titleLabel.font} context:nil];
    CGRect frame = _flagView.frame;
    frame.origin.x = _rentalManageButton.frame.origin.x + CGRectGetWidth(_rentalManageButton.bounds) / 2 + contentRect.size.width / 2;
    frame.origin.y = _rentalManageButton.frame.origin.y + 5;
    [_flagView setFrame:frame];
}

- (void)setNewUpdate:(NSNumber *)newUpdate {
    _flagView.hidden = ![newUpdate boolValue];
}

@end
