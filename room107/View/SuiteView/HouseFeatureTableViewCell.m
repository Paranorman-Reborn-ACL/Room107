//
//  HouseFeatureTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/29.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "HouseFeatureTableViewCell.h"
#import "CustomImageView.h"
#import "YellowColorTextLabel.h"
#import "SystemAgent.h"

static CGFloat originY = 11;
static CGFloat spaceX = 11;
static CGFloat spaceY = 11; //每个标签的间隔
static CGFloat featureImageHeight = 33;

@interface HouseFeatureTableViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic) CGFloat contentY;

@end

@implementation HouseFeatureTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView setBackgroundColor:[UIColor room107GrayColorA]];
        _containerView = [[UIView alloc] initWithFrame:(CGRect){0, originY, [self cellFrame].size}];
        [_containerView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_containerView];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, originY + 2 * spaceY + featureImageHeight);
}

- (void)setFeatureTagIDs:(NSArray *)tagIDs {
    _containerView.hidden = YES;
    for (UIView *subView in _containerView.subviews) {
        [subView removeFromSuperview];
    }
    
    if (tagIDs.count > 0) {
        _contentY = spaceY;
        for (NSNumber *tagID in tagIDs) {
            NSArray *houseTags = [[[SystemAgent sharedInstance] getPropertiesFromLocal] houseTags];
            NSUInteger index = [tagIDs indexOfObject:tagID];
            if (houseTags && houseTags.count > index) {
                [self refreshDataWithHouseTags:houseTags andTagID:tagID andIndex:index];
            } else {
                WEAK_SELF weakSelf = self;
                [[SystemAgent sharedInstance] getPropertiesFromServer:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, AppPropertiesModel *model) {
                    if (errorTitle || errorMsg) {
                        [PopupView showTitle:errorTitle message:errorMsg];
                    }
                
                    if (!errorCode) {
                        if (model.houseTags && [model.houseTags count] > 0) {
                            [weakSelf refreshDataWithHouseTags:model.houseTags andTagID:tagID andIndex:index];
                        }
                    }
                }];
            }
        }
        
        CGRect frame = _containerView.frame;
        frame.size.height = [self getCellHeightWithTagIDs:tagIDs] - originY;
        [_containerView setFrame:frame];
        _containerView.hidden = NO;
    }
}

- (void)refreshDataWithHouseTags:(NSArray *)houseTags andTagID:(NSNumber *)tagID andIndex:(NSUInteger)index {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", [tagID longLongValue]]; //实现数组的快速查询
    NSArray *filteredArray = [houseTags filteredArrayUsingPredicate:predicate];
    if (filteredArray.count == 0) {
        return;
    }
    NSDictionary *tag = filteredArray[0];
    //包含appTargetUrl、color、content、id、imageUrl、title、webTargetUrl
    CustomImageView *featureImageView = [[CustomImageView alloc] initWithFrame:(CGRect){spaceX, (index + 1) * spaceY + index * featureImageHeight, featureImageHeight, featureImageHeight}];
    [featureImageView setImageWithURL:tag[@"imageUrl"]];
    [featureImageView setBackgroundColor:[UIColor whiteColor]];
    [_containerView addSubview:featureImageView];
    
    CGFloat originX = 2 * spaceX + featureImageHeight;
    CGFloat labelWidth = [self cellFrame].size.width - originX - spaceX;
    CGFloat labelHeight = MAX([CommonFuncs rectWithText:tag[@"content"] ? tag[@"content"] : @"" andMaxDisplayWidth:[self maxContentWidth] andAttributes:[self attributes]].size.height, featureImageHeight);
    YellowColorTextLabel *featureLabel = [[YellowColorTextLabel alloc] initWithFrame:(CGRect){originX, _contentY, labelWidth, labelHeight}];
    [featureLabel setFont:[UIFont room107SystemFontOne]];
    [featureLabel setTitle:tag[@"content"] withTitleColor:[UIColor room107GrayColorC] withAlignment:NSTextAlignmentLeft];
    [_containerView addSubview:featureLabel];
    
    CGPoint featureImageViewCenter = featureImageView.center;
    featureImageViewCenter.y = featureLabel.center.y;
    [featureImageView setCenter:featureImageViewCenter];
    _contentY += labelHeight + spaceY;
}

- (CGFloat)maxContentWidth {
    return CGRectGetWidth([self cellFrame]) - spaceX * 3 - featureImageHeight;
}

- (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5; //字体的行间距
    return @{NSFontAttributeName:[UIFont room107SystemFontOne],
             NSParagraphStyleAttributeName:paragraphStyle};
}

- (CGFloat)getCellHeightWithTagIDs:(NSArray *)tagIDs {
    CGFloat cellHeight = originY + spaceY;
    if (tagIDs.count > 0) {
        for (NSNumber *tagID in tagIDs) {
            NSArray *houseTags = [[[SystemAgent sharedInstance] getPropertiesFromLocal] houseTags];
            NSUInteger index = [tagIDs indexOfObject:tagID];
            if (houseTags.count > index) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", [tagID longLongValue]]; //实现数组的快速查询
                NSArray *filteredArray = [houseTags filteredArrayUsingPredicate:predicate];
                if (filteredArray.count == 0) {
                    continue;
                }
                cellHeight += MAX([CommonFuncs rectWithText:filteredArray[0][@"content"] ? filteredArray[0][@"content"] : @"" andMaxDisplayWidth:[self maxContentWidth] andAttributes:[self attributes]].size.height, featureImageHeight) + spaceY;
            } else {
                [[SystemAgent sharedInstance] getPropertiesFromServer];
                continue;
            }
        }
    }
    
    return cellHeight;
}

@end
