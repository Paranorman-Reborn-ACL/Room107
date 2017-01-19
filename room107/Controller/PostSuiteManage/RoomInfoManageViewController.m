//
//  RoomInfoManageViewController.m
//  room107
//
//  Created by ningxia on 15/8/28.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "RoomInfoManageViewController.h"
#import "Room107TableView.h"
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

@interface RoomInfoManageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *imageToken;
@property (nonatomic, strong) NSString *imageKeyPattern;
@property (nonatomic, strong) NSMutableDictionary *houseJSON;//描述房子信息（不含房子信息），json格式，json对应的数据结构为LandlordSuiteItem，json整体进行urlEncode
@property (nonatomic, strong) NSMutableArray *rooms;//photos，房子照片，必填；type，房子类型，见RoomType（RoomModel的type），必填；area，房子面积，必填；orientation，房子朝向，必填
@property (nonatomic, strong) Room107TableView *roomsTableView;
@property (nonatomic, strong) RoomDetailViewController *roomDetailViewController;
@property (nonatomic, strong) OtherRoomPhotosViewController *otherRoomPhotosViewController;
@property (nonatomic, strong) NSMutableArray *otherRoomPhotos;
@property (nonatomic, strong) SublettingRoomDetailViewController *sublettingRoomDetailViewController;
@property (nonatomic, strong) void (^dismissHandlerBlock)();
@property (nonatomic) BOOL toBeSave;

@end

@implementation RoomInfoManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _otherRoomPhotos = [[NSMutableArray alloc] init];
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Kitchen"), @"key", _houseJSON[@"kitchenPhotos"], @"value", nil]];
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"LivingRoom"), @"key", _houseJSON[@"hallPhotos"], @"value", nil]];
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Toilet"), @"key", _houseJSON[@"toiletPhotos"], @"value", nil]];
    [_otherRoomPhotos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Other"), @"key", _houseJSON[@"otherPhotos"], @"value", nil]];
    
    _rooms = [[NSMutableArray alloc] init];
    [_rooms addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"Bedroom"), @"key", [_houseJSON[@"rooms"] mutableCopy], @"value", nil]];
    [_rooms addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[lang(@"OtherRoomPhotos") stringByAppendingFormat:@"（%@）", lang(@"Optional")], @"key", _otherRoomPhotos, @"value", nil]];
    
    CGRect frame = self.view.frame;
    frame.size.height -= statusBarHeight + navigationBarHeight + [self heightOfSegmentedControl];
    _roomsTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    _roomsTableView.delegate = self;
    _roomsTableView.dataSource = self;
    _roomsTableView.tableHeaderView = [self createTableHeaderView];
    [self.view addSubview:_roomsTableView];
    
    _toBeSave = NO;
}

- (UIView *)createTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 20.0f}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    return headerView;
}

- (id)initWithImageToken:(NSString *)imageToken andImageKeyPattern:(NSString *)imageKeyPattern andHouseJSON:(NSMutableDictionary *)houseJSON {
    self = [super init];
    if (self != nil) {
        _imageToken = imageToken;
        _imageKeyPattern = imageKeyPattern;
        _houseJSON = houseJSON;
    }
    
    return self;
}

