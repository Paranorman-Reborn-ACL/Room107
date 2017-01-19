//
//  InterestSuiteTableViewCell.m
//  room107
//
//  Created by ningxia on 16/1/28.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "InterestSuiteTableViewCell.h"
#import "SuiteProfileView.h"
#import "SearchTipLabel.h"
#import "CustomRoundButton.h"
#import "RoundedGreenButton.h"
#import "NSString+AttributedString.h"
#import "ReddieView.h"

@interface InterestSuiteTableViewCell ()

@property (nonatomic, strong) SuiteProfileView *suiteProfileView;
@property (nonatomic, strong) RoundedGreenButton *signedDealButton;
@property (nonatomic, strong) ReddieView *flagView;
@property (nonatomic, strong) void (^viewHouseTagExplanationHandlerBlock)(NSDictionary *params);

@end

@implementation InterestSuiteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 11.0f;
        CGFloat originY = 11.0f;
        CGFloat cornerRadius = [CommonFuncs cornerRadius];
        CGFloat containerViewWidth = CGRectGetWidth([self cellFrame]) - 2 * originX;
        CGFloat containerViewHeight = CGRectGetHeight([self cellFrame]) - originY;
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, containerViewWidth, containerViewHeight}];
        containerView.layer.cornerRadius = cornerRadius;
        containerView.layer.masksToBounds = YES;
        [containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:containerView];
        
        //添加阴影效果
        UIView *shadowView = [[UIView alloc] initWithFrame:containerView.frame];
        shadowView.layer.cornerRadius = cornerRadius;
        [shadowView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:shadowView];
        [self.contentView sendSubviewToBack:shadowView];
        shadowView.layer.shadowColor = [CommonFuncs shadowColor].CGColor;
        shadowView.layer.shadowOffset = CGSizeMake([CommonFuncs shadowRadius], [CommonFuncs shadowRadius]);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3)
        shadowView.layer.shadowOpacity = [CommonFuncs shadowOpacity];//阴影透明度，默认0
        shadowView.layer.shadowRadius = [CommonFuncs shadowRadius];//阴影半径，默认3
        
        _suiteProfileView = [[SuiteProfileView alloc] initWithFrame:(CGRect){0, 0, containerViewWidth, [CommonFuncs houseCardHeight]}];
        [containerView addSubview:_suiteProfileView];
        
        CGFloat buttonHeight = 33;
        CustomRoundButton *favoriteButton = [[CustomRoundButton alloc] initWithFrame:(CGRect){containerViewWidth - originX - buttonHeight, originY, buttonHeight, buttonHeight}];
        [favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        [containerView addSubview:favoriteButton];
        [favoriteButton addTarget:self action:@selector(favoriteButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CustomRoundButton *reportButton = [[CustomRoundButton alloc] initWithFrame:(CGRect){originX, CGRectGetHeight(_suiteProfileView.bounds), buttonHeight, buttonHeight}];
        [reportButton setImage:[UIImage makeImageFromText:@"\ue65d" font:[UIFont fontWithName:fontIconName size:buttonHeight] color:[UIColor room107YellowColor]] forState:UIControlStateNormal];
        [containerView addSubview:reportButton];
        [reportButton addTarget:self action:@selector(reportButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CustomRoundButton *contactOwnerButton = [[CustomRoundButton alloc] initWithFrame:(CGRect){2 * originX + buttonHeight, reportButton.frame.origin.y, buttonHeight, buttonHeight}];
        [contactOwnerButton setImage:[UIImage makeImageFromText:@"\ue65e" font:[UIFont fontWithName:fontIconName size:buttonHeight] color:[UIColor room107GreenColor]] forState:UIControlStateNormal];
        [containerView addSubview:contactOwnerButton];
        [contactOwnerButton addTarget:self action:@selector(contactOwnerButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat buttonWidth = containerViewWidth - 4 * originX - 2 * buttonHeight;
        _signedDealButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){3 * originX + 2 * buttonHeight, reportButton.frame.origin.y, buttonWidth, buttonHeight}];
        [_signedDealButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        [containerView addSubview:_signedDealButton];
        [_signedDealButton addTarget:self action:@selector(signedDealButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //未读标示
        _flagView = [[ReddieView alloc] initWithOrigin:CGPointMake(CGRectGetWidth(_signedDealButton.bounds) / 2, CGRectGetHeight(_signedDealButton.bounds) / 2 - 10)];
        [_signedDealButton addSubview:_flagView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [CommonFuncs houseCardHeight] + 11 + 33 + 11);
}

- (void)setButtonType:(NSNumber *)type {
    [_signedDealButton setEnabled:YES];
    //0表示可线上签约；1表示不可线上签约；2表示“已租”。
    NSString *title = lang(@"Signed");
    [_signedDealButton setBackgroundColor:[UIColor room107GreenColor]];
    switch ([type intValue]) {
        case 1:
            [_signedDealButton setBackgroundColor:[UIColor room107GrayColorC]];
            break;
        case 2:
            [_signedDealButton setBackgroundColor:[UIColor room107GrayColorC]];
            title = lang(@"BeenRented");
            break;
        default:
            break;
    }
    [_signedDealButton setTitle:title forState:UIControlStateNormal];
    
    //计算文字的宽度
    CGRect contentRect = [title boundingRectWithSize:(CGSize){CGRectGetWidth(_signedDealButton.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_signedDealButton.titleLabel.font} context:nil];
    CGRect frame = _flagView.frame;
    frame.origin.x = CGRectGetWidth(_signedDealButton.bounds) / 2 + contentRect.size.width / 2;
    [_flagView setFrame:frame];
}

- (void)setNewUpdate:(NSNumber *)newUpdate {
    _flagView.hidden = ![newUpdate boolValue];
}

- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler {
    _viewHouseTagExplanationHandlerBlock = handler;
}

- (IBAction)favoriteButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteSuiteButtonDidClick:)]) {
        [self.delegate deleteSuiteButtonDidClick:self];
    }
}

- (IBAction)reportButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(reportButtonDidClick:)]) {
        [self.delegate reportButtonDidClick:self];
    }
}

- (IBAction)contactOwnerButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactOwnerButtonDidClick:)]) {
        [self.delegate contactOwnerButtonDidClick:self];
    }
}

