//
//  SuiteSearchCollectionViewCell.m
//  room107
//
//  Created by ningxia on 15/7/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteSearchCollectionViewCell.h"
#import "SuiteProfileView.h"

@interface SuiteSearchCollectionViewCell ()

@property (nonatomic, strong) SuiteProfileView *suiteProfileView;
@property (nonatomic, strong) void (^viewHouseTagExplanationHandlerBlock)(NSDictionary *params);

@end

@implementation SuiteSearchCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        //添加阴影效果
        self.layer.shadowColor = [CommonFuncs shadowColor].CGColor;
        self.layer.shadowOffset = CGSizeMake([CommonFuncs shadowRadius], [CommonFuncs shadowRadius]);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3)
        self.layer.shadowOpacity = [CommonFuncs shadowOpacity];//阴影透明度，默认0
        self.layer.shadowRadius = [CommonFuncs shadowRadius];//阴影半径，默认3
        
        frame.origin.x = 0;
        frame.origin.y = 0;
        _suiteProfileView = [[SuiteProfileView alloc] initWithFrame:frame];
        _suiteProfileView.layer.cornerRadius = [CommonFuncs cornerRadius];
        _suiteProfileView.layer.masksToBounds = YES;
        [self addSubview:_suiteProfileView];
    }
    
    return self;
}

- (void)setItem:(HouseListItemModel *)item {
    if ([item.hasCover boolValue] && item.cover) {
        [_suiteProfileView setRoomImageURL:item.cover[@"url"]];
    } else {
        [_suiteProfileView setRoomImageURL:@""];
    }
    [_suiteProfileView setAvatarImageURL:item.faviconUrl];
    if ([item.rentType isEqual:@2]) {
        //整租
        [_suiteProfileView setRoomType:[item.houseName stringByAppendingFormat:@" %@", item.roomName]];
    } else {
        [_suiteProfileView setRoomType:[item.houseName stringByAppendingFormat:@" %@ %@", item.roomName, [CommonFuncs requiredGenderText:item.requiredGender]]];
    }
    [_suiteProfileView setDateString:[NSString stringWithFormat:@"\ue63e %@", [TimeUtil timeStringFromTimestamp:[item.modifiedTime doubleValue] / 1000 withDateFormat:@"MM/dd"]]];
    [_suiteProfileView setPosition:[item.city stringByAppendingFormat:@" %@", item.position]];
    [_suiteProfileView setPrice:item.price];
    [_suiteProfileView setFeatureTagIDs:item.tagIds];
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

@end
