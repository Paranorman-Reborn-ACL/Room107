//
//  PostSuiteManageTableViewCell.m
//  room107
//
//  Created by ningxia on 15/7/31.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "PostSuiteManageTableViewCell.h"
#import "SuiteProfileView.h"
#import "SearchTipLabel.h"
#import "CustomRoundButton.h"
#import "RoundedGreenButton.h"
#import "NSString+AttributedString.h"
#import "ReddieView.h"

@interface PostSuiteManageTableViewCell ()

@property (nonatomic, strong) SuiteProfileView *suiteProfileView;
@property (nonatomic, strong) SearchTipLabel *houseStatusLabel;
@property (nonatomic, strong) CustomRoundButton *openOrCloseHouseButton;
@property (nonatomic, strong) RoundedGreenButton *signedInviteButton;
@property (nonatomic, strong) ReddieView *flagView;

@end

@implementation PostSuiteManageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

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
        
        CGFloat labelWidth = 80;
        _houseStatusLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){containerViewWidth - labelWidth, originY, labelWidth, 30}];
        [_houseStatusLabel setTextAlignment:NSTextAlignmentCenter];
        [_houseStatusLabel setFont:[UIFont room107FontThree]];
        [_houseStatusLabel setTextColor:[UIColor whiteColor]];
        [containerView addSubview:_houseStatusLabel];
        
        CGFloat buttonHeight = 33;
        CustomRoundButton *suiteManageButton = [[CustomRoundButton alloc] initWithFrame:(CGRect){originX, CGRectGetHeight(_suiteProfileView.bounds), buttonHeight, buttonHeight}];
        [suiteManageButton setImage:[UIImage makeImageFromText:@"\ue65a" font:[UIFont fontWithName:fontIconName size:buttonHeight] color:[UIColor room107GreenColor]] forState:UIControlStateNormal];
        [containerView addSubview:suiteManageButton];
        [suiteManageButton addTarget:self action:@selector(suiteManageButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _openOrCloseHouseButton = [[CustomRoundButton alloc] initWithFrame:(CGRect){2 * originX + buttonHeight, suiteManageButton.frame.origin.y, buttonHeight, buttonHeight}];
        [containerView addSubview:_openOrCloseHouseButton];
        [_openOrCloseHouseButton addTarget:self action:@selector(openOrCloseHouseButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat buttonWidth = containerViewWidth - 4 * originX - 2 * buttonHeight;
        _signedInviteButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){3 * originX + 2 * buttonHeight, suiteManageButton.frame.origin.y, buttonWidth, buttonHeight}];
        [_signedInviteButton.titleLabel setFont:[UIFont room107SystemFontThree]];
        [containerView addSubview:_signedInviteButton];
        [_signedInviteButton addTarget:self action:@selector(signedInviteButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //未读标示
        _flagView = [[ReddieView alloc] initWithOrigin:CGPointMake(CGRectGetWidth(_signedInviteButton.bounds) / 2, CGRectGetHeight(_signedInviteButton.bounds) / 2 - 10)];
        [_signedInviteButton addSubview:_flagView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [CommonFuncs houseCardHeight] + 11 + 33 + 11);
}

- (void)setButtonType:(NSNumber *)type {
    [_signedInviteButton setBackgroundColor:[UIColor room107GreenColor]];
    NSString *title = lang(@"LeaseManage");
    switch ([type intValue]) {
        case 0:
        case 1:
            if ([type isEqual:@0]) {
                [_signedInviteButton setBackgroundColor:[UIColor room107GrayColorC]];
            }
            title = lang(@"ViewSignedApply");
            break;
        default:
            break;
    }
    [_signedInviteButton setTitle:title forState:UIControlStateNormal];
    
    //计算文字的宽度
    CGRect contentRect = [title boundingRectWithSize:(CGSize){CGRectGetWidth(_signedInviteButton.bounds), MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_signedInviteButton.titleLabel.font} context:nil];
    CGRect frame = _flagView.frame;
    frame.origin.x = CGRectGetWidth(_signedInviteButton.bounds) / 2 + contentRect.size.width / 2;
    [_flagView setFrame:frame];
}

- (void)setNewUpdate:(NSNumber *)newUpdate {
    _flagView.hidden = ![newUpdate boolValue];
}

- (IBAction)suiteManageButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(suiteManageButtonDidClick:)]) {
        [self.delegate suiteManageButtonDidClick:self];
    }
}

- (IBAction)openOrCloseHouseButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(openOrCloseHouseButtonDidClick:)]) {
        [self.delegate openOrCloseHouseButtonDidClick:self];
    }
}

- (IBAction)signedInviteButtonDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(signedInviteButtonDidClick:)]) {
        [self.delegate signedInviteButtonDidClick:self];
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
}

- (void)setHouseStatus:(NSNumber *)status {
    switch ([status intValue]) {
        case 0:
            [_houseStatusLabel setBackgroundColor:[UIColor room107YellowColor]];
            [_houseStatusLabel setText:lang(@"UnderReview")];
            break;
        case 1:
            [_houseStatusLabel setBackgroundColor:[UIColor room107GrayColorC]];
            [_houseStatusLabel setText:lang(@"AuditFailed")];
            break;
        case 2:
            [_houseStatusLabel setBackgroundColor:[UIColor room107GreenColor]];
            [_houseStatusLabel setText:lang(@"WaitForRent")];
            break;
        default:
            [_houseStatusLabel setBackgroundColor:[UIColor room107GrayColorC]];
            [_houseStatusLabel setText:lang(@"TemporarilyOutside")];
            break;
    }
}

- (void)setRentStatusButton:(NSNumber *)type {
    _openOrCloseHouseButton.enabled = YES;
    _openOrCloseHouseButton.hidden = NO;
    switch ([type intValue]) {
        case 0:
            [_openOrCloseHouseButton setImage:[UIImage makeImageFromText:@"\ue65b" font:[UIFont fontWithName:fontIconName size:_openOrCloseHouseButton.frame.size.height] color:[UIColor room107GreenColor]] forState:UIControlStateNormal];
            break;
        case 1:
            [_openOrCloseHouseButton setImage:[UIImage makeImageFromText:@"\ue65c" font:[UIFont fontWithName:fontIconName size:_openOrCloseHouseButton.frame.size.height] color:[UIColor room107GreenColor]] forState:UIControlStateNormal];
            break;
        default:
            _openOrCloseHouseButton.enabled = NO;
            _openOrCloseHouseButton.hidden = YES;
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
