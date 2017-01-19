//
//  SuiteProfileView.m
//  room107
//
//  Created by ningxia on 16/1/26.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuiteProfileView.h"
#import "CustomImageView.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "NSString+AttributedString.h"
#import "SystemAgent.h"

static CGFloat originX = 11.0f;

@interface SuiteProfileView ()

@property (nonatomic, strong) CustomImageView *roomImageView; //房屋照片
@property (nonatomic, strong) CustomImageView *avatarImageView;
@property (nonatomic, strong) CustomButton *onlineButton;
@property (nonatomic, strong) NSDictionary *houseTag;
@property (nonatomic, strong) CustomLabel *originalPriceLabel;
@property (nonatomic, strong) CustomLabel *onlinePriceLabel;
@property (nonatomic, strong) CustomLabel *intentionLabel; //XXX人想租
@property (nonatomic, strong) CustomLabel *positionLabel;
@property (nonatomic, strong) CustomLabel *roomTypeLabel;
@property (nonatomic, strong) CustomLabel *distanceLabel;
@property (nonatomic, strong) CustomLabel *timeLabel;
@property (nonatomic, strong) void (^viewHouseTagExplanationHandlerBlock)(NSDictionary *params);

@end

@implementation SuiteProfileView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        if (!_roomImageView) {
            frame.size.height = frame.size.width / 1.5;
            _roomImageView = [[CustomImageView alloc] initWithFrame:frame];
            [self addSubview:_roomImageView];
            
            CGFloat distanceY = 11.0f;
            CGFloat avatarImageY = 11.0f;
            CGFloat imageViewWidth = 44;
            _avatarImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(originX, avatarImageY, imageViewWidth, imageViewWidth)];
            [_avatarImageView setBackgroundColor:[UIColor whiteColor]];
            [_avatarImageView setCornerRadius:CGRectGetWidth(_avatarImageView.bounds) / 2];
            _avatarImageView.layer.borderWidth = 1.0f;
            _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:_avatarImageView];
            _avatarImageView.userInteractionEnabled = YES ;
            UITapGestureRecognizer *tapClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onlineButtonDidClick:)];
            [_avatarImageView addGestureRecognizer:tapClick];
            
            _onlineButton = [[CustomButton alloc] initWithFrame:(CGRect){originX + imageViewWidth * 60/88, avatarImageY + imageViewWidth * 32/88, 28, 28}];
            [_onlineButton addTarget:self action:@selector(onlineButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_onlineButton];
            
            CGFloat labelWidth = 100;
            CGFloat labelHeight = 36;
            _onlinePriceLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, frame.size.height - distanceY - labelHeight, labelWidth, labelHeight)];
            [_onlinePriceLabel setBackgroundColor:[UIColor room107GrayColorEWithAlpha:0.9]];
            [_onlinePriceLabel setTextAlignment:NSTextAlignmentCenter];
            [_onlinePriceLabel setTextColor:[UIColor whiteColor]];
            [self addSubview:_onlinePriceLabel];
            
            labelWidth = 70;
            labelHeight = 26;
            _originalPriceLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(frame.size.width - labelWidth, frame.size.height - distanceY - labelHeight, labelWidth, labelHeight)];
            [_originalPriceLabel setBackgroundColor:[UIColor room107GrayColorEWithAlpha:0.9]];
            [_originalPriceLabel setTextAlignment:NSTextAlignmentCenter];
            [_originalPriceLabel setTextColor:[UIColor room107GrayColorC]];
            [_originalPriceLabel setHidden:YES];
            [self addSubview:_originalPriceLabel];
            
            _intentionLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(frame.size.width - labelWidth, frame.size.height - distanceY - labelHeight, labelWidth, labelHeight)];
            [_intentionLabel setBackgroundColor:[UIColor room107GrayColorEWithAlpha:0.9]];
            [_intentionLabel setTextAlignment:NSTextAlignmentCenter];
            [_intentionLabel setTextColor:[UIColor whiteColor]];
            [_intentionLabel setHidden:YES];
            [self addSubview:_intentionLabel];
            
            labelHeight = 16;
            _positionLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(originX, frame.size.height + distanceY, frame.size.width - 2 * originX, labelHeight)];
            [_positionLabel setFont:[UIFont room107SystemFontThree]];
            [_positionLabel setTextAlignment:NSTextAlignmentLeft];
            [_positionLabel setTextColor:[UIColor room107GrayColorE]];
            [self addSubview:_positionLabel];
            
            labelWidth = (frame.size.width - 2 * originX) / 2;
            labelHeight = 14;
            _roomTypeLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(originX, _positionLabel.frame.origin.y + CGRectGetHeight(_positionLabel.bounds) + 7, labelWidth, labelHeight)];
            _roomTypeLabel.textAlignment = NSTextAlignmentLeft;
            [_roomTypeLabel setFont:[UIFont room107SystemFontOne]];
            [_roomTypeLabel setTextColor:[UIColor room107GrayColorD]];
            [self addSubview:_roomTypeLabel];
            
            labelWidth = 130;
            _timeLabel = [[CustomLabel alloc] initWithFrame:(CGRect){frame.size.width - labelWidth - originX, _roomTypeLabel.frame.origin.y, labelWidth, labelHeight}];
            [_timeLabel setFont:[UIFont room107FontOne]];
            [_timeLabel setTextColor:[UIColor room107GrayColorC]];
            [self addSubview:_timeLabel];
            
            labelWidth = 60;
            _distanceLabel = [[CustomLabel alloc] initWithFrame:(CGRect){frame.size.width -  2 * labelWidth - originX, _roomTypeLabel.frame.origin.y, labelWidth, labelHeight}];
            [_distanceLabel setFont:[UIFont room107FontOne]];
            [_distanceLabel setTextColor:[UIColor room107GrayColorC]];
            [self addSubview:_distanceLabel];
        }
    }
    
    return self;
}

