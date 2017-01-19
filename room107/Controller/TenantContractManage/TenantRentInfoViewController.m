//
//  TenantRentInfoViewController.m
//  room107
//
//  Created by ningxia on 15/9/11.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TenantRentInfoViewController.h"
#import "Room107TableView.h"
#import "RoundedGreenButton.h"
#import "CustomInfoItemTableViewCell.h"

@interface TenantRentInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) RentedHouseItemModel *rentedHouseItem;
@property (nonatomic, strong) void (^roundedGreenButtonHandlerBlock)();

@end

@implementation TenantRentInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sectionsTableView = [[Room107TableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _sectionsTableView.delegate = self;
    _sectionsTableView.dataSource = self;
    _sectionsTableView.tableFooterView = [self createFooterView];
    [self.view addSubview:_sectionsTableView];
}

- (id)initWithRentedHouseItem:(RentedHouseItemModel *)rentedHouseItem {
    _rentedHouseItem = rentedHouseItem;
    
    self = [super init];
    if (self != nil) {
        if (!rentedHouseItem) {
            return self;
        }
        
        if (!_sections) {
            _sections = [[NSMutableArray alloc] init];
        }
        [_sections removeAllObjects];
        
        NSMutableArray *followingInfos = [[NSMutableArray alloc] init];
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"CheckInDate"), @"key", [TimeUtil friendlyDateTimeFromDateTime:rentedHouseItem.checkinTime withFormat:@"%Y/%m/%d"], @"value", nil]];
        if (rentedHouseItem.terminatedTime) {
            //提前退租
//            [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"TerminatedRent"), @"key", [@"20160906" stringByAppendingFormat:@"\n(%@ %@)", lang(@"OldExitTime"), rentedHouseItem.exitTime], @"value", nil]];
            [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"TerminatedRent"), @"key", [[TimeUtil friendlyDateTimeFromDateTime:rentedHouseItem.terminatedTime withFormat:@"%Y/%m/%d"] stringByAppendingFormat:@"\n(%@ %@)", lang(@"OldExitTime"), [TimeUtil friendlyDateTimeFromDateTime:rentedHouseItem.exitTime withFormat:@"%Y/%m/%d"]], @"value", nil]];
        } else {
            [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"CheckOutDate"), @"key", [TimeUtil friendlyDateTimeFromDateTime:rentedHouseItem.exitTime withFormat:@"%Y/%m/%d"], @"value", nil]];
        }
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"PaymentMethod"), @"key", [rentedHouseItem.payingType isEqualToNumber:@0] ? lang(@"PaymentPerMonth") : lang(@"PaymentPerQuarter"), @"value", nil]];
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ContractMoney"), @"key", [@"￥" stringByAppendingString:[rentedHouseItem.monthlyPrice stringValue] ? [rentedHouseItem.monthlyPrice stringValue] : @""], @"value", nil]];
        //月付利息
        [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"InstalmentFee"), @"key", [[CommonFuncs moneyStrByDouble:[rentedHouseItem.instalmentFee doubleValue] / 100] stringByAppendingFormat:@" （%@*%@）", lang(@"RentMoneyMonthly"), [CommonFuncs percentString:[rentedHouseItem.instalmentFeeRate floatValue]]], @"value", nil]];
        //保障费
        if (rentedHouseItem.contractFee && ![rentedHouseItem.contractFee isEqual:@0]) {
            [followingInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"ContractFee"), @"key", [CommonFuncs moneyStrByDouble:[rentedHouseItem.contractFee doubleValue] / 100], @"value", nil]];
        }
        [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:lang(@"MoreRentalInfo"), @"key", followingInfos, @"value", nil]];
    }
    
    return self;
}

- (void)scrollToTop {
    [_sectionsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)setRoundedGreenButtonDidClickHandler:(void(^)())handler {
    _roundedGreenButtonHandlerBlock = handler;
}

- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 250.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 22.0f;
    CGFloat buttonWidth = CGRectGetWidth(footerView.bounds) - 2 * originX;
    CGFloat buttonHeight = 53.0f;
    CGFloat originY = 0;
    
    RoundedGreenButton *roundedGreenButton = [[RoundedGreenButton alloc] initWithFrame:(CGRect){originX, originY, buttonWidth, buttonHeight}];
    [roundedGreenButton setTitle:lang(@"ContinueRent") forState:UIControlStateNormal];
    if (![_rentedHouseItem.reletStatus isEqual:@1]) {
        roundedGreenButton.hidden = YES;
    }
    [footerView addSubview:roundedGreenButton];
    [roundedGreenButton addTarget:self action:@selector(roundedGreenButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return footerView;
}

- (IBAction)roundedGreenButtonDidClick:(id)sender {
    RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:lang(@"Cancel") action:^{
    }];
    RIButtonItem *otherButtonItem = [RIButtonItem itemWithLabel:[lang(@"ContinueRent") substringFromIndex:2] action:^{
        if (_roundedGreenButtonHandlerBlock) {
            _roundedGreenButtonHandlerBlock();
        }
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:lang(@"WhetherToReletTitle") message:lang(@"WhetherToReletMessage") cancelButtonItem:cancelButtonItem otherButtonItems:otherButtonItem, nil];
    [alert show];
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
    if ([_sections[indexPath.section][@"value"][indexPath.row][@"key"] isEqualToString:lang(@"PayableMonthly")] || [_sections[indexPath.section][@"value"][indexPath.row][@"key"] isEqualToString:lang(@"SigningRentalGuarantee")]) {
        NSArray *components = [_sections[indexPath.section][@"value"][indexPath.row][@"value"] componentsSeparatedByString:@" "];
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorD]};
        [attributedContent addAttributes:attrs range:NSMakeRange(0, [(NSString *)components[0] length])];
        attrs = @{NSFontAttributeName:[UIFont room107FontTwo], NSForegroundColorAttributeName:[UIColor room107GrayColorC]};
        [attributedContent addAttributes:attrs range:NSMakeRange([(NSString *)components[0] length] + 1, [(NSString *)components[1] length])];
    }
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
