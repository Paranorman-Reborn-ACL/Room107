//
//  HouseLandlordDetailViewController.m
//  room107
//
//  Created by ningxia on 16/4/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "HouseLandlordDetailViewController.h"
#import "Room107TableView.h"
#import "SuiteAgent.h"
#import "CustomImageView.h"
#import "CustomButton.h"
#import "SearchTipLabel.h"
#import "SuiteManageViewController.h"
#import "Room107TableViewCell.h"
#import "QuickEditView.h"
#import "SevenTemplateView.h"
#import "HouseManageAgent.h"
#import "EightTemplateTableViewCell.h"
#import "NineTemplateTableViewCell.h"
#import "SelectOtherTypeTableViewCell.h"
#import "LandlordTradingViewController.h"
#import "LandlordContractManageViewController.h"
#import "TwelveTemplateView.h"
#import "SignedProcessAgent.h"
#import "SystemAgent.h"
#import "NSString+Encoded.h"
#import "HouseLandlordUpdateCoverViewController.h"

@interface HouseLandlordDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Room107TableView *houseDetailTableView;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSNumber *houseID;
@property (nonatomic, strong) NSNumber *roomID;
@property (nonatomic, strong) NSDictionary *houseInfo;
@property (nonatomic, strong) NSMutableArray *items; //出租情况
@property (nonatomic) BOOL isPackUpItems; //出租情况项是否收起
@property (nonatomic, strong) NSMutableArray *expiredItems; //签约申请
@property (nonatomic) BOOL isPackUpExpiredItems; //签约申请项是否收起

@end

@implementation HouseLandlordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:lang(@"HouseLandlordDetail")];
    [self setRightBarButtonTitle:lang(@"Preview")];
    _isPackUpItems = YES;
    _isPackUpExpiredItems = YES;
}

- (IBAction)rightBarButtonDidClick:(id)sender {
    //跳转至房子详情页
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] init];
    if (_houseID) {
        [paramsDic setObject:_houseID forKey:@"houseId"];
    }
    if (_roomID) {
        [paramsDic setObject:_roomID forKey:@"roomId"];
    }
    [[NXURLHandler sharedInstance] handleOpenURL:houseDetailURI params:paramsDic context:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getHouseLandlordDetail];
}

- (id)initWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID {
    self = [super init];
    if (self != nil) {
        _houseID = houseID;
        _roomID = roomID;
    }
    
    return self;
}

/*
 URLParams:{
 houseId = 15515;
 roomId = 6515;
 }
 */
- (void)setURLParams:(NSDictionary *)URLParams {
    _houseID = URLParams[@"houseId"];
    _roomID = URLParams[@"roomId"];
}

- (void)getHouseLandlordDetail {
    if (!_sections) {
        [self showLoadingView];
    }
    
    [[SuiteAgent sharedInstance] getLandlordHouseSuiteByHouseID:_houseID andRoomID:_roomID completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *item, NSArray *requests) {
        [self hideLoadingView];
        if (errorTitle || errorMsg) {
            [PopupView showTitle:errorTitle message:errorMsg];
        }
        
        if (!errorCode) {
            _houseInfo = item;
            [self createTableView];
            _sections = [[NSMutableArray alloc] initWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"RentConditions"), @"title", [[NSMutableArray alloc] init], @"value", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"SignedInvite"), @"title", [[NSMutableArray alloc] init], @"value", nil], nil];
            [self classifiedContractByRequests:requests];
            [self resetItems];
            [self resetExpiredItems];
        } else {
            if ([self isLoginStateError:errorCode]) {
                return;
            }
            
            if (!_sections) {
                if ([errorCode isEqual:[NSNumber numberWithUnsignedInteger:networkErrorCode]]) {
                    [self showNetworkFailedWithFrame:self.view.frame andRefreshHandler:^{
                        [self getHouseLandlordDetail];
                    }];
                } else {
                    [self showUnknownErrorWithFrame:self.view.frame andRefreshHandler:^{
                        [self getHouseLandlordDetail];
                    }];
                }
            }
        }
    }];
}

