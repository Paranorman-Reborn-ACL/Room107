//
//  SuiteSearchFromMapBottomView.m
//  room107
//
//  Created by 107间 on 16/1/6.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "SuiteSearchFromMapBottomView.h"
#import "CustomImageView.h"
#import "CustomLabel.h"
#import "SystemAgent.h"

static CGFloat space = 11;
static CGFloat btnHeight = 25;

@interface SuiteSearchFromMapBottomView()

@property (nonatomic, strong) CustomImageView *roomImage;//房间照片
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) CustomLabel *infoTitle ;//房间信息
@property (nonatomic, strong) CustomLabel *timeLabel ;//日期信息
@property (nonatomic, strong) CustomLabel *addressLabel;//地址
@property (nonatomic, strong) UIScrollView *houseTagsScrollView;
@property (nonatomic, assign) CGFloat contentWidth;

@end
@implementation SuiteSearchFromMapBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat width = frame.size.width ;
    CGFloat height = frame.size.height ;
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        CGFloat imageWidth = width * 0.4;
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, height)];
        [_backView setBackgroundColor:[UIColor room107GrayColorA]];
        [self addSubview:_backView];
        
        self.roomImage = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, height)];
        [_roomImage setBackgroundColor:[UIColor room107GrayColorA]];
        [self.backView addSubview:_roomImage];
        
        self.infoTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(imageWidth + space , space, 150, 16)];
        [_infoTitle setFont:[UIFont room107SystemFontThree]];
        [_infoTitle setTextAlignment:NSTextAlignmentLeft];
        [_infoTitle setTextColor:[UIColor room107GrayColorD]];
        [self addSubview:_infoTitle];
        
        self.timeLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(width - 70 - 11, space, 70, 16)];
        [_timeLabel setFont:[UIFont room107FontOne]];
        [_timeLabel setTextColor:[UIColor room107GrayColorC]];
        [self addSubview:_timeLabel];
        
        self.addressLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(imageWidth + space , CGRectGetMaxY(_infoTitle.frame) + 5, width*0.6 - 2*space, 14)];
        [_addressLabel setTextAlignment:NSTextAlignmentLeft];
        [_addressLabel setTextColor:[UIColor room107GrayColorD]];
        [_addressLabel setFont:[UIFont room107SystemFontOne]];
        [self addSubview:_addressLabel];
        
        _houseTagsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(imageWidth + space , height - space - btnHeight, width*0.6 - 2*space , btnHeight)];
        _houseTagsScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_houseTagsScrollView];
    }
    
    return self;
}

- (void)setItem:(HouseListItemModel *)item {
    //1.设置基本信息，地址，日期等
    if ([item.rentType isEqual:@2]) {
        //整租
        [_infoTitle setText:[NSString stringWithFormat:@"%@ %@", lang(@"RentHouse"), item.name]];
    } else {
        //分租
        NSString *rentType;
        switch ([item.requiredGender intValue]) {
            case 1:
                rentType = lang(@"MaleLimit");
                break;
            case 2:
                rentType = lang(@"FemaleLimit");
                break;
            case 3:
            case 0:
                rentType = @""; //如果不限男女，不需要显示“不限男女”的字样
            default:
                break;
        }
        [_infoTitle setText:[NSString stringWithFormat:@"%@ %@ %@", lang(@"Subletting"), item.name, rentType]];
    }
    
    [_addressLabel setText:[NSString stringWithFormat:@"%@ %@",item.city ,item.position]];
    [_timeLabel setText:[NSString stringWithFormat:@"\ue63e%@", [TimeUtil timeStringFromTimestamp:[item.modifiedTime doubleValue] / 1000 withDateFormat:@"MM/dd"]]];
    //2.设置图片内容
    NSString *imageURL = item.cover[@"url"];
    CGPoint center =_roomImage.center;
    CGFloat imageViewHeight = self.frame.size.height;
    CGFloat imageViewWidth = self.frame.size.width * 0.4;
    [_roomImage setFrame:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
    _roomImage.contentMode = UIViewContentModeCenter;
    WEAK_SELF weakSelf = self;
    if ([item.hasCover boolValue]) {
        [weakSelf.roomImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"imageLoading.png"] withCompletionHandler:^(UIImage *image) {
            if (image) {
                CGFloat width = image.size.width;
                CGFloat height = image.size.height;
                CGFloat proportion = width/height;
                if (proportion < 1.5) {
                    [weakSelf.roomImage setBounds:CGRectMake(0, 0, imageViewHeight * proportion, imageViewHeight)];
                } else {
                    [weakSelf.roomImage setBounds:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
                }
                weakSelf.roomImage.center = center;
                weakSelf.roomImage.contentMode = UIViewContentModeScaleToFill;
            }
        }];
    } else {
        [weakSelf.roomImage setImageWithName:@"defaultRoomPic.jpg"];
        weakSelf.roomImage.contentMode = UIViewContentModeScaleAspectFill; //图片撑满显示
    }
    
    [UIView setAnimationsEnabled:NO];
    //3.设置卡片类型
    [self setRoomType:item.tagIds];
    [UIView setAnimationsEnabled:YES];
}

- (void)setRoomType:(NSArray *)tagIDs {
    self.contentWidth = 0;
    for (UIView *subview in  _houseTagsScrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (tagIDs.count > 0 ) {
        NSArray *houseTags = [[[SystemAgent sharedInstance] getPropertiesFromLocal] houseTags];
        for (NSNumber *tagID in tagIDs) {
            if (houseTags && houseTags.count > 0) {
                [self refreshHouseTagsWithHouseArray:houseTags andTagID:tagID];
            } else {
                [[SystemAgent sharedInstance] getPropertiesFromServer:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, AppPropertiesModel *model) {
                    if (errorTitle || errorMsg) {
                        [PopupView showTitle:errorTitle message:errorMsg];
                    }
                
                    if (!errorCode) {
                        if (model.houseTags && [model.houseTags count] > 0) {
                            [self refreshHouseTagsWithHouseArray:model.houseTags andTagID:tagID];
                        }
                    }
                }];
            }
        }
    }
    
    [_houseTagsScrollView setContentSize:CGSizeMake(self.contentWidth - 5, 0)];
}

- (void)refreshHouseTagsWithHouseArray:(NSArray *)houseTags andTagID:(NSNumber *)tagID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%lld", [tagID longLongValue]];
    NSArray *filteredArray = [houseTags filteredArrayUsingPredicate:predicate];
    if (filteredArray.count == 0) {
        return;
    }
    NSDictionary *tag = filteredArray[0];
    NSString *title = tag[@"title"];
    UIColor *color = [UIColor colorFromHexString:[NSString stringWithFormat:@"#%@", tag[@"color"]]];
    
    UILabel *titleLable = [[UILabel alloc] init];
    [titleLable setText:title];
    [titleLable setTextColor:color];
    [titleLable setFont:[UIFont room107SystemFontOne]];
    titleLable.layer.cornerRadius = 5.0f;
    titleLable.layer.borderWidth = 1.0f;
    titleLable.layer.borderColor = color.CGColor ;
    titleLable.textAlignment = NSTextAlignmentCenter;
    CGRect titleRect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, btnHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLable.font} context:nil];
    CGFloat lastOriginX = CGRectGetMaxX(_houseTagsScrollView.subviews.lastObject.frame);

    [titleLable setFrame:CGRectMake(lastOriginX ? lastOriginX + 5 : lastOriginX, 0, titleRect.size.width + 15, btnHeight)];
    [_houseTagsScrollView addSubview:titleLable];
    self.contentWidth += titleLable.frame.size.width + 5;
}

@end
