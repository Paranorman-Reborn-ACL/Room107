//
//  RoomInfoFillInViewController.m
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RoomInfoFillInViewController.h"
#import "Room107TableView.h"
#import "SearchTipLabel.h"
#import "CircleGreenMarkView.h"
#import "RoomSummaryTableViewCell.h"
#import "RoomAddTableViewCell.h"
#import "SublettingRoomAddTableViewCell.h"
#import "RoomDetailViewController.h"
#import "OtherRoomPhotosViewController.h"
#import "NSString+Valid.h"
#import "OtherRoomPhotosTableViewCell.h"
#import "SublettingOtherRoomPhotosTableViewCell.h"
#import "OpenRoomSummaryTableViewCell.h"
#import "ClosedRoomSummaryTableViewCell.h"
#import "SublettingRoomDetailViewController.h"
#import "HouseManageAgent.h"
#import "YellowColorTextLabel.h"

@interface RoomInfoFillInViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) Room107TableView *roomsTableView;
@property (nonatomic, strong) NSMutableArray *rooms;//photos，房子照片，必填；type，房子类型，见RoomType（RoomModel的type），必填；area，房子面积，必填；orientation，房子朝向，必填
@property (nonatomic, strong) void (^prevStepHandlerBlock)();
@property (nonatomic, strong) void (^postSuiteHandlerBlock)();
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（包含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) NSArray *houseKeysArray;
@property (nonatomic, strong) RoomDetailViewController *roomDetailViewController; //添加卧室 （整租）
@property (nonatomic, strong) OtherRoomPhotosViewController *otherRoomPhotosViewController;  //添加其他房间VC
@property (nonatomic, strong) NSMutableArray *otherRoomPhotos;
@property (nonatomic, strong) SublettingRoomDetailViewController *sublettingRoomDetailViewController; //添加卧室 (分租)

@end

@implementation RoomInfoFillInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON andHouseKeysArray:(NSArray *)houseKeysArray {
    _imageToken = imageToken;
    _imageKeyPattern = imageKeyPattern;
    _houseJSON = houseJSON;
    _houseKeysArray = houseKeysArray;
    
    if (!_rooms) {
        _otherRoomPhotos = [[NSMutableArray alloc] init];
        _rooms = [[NSMutableArray alloc] init];
    }
    [_otherRoomPhotos removeAllObjects];
    [_rooms removeAllObjects];
    
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Kitchen"), @"key", _houseJSON[@"kitchenPhotos"], @"value", nil]];
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"LivingRoom"), @"key", _houseJSON[@"hallPhotos"], @"value", nil]];
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Toilet"), @"key", _houseJSON[@"toiletPhotos"], @"value", nil]];
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Other"), @"key", _houseJSON[@"otherPhotos"], @"value", nil]];
    
    if (!_roomsTableView) {
        _roomsTableView = [[Room107TableView alloc] initWithFrame:[CommonFuncs tableViewFrame] style:UITableViewStyleGrouped];
        _roomsTableView.delegate = self;
        _roomsTableView.dataSource = self;
        _roomsTableView.tableHeaderView = [self createHeaderView];
        _roomsTableView.tableFooterView = [self createFooterView];
        [self.view addSubview:_roomsTableView];
    }
    
    //_houseJSON[@"rooms"] 表示房间信息
    [_rooms addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Bedroom"), @"key", [_houseJSON[@"rooms"] mutableCopy], @"value", nil]];
    [_rooms addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[lang(@"OtherRoomPhotos") stringByAppendingFormat:@"（%@）", lang(@"Optional")], @"key", _otherRoomPhotos, @"value", nil]];
    [_roomsTableView reloadData];
}