- (void)classifiedContractByRequests:(NSArray *)requests {
    _items = [[NSMutableArray alloc] init];
    _expiredItems = [[NSMutableArray alloc] init];
    for (NSDictionary *request in requests) {
        /*
         public static enum RequestStatus {
         FILLING, CONFIRMING, RENTING, TERMINATED, CLOSE_BY_ADMIN, CLOSE_BY_LANDLORD, CLOSE_BY_TENANT
         }
         */
        if ([request[@"requestStatus"] isEqual:@2] || [request[@"requestStatus"] isEqual:@3]) {
            [_items addObject:request];
        } else {
            [_expiredItems addObject:request];
        }
    }
}

- (void)resetItems {
    if (_sections.count > 0 && _items) {
        if (_isPackUpItems) {
            if (_items.count > 0) {
                [_sections[0] setValue:[[NSMutableArray alloc] initWithObjects:_items[0], nil] forKey:@"value"];
            }
        } else {
            [_sections[0] setValue:[[NSMutableArray alloc] initWithArray:_items] forKey:@"value"];
        }
        [_houseDetailTableView reloadData];
    }
}

- (void)resetExpiredItems {
    if (_sections.count > 1 && _expiredItems) {
        if (_isPackUpExpiredItems) {
            if (_expiredItems.count > 0) {
                [_sections[1] setValue:[[NSMutableArray alloc] initWithObjects:_expiredItems[0], nil] forKey:@"value"];
            }
        } else {
            [_sections[1] setValue:[[NSMutableArray alloc] initWithArray:_expiredItems] forKey:@"value"];
        }
        [_houseDetailTableView reloadData];
    }
}

- (void)createTableView {
    if (!_houseDetailTableView) {
        _houseDetailTableView = [[Room107TableView alloc] initWithFrame:[CommonFuncs tableViewFrame] style:UITableViewStyleGrouped];
        _houseDetailTableView.delegate = self;
        _houseDetailTableView.dataSource = self;
        [self.view addSubview:_houseDetailTableView];
        _houseDetailTableView.tableFooterView = [self createTableFooterView];
    }
    _houseDetailTableView.tableHeaderView = [self createTableHeaderView];
}