- (void)setRoomImageURL:(NSString *)url {
    if (url && ![url isEqualToString:@""]) {
        [_roomImageView setContentMode:UIViewContentModeCenter]; //图片按实际大小居中显示
        WEAK_SELF weakSelf = self;
        [_roomImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"imageLoading"] withCompletionHandler:^(UIImage *image) {
            if (image) {
                weakSelf.roomImageView.contentMode = UIViewContentModeScaleAspectFill; //图片撑满显示
            }
        }];
    } else {
        [_roomImageView setImageWithName:@"defaultRoomPic.jpg"];
        _roomImageView.contentMode = UIViewContentModeScaleAspectFill; //图片撑满显示
    }
}

- (void)setAvatarImageURL:(NSString *)url {
    [_avatarImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loginlogo.png"]];
}

- (void)setOfflinePrice:(NSNumber *)offlinePrice onlinePrice:(NSNumber *)onlinePrice {
    if (onlinePrice && ![onlinePrice isEqual:@(0)] && offlinePrice && ![offlinePrice isEqual:@(0)]) {
        //线上签约 以及原价 均有
//        _originalPriceLabel.hidden = NO;
        _onlinePriceLabel.hidden = NO;
        
        NSString *onlineString = [NSString stringWithFormat:@"￥%@", onlinePrice];
        [self refreshOnlinePrice:onlineString];
        
        NSString *originalString = [NSString stringWithFormat:@"￥%@", offlinePrice];
        NSMutableAttributedString *attOriginalString = [NSString attributedStringFromPriceStr:originalString andPriceFont:[UIFont room107SystemFontThree] andPriceColor:_originalPriceLabel.textColor andUnitFont:[UIFont room107SystemFontOne] andUnitColor:_originalPriceLabel.textColor];
        NSUInteger length = attOriginalString.length;
        [attOriginalString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, length)];
        [attOriginalString addAttribute:NSStrikethroughColorAttributeName value:_originalPriceLabel.textColor range:NSMakeRange(0, length)];
        [_originalPriceLabel setAttributedText:attOriginalString];
        CGRect frame = _originalPriceLabel.frame;
        frame.size.width = attOriginalString.size.width + 18;
        frame.origin.x = CGRectGetWidth(self.bounds) - frame.size.width;
        [_originalPriceLabel setFrame:frame];
    } else {
//        _originalPriceLabel.hidden = YES;
        _onlinePriceLabel.hidden = NO;
        
        NSString *onlineString = [NSString stringWithFormat:@"￥%@", onlinePrice && ![onlinePrice isEqual:@(0)] ? onlinePrice : offlinePrice && ![offlinePrice isEqual:@(0)] ? offlinePrice : @"0"];
        [self refreshOnlinePrice:onlineString];
    }
}

- (void)refreshOnlinePrice:(NSString *)onlineString {
    NSMutableAttributedString *attOnlineString = [NSString attributedStringFromPriceStr:onlineString andPriceFont:[UIFont room107SystemFontFive] andPriceColor:_onlinePriceLabel.textColor andUnitFont:[UIFont room107SystemFontThree] andUnitColor:_onlinePriceLabel.textColor];
    CGRect frame = _onlinePriceLabel.frame;
    frame.size.width = attOnlineString.size.width + 18;
    [_onlinePriceLabel setFrame:frame];
    [_onlinePriceLabel setAttributedText:attOnlineString];
}

