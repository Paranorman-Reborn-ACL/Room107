//
//  HouseDetailViewController.m
//  room107
//
//  Created by ningxia on 15/12/28.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "HouseDetailViewController.h"
#import "SuiteAgent.h"
#import "SuiteModel.h"
#import "HouseModel.h"
#import "UserModel.h"
#import "RoomModel.h"
#import "HouseProfileTableViewCell.h"
#import "HouseFeatureTableViewCell.h"
#import "HouseSignedWarningTableViewCell.h"
#import "BasicInfoTableViewCell.h"
#import "FacilityTableViewCell.h"
#import "SuiteCotenantGuideTableViewCell.h"
#import "DescriptionTableViewCell.h"
#import "MapPositionTableViewCell.h"
#import "SimilarHouseTableViewCell.h"
#import "DateShowTableViewCell.h"
#import "SuiteBottomView.h"
#import "MapPositionViewController.h"
#import "Room107TableView.h"
#import "IconMutualView.h"
#import "OnlineContractGuideViewController.h"
#import "AuthenticationAgent.h"
#import "NYPhotoBrowser.h"
#import "SuiteReportViewController.h"
#import "AppTextModel.h"
#import "SystemAgent.h"
#import "SDCycleScrollView.h"
#import "CExpandHeader.h"
#import "CustomImageView.h"
#import "UserAccountAgent.h"
#import "QiniuFileAgent.h"
#import "TenantTradingViewController.h"
#import "NSString+Encoded.h"
#import "TemplateViewFuncs.h"

static CGFloat bottomViewHeight = 49.0f;

@interface HouseDetailViewController () <UITableViewDataSource, UITableViewDelegate, SDCycleScrollViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) Room107TableView *suiteTableView;
@property (nonatomic, strong) HouseFeatureTableViewCell *staticHouseFeatureTableViewCell;
@property (nonatomic, strong) HouseSignedWarningTableViewCell *staticHouseSignedWarningTableViewCell;
@property (nonatomic, strong) SuiteCotenantGuideTableViewCell *staticSuiteCotenantGuideTableViewCell;
@property (nonatomic, strong) SuiteCotenantGuideTableViewCell *suiteCotenantGuideTableViewCell; //当前需要交互的SuiteCotenantGuideTableViewCell
@property (nonatomic, strong) DescriptionTableViewCell *staticDescriptionTableViewCell;
@property (nonatomic, strong) SuiteBottomView *suiteBottomView;
@property (nonatomic, strong) ItemModel *item;
@property (nonatomic, strong) SuiteModel *suite;
@property (nonatomic, strong) NSDictionary *URLParams;
@property (nonatomic, strong) NSDictionary *contact; //房东的联系信息
@property (nonatomic, strong) UIBarButtonItem *starButtonItem; //收藏按钮
@property (nonatomic, strong) UIBarButtonItem *shareButtonItem; //分享按钮
@property (nonatomic, strong) UIBarButtonItem *reportButtonItem; //举报按钮
@property (nonatomic, strong) NSMutableArray *suiteImages; //房间所有图片URL
@property (nonatomic, strong) NSMutableArray *imageNames; //房间所有图片名称
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) CExpandHeader *expandHeader; //必须申明，否则Register无效
@property (nonatomic, strong) UILabel *imageIndexLabel;
@property (nonatomic, strong) UILabel *imageNameLabel;
@property (nonatomic, strong) void (^houseInterestHandlerBlock)(NSNumber *isInterest); //将当前房间的收藏操作结果回调给找房页
@property (nonatomic, strong) CustomImageView *avatarImageView;//针对ios7的特殊情况添加头像覆盖
@property (nonatomic) NSNumber *ID; //房间ID，为id或roomId
@property (nonatomic) NSUInteger rentType; //房间类型，0：未知，1：单间，2：整租，3：不限
@property (nonatomic, strong) UILabel *priceLabel; //用于在Header上显示价格

@end

@implementation HouseDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _suiteImages = [[NSMutableArray alloc] init];
    _imageNames = [[NSMutableArray alloc] init];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, self.view.frame.size.width, 28)];
    [_priceLabel setTextColor:[UIColor room107GrayColorE]];
    [_priceLabel setFont:[UIFont room107SystemFontFour]];
    self.navigationItem.titleView = _priceLabel;
}