- (UIView *)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, CGRectGetWidth(self.view.bounds), 0}];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat originY = 0;
    CGFloat imageViewWidth = CGRectGetWidth(headerView.bounds);
    CGFloat imageViewHeight = imageViewWidth * 9 / 16;
    CustomImageView *imageView = [[CustomImageView alloc] initWithFrame:(CGRect){0, originY, imageViewWidth, imageViewHeight}];
    NSDictionary *houseListItem = _houseInfo[@"houseListItem"];
    if (houseListItem && houseListItem[@"hasCover"] && [houseListItem[@"hasCover"] boolValue]) {
        [imageView setContentMode:UIViewContentModeCenter]; //图片按实际大小居中显示
        WEAK(imageView) weakImageView = imageView;
        NSString *imageURL = houseListItem[@"cover"] ? houseListItem[@"cover"][@"url"] : @"";
        [imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"imageLoading"] withCompletionHandler:^(UIImage *image) {
            if (image) {
                weakImageView.contentMode = UIViewContentModeScaleAspectFill; //图片撑满显示
            }
        }];
    } else {
        //该房间无图片，给张本地的默认图
        [imageView setImageWithName:@"defaultRoomPic.jpg"];
    }
    [headerView addSubview:imageView];
    
    CGFloat buttonWidth = 70;
    CGFloat buttonHeight = 30;
    CGFloat originX = CGRectGetWidth(imageView.bounds) - 11 - buttonWidth;
    originY = CGRectGetHeight(imageView.bounds) - 11 - buttonHeight;
    CustomButton *editCoverButton = [[CustomButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, buttonHeight}];
    [editCoverButton setBackgroundColor:[UIColor room107BlackColorWithAlpha:0.5]];
    editCoverButton.layer.cornerRadius = 2;
    editCoverButton.layer.masksToBounds = YES;
    [editCoverButton.titleLabel setFont:[UIFont room107FontTwo]];
    [editCoverButton setTitle:lang(@"EditCover") forState:UIControlStateNormal];
    [editCoverButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editCoverButton addTarget:self action:@selector(editCoverButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editCoverButton];
    
    originX = 11;
    originY = CGRectGetHeight(imageView.bounds) + 11;
    CGFloat labelWidth = CGRectGetWidth(headerView.bounds) - 2 * originX;
    CGFloat labelHeight = 16;
    SearchTipLabel *positionLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
    [positionLabel setNumberOfLines:1];
    [positionLabel setTextColor:[UIColor room107GrayColorE]];
    [positionLabel setText:[houseListItem[@"city"] ? houseListItem[@"city"] : @"" stringByAppendingFormat:@" %@", houseListItem[@"position"] ? houseListItem[@"position"] : @""]];
    [headerView addSubview:positionLabel];
    
    originY += CGRectGetHeight(positionLabel.bounds) + 11;
    labelHeight = 12;
    SearchTipLabel *basicInfoLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, labelWidth, labelHeight}];
    [basicInfoLabel setNumberOfLines:1];
    [basicInfoLabel setFont:[UIFont room107SystemFontOne]];
    NSString *houseName = houseListItem[@"houseName"];
    NSString *areaInfo = [NSString stringWithFormat:@"%@m²", houseListItem[@"area"] ? houseListItem[@"area"] : @0];
    NSString *floorInfo = [NSString stringWithFormat:@"%@%@", houseListItem[@"floor"] ? houseListItem[@"floor"] : @0, lang(@"Floor")];
    NSString *priceInfo = [NSString stringWithFormat:@"￥%@", houseListItem[@"price"] ? houseListItem[@"price"] : @0];
    [basicInfoLabel setText:[houseName stringByAppendingFormat:@"  %@  %@", areaInfo, floorInfo]];
    [headerView addSubview:basicInfoLabel];
    
    originY += CGRectGetHeight(basicInfoLabel.bounds) + 12;
    labelHeight = 20;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:priceInfo];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontTwo] range:NSMakeRange(0, 1)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont room107SystemFontFour] range:NSMakeRange(1, priceInfo.length - 1)];
    SearchTipLabel *priceLabel = [[SearchTipLabel alloc] initWithFrame:(CGRect){originX, originY, attributedString.size.width, labelHeight}];
    [priceLabel setTextColor:[UIColor room107GreenColor]];
    [priceLabel setAttributedText:attributedString];
    [headerView addSubview:priceLabel];
    
    originX += CGRectGetWidth(priceLabel.bounds) + 11;
    if (_roomID) {
        //分租
        UILabel *tagLabel = [self tagLabelWithOrigin:CGPointMake(originX, originY) andTag:lang(@"Subletting")];
        [headerView addSubview:tagLabel];
        
        originX += CGRectGetWidth(tagLabel.bounds) + 5;
        tagLabel = [self tagLabelWithOrigin:CGPointMake(originX, originY) andTag:lang(@"MasterBedroom")];
        [headerView addSubview:tagLabel];
        
        originX += CGRectGetWidth(tagLabel.bounds) + 5;
        tagLabel = [self tagLabelWithOrigin:CGPointMake(originX, originY) andTag:[CommonFuncs requiredGenderText:houseListItem[@"requiredGender"] ? houseListItem[@"requiredGender"] : @0]];
        [headerView addSubview:tagLabel];
    } else {
        //整租
        UILabel *tagLabel = [self tagLabelWithOrigin:CGPointMake(originX, originY) andTag:lang(@"RentHouse")];
        [headerView addSubview:tagLabel];
    }
    
    //编辑信息
    originY += CGRectGetHeight(priceLabel.bounds) + 11;
    CGFloat viewWidth = CGRectGetWidth(headerView.bounds);
    CGFloat viewHeight = 44;
    QuickEditView *editInfoView = [[QuickEditView alloc] initWithFrame:(CGRect){0, originY, viewWidth, viewHeight} withButtonTitle:[@"\ue67e " stringByAppendingString:lang(@"EditInfo")]];
    WEAK_SELF weakSelf = self;
    [editInfoView setButtonDidClickHandler:^{
        SuiteManageViewController *suiteManageViewController = [[SuiteManageViewController alloc] initWithHouseID:weakSelf.houseID andRoomID:weakSelf.roomID];
        [weakSelf.navigationController pushViewController:suiteManageViewController animated:YES];
    }];
    [headerView addSubview:editInfoView];
    
    originY += CGRectGetHeight(editInfoView.bounds);
    UIView *spaceView = [[UIView alloc] initWithFrame:(CGRect){0, originY, viewWidth, 11}];
    [spaceView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
    [headerView addSubview:spaceView];
    
    originY += CGRectGetHeight(spaceView.bounds);
    //houseStatus房间状态，0表示审核中，1表示审核失败，2表示对外出租，3暂不对外，4租住中
    NSArray *houseStatuses = @[lang(@"UnderReview"), lang(@"AuditFailed"), lang(@"Opening"), lang(@"CloseIn"), lang(@"BeRented")];
    NSString *displayStatusText = [_houseInfo[@"displayStatus"] ? _houseInfo[@"displayStatus"] : @"" stringByAppendingFormat:@"  %@", _houseInfo[@"houseStatus"] ? houseStatuses[[_houseInfo[@"houseStatus"] intValue]] : houseStatuses[0]];
    SevenTemplateView *houseStatusView = [[SevenTemplateView alloc] initWithFrame:(CGRect){0, originY, viewWidth, viewHeight} andTemplateDataDictionary:@{@"text":displayStatusText ? displayStatusText : @"", @"textColor":@"797979"}];
    [headerView addSubview:houseStatusView];
    
    //开放出租or关闭出租
    originY += CGRectGetHeight(houseStatusView.bounds);
    NSNumber *houseStatus = houseListItem[@"status"] ? houseListItem[@"status"] : @0;
    NSString *buttonTitle = [houseStatus isEqual:@0] ? [@"\ue65b " stringByAppendingString:lang(@"CloseHouse")] : [@"\ue65c " stringByAppendingString:lang(@"OpenHouse")];
    QuickEditView *changeHouseStatusView = [[QuickEditView alloc] initWithFrame:(CGRect){0, originY, viewWidth, viewHeight} withButtonTitle:buttonTitle];
    [changeHouseStatusView setButtonDidClickHandler:^{
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
        }];
        //即将关闭出租
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[houseStatus isEqual:@0] ? lang(@"Closed") : lang(@"Open") action:^{
            [weakSelf showLoadingView];
            [[HouseManageAgent sharedInstance] updateHouseStatusWithHouseID:weakSelf.houseID andRoomID:weakSelf.roomID andStatus:[NSNumber numberWithBool:[houseStatus isEqual:@0]] completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [self hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    if ([houseStatus isEqual:@0]) {
                        //关闭成功
                        [weakSelf showAlertViewWithTitle:lang(@"CloseHouseSuccess") message:nil];
                    } else {
                        [weakSelf showAlertViewWithTitle:lang(@"OpenHouseSuccess") message:nil];
                    }
                    
                    [weakSelf getHouseLandlordDetail];
                }
            }];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[houseStatus isEqual:@0] ? lang(@"CloseHouseTips") : lang(@"OpenHouseTips")
                                                        message:nil
                                               cancelButtonItem:cancelButtonItem
                                               otherButtonItems:otherButtonItem, nil];
        [alert show];
    }];
    [headerView addSubview:changeHouseStatusView];
    
    [headerView setFrame:(CGRect){0, 0, CGRectGetWidth(self.view.bounds), originY + CGRectGetHeight(changeHouseStatusView.frame)}];

    return headerView;
}