- (void)setReadStatus:(BOOL)isRead {
    [_positionLabel setTextColor:isRead ? [UIColor room107GrayColorC] : [UIColor room107GrayColorE]];
    [_roomTypeLabel setTextColor:isRead ? [UIColor room107GrayColorB] : [UIColor room107GrayColorD]];
}

- (void)setPosition:(NSString *)position {
    [_positionLabel setText:position];
}

- (void)setRoomType:(NSString *)roomType {
    [_roomTypeLabel setText:roomType];
}

- (void)setIntentionInfo:(NSString *)intention {
    [_intentionLabel setHidden:NO];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:intention];
    NSUInteger length = attributedString.length;
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontThree] range:NSMakeRange(0, length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:_intentionLabel.textColor range:NSMakeRange(0, length)];
    [_intentionLabel setAttributedText:attributedString];
    CGRect frame = _intentionLabel.frame;
    frame.size.width = attributedString.size.width + 18;
    frame.origin.x = CGRectGetWidth(self.bounds) - frame.size.width;
    [_intentionLabel setFrame:frame];
}

- (void)setDistance:(NSNumber *)distance {
    [_distanceLabel setHidden:YES];
    if (distance && ![distance isEqual:@0] && [distance compare:[NSNumber numberWithUnsignedInteger:maxUInteger]] == NSOrderedAscending) {
        [_distanceLabel setHidden:NO];
        int doubleDistance = [distance intValue];
        NSString *distanceText = [NSString stringWithFormat:@"\ue60e%dm", doubleDistance];
        if (doubleDistance >= 1000) {
            distanceText = [NSString stringWithFormat:@"\ue60e%.1fkm", doubleDistance * 0.001];
        }
        [_distanceLabel setText:distanceText];
        CGRect frame = _timeLabel.frame;
        frame.size.width = 60;
        frame.origin.x = _roomImageView.frame.size.width - frame.size.width - originX;
        [_timeLabel setFrame:frame];
    }
}

- (void)setDateString:(NSString *)dateString {
    [_timeLabel setText:dateString];
}

- (void)setFeatureTagIDs:(NSArray *)tagIDs {
    _onlineButton.hidden = tagIDs.count > 0 ? NO : YES;
    NSUInteger index = 0;//只显示第一个标签
    if (tagIDs.count > index) {
        NSArray *houseTags = [[[SystemAgent sharedInstance] getPropertiesFromLocal] houseTags];
        if (houseTags && houseTags.count > index) {
            [self refreshDataWithHouseTags:houseTags andTagID:tagIDs[index] andIndex:index];
        } else {
            WEAK_SELF weakSelf = self;
            [[SystemAgent sharedInstance] getPropertiesFromServer:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, AppPropertiesModel *model) {
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    if (model.houseTags && [model.houseTags count] > 0) {
                        [weakSelf refreshDataWithHouseTags:model.houseTags andTagID:tagIDs[index] andIndex:index];
                    }
                }
            }];
        }
    } else {
        _houseTag = nil;
    }
}

- (void)refreshDataWithHouseTags:(NSArray *)houseTags andTagID:(NSNumber *)tagID andIndex:(NSUInteger)index {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", [tagID longLongValue]]; //实现数组的快速查询
    NSArray *filteredArray = [houseTags filteredArrayUsingPredicate:predicate];
    if (filteredArray.count == 0) {
        return;
    }
    _houseTag = filteredArray[0];
    //包含appTargetUrl、color、content、id、imageUrl、title、webTargetUrl
    [_onlineButton setImageWithURL:_houseTag[@"imageUrl"]];
}

- (void)setViewHouseTagExplanationHandler:(void (^)(NSDictionary *params))handler {
    _viewHouseTagExplanationHandlerBlock = handler;
}

- (IBAction)onlineButtonDidClick:(id)sender {
    if (_houseTag && _viewHouseTagExplanationHandlerBlock) {
        _viewHouseTagExplanationHandlerBlock(@{@"url":_houseTag[@"appTargetUrl"], @"title":_houseTag[@"title"]});
    }
}

- (void)setPrice:(NSNumber *)price {
    NSString *priceString = [NSString stringWithFormat:@"￥%@", price];
    [self refreshOnlinePrice:priceString];
}
@end