- (IBAction)signedDealButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(signedDealButtonDidClick:)]) {
        [self.delegate signedDealButtonDidClick:self];
    }
}

- (void)setItemDic:(NSDictionary *)itemDic {
    [_suiteProfileView setRoomImageURL:itemDic[@"cover"][@"url"]];
    [_suiteProfileView setAvatarImageURL:itemDic[@"faviconUrl"]];
    if ([itemDic[@"rentType"] isEqual:@2]) {
        //整租
        [_suiteProfileView setRoomType:[itemDic[@"houseName"] stringByAppendingFormat:@" %@", itemDic[@"roomName"]]];
    } else {
        [_suiteProfileView setRoomType:[itemDic[@"houseName"] stringByAppendingFormat:@" %@ %@", itemDic[@"roomName"], [CommonFuncs requiredGenderText:itemDic[@"requiredGender"]]]];
    }
    [_suiteProfileView setDateString:[NSString stringWithFormat:@"\ue63e %@", [TimeUtil timeStringFromTimestamp:[itemDic[@"modifiedTime"] doubleValue] / 1000 withDateFormat:@"MM/dd"]]];
    [_suiteProfileView setPosition:[itemDic[@"city"] stringByAppendingFormat:@" %@", itemDic[@"position"]]];
    [_suiteProfileView setPrice:itemDic[@"price"]];
    [_suiteProfileView setFeatureTagIDs:itemDic[@"tagIds"]];
    WEAK_SELF weakSelf = self;
    [_suiteProfileView setViewHouseTagExplanationHandler:^(NSDictionary *params) {
        if (weakSelf.viewHouseTagExplanationHandlerBlock) {
            weakSelf.viewHouseTagExplanationHandlerBlock(params);
        }
    }];
}

@end