- (UIView *)createTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, CGRectGetWidth(self.view.bounds), 88}];
    
    SevenTemplateView *houseStatusView = [[SevenTemplateView alloc] initWithFrame:(CGRect){0, 22, CGRectGetWidth(self.view.bounds), 44} andTemplateDataDictionary:@{@"imageCode":lang(@"Share"), @"text":lang(@"ShareToQuicklyRent"), @"textColor":@"00ac97"}];
    [footerView addSubview:houseStatusView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(willShareHouse)];
    [footerView addGestureRecognizer:tapGesture];
    
    return footerView;
}

- (void)willShareHouse {
    NSString *url = [[[AppClient sharedInstance] baseDomain] stringByAppendingFormat:@"/app/html/share?houseId=%@", [_houseID stringValue]];
    if (_roomID) {
        url = [[[AppClient sharedInstance] baseDomain] stringByAppendingFormat:@"/app/html/share?roomId=%@", [_roomID stringValue]];
    }
    
    NSDictionary *houseListItem = _houseInfo[@"houseListItem"];
    NSString *imageURL = @"";
    if (houseListItem && houseListItem[@"hasCover"] && [houseListItem[@"hasCover"] boolValue]) {
        imageURL = houseListItem[@"cover"] ? [houseListItem[@"cover"][@"url"] stringByAppendingString:[NSString stringWithFormat:@"%@%d", imageView2Thumbnails, 100]] : @""; //大小不能超过32K
    }
    AppTextModel *appText = [[SystemAgent sharedInstance] getTextPropertyByID:@9];
    NSString *title = appText.title ? appText.title : @"";
    NSString *content = [NSString stringWithFormat:@"%@%@ %@ %@ %@ %@", houseListItem[@"price"] ? houseListItem[@"price"] : @0, lang(@"MoneyPerMonth"), houseListItem[@"name"] ? houseListItem[@"name"] : @"", [CommonFuncs requiredGenderTextForWXMediaMessage:houseListItem[@"requiredGender"] ? houseListItem[@"requiredGender"] : @0], houseListItem[@"city"] ? houseListItem[@"city"] : @"", houseListItem[@"position"] ? houseListItem[@"position"] : @""];
    
    //避免部分特殊格式数据无法解析
    [[NXURLHandler sharedInstance] handleOpenURL:shareURI params:@{@"title":title ? [title URLEncodedString] : @"", @"content":content ? [content URLEncodedString] : @"", @"imageUrl":imageURL ? imageURL : @"", @"targetUrl":url ? url : @""} context:self];
}