- (void)createTableView {
    if (!_suiteTableView) {
        CGRect frame = [CommonFuncs tableViewFrame];
        _suiteTableView = [[Room107TableView alloc] initWithFrame:frame];
        _suiteTableView.delegate = self;
        _suiteTableView.dataSource = self;
        UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){frame.origin, frame.size.width, bottomViewHeight + 11}];
        [footerView setBackgroundColor:[UIColor clearColor]];
        _suiteTableView.tableFooterView = footerView;
        [self.view addSubview:_suiteTableView];
        
        frame.size.height = [CommonFuncs houseImageCellSize].height;
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:frame imagesGroup:nil];
        _cycleScrollView.delegate = self;
        _cycleScrollView.sourceViewHeight = CGRectGetHeight(frame);
        _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        _cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleNone;
        _cycleScrollView.placeholderImage = [UIImage imageNamed:@"imageLoading"];
        _cycleScrollView.placeholderImageContentMode = UIViewContentModeCenter;
        _cycleScrollView.autoScroll = NO;
        WEAK_SELF weakSelf = self;
        [self.cycleScrollView setViewDidScrollHandler:^(NSInteger index) {
            if (weakSelf.imageNames && weakSelf.imageNames.count > index) {
                [weakSelf.imageNameLabel setText:weakSelf.imageNames[index]];
                [weakSelf.imageIndexLabel setText:[NSString stringWithFormat:@"%d/%lu", index + 1, (unsigned long)weakSelf.imageNames.count]];
            }
        }];
        _expandHeader = [CExpandHeader expandWithScrollView:_suiteTableView expandView:_cycleScrollView];
        if (!_imageNameLabel && !_imageNameLabel) {
            CGFloat labelWidth = 55.0f;
            CGFloat labelHeight = 22.0f;
            CGFloat originY = 11;
            _imageIndexLabel = [[UILabel alloc] initWithFrame:(CGRect){originY, originY, labelWidth, labelHeight}];
            [_imageIndexLabel setBackgroundColor:[UIColor room107BlackColorWithAlpha:0.3]];
            [_imageIndexLabel setTextColor:[UIColor whiteColor]];
            [_imageIndexLabel setTextAlignment:NSTextAlignmentCenter];
            [_imageIndexLabel setFont:[UIFont room107SystemFontTwo]];
            _imageIndexLabel.layer.cornerRadius = labelHeight / 2;
            _imageIndexLabel.layer.masksToBounds = YES;
            [_cycleScrollView addSubview:_imageIndexLabel];
            
            _imageNameLabel = [[UILabel alloc] initWithFrame:(CGRect){frame.size.width - labelWidth - originY, originY, labelWidth, labelHeight}];
            [_imageNameLabel setBackgroundColor:[UIColor room107BlackColorWithAlpha:0.3]];
            [_imageNameLabel setTextColor:[UIColor whiteColor]];
            [_imageNameLabel setTextAlignment:NSTextAlignmentCenter];
            [_imageNameLabel setFont:[UIFont room107SystemFontTwo]];
            _imageNameLabel.layer.cornerRadius = labelHeight / 2;
            _imageNameLabel.layer.masksToBounds = YES;
            [_cycleScrollView addSubview:_imageNameLabel];
        }
        
        _staticHouseFeatureTableViewCell = [[HouseFeatureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseFeatureTableViewCell"];
        _staticHouseSignedWarningTableViewCell = [[HouseSignedWarningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseSignedWarningTableViewCell"];
        _staticSuiteCotenantGuideTableViewCell = [[SuiteCotenantGuideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteCotenantGuideTableViewCell"];
        _staticDescriptionTableViewCell = [[DescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DescriptionTableViewCell"];
    }
}

- (void)createBasicView {
    if (!_suiteBottomView) {
        NSString *buttonTitle = lang(@"BeSignedOnline");
        AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@15];
        if (!appText) {
            [[SystemAgent sharedInstance] getTextPropertiesFromServer];
        } else {
            buttonTitle = appText.text;
        }
        _suiteBottomView = [[SuiteBottomView alloc] initWithFrame:(CGRect){0, CGRectGetHeight(_suiteTableView.bounds) - bottomViewHeight, CGRectGetWidth(self.view.bounds), bottomViewHeight} andBeSignedOnlineButtonTitle:buttonTitle];
        [self.view addSubview:_suiteBottomView];
        
        WEAK_SELF weakSelf = self;
        [_suiteBottomView setBeSignedOnlineButtonDidClickHandler:^{
            [weakSelf willSignedOnline];
        }];
        
        [_suiteBottomView setContactOwnerButtonDidClickHandler:^() {
            [weakSelf contactOwner];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_suiteTableView) {
        [self updateStarButtonItemWithInterest];
    }
}

- (void)updateStarButtonItemWithInterest {
    if (!_shareButtonItem) {
        _shareButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage makeImageFromText:lang(@"Share") font:[UIFont room107FontFour] color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonDidClicked:)];
        
        _reportButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage makeImageFromText:@"\ue647" font:[UIFont room107FontFour] color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(reportButtonDidClicked:)];
        
        _starButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage makeImageFromText:@"\ue645" font:[UIFont room107FontFour] color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(starButtonDidClicked:)];
    }
    
    [_starButtonItem setImage:[UIImage makeImageFromText:[_suite.isInterest boolValue] ? @"\ue646": @"\ue645" font:[UIFont room107FontFour] color:[UIColor whiteColor]]];
    
    self.navigationItem.rightBarButtonItems = @[_shareButtonItem, _reportButtonItem, _starButtonItem];
}

- (IBAction)reportButtonDidClicked:(id)sender {
    if (![[AppClient sharedInstance] isLogin]) {
        //未登录
        [self pushLoginAndRegisterViewController];
        return;
    }
    
    if (![[AppClient sharedInstance] isAuthenticated]) {
        //未认证
        [self pushAuthenticateViewController];
        return;
    }
    
    //举报需认证权限
    NSNumber *houseID = _item.id;
    NSNumber *roomID = [_item.rentType isEqual:@1] ? _item.roomId : nil;
    if (_URLParams) {
        houseID = [NSNumber numberWithLongLong:[_URLParams[@"houseId"] longLongValue]];
        roomID = _URLParams[@"roomId"] ? [NSNumber numberWithLongLong:[_URLParams[@"roomId"] longLongValue]] : nil;
    }
    SuiteReportViewController *suiteReportViewController = [[SuiteReportViewController alloc] initWithHouseID:houseID andRoomID:roomID];
    [self.navigationController pushViewController:suiteReportViewController animated:YES];
}

- (IBAction)starButtonDidClicked:(id)sender {
    if (![[AppClient sharedInstance] isLogin]) {
        [self pushLoginAndRegisterViewController];
        return;
    }
    
    NSNumber *houseID = _item.id;
    NSNumber *roomID = [_item.rentType isEqual:@1] ? _item.roomId : nil;
    if (_URLParams) {
        houseID = [NSNumber numberWithLongLong:[_URLParams[@"houseId"] longLongValue]];
        roomID = _URLParams[@"roomId"] ? [NSNumber numberWithLongLong:[_URLParams[@"roomId"] longLongValue]] : nil;
    }
    if ([_suite.isInterest boolValue]) {
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            
        }];
        WEAK_SELF weakSelf = self;
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Delete") action:^{
            [weakSelf showLoadingView];
            [[SuiteAgent sharedInstance] removeInterestWithHouseID:houseID andRoomID:roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [weakSelf hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                    if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                        //业务限制
                        return;
                    }
                }
                if (!errorCode) {
                    [weakSelf refreshInterestState];
                    [weakSelf showAlertViewWithTitle:lang(@"SuiteHasBeenDeleted") message:nil];
                }
            }];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"WhetherDeleteTargetSuite")
                                                        message:@"" cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    } else {
        [self showLoadingView];
        WEAK_SELF weakSelf = self;
        [[SuiteAgent sharedInstance] addInterestWithHouseID:houseID andRoomID:roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
            [weakSelf hideLoadingView];
            if (errorTitle || errorMsg) {
                [PopupView showTitle:errorTitle message:errorMsg];
                if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                    //业务限制
                    return;
                }
            }
            if (!errorCode) {
                [weakSelf refreshInterestState];
                [weakSelf showAlertViewWithTitle:lang(@"JoinedBeSignedListTitle") message:lang(@"JoinedBeSignedListMessage")];
            }
        }];
    }
}

