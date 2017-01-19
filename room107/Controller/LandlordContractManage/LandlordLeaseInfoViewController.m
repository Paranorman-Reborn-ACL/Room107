//
//  LandlordLeaseInfoViewController.m
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordLeaseInfoViewController.h"
#import "Room107TableView.h"
#import "CustomInfoItemTableViewCell.h"

@interface LandlordLeaseInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) LandlordHouseItemModel *landlordHouseItem;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;

@end

@implementation LandlordLeaseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sectionsTableView = [[Room107TableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _sectionsTableView.delegate = self;
    _sectionsTableView.dataSource = self;
    [self.view addSubview:_sectionsTableView];
}

- (id)initWithLandlordHouseItem:(LandlordHouseItemModel *)landlordHouseItem {
    _landlordHouseItem = landlordHouseItem;
    
    self = [super init];
    if (self != nil) {
        if (!landlordHouseItem) {
            return self;
        }
        
        if (!_sections) {
            _sections = [[NSMutableArray alloc] init];
        }
        [_sections removeAllObjects];
        
        NSMutableArray *followingInfos = [[NSMutableArray alloc] init];
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"CheckInDate"), @"key", [TimeUtil friendlyDateTimeFromDateTime:landlordHouseItem.checkinTime withFormat:@"%Y/%m/%d"], @"value", nil]];
        if (landlordHouseItem.terminatedTime) {
            //提前退租
            //            [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"TerminatedRent"), @"key", [@"20160906" stringByAppendingFormat:@"\n(%@ %@)", lang(@"OldExitTime"), landlordHouseItem.exitTime], @"value", nil]];
            [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"TerminatedRent"), @"key", [[TimeUtil friendlyDateTimeFromDateTime:landlordHouseItem.terminatedTime withFormat:@"%Y/%m/%d"] stringByAppendingFormat:@"\n(%@ %@)", lang(@"OldExitTime"), [TimeUtil friendlyDateTimeFromDateTime:landlordHouseItem.exitTime withFormat:@"%Y/%m/%d"]], @"value", nil]];
        } else {
            [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"CheckOutDate"), @"key", [TimeUtil friendlyDateTimeFromDateTime:landlordHouseItem.exitTime withFormat:@"%Y/%m/%d"], @"value", nil]];
        }
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"PaymentMethod"), @"key", [landlordHouseItem.payingType isEqualToNumber:@0] ? lang(@"PaymentPerMonth") : lang(@"PaymentPerQuarter"), @"value", nil]];
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ContractMoney"), @"key", [@"￥" stringByAppendingString:[landlordHouseItem.monthlyPrice stringValue] ? [landlordHouseItem.monthlyPrice stringValue] : @""], @"value", nil]];
        [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"MoreRentalInfo"), @"key", followingInfos, @"value", nil]];
    }
    
    return self;
}

- (void)scrollToTop {
    [_sectionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSMutableArray *)_sections[section][@"value"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomInfoItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomInfoItemTableViewCell"];
    if (!cell) {
        cell = [[CustomInfoItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomInfoItemTableViewCell"];
    }
    [cell setNameLabelWidth:100];
    NSMutableAttributedString *attributedName = [[NSMutableAttributedString alloc] initWithString:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:_sections[indexPath.section][@"value"][indexPath.row][@"value"]];
    if ([_sections[indexPath.section][@"value"][indexPath.row][@"key"] isEqualToString:lang(@"TerminatedRent")]) {
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107YellowColor]};
        [attributedName addAttributes:attrs range:NSMakeRange(0, attributedName.length)];
        
        NSArray *components = [_sections[indexPath.section][@"value"][indexPath.row][@"value"] componentsSeparatedByString:@"\n"];
        attrs = @{NSForegroundColorAttributeName:[UIColor room107YellowColor]};
        [attributedContent addAttributes:attrs range:NSMakeRange(0, [(NSString *)components[0] length])];
        attrs = @{NSFontAttributeName:[UIFont room107FontTwo], NSForegroundColorAttributeName:[UIColor room107GrayColorC]};
        [attributedContent addAttributes:attrs range:NSMakeRange([(NSString *)components[0] length] + 1, [(NSString *)components[1] length])];
    }
    [cell setAttributedName:attributedName];
    [cell setAttributedContent:attributedContent];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return customInfoItemTableViewCellHeight + 22;
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
