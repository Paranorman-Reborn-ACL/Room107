//
//  SuiteSearchTableViewCell.m
//  room107
//
//  Created by ningxia on 16/1/27.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuiteSearchTableViewCell.h"
#import "SuiteProfileView.h"
#import "CustomRoundButton.h"
#import "CustomImageView.h"

@interface SuiteSearchTableViewCell ()

@property (nonatomic, strong) SuiteProfileView *suiteProfileView;
@property (nonatomic, strong) CustomRoundButton *favoriteButton;
@property (nonatomic, strong) CustomImageView *isReadImageView;
@property (nonatomic, strong) void (^viewHouseTagExplanationHandlerBlock)(NSDictionary *params);
@property (nonatomic, strong) void (^itemFavoriteHandlerBlock)();

@end

@implementation SuiteSearchTableViewCell

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
        _favoriteButton = [[CustomRoundButton alloc] initWithFrame:(CGRect){containerViewWidth - originX - buttonHeight, originY, buttonHeight, buttonHeight}];
        [containerView addSubview:_favoriteButton];
        [_favoriteButton addTarget:self action:@selector(favoriteButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        originX = _favoriteButton.frame.origin.x - 11 - buttonHeight;
        _isReadImageView = [[CustomImageView alloc] initWithFrame:(CGRect){originX, originY, buttonHeight, buttonHeight}];
        [_isReadImageView setImageWithName:@"isRead.png"];
        [containerView addSubview:_isReadImageView];
        [_isReadImageView setHidden:YES];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [CommonFuncs houseCardHeight] + 11);
}

- (void)setItemDic:(NSDictionary *)itemDic {
    [_suiteProfileView setRoomImageURL:itemDic[@"cover"][@"url"]];
    [_suiteProfileView setAvatarImageURL:itemDic[@"faviconUrl"]];
    [_isReadImageView setHidden:itemDic[@"isRead"] ? [itemDic[@"isRead"] intValue] == 0 : YES];
    [_suiteProfileView setReadStatus:itemDic[@"isRead"] ? [itemDic[@"isRead"] intValue] != 0 : NO];
    [_favoriteButton setImage:[UIImage imageNamed:[itemDic[@"isInterest"] boolValue] ?  @"favorite.png" : @"unFavorite.png"] forState:UIControlStateNormal];
    if ([itemDic[@"rentType"] isEqual:@2]) {
        //整租
        [_suiteProfileView setRoomType:[itemDic[@"houseName"] stringByAppendingFormat:@" %@", itemDic[@"roomName"]]];
    } else {
        [_suiteProfileView setRoomType:[itemDic[@"houseName"] stringByAppendingFormat:@" %@ %@", itemDic[@"roomName"], [CommonFuncs requiredGenderText:itemDic[@"requiredGender"]]]];
    }
    [_suiteProfileView setDistance:itemDic[@"distance"]];
    [_suiteProfileView setDateString:[NSString stringWithFormat:@"\ue63e %@", [TimeUtil timeStringFromTimestamp:[itemDic[@"modifiedTime"] doubleValue] / 1000 withDateFormat:@"MM/dd"]]];
    [_suiteProfileView setPosition:[itemDic[@"city"] stringByAppendingFormat:@" %@", itemDic[@"position"]]];
    [_suiteProfileView setPrice:itemDic[@"price"]];
    [_suiteProfileView setIntentionInfo:[NSString stringWithFormat:lang(@"IntentionNumber"), itemDic[@"viewCount"]]];
    [_suiteProfileView setFeatureTagIDs:itemDic[@"tagIds"]];
    WEAK_SELF weakSelf = self;
    [_suiteProfileView setViewHouseTagExplanationHandler:^(NSDictionary *params) {
        if (weakSelf.viewHouseTagExplanationHandlerBlock) {
            weakSelf.viewHouseTagExplanationHandlerBlock(params);
        }
    }];
}

- (void)setViewHouseTagExplanationHandler:(void(^)(NSDictionary *params))handler {
    _viewHouseTagExplanationHandlerBlock = handler;
}

- (void)setItemFavoriteHandler:(void(^)())handler {
    _itemFavoriteHandlerBlock = handler;
}

- (IBAction)favoriteButtonDidClick:(id)sender {
    if (_itemFavoriteHandlerBlock) {
        _itemFavoriteHandlerBlock();
    }
}

@end