- (UILabel *)tagLabelWithOrigin:(CGPoint)origin andTag:(NSString *)tag {
    UILabel *tagLabel = [[UILabel alloc] init];
    [tagLabel setBackgroundColor:[UIColor clearColor]];
    if (tag && [tag isEqualToString:@""]) {
        return tagLabel;
    }
    
    //圆角
    tagLabel.layer.cornerRadius = 1.0f;
    tagLabel.layer.masksToBounds = YES;
    //描边
    tagLabel.layer.borderWidth = 0.5f;
    tagLabel.layer.borderColor = [UIColor room107GrayColorC].CGColor;
    [tagLabel setFont:[UIFont room107SystemFontOne]];
    [tagLabel setTextColor:[UIColor room107GrayColorD]];
    [tagLabel setText:tag];
    [tagLabel setTextAlignment:NSTextAlignmentCenter];
    //计算文字的宽度
    CGRect contentRect = [tag ? tag : @"" boundingRectWithSize:(CGSize){100, MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:tagLabel.font} context:nil];
    [tagLabel setFrame:(CGRect){origin, contentRect.size.width + 10, 20}];
    
    return tagLabel;
}

- (IBAction)editCoverButtonDidClick:(id)sender {
    HouseLandlordUpdateCoverViewController *houseLandlordUpdateCoverViewController = [[HouseLandlordUpdateCoverViewController alloc] initWithHouseID:_houseID andRoomID:_roomID];
    [self.navigationController pushViewController:houseLandlordUpdateCoverViewController animated:YES];
}

- (void)operateSignedInviteWithContractRequest:(NSDictionary *)request {
    //FILLING, CONFIRMING, RENTING, TERMINATED, CLOSE_BY_ADMIN, CLOSE_BY_LANDLORD, CLOSE_BY_TENANT
    NSString *title = @"";
    NSString *message = lang(@"WhetherRefuseSignedInvite");
    NSString *cancelButtonTitle = lang(@"Cancel");
    NSString *otherTitle = lang(@"Refuse");
    
    BOOL showAlertView = YES;
    switch ([request[@"requestStatus"] intValue]) {
        case 2:
            showAlertView = NO;
            break;
        case 0:
        case 1:
            break;
        default:
            showAlertView = NO;
            message = lang(@"WhetherDeleteNotes");
            otherTitle = lang(@"Delete");
            break;
    }
    if (showAlertView) {
        RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:cancelButtonTitle action:^{
        }];
        RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:otherTitle action:^{
            [self showLoadingView];
            [[SignedProcessAgent sharedInstance] landlordDiscardContractWithContractID:request[@"contractId"] completion:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode) {
                [self hideLoadingView];
                if (errorTitle || errorMsg) {
                    [PopupView showTitle:errorTitle message:errorMsg];
                }
                
                if (!errorCode) {
                    if ([request[@"waitOtherContract"] boolValue]) {
                        [_sections[0][@"value"] removeObject:request];
                    } else {
                        switch ([request[@"requestStatus"] intValue]) {
                            case 0:
                            case 1:
                            case 2:
                                [_sections[0][@"value"] removeObject:request];
                                break;
                            default:
                                [_sections[1][@"value"] removeObject:request];
                                break;
                        }
                    }
                    [_houseDetailTableView reloadData];
                }
            }];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
        [alert show];
    }
}