- (void)refreshInterestState {
    _suite.isInterest = [NSNumber numberWithBool:![_suite.isInterest boolValue]];
    if (_houseInterestHandlerBlock) {
        _houseInterestHandlerBlock(_suite.isInterest);
    }
    [self updateStarButtonItemWithInterest];
}

- (IBAction)shareButtonDidClicked:(id)sender {
    NSString *url = [[[AppClient sharedInstance] baseDomain] stringByAppendingFormat:@"/app/html/share?houseId=%@", [_ID stringValue]];
    if (_rentType == 1) {
        url = [[[AppClient sharedInstance] baseDomain] stringByAppendingFormat:@"/app/html/share?roomId=%@", [_ID stringValue]];
    }
    
    NSString *imageURL = [_suite.house.imageId[@"url"] stringByAppendingString:[NSString stringWithFormat:@"%@%d", imageView2Thumbnails, 100]]; //大小不能超过32K
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@9];
    NSString *title = appText.title ? appText.title : @"";
    NSString *content = [NSString stringWithFormat:@"%@%@ %@ %@ %@", _suite.house.price, lang(@"MoneyPerMonth"), _suite.house.name, _suite.house.city, _suite.house.position]; //价格 几室几厅（主次卧 性别限制）区 地址
    if ([_suite.house.rentType isEqual:@1]) {
        //分租
        RoomModel *room = _suite.rooms[0];
        content = [NSString stringWithFormat:@"%@%@ %@ %@ %@ %@", room.price, lang(@"MoneyPerMonth"), room.name, [CommonFuncs requiredGenderTextForWXMediaMessage:_suite.house.requiredGender], _suite.house.city, _suite.house.position];
    }
    
    //避免部分特殊格式数据无法解析
    [[NXURLHandler sharedInstance] handleOpenURL:shareURI params:@{@"title":title ? [title URLEncodedString] : @"", @"content":content ? [content URLEncodedString] : @"", @"imageUrl":imageURL ? imageURL : @"", @"targetUrl":url ? url : @""} context:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationItem.rightBarButtonItems = @[];
}