- (UIView *)createHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 76.0f}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = headerView.frame;
    frame.origin.x = 33;
    frame.size.width = frame.size.width - 2 * frame.origin.x;
    frame.size.height -= 13;
    YellowColorTextLabel *houseInfoTipsLabel = [[YellowColorTextLabel alloc] initWithFrame:frame withTitle:lang(@"PostRoomInfoTips")];
    [headerView addSubview:houseInfoTipsLabel];
    
    return headerView;
}
- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 220.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = footerView.frame;
    frame.size.height = 100;
    SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:lang(@"PostSuite") andAssistantButtonTitle:lang(@"BackToPreviousStep")];
    [footerView addSubview:mutualBottomView];
    //发布房子
    [mutualBottomView setMainButtonDidClickHandler:^{
        if ([(NSMutableArray *)_houseJSON[@"rooms"] count] <= 0) {
            [PopupView showMessage:lang(@"BedroomNumberIsZero")];
            return;
        }
        
        if (self.postSuiteHandlerBlock) {
            self.postSuiteHandlerBlock();
        }
    }];
    //返回上一步
    [mutualBottomView setAssistantButtonDidClickHandler:^{
        if (self.prevStepHandlerBlock) {
            self.prevStepHandlerBlock();
        }
    }];
    
    return footerView;
}

- (void)setPrevStepButtonDidClickHandler:(void(^)())handler {
    self.prevStepHandlerBlock = handler;
}