- (EightTemplateTableViewCell *)eightTemplateTableViewCellAtIndexPath:(NSIndexPath *)indexPath  andTableView:(UITableView *)tableView {
    EightTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EightTemplateTableViewCell"];
    if (!cell) {
        cell = [[EightTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EightTemplateTableViewCell"];
    }
    NSDictionary *request = _sections[indexPath.section][@"value"][indexPath.row];
    NSString *tailText = [NSString stringWithFormat:lang(@"RentalDateRange"), [TimeUtil friendlyDateTimeFromDateTime:request[@"checkinTime"] withFormat:@"%Y/%m/%d"], [TimeUtil friendlyDateTimeFromDateTime:request[@"exitTime"] withFormat:@"%Y/%m/%d"]];
    //FILLING, CONFIRMING, RENTING, TERMINATED, CLOSE_BY_ADMIN, CLOSE_BY_LANDLORD, CLOSE_BY_TENANT
    NSArray *requestStatuses = @[lang(@"Filling"), lang(@"Confirming"), lang(@"Renting"), lang(@"Terminated"), lang(@"CloseByAdmin"), lang(@"CloseByLandlord"), lang(@"CloseByTenant")];
    NSString *headText = requestStatuses[[request[@"requestStatus"] intValue]];
    NSString *headBackgroundColor = @"c9c9c9";
    if ([request[@"requestStatus"] intValue] == 0) {
        headBackgroundColor = @"ffbc00";
    } else if ([request[@"requestStatus"] intValue] < 4) {
        headBackgroundColor = @"00ac97";
    }
    
    [cell setTemplateDataDictionary:@{@"imageUrl":request[@"tenantFavicon"] ? request[@"tenantFavicon"] : @"", @"imageType":@1, @"text":request[@"tenantName"] ? request[@"tenantName"] : @"", @"reddie":request[@"newUpdate"] ? request[@"newUpdate"] : @0, @"subtext":request[@"tenantTelephone"] ? request[@"tenantTelephone"] : @"", @"headText":headText, @"headBackgroundColor":headBackgroundColor, @"tailText":tailText ? tailText : @"", @"isEnable":@1}];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
    }];
    
    return cell;
}