/*
 URLParams:{
 houseId = 15106;
 roomId = 26871;
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _URLParams = URLParams;
    _ID = _URLParams[@"roomId"] ? @([_URLParams[@"roomId"] longLongValue]) : @([_URLParams[@"houseId"] longLongValue]);
    _rentType = _URLParams[@"roomId"] ? 1 : 0;

    [self getSuite];
}

- (void)setItem:(ItemModel *)item {
    _item = item;
    //此时即获取_ID与_rentType值，避免_item为<fault>后数据异常
    _ID = [_item.rentType isEqual:@1] ? _item.roomId : _item.id;
    _rentType = [_item.rentType unsignedIntegerValue];
    [self getSuite];
}

- (void)setHouseInterestHandler:(void(^)(NSNumber *isInterest))handler {
    _houseInterestHandlerBlock = handler;
}

- (void)willSignedOnline {
    if (![_suite.house.status isEqual:@0] || ![_suite.house.auditStatus isEqual:@0] || [_item.rentType isEqual:@1] ? ![_item.status isEqual:@0] : NO) {
        //已出租
        [self showAlertViewWithTitle:lang(@"SuiteHasBeenRented") message:nil];
        return;
    }
    
    [self pushTenantTradingViewControllerWithSuite:_suite andItem:_item];
}

- (void)pushTenantTradingViewControllerWithSuite:(SuiteModel *)suite andItem:(ItemModel *)item {
    NSNumber *houseID = item.id;
    NSNumber *roomID = [item.rentType isEqual:@1] ? item.roomId : nil;
    if (_URLParams) {
        houseID = [NSNumber numberWithLongLong:[_URLParams[@"houseId"] longLongValue]];
        roomID = _URLParams[@"roomId"] ? [NSNumber numberWithLongLong:[_URLParams[@"roomId"] longLongValue]] : nil;
    }
    
    if ([suite.hasContract boolValue]) {
        TenantTradingViewController *tenantTradingViewController = [[TenantTradingViewController alloc] initWithHouseID:houseID andRoomID:roomID isInterest:[suite.isInterest boolValue]];
        [self.navigationController pushViewController:tenantTradingViewController animated:YES];
    } else {
        OnlineContractGuideViewController *onlineContractGuideViewController = [[OnlineContractGuideViewController alloc] initWithHouseID:houseID andRoomID:roomID isInterest:[suite.isInterest boolValue] isOnlineSigned:[_suite.house.contractEnableStatus isEqual:@0]];
        [self.navigationController pushViewController:onlineContractGuideViewController animated:YES];
    }
    
    if (![suite.isInterest boolValue]) {
        //必须为收藏的房间
        [self refreshInterestState];
    }
}

- (void)contactOwner {
    if (![[AppClient sharedInstance] isLogin]) {
        [self pushLoginAndRegisterViewController];
        return;
    }
    
    NSNumber *houseID = _item.id;
    if (!houseID) {
        if (_URLParams) {
            houseID = @([_URLParams[@"houseId"] longLongValue]);
        } else {
            return;
        }
    }
    [self showLoadingView];
    [[SuiteAgent sharedInstance] getContactWithHouseID:houseID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *contact, NSNumber *authStatus) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
                [PopupView showTitle:errorTitle message:errorMsg];
                //业务限制
                return;
            }
        }
        if (!errorCode) {
            _contact = contact;
            NSString *telephone = contact[@"telephone"];
            NSString *wechat = contact[@"wechat"];
            NSString *qq = contact[@"qq"];
            
            IconMutualView *iconMutualView = [[IconMutualView alloc] initWithIcons:@[@{@"title":@"\ue618", @"color":telephone && ![telephone isEqualToString:@""] ? [UIColor room107GreenColor] : [UIColor room107GrayColorC]}, @{@"title":@"\ue616", @"color":qq && ![qq isEqualToString:@""] ? [UIColor room107GreenColor] : [UIColor room107GrayColorC]}, @{@"title":@"\ue612", @"color":wechat && ![wechat isEqualToString:@""] ? [UIColor room107GreenColor] : [UIColor room107GrayColorC]}]];
            [iconMutualView setIconButtonDidClickHandler:^(NSInteger index) {
                switch (index) {
                    case 0:
                        if (telephone && ![telephone isEqualToString:@""]) {
                            NSString *title = telephone;
                            NSString *message = @"";
                            NSString *cancelButtonTitle = lang(@"Cancel");
                            NSString *otherButtonTitle = lang(@"Dial");
                            RIButtonItem *cancelButtonItem = [cancelButtonTitle isEqualToString:@""] ? nil : [RIButtonItem itemWithLabel:cancelButtonTitle action:^{
                            }];
                            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:otherButtonTitle action:^{
                                [CommonFuncs callTelephone:telephone];
                                AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@17];
                                if (!appText) {
                                    [[SystemAgent sharedInstance] getTextPropertiesFromServer];
                                } else {
                                    [self showAlertViewWithTitle:appText.title message:appText.text];
                                }
                            }];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
                            [alert show];
                        } else {
                            [PopupView showMessage:lang(@"NoSuchContactInfo")];
                        }
                        break;
                    default:
                    {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];//系统剪贴板
                        NSString *title = @"";
                        NSString *message = @"";
                        BOOL hasSuchContactInfo = NO;
                        if (index == 1) {
                            if (qq && ![qq isEqualToString:@""]) {
                                pasteboard.string = qq;
                                title = qq;
                                message = lang(@"CopyLandlordQQ");
                                hasSuchContactInfo = YES;
                            }
                        } else {
                            if (wechat && ![wechat isEqualToString:@""]) {
                                pasteboard.string = wechat;
                                title = wechat;
                                message = lang(@"CopyLandlordWechat");
                                hasSuchContactInfo = YES;
                            }
                        }
                        
                        if (hasSuchContactInfo) {
                            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"OK") action:^{
                                AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@17];
                                if (!appText) {
                                    [[SystemAgent sharedInstance] getTextPropertiesFromServer];
                                } else {
                                    [self showAlertViewWithTitle:appText.title message:appText.text];
                                }
                            }];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:nil otherButtonItems:otherButtonItem, nil];
                            [alert show];
                        } else {
                            [PopupView showMessage:lang(@"NoSuchContactInfo")];
                        }

                        break;
                    }
                }
            }];
        } else {
            if ([errorCode unsignedIntegerValue] == unAuthenticateCode) {
                //未认证
                [self pushAuthenticateViewController];
            }
        }
    }];
}

- (void)getSuite {
    [[SuiteAgent sharedInstance] getSuiteByID:_ID andRentType:_rentType completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, SuiteModel *suite) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            //标记该房子为已读
            NSNumber *houseID = _item.id;
            NSNumber *roomID = [_item.rentType isEqual:@1] ? _item.roomId : nil;
            if (_URLParams) {
                houseID = [NSNumber numberWithLongLong:[_URLParams[@"houseId"] longLongValue]];
                roomID = _URLParams[@"roomId"] ? [NSNumber numberWithLongLong:[_URLParams[@"roomId"] longLongValue]] : nil;
            }
            [[SuiteAgent sharedInstance] updateSubscribeItemToReadByHouseID:houseID andRoomID:roomID];
            
            [self createTableView];
            [self createBasicView];
            
            _suite = suite;
            [self updateStarButtonItemWithInterest];
            [_suiteImages removeAllObjects];
            [_imageNames removeAllObjects];
            for (RoomModel *room in _suite.rooms) {
                if (((NSArray *)room.imageIds).count > 0) {
                    for (NSDictionary *imageId in room.imageIds) {
                        [_suiteImages addObject:imageId[@"url"]];
                        [_imageNames addObject:room.name];
                    }
                }
            }
            if (_suiteImages.count > 0) {
                _cycleScrollView.imageURLStringsGroup = _suiteImages;
            } else {
                //该房间无图片，给张本地的默认图
                _cycleScrollView.localizationImagesGroup = @[[UIImage imageNamed:@"defaultRoomPic.jpg"]];
            }
            _imageIndexLabel.hidden = _imageNames.count == 0;
            _imageNameLabel.hidden = _imageNames.count == 0;
            
            [_suiteTableView reloadData];
            //系统版本低于8.0 采取备用方案
            if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                [self addAnotherAvatarWithUrl:suite.landlord.faviconUrl];
            }
        }
    }];
}

- (void)addOrRemoveCotenantWithHouseID:(NSNumber *)houseID {
    WEAK_SELF weakSelf = self;
    WEAK(_suiteCotenantGuideTableViewCell) weakCell = _suiteCotenantGuideTableViewCell;
    __block NSString *alertMessage = [_suite.isCotenant boolValue] ? lang(@"MarkedInterestMessage") : lang(@"RentSingleRoomMessage");
    
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
    }];
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
        [weakSelf showLoadingView];
        if ([_suite.isCotenant boolValue]) {
            [[SuiteAgent sharedInstance] removeCotenantWithHouseID:houseID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [weakSelf hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    weakSelf.suite.isCotenant = [NSNumber numberWithBool:NO];
                    [weakCell refreshCotenantGuideButtonStatusByIsCotenant:NO];
                }
            }];
        } else {
            [[SuiteAgent sharedInstance] addCotenantWithHouseID:houseID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [weakSelf hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    weakSelf.suite.isCotenant = [NSNumber numberWithBool:YES];
                    [weakCell refreshCotenantGuideButtonStatusByIsCotenant:YES];
                }
            }];
        }
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:alertMessage cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];
}

- (void)contactCotenantWithHouseID:(NSNumber *)houseID andUserID:(NSNumber *)userID {
    WEAK_SELF weakSelf = self;
    [self showLoadingView];
    [[SuiteAgent sharedInstance] contactCotenantWithHouseID:houseID andUserID:userID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *telephone) {
        [weakSelf hideLoadingView];
        
        if ([errorCode unsignedIntegerValue] == BusinessErrorCode) {
            //业务限制
            WEAK(weakSelf.suiteCotenantGuideTableViewCell) weakCell = weakSelf.suiteCotenantGuideTableViewCell;
            RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            }];
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
                [weakSelf showLoadingView];
                [[SuiteAgent sharedInstance] addCotenantWithHouseID:houseID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                    [weakSelf hideLoadingView];
                    if (errorTitle || errorMsg) {
                        [PopupView showTitle:errorTitle message:errorMsg];
                    }
                    
                    if (!errorCode) {
                        weakSelf.suite.isCotenant = [NSNumber numberWithBool:YES];
                        [weakCell refreshCotenantGuideButtonStatusByIsCotenant:YES];
                        //此时用户是通过点击头像标记合租意向的，需要继续请求合租人的手机号
                        [weakSelf contactCotenantWithHouseID:houseID andUserID:userID];
                    }
                }];
            }];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:lang(@"RentSingleRoomMessage") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
            [alert show];
            
            return;
        }
        
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
            
        if (!errorCode) {
            RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
            }];
            RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Dial") action:^{
                [CommonFuncs callTelephone:telephone];
            }];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:telephone message:@"" cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
            [alert show];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
}

- (void)showAvatarUploadedView {
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
    }];
    WEAK_SELF weakSelf = self;
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:lang(@"Confirm") action:^{
        [weakSelf willUploadAvatar];
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"AvatarUploadedTitle")
                                                    message:lang(@"AvatarUploadedMessage") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];
}

- (void)willUploadAvatar {
    if ([[AppClient sharedInstance] isLogin]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:lang(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:lang(@"Camera"), lang(@"Photos"), nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                [PopupView showMessage:lang(@"DeviceDoesNotSupportTakePhotos")];
            }
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:picker animated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self showLoadingView];
    
    __block UIImage *avatarImage = info[UIImagePickerControllerEditedImage];
    WEAK_SELF weakSelf = self;
    // 在此处将获得的avatarImage上传
    [[UserAccountAgent sharedInstance] getUploadAvatarTokenWithCompletion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *faviconKey) {
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
                
        if (!errorCode) {
            NSMutableArray *imageDics = [[NSMutableArray alloc] init];
            [imageDics addObject:@{@"image":avatarImage, @"key":faviconKey}];
            [[QiniuFileAgent sharedInstance] uploadWithImageDics:imageDics token:token completion:^(NSError *error, NSString *errorMsg) {
                if (!error) {
                    [[UserAccountAgent sharedInstance] uploadAvatarWithFaviconKey:faviconKey completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *faviconImage) {
                        [weakSelf hideLoadingView];
                        
                        if (errorTitle || errorMsg) {
                            [PopupView showTitle:errorTitle message:errorMsg];
                        }
                
                        if (!errorCode) {
                            //将头像URL写入数据库
                            [[AuthenticationAgent sharedInstance] updateUserSetFaviconURL:faviconImage];
                            NSNumber *houseID = weakSelf.item.id;
                            if (weakSelf.URLParams) {
                                houseID = [NSNumber numberWithLongLong:[weakSelf.URLParams[@"houseId"] longLongValue]];
                            }
                            [weakSelf addOrRemoveCotenantWithHouseID:houseID];
                        } else {
                            if ([self isLoginStateError:errorCode]) {
                                return;
                            }
                        }
                    }];
                } else {
                    [weakSelf hideLoadingView];
                    [PopupView showMessage:errorMsg];
                }
            }];
        } else {
            [weakSelf hideLoadingView];
            if ([self isLoginStateError:errorCode]) {
                return;
            }
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - cycleScrollViewDelegate
//轮播图点击事件监听
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (_suiteImages.count > 0) {
        NYPhotoBrowser *photoBrowser = [[NYPhotoBrowser alloc] initWithImages:_suiteImages supportDelete:NO];
        [photoBrowser setImageNames:_imageNames];
        [photoBrowser setInitialPageIndex:index];
        [self presentViewController:photoBrowser animated:YES completion:^{
            
        }];
    } else {
        [self showAlertViewWithTitle:lang(@"SuiteHasNoImages") message:nil];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    _priceLabel.hidden = offsetY < houseProfileTableViewCellHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            HouseProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseProfileTableViewCell"];
            if (!cell) {
                cell = [[HouseProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseProfileTableViewCell"];
            }

            NSNumber *price = _suite.house.price;
            NSString *name = _suite.house.name;
            NSString *requiredGender = @"";
            if (_rentType == 1) {
                //分租才有性别限制
                requiredGender = [CommonFuncs requiredGenderText:_suite.house.requiredGender];
                for (RoomModel *room in _suite.rooms) {
                    if ([room.id isEqual:_ID]) {
                        price = room.price;
                        name = room.name;
                        break;
                    }
                }
            }
            
            [_priceLabel setText:[NSString stringWithFormat:@"￥%@", price ? price : @""]];
            [cell setAvatarImageViewWithURL:_suite.landlord.faviconUrl];
            [cell setCity:_suite.house.city andName:name andRequiredGender:requiredGender];
            [cell setPosition:_suite.house.position];
            [cell setPrice:price];
            [cell setHouseNumber:_suite.house.externalId];
            if (_suite.house.lastModifiedTime) {
                [cell setSubmitTime:[TimeUtil timeStringFromTimestamp:[_suite.house.lastModifiedTime doubleValue] / 1000 withDateFormat:@"yyyy/MM/dd HH:mm"]];
            }
            
            return cell;
        }
            break;
        case 1:
        {
            HouseFeatureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseFeatureTableViewCell"];
            if (!cell) {
                cell = [[HouseFeatureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseFeatureTableViewCell"];
            }
            [cell setFeatureTagIDs:_suite.house.tagIds];
            
            return cell;
        }
            break;
        case 2:
        {
            HouseSignedWarningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseSignedWarningTableViewCell"];
            if (!cell) {
                cell = [[HouseSignedWarningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HouseSignedWarningTableViewCell"];
            }
            AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@16];
            [cell setContent:appText.text];
            
            return cell;
        }
            break;
        case 3:
        {
            BasicInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicInfoTableViewCell"];
            if (!cell) {
                cell = [[BasicInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BasicInfoTableViewCell"];
            }
            
            [cell setName:[NSString stringWithFormat:[lang(@"HouseName") stringByAppendingFormat:@"  %@", lang(@"KitchenName")], [CommonFuncs chineseFigureByNumber:_suite.house.roomNumber], [CommonFuncs chineseFigureByNumber:_suite.house.hallNumber], [CommonFuncs chineseFigureByNumber:_suite.house.kitchenNumber], [CommonFuncs chineseFigureByNumber:_suite.house.toiletNumber]]];
            if (_rentType == 1) {
                for (RoomModel *room in _suite.rooms) {
                    if ([room.id isEqual:_ID]) {
                        if (room.area && ![room.area isEqual:@0]) {
                            [cell setAreaContent:[NSString stringWithFormat:@"%@m²/%@m²", room.area, _suite.house.area]];
                        } else {
                            [cell setAreaContent:@""];
                        }
                        [cell setFloor:_suite.house.floor];
                        [cell setOrientation:room.orientation];
                        
                        break;
                    }
                }
            } else {
                if (_suite.house.area && ![_suite.house.area isEqual:@0]) {
                    [cell setAreaContent:[NSString stringWithFormat:@"%@m²", _suite.house.area]];
                } else {
                    [cell setAreaContent:@""];
                }
                [cell setFloor:_suite.house.floor];
                [cell setOrientation:@""];
            }
            
            return cell;
        }
            break;
        case 4:
        {
            FacilityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacilityTableViewCell"];
            if (!cell) {
                cell = [[FacilityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacilityTableViewCell"];
                [cell setCellTitle:lang(@"Facility")];
                [cell setSourceFacilities:@[@{@"icon":@"\ue600", @"content":lang(@"TV")}, @{@"icon":@"\ue601", @"content":lang(@"Fridge")}, @{@"icon":@"\ue602", @"content":lang(@"Washer")}, @{@"icon":@"\ue603", @"content":lang(@"AirConditioner")}, @{@"icon":@"\ue604", @"content":lang(@"Elevator")}, @{@"icon":@"\ue605", @"content":lang(@"WaterHeater")}, @{@"icon":@"\ue606", @"content":lang(@"WIFI")}, @{@"icon":@"\ue607", @"content":lang(@"Balcony")}]];
            }
            [cell setFacilities:_suite.house.facilities];
            
            return cell;
        }
            break;
        case 5:
        {
            SuiteCotenantGuideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuiteCotenantGuideTableViewCell"];
            if (!cell) {
                cell = [[SuiteCotenantGuideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuiteCotenantGuideTableViewCell"];
                _suiteCotenantGuideTableViewCell = cell;
            }
            if (_rentType != 1) {
                //不是分租
                NSNumber *appTextID = @20;
                if ([_suite.cotenants count] > 0) {
                    appTextID = @19;
                }
                
                AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:appTextID];
                [cell refreshCotenantGuideButtonStatusByIsCotenant:[_suite.isCotenant boolValue]];
                [cell setContent:appText.text andCotenants:_suite.cotenants];
                WEAK_SELF weakSelf = self;
                __block NSNumber *houseID = weakSelf.item.id;
                if (weakSelf.URLParams) {
                    houseID = [NSNumber numberWithLongLong:[weakSelf.URLParams[@"houseId"] longLongValue]];
                }
                [cell setCotenantGuideButtonDidClickHandler:^{
                    if (![[AppClient sharedInstance] isLogin]) {
                        [weakSelf pushLoginAndRegisterViewController];
                    } else {
                        if (![[AppClient sharedInstance] isAuthenticated]) {
                            [weakSelf pushAuthenticateViewController];
                        } else {
                            if (![[AppClient sharedInstance] hasAvatar]) {
                                //准备上传头像
                                [weakSelf showAvatarUploadedView];
                            } else {
                                [weakSelf addOrRemoveCotenantWithHouseID:houseID];
                            }
                        }
                    }
                }];
                [cell setCotenantAvatarDidClickHandler:^(NSUInteger index) {
                    if ([_suite.cotenants count] > index) {
                        if (![[AppClient sharedInstance] isLogin]) {
                            [weakSelf pushLoginAndRegisterViewController];
                        } else {
                            if (![[AppClient sharedInstance] isAuthenticated]) {
                                [weakSelf pushAuthenticateViewController];
                            } else {
                                if (![[AppClient sharedInstance] hasAvatar]) {
                                    //准备上传头像
                                    [weakSelf showAvatarUploadedView];
                                } else {
                                    [weakSelf contactCotenantWithHouseID:houseID andUserID:_suite.cotenants[index][@"id"]];
                                }
                            }
                        }
                    }
                }];
            }
            
            return cell;
        }
            break;
        case 6:
        {
            DescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionTableViewCell"];
            if (!cell) {
                cell = [[DescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DescriptionTableViewCell"];
            }
            [cell setDescription:_suite.house.houseDescription];
            
            return cell;
        }
            break;
        case 7:
        {
            MapPositionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapPositionTableViewCell"];
            if (!cell) {
                cell = [[MapPositionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapPositionTableViewCell"];
            }
            NSString *urlString = nil;
            if (_suite.house.locationX && _suite.house.locationY && ![_suite.house.locationX isEqual:@-1] && ![_suite.house.locationY isEqual:@-1]) {
                //locationX:经度，locationY：维度
                urlString = [NSString stringWithFormat:@"http://api.map.baidu.com/staticimage?center=%f,%f&width=%.f&height=%.f&zoom=%f&ak=%@", [_suite.house.locationX doubleValue], [_suite.house.locationY doubleValue], [CommonFuncs suiteViewOtherCellSize].width, [CommonFuncs suiteViewOtherCellSize].height, [CommonFuncs mapZoomLevel], BaiduMapKey];
            }
            [cell setMapPositionWithURL:urlString];
            
            return cell;
        }
            break;
        case 8:
        {
            DateShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateShowTableViewCell"];
            if (!cell) {
                cell = [[DateShowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DateShowTableViewCell"];
            }
            [cell setDateShowText:_suite.house.checkinTime ? [TimeUtil friendlyDateTimeFromDateTime:_suite.house.checkinTime withFormat:@"%Y/%m/%d"] : nil];
            
            return cell;
        }
            break;
        case 9:
        {
            FacilityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RentsIncludeFeesCell"];
            if (!cell) {
                cell = [[FacilityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RentsIncludeFeesCell"];
                [cell setCellTitle:lang(@"RentsIncludeFees")];
                [cell setSourceFacilities:@[@{@"icon":@"\ue670", @"content":lang(@"Water")}, @{@"icon":@"\ue671", @"content":lang(@"Electricity")}, @{@"icon":@"\ue672", @"content":lang(@"Gas")}, @{@"icon":@"\ue606", @"content":lang(@"Net")}, @{@"icon":@"\ue673", @"content":lang(@"Estate")}, @{@"icon":@"\ue674", @"content":lang(@"Health")}, @{@"icon":@"\ue675", @"content":lang(@"Heater")}, @{@"icon":@"\ue600", @"content":lang(@"TV")}]];
            }
            [cell setFacilities:_suite.house.extraFees];
            
            return cell;
        }
            break;
        case 10:
        {
            SimilarHouseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimilarHouseTableViewCell"];
            if (!cell) {
                cell = [[SimilarHouseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimilarHouseTableViewCell"];
            }
            [cell setRecommendHouses:_suite.recommendHouses];
            WEAK_SELF weakSelf = self;
            [cell setViewHouseTagExplanationHandler:^(NSDictionary *params) {
                [[NXURLHandler sharedInstance] handleOpenURL:htmlURI params:params context:weakSelf];
            }];
            [cell setSelectHouseHandler:^(NSArray *houses, NSInteger index) {
                if (houses.count > index) {
                    HouseDetailViewController *houseDetailViewController = [[HouseDetailViewController alloc] init];
                    [houseDetailViewController setItem:houses[index]];
                    [weakSelf.navigationController pushViewController:houseDetailViewController animated:YES];
                }
            }];
            
            return cell;
        }
            break;
        default:
            return [Room107TableViewCell new];
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 2:
            [self willSignedOnline];
            break;
        case 7:
        {
            MapPositionViewController *mapPositionVC = [[MapPositionViewController alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([_suite.house.locationY doubleValue], [_suite.house.locationX doubleValue]);
            [mapPositionVC setCoordinate:coordinate position:_suite.house.position];
            [self presentViewController:mapPositionVC animated:YES completion:^{
                
            }];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return houseProfileTableViewCellHeight;
            break;
        case 1:
            if ([(NSArray *)_suite.house.tagIds count] > 0) {
                return [_staticHouseFeatureTableViewCell getCellHeightWithTagIDs:_suite.house.tagIds];
            }
            return 0;
            break;
        case 2:
        {
            AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@16];
            if (!appText) {
                //一次性执行
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [[SystemAgent sharedInstance] getTextPropertiesFromServer];
                });
            }
            return MAX(houseSignedWarningTableViewCellMinHeight, [_staticHouseSignedWarningTableViewCell getCellHeightWithContent:appText.text]);
        }
            break;
        case 3:
        {
            CGFloat viewHeight = basicInfoViewMinHeight;
            if (_rentType == 1) {
                for (RoomModel *room in _suite.rooms) {
                    if ([room.id isEqual:_ID]) {
                        if (room.area && ![room.area isEqual:@0]) {
                            viewHeight += basicInfoItemHeight;
                        }
                        if (_suite.house.floor && ![_suite.house.floor isEqual:@0]) {
                            viewHeight += basicInfoItemHeight;
                        }
                        if (room.orientation && ![room.orientation isEqualToString:@""]) {
                            viewHeight += basicInfoItemHeight;
                        }
                        
                        return viewHeight;
                    }
                }
                
                return viewHeight;
            } else {
                if (_suite.house.area && ![_suite.house.area isEqual:@0]) {
                    viewHeight += basicInfoItemHeight;
                }
                if (_suite.house.floor && ![_suite.house.floor isEqual:@0]) {
                    viewHeight += basicInfoItemHeight;
                }
            }
            
            return viewHeight;
        }
            break;
        case 4:
            if (_suite.house.facilities && [_suite.house.facilities count] > 0) {
                return facilityTableViewCellHeight;
            }
            return 0;
            break;
        case 5:
        {
            if (_rentType != 1) {
                //不是分租
                NSNumber *appTextID = @20;
                if ([_suite.cotenants count] > 0) {
                    appTextID = @19;
                }
                
                AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:appTextID];
                if (!appText) {
                    //一次性执行
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        [[SystemAgent sharedInstance] getTextPropertiesFromServer];
                    });
                    return 0;
                }
                return [_staticSuiteCotenantGuideTableViewCell getCellHeightWithContent:appText.text andCotenants:_suite.cotenants];
            } else {
                return 0;
            }
        }
            break;
        case 6:
            // 注意houseDescription与description的区别（细心）
            return [_staticDescriptionTableViewCell getCellHeightWithDescription:_suite.house.houseDescription];
            break;
        case 7:
            if (_suite.house.locationX && _suite.house.locationY && ![_suite.house.locationX isEqual:@-1] && ![_suite.house.locationY isEqual:@-1]) {
                return [CommonFuncs suiteViewOtherCellSize].height + 64;
            }
            return 0;
            break;
        case 8:
            if (_suite.house.checkinTime && ![_suite.house.checkinTime isEqualToString:@""]) {
                return dateShowTableViewCellHeight;
            }
            return 0;
            break;
        case 9:
            if (_suite.house.extraFees && [_suite.house.extraFees count] > 0) {
                return facilityTableViewCellHeight;
            }
            return 0;
            break;
        case 10:
            if ([(NSArray *)_suite.recommendHouses count] > 0) {
                return spaceY + [TemplateViewFuncs sixSubTemplateCellSize].height + similarHouseTableViewCellMinHeight;
            }
            return 0;
            break;
        default:
            break;
    }
    
    return 200.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAnotherAvatarWithUrl:(NSString *)url {
    if (!_avatarImageView) {
        //针对ios7 滑动事件不响应的问题的解决
        CGFloat avatarImageViewWidth = 66;
        CGFloat originX = 11;
        self.avatarImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - avatarImageViewWidth - originX,  -avatarImageViewWidth/2, avatarImageViewWidth, avatarImageViewWidth)];
        [_avatarImageView setCornerRadius:avatarImageViewWidth / 2];
        _avatarImageView.layer.borderWidth = 2.0f;
        _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_suiteTableView addSubview:_avatarImageView];        
        if (!url || [url isEqualToString:@""]) {
            [_avatarImageView setImageWithName:@"loginlogo.png"];
        } else {
            [_avatarImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loginlogo.png"]];
        } 
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