- (void)setViewControllerDismissHandler:(void(^)())handler {
    _dismissHandlerBlock = handler;
    
    WEAK_SELF weakSelf = self;
    if (_toBeSave) {
        if (_roomDetailViewController) {
            [_roomDetailViewController setViewControllerDismissHandler:^{
                if (weakSelf.dismissHandlerBlock) {
                    weakSelf.dismissHandlerBlock();
                }
            }];
        }
        if (_sublettingRoomDetailViewController) {
            [_sublettingRoomDetailViewController setViewControllerDismissHandler:^{
                if (weakSelf.dismissHandlerBlock) {
                    weakSelf.dismissHandlerBlock();
                }
            }];
        }
        if (_otherRoomPhotosViewController) {
            [_otherRoomPhotosViewController setViewControllerDismissHandler:^{
                if (weakSelf.dismissHandlerBlock) {
                    weakSelf.dismissHandlerBlock();
                }
            }];
        }
    } else {
        if (weakSelf.dismissHandlerBlock) {
            weakSelf.dismissHandlerBlock();
        }
    }
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
                
                if ([_houseJSON[@"rentType"] isEqual:[CommonFuncs rentTypeForHouse]]) {
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
                if ([_houseJSON[@"rentType"] isEqual:[CommonFuncs rentTypeForHouse]]) {
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
                    if ([_houseJSON[@"rentType"] isEqual:[CommonFuncs rentTypeForHouse]]) {
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
            
            if ([_houseJSON[@"rentType"] isEqual:[CommonFuncs rentTypeForHouse]]) {
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
                
                if ([_houseJSON[@"rentType"] isEqual:[CommonFuncs rentTypeForHouse]]) {
                    return roomSummaryTableViewCellHeight;
                } else {
                    if ([room[@"status"] isEqual:@0]) {
                        return openRoomSummaryTableViewCellHeight;
                    } else {
                        return closedRoomSummaryTableViewCellHeight;
                    }
                }
            } else {
                return roomAddTableViewCellHeight;
            }
            break;
        default:
            return roomAddTableViewCellHeight;
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
    
    switch (indexPath.section) {
        case 0:
        {
            __block NSMutableArray *oldRooms = _rooms[indexPath.section][@"value"];
            __block NSMutableDictionary *oldRoom = [[NSMutableDictionary alloc] init];
            if (indexPath.row < [oldRooms count]) {
                oldRoom = oldRooms[indexPath.row];
            }
            
            if ([_houseJSON[@"rentType"] isEqual:[CommonFuncs rentTypeForHouse]]) {
                if (!_roomDetailViewController) {
                    _roomDetailViewController = [[RoomDetailViewController alloc] init];
                    [_roomDetailViewController setNavigationController:self.navigationController];
                    [_roomDetailViewController.view setFrame:frame];
                    [self.view addSubview:_roomDetailViewController.view];
                }
                _toBeSave = YES;
                [_roomDetailViewController setImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseID:_houseJSON[@"id"] andRoom:oldRoom andType:RoomDetailViewTypeManage];
                WEAK_SELF weakSelf = self;
                [_roomDetailViewController setSaveInfoButtonDidClickHandler:^(NSMutableDictionary *room) {
                    _toBeSave = NO;
                    if (indexPath.row >= oldRooms.count) {
                        [oldRooms addObject:room];
                    } else {
                        [oldRooms removeObject:oldRoom];
                        [oldRooms insertObject:room atIndex:indexPath.row];
                    }
                    
                    [weakSelf.roomsTableView reloadData];
                    [weakSelf showRoomDetailView:NO];
                }];
                [_roomDetailViewController setCancelButtonDidClickHandler:^{
                    _toBeSave = NO;
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
                _toBeSave = YES;
                [_sublettingRoomDetailViewController setImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseID:_houseJSON[@"id"] andRoom:oldRoom andType:SublettingRoomDetailViewTypeManage];
                WEAK_SELF weakSelf = self;
                [_sublettingRoomDetailViewController setSaveInfoButtonDidClickHandler:^(NSMutableDictionary *room) {
                    _toBeSave = NO;
                    if (indexPath.row >= oldRooms.count) {
                        [oldRooms addObject:room];
                    } else {
                        [oldRooms removeObject:oldRoom];
                        [oldRooms insertObject:room atIndex:indexPath.row];
                    }
                    
                    [weakSelf.roomsTableView reloadData];
                    [weakSelf showSublettingRoomDetailView:NO];
                }];
                [_sublettingRoomDetailViewController setCancelButtonDidClickHandler:^{
                    _toBeSave = NO;
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
            _toBeSave = YES;
            [_otherRoomPhotosViewController setImageToken:_imageToken andImageKeyPattern:_imageKeyPattern andHouseJSON:_houseJSON andType:OtherRoomPhotosViewTypeManage];
            WEAK_SELF weakSelf = self;
            [_otherRoomPhotosViewController setSaveInfoButtonDidClickHandler:^() {
                _toBeSave = NO;
                [weakSelf.otherRoomPhotos[0] setObject:weakSelf.houseJSON[@"kitchenPhotos"] forKey:@"value"];
                [weakSelf.otherRoomPhotos[1] setObject:weakSelf.houseJSON[@"hallPhotos"] forKey:@"value"];
                [weakSelf.otherRoomPhotos[2] setObject:weakSelf.houseJSON[@"toiletPhotos"] forKey:@"value"];
                [weakSelf.otherRoomPhotos[3] setObject:weakSelf.houseJSON[@"otherPhotos"] forKey:@"value"];
                
                [weakSelf.rooms[1] setObject:weakSelf.otherRoomPhotos forKey:@"value"];
                [weakSelf.roomsTableView reloadData];
                [weakSelf showOtherRoomPhotosView:NO];
            }];
            [_otherRoomPhotosViewController setCancelButtonDidClickHandler:^{
                _toBeSave = NO;
                [weakSelf showOtherRoomPhotosView:NO];
            }];
            [self showOtherRoomPhotosView:YES];
        }
            break;
    }
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