- (NineTemplateTableViewCell *)nineTemplateTableViewCellAtIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView {
    NineTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NineTemplateTableViewCell"];
    if (!cell) {
        cell = [[NineTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NineTemplateTableViewCell"];
    }
    [cell setTemplateDataDictionary:@{@"text":indexPath.section == 0 ? lang(@"NoCurrentRent") : lang(@"NoCurrentApply"), @"subtext":indexPath.section == 0 ? lang(@"HouseCanShareOut") : lang(@"CanStayDynamic")}];
    
    return cell;
}

- (SelectOtherTypeTableViewCell *)selectOtherTypeTableViewCellAtIndexPath:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView {
    SelectOtherTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectOtherTypeTableViewCell"];
    if (!cell) {
        cell = [[SelectOtherTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectOtherTypeTableViewCell"];
    }
    if ([_sections[indexPath.section][@"value"] count] > 1) {
        [cell setDisplayText:lang(@"PackUp")];
    } else {
        [cell setDisplayText:indexPath.section == 0 ? lang(@"HistoryRental") : lang(@"AllApplications")];
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_sections.count > section) {
        if (section == 0) {
            //出租情况
            if (!_items || _items.count <= 1) {
                return 1;
            } else {
                return [_sections[section][@"value"] count] + 1;
            }
        } else {
            //签约申请
            if (!_expiredItems || _expiredItems.count <= 1) {
                return 1;
            } else {
                return [_sections[section][@"value"] count] + 1;
            }
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections.count > indexPath.section) {
        if (indexPath.section == 0) {
            //出租情况
            if (!_items || _items.count <= 1) {
                if (!_items || _items.count == 0) {
                    return [self nineTemplateTableViewCellAtIndexPath:indexPath andTableView:tableView];
                } else {
                    return [self eightTemplateTableViewCellAtIndexPath:indexPath andTableView:tableView];
                }
            } else {
                if ([_sections[indexPath.section][@"value"] count] > indexPath.row) {
                    return [self eightTemplateTableViewCellAtIndexPath:indexPath andTableView:tableView];
                } else {
                    return [self selectOtherTypeTableViewCellAtIndexPath:indexPath andTableView:tableView];
                }
            }
        } else {
            //签约申请
            if (!_expiredItems || _expiredItems.count <= 1) {
                if (!_expiredItems || _expiredItems.count == 0) {
                    return [self nineTemplateTableViewCellAtIndexPath:indexPath andTableView:tableView];
                } else {
                    return [self eightTemplateTableViewCellAtIndexPath:indexPath andTableView:tableView];
                }
            } else {
                if ([_sections[indexPath.section][@"value"] count] > indexPath.row) {
                    return [self eightTemplateTableViewCellAtIndexPath:indexPath andTableView:tableView];
                } else {
                    return [self selectOtherTypeTableViewCellAtIndexPath:indexPath andTableView:tableView];
                }
            }
        }
    }
    
    return [Room107TableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections.count > indexPath.section) {
        if (indexPath.section == 0) {
            //出租情况
            if (!_items || _items.count <= 1) {
                if (!_items || _items.count == 0) {
                    return nineTemplateTableViewCellHeight;
                } else {
                    return eightTemplateTableViewCellHeight;
                }
            } else {
                if ([_sections[indexPath.section][@"value"] count] > indexPath.row) {
                    return eightTemplateTableViewCellHeight;
                } else {
                    return selectOtherTypeTableViewCellHeight;
                }
            }
        } else {
            //签约申请
            if (!_expiredItems || _expiredItems.count <= 1) {
                if (!_expiredItems || _expiredItems.count == 0) {
                    return nineTemplateTableViewCellHeight;
                } else {
                    return eightTemplateTableViewCellHeight;
                }
            } else {
                if ([_sections[indexPath.section][@"value"] count] > indexPath.row) {
                    return eightTemplateTableViewCellHeight;
                } else {
                    return selectOtherTypeTableViewCellHeight;
                }
            }
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_sections.count > section) {
        return 11 + 36;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //若tableView是Group类型 返回值是0,则会返回默认值  所以保证隐藏footerInSection 给一极小值。
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    [headerView setBackgroundColor:[UIColor room107ViewBackgroundColor]];
    
    if (_sections.count > section) {
        TwelveTemplateView *titleView = [[TwelveTemplateView alloc] initWithFrame:(CGRect){0, 11, CGRectGetWidth(frame), 36} andTemplateDataDictionary:@{@"image":@"trim.png", @"text":_sections[section][@"title"] ? _sections[section][@"title"] : @""}];
        [headerView addSubview:titleView];
    }

    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sections.count > indexPath.section && [_sections[indexPath.section][@"value"] count] > indexPath.row) {
        NSDictionary *request = _sections[indexPath.section][@"value"][indexPath.row];
        
        if ([request[@"waitOtherContract"] boolValue]) {
            return;
        }
        
        if ([request[@"requestStatus"] intValue] <= 1 || [request[@"requestStatus"] intValue] >= 4) {
            LandlordTradingViewController *landlordTradingViewController = [[LandlordTradingViewController alloc] initWithContractID:request[@"contractId"]];
            [self.navigationController pushViewController:landlordTradingViewController animated:YES];
        } else {
            LandlordContractManageViewController *landlordContractManageViewController = [[LandlordContractManageViewController alloc] initWithContractID:request[@"contractId"] andSelectedIndex:0];
            [self.navigationController pushViewController:landlordContractManageViewController animated:YES];
        }
    } else {
        switch (indexPath.section) {
            case 0:
                _isPackUpItems = !_isPackUpItems;
                [self resetItems];
                break;
            default:
                _isPackUpExpiredItems = !_isPackUpExpiredItems;
                [self resetExpiredItems];
                break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