- (void)setPostSuiteButtonDidClickHandler:(void(^)())handler {
    self.postSuiteHandlerBlock = handler;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _rooms.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [(NSMutableArray *)_rooms[section][@"value"] count] + 1;
            break;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (indexPath.row < [(NSMutableArray *)_rooms[indexPath.section][@"value"] count]) {
                NSMutableDictionary *room = _rooms[indexPath.section][@"value"][indexPath.row];
                
                if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                    RoomSummaryTableViewCell *cell = (RoomSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RoomSummaryTableViewCell"];
                    if (!cell) {
                        cell = [[RoomSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomSummaryTableViewCell"];
                    }
                    
                    [cell setCoverImageURL:[room[@"photos"] firstStringBySeparatedString:@"|"]];
                    [cell setRoomType:room[@"type"]];
                    [cell setArea:room[@"area"]];
                    [cell setOrientation:room[@"orientation"]];
                    
                    return cell;
                } else {
                    if ([room[@"status"] isEqual:@0]) {
                        OpenRoomSummaryTableViewCell *cell = (OpenRoomSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OpenRoomSummaryTableViewCell"];
                        if (!cell) {
                            cell = [[OpenRoomSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OpenRoomSummaryTableViewCell"];
                        }
                        
                        [cell setPrice:room[@"price"]];
                        [cell setCoverImageURL:[room[@"photos"] firstStringBySeparatedString:@"|"]];
                        [cell setRoomType:room[@"type"]];
                        [cell setArea:room[@"area"]];
                        [cell setOrientation:room[@"orientation"]];
                        
                        return cell;
                    } else {
                        ClosedRoomSummaryTableViewCell *cell = (ClosedRoomSummaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ClosedRoomSummaryTableViewCell"];
                        if (!cell) {
                            cell = [[ClosedRoomSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClosedRoomSummaryTableViewCell"];
                        }
                        
                        [cell setPhotos:[room[@"photos"] getComponentsBySeparatedString:@"|"]];
                        [cell setRoomType:room[@"type"]];
                        NSInteger row = indexPath.row;
                        NSInteger section = indexPath.section;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                        WEAK_SELF weakSelf = self;
                        cell.closedRoomSummarydidClick = ^(void){
                            [weakSelf tableView:weakSelf.roomsTableView didSelectRowAtIndexPath:indexPath];
                        };
                        return cell;
                    }
                }
            } else {
                if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                    RoomAddTableViewCell *cell = (RoomAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RoomAddTableViewCell"];
                    if (!cell) {
                        cell = [[RoomAddTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomAddTableViewCell"];
                    }
                    [cell setLabelText:lang(@"AddBedroom")];
                    
                    return cell;
                } else {
                    SublettingRoomAddTableViewCell *cell = (SublettingRoomAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SublettingRoomAddTableViewCell"];
                    if (!cell) {
                        cell = [[SublettingRoomAddTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SublettingRoomAddTableViewCell"];
                    }
                    [cell setLabelText:lang(@"AddBedroom")];
                    
                    return cell;
                }
            }
            break;
        default:
        {
            for (NSMutableDictionary *photoDic in _otherRoomPhotos) {
                if (photoDic[@"value"] && ![photoDic[@"value"] isEqualToString:@""]) {
                    if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                        OtherRoomPhotosTableViewCell *cell = (OtherRoomPhotosTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OtherRoomPhotosTableViewCell"];
                        if (!cell) {
                            cell = [[OtherRoomPhotosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OtherRoomPhotosTableViewCell"];
                        }
                        [cell setOtherRoomPhotos:_otherRoomPhotos];
                        
                        return cell;
                    } else {
                        SublettingOtherRoomPhotosTableViewCell *cell = (SublettingOtherRoomPhotosTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SublettingOtherRoomPhotosTableViewCell"];
                        if (!cell) {
                            cell = [[SublettingOtherRoomPhotosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SublettingOtherRoomPhotosTableViewCell"];
                        }
                        [cell setOtherRoomPhotos:_otherRoomPhotos];
                        
                        return cell;
                    }
                }
            }
            
            if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                RoomAddTableViewCell *cell = (RoomAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RoomAddTableViewCell"];
                if (!cell) {
                    cell = [[RoomAddTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomAddTableViewCell"];
                }
                [cell setLabelText:lang(@"AddOtherPhotos")];
                
                return cell;
            } else {
                SublettingRoomAddTableViewCell *cell = (SublettingRoomAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SublettingRoomAddTableViewCell"];
                if (!cell) {
                    cell = [[SublettingRoomAddTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SublettingRoomAddTableViewCell"];
                }
                [cell setLabelText:lang(@"AddOtherPhotos")];
                
                return cell;
            }
        }
            break;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (indexPath.row < [(NSMutableArray *)_rooms[indexPath.section][@"value"] count]) {
                NSMutableDictionary *room = _rooms[indexPath.section][@"value"][indexPath.row];
                
                if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                    return roomSummaryTableViewCellHeight;
                } else {
                    if ([room[@"status"] isEqual:@0]) {
                        return openRoomSummaryTableViewCellHeight;
                    } else {
                        return closedRoomSummaryTableViewCellHeight;
                    }
                }
            } else {
                if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                    return roomAddTableViewCellHeight;
                } else {
                    return sublettingRoomAddTableViewCellHeight;
                }
            }
            break;
        default:
            if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                return roomAddTableViewCellHeight;
            } else {
                return sublettingRoomAddTableViewCellHeight;
            }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]}];
    [view setBackgroundColor:[UIColor clearColor]];
    
    CGFloat labelHeight = CGRectGetHeight(view.bounds);
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){11, (CGRectGetHeight(view.bounds) - labelHeight) / 2, CGRectGetWidth(view.bounds), labelHeight}];
    [label setFont:[UIFont room107FontTwo]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:[UIColor room107GrayColorC]];
    [label setText:_rooms[section][@"key"]];
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    switch (indexPath.section) {
        case 0:
        {
            __block NSMutableArray *oldRooms = _rooms[indexPath.section][@"value"];
            if (!oldRooms) {
                oldRooms = [[NSMutableArray alloc] init];
                [_rooms[indexPath.section] setObject:oldRooms forKey:@"value"];
            }
            __block NSMutableDictionary *oldRoom = [[NSMutableDictionary alloc] init];
            if (indexPath.row < [oldRooms count]) {
                oldRoom = oldRooms[indexPath.row];
            }
            
            if ([_houseJSON[_houseKeysArray[8][0]] isEqual:@2]) {
                if (!_roomDetailViewController) {
                    _roomDetailViewController = [[RoomDetailViewController alloc] init];
                    [_roomDetailViewController setNavigationController:self.navigationController];
                    [_roomDetailViewController.view setFrame:frame];
                    [self.view addSubview:_roomDetailViewController.view];
                }
                [_roomDetailViewController setImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseID:_houseJSON[@"id"] andRoom:oldRoom andType:RoomDetailViewTypeNew];
                WEAK_SELF weakSelf = self;
                [_roomDetailViewController setSaveInfoButtonDidClickHandler:^(NSMutableDictionary *room) {
                    if (indexPath.row >= oldRooms.count) {
                        [oldRooms addObject:room];
                    } else {
                        [oldRooms removeObject:oldRoom];
                        [oldRooms insertObject:room atIndex:indexPath.row];
                    }
                    
                    [weakSelf.roomsTableView reloadData];
                    [weakSelf showRoomDetailView:NO];
                    [weakSelf saveHouseJSON];
                }];
                [_roomDetailViewController setCancelButtonDidClickHandler:^{
                    [weakSelf showRoomDetailView:NO];
                }];
                [self showRoomDetailView:YES];
            } else {
                if (!_sublettingRoomDetailViewController) {
                    _sublettingRoomDetailViewController = [[SublettingRoomDetailViewController alloc] init];
                    [_sublettingRoomDetailViewController setNavigationController:self.navigationController];
                    [_sublettingRoomDetailViewController.view setFrame:frame];
                    [self.view addSubview:_sublettingRoomDetailViewController.view];
                }
                [_sublettingRoomDetailViewController setImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseID:_houseJSON[@"id"] andRoom:oldRoom andType:SublettingRoomDetailViewTypeNew];
                WEAK_SELF weakSelf = self;
                [_sublettingRoomDetailViewController setSaveInfoButtonDidClickHandler:^(NSMutableDictionary *room) {
                    if (indexPath.row >= oldRooms.count) {
                        [oldRooms addObject:room];
                    } else {
                        [oldRooms removeObject:oldRoom];
                        [oldRooms insertObject:room atIndex:indexPath.row];
                    }
                    
                    [weakSelf.roomsTableView reloadData];
                    [weakSelf showSublettingRoomDetailView:NO];
                    [weakSelf saveHouseJSON];
                }];
                [_sublettingRoomDetailViewController setCancelButtonDidClickHandler:^{
                    [weakSelf showSublettingRoomDetailView:NO];
                }];
                [self showSublettingRoomDetailView:YES];
            }
        }
            break;
        default:
        {
            if (!_otherRoomPhotosViewController) {
                _otherRoomPhotosViewController = [[OtherRoomPhotosViewController alloc] init];
                [_otherRoomPhotosViewController setNavigationController:self.navigationController];
                [_otherRoomPhotosViewController.view setFrame:frame];
                [self.view addSubview:_otherRoomPhotosViewController.view];
            }
            [_otherRoomPhotosViewController setImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseJSON:_houseJSON andType:OtherRoomPhotosViewTypeNew];
            WEAK_SELF weakSelf = self;
            [_otherRoomPhotosViewController setSaveInfoButtonDidClickHandler:^() {
                [weakSelf.otherRoomPhotos[0] setObject:weakSelf.houseJSON[@"kitchenPhotos"] forKey:@"value"];
                [weakSelf.otherRoomPhotos[1] setObject:weakSelf.houseJSON[@"hallPhotos"] forKey:@"value"];
                [weakSelf.otherRoomPhotos[2] setObject:weakSelf.houseJSON[@"toiletPhotos"] forKey:@"value"];
                [weakSelf.otherRoomPhotos[3] setObject:weakSelf.houseJSON[@"otherPhotos"] forKey:@"value"];
                
                [weakSelf saveHouseJSON];
                [weakSelf.rooms[1] setObject:weakSelf.otherRoomPhotos forKey:@"value"];
                [weakSelf.roomsTableView reloadData];
                [weakSelf showOtherRoomPhotosView:NO];
            }];
            [_otherRoomPhotosViewController setCancelButtonDidClickHandler:^{
                [weakSelf showOtherRoomPhotosView:NO];
            }];
            [self showOtherRoomPhotosView:YES];
        }
            break;
    }
}

- (void)saveHouseJSON {
    [_houseJSON setObject:_rooms[0][@"value"] forKey:@"rooms"];
    [[HouseManageAgent sharedInstance] saveLandlordSuiteItem:_houseJSON];
}

- (void)showRoomDetailView:(BOOL)show {
    _roomDetailViewController.view.hidden = !show;
    _roomsTableView.hidden = show;
}

- (void)showSublettingRoomDetailView:(BOOL)show {
    _sublettingRoomDetailViewController.view.hidden = !show;
    _roomsTableView.hidden = show;
}

- (void)showOtherRoomPhotosView:(BOOL)show {
    _otherRoomPhotosViewController.view.hidden = !show;
    _roomsTableView.hidden = show;
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
