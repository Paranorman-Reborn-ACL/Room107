//
//  LandlordPendingChargesViewController.m
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "LandlordPendingChargesViewController.h"
#import "Room107TableView.h"
#import "SystemAgent.h"
#import "AppPropertiesModel.h"
#import "ExpenseOrderLargeItemView.h"
#import "ExpenseOrderTableViewCell.h"
#import "TotalPriceView.h"
#import "SuiteTitleView.h"

@interface LandlordPendingChargesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) Room107TableView *sectionsTableView;
@property (nonatomic, strong) LandlordHouseItemModel *landlordHouseItem;
@property (nonatomic, strong) ExpenseOrderTableViewCell *staticExpenseOrderTableViewCell;

@end

@implementation LandlordPendingChargesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _staticExpenseOrderTableViewCell = [[ExpenseOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExpenseOrderTableViewCell"];
}

- (id)initWithLandlordHouseItem:(LandlordHouseItemModel *)landlordHouseItem {
    _landlordHouseItem = landlordHouseItem;
    
    self = [super init];
    if (self != nil) {
        if (!landlordHouseItem || !landlordHouseItem.incomeOrders) {
            CGRect frame = self.view.frame;
            frame.size.height -= statusBarHeight + navigationBarHeight + [self heightOfSegmentedControl];
            [self showContent:lang(@"HasNoPendingCharges") withFrame:frame];
            
            return self;
        }
        
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        if (!_sectionsTableView) {
            _sectionsTableView = [[Room107TableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
            _sectionsTableView.delegate = self;
            _sectionsTableView.dataSource = self;
            _sectionsTableView.tableHeaderView = [self createHeaderView];
            _sectionsTableView.tableFooterView = [self createFooterView];
            [self.view addSubview:_sectionsTableView];
        }
        
        if (!_sections) {
            _sections = [[NSMutableArray alloc] init];
        }
        [_sections removeAllObjects];
        
        AppPropertiesModel *appProperties = [[SystemAgent sharedInstance] getPropertiesFromLocal];
        //按照orderType顺序排序
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderType" ascending:YES];
        landlordHouseItem.incomeOrders = [landlordHouseItem.incomeOrders sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
        
        NSNumber *orderType = landlordHouseItem.incomeOrders[0][@"orderType"];
        NSMutableArray *incomeOrders = [[NSMutableArray alloc] init];
        for (NSDictionary *incomeOrder in landlordHouseItem.incomeOrders) {
            if (![incomeOrder[@"orderType"] isEqual:orderType]) {
                double price = 0;
                for (NSMutableDictionary *incomeOrder in incomeOrders) {
                    price += [incomeOrder[@"value"] doubleValue];
                }
                [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:appProperties.orderTypeNames[[orderType integerValue]], @"key", orderType, @"orderType", incomeOrders, @"value", [NSNumber numberWithDouble:price / 100], @"price", nil]];
                
                orderType = incomeOrder[@"orderType"];
                incomeOrders = [[NSMutableArray alloc] init];
            }
            
            [incomeOrders addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:incomeOrder[@"name"], @"key", incomeOrder[@"orderType"], @"orderType", incomeOrder[@"price"], @"value", nil]];
        }
        
        if (incomeOrders.count > 0) {
            double price = 0;
            for (NSMutableDictionary *incomeOrder in incomeOrders) {
                price += [incomeOrder[@"value"] doubleValue];
            }
            [_sections addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:appProperties.orderTypeNames[[orderType integerValue]], @"key", incomeOrders[0][@"orderType"], @"orderType", incomeOrders, @"value", [NSNumber numberWithDouble:price / 100], @"price", nil]];
        }
    }
    
    return self;
}

- (UIView *)createHeaderView {
    CGFloat spaceY = 11;
    CGFloat titleViewHeight = 36.5;
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, spaceY + titleViewHeight}];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    SuiteTitleView *titleView = [[SuiteTitleView alloc] initWithFrame:(CGRect){0, spaceY, CGRectGetWidth(headerView.bounds), titleViewHeight} andTitle:lang(@"PendingCharges")];
    [headerView addSubview:titleView];
    
    return headerView;
}

- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.bounds.size.width, 240.0f}];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    TotalPriceView *totalPriceView = [[TotalPriceView alloc] initWithFrame:(CGRect){originX, originY, CGRectGetWidth(footerView.bounds), 64}];
    NSString *deadline = @"";
    double amount = 0;
    for (NSMutableDictionary *expenseOrder in _landlordHouseItem.incomeOrders) {
        amount += [expenseOrder[@"price"] doubleValue];
        deadline = expenseOrder[@"deadline"];
    }
    NSString *content = [lang(@"Total") stringByAppendingString:[CommonFuncs moneyStrByDouble:amount / 100]];
    content = [[content stringByAppendingString:@"\n"] stringByAppendingFormat:lang(@"EstimateMoneyArriveBefore%@"), [TimeUtil friendlyDateTimeFromDateTime:deadline withFormat:@"%Y/%m/%d"]];
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    NSArray *components = [content componentsSeparatedByString:@"\n"];
    NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorE], NSFontAttributeName:[UIFont room107SystemFontThree]};
    [attributedContent addAttributes:attrs range:NSMakeRange(0, 2)];
    attrs = @{NSForegroundColorAttributeName:[UIColor room107GreenColor], NSFontAttributeName:[UIFont room107SystemFontFour]};
    [attributedContent addAttributes:attrs range:NSMakeRange(2, [(NSString *)components[0] length] - 1)];
    attrs = @{NSForegroundColorAttributeName:[UIColor room107GrayColorD], NSFontAttributeName:[UIFont room107SystemFontOne]};
    [attributedContent addAttributes:attrs range:NSMakeRange([(NSString *)components[0] length] + 1, [(NSString *)components[1] length])];
    [totalPriceView setAttributedContent:attributedContent];
    [footerView addSubview:totalPriceView];
    
    return footerView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSMutableArray *)_sections[section][@"value"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExpenseOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpenseOrderTableViewCell"];
    if (!cell) {
        cell = [[ExpenseOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExpenseOrderTableViewCell"];
    }
    [cell setName:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
    [cell setContent:[CommonFuncs moneyStrByDouble:[_sections[indexPath.section][@"value"][indexPath.row][@"value"] doubleValue] / 100]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_staticExpenseOrderTableViewCell getCellHeightWithName:_sections[indexPath.section][@"value"][indexPath.row][@"key"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForHeaderInSection:section]};
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:frame];
    [sectionHeaderView setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat originY = 5.5;
    ExpenseOrderLargeItemView *expenseOrderLargeItemView = [[ExpenseOrderLargeItemView alloc] initWithFrame:(CGRect){0, originY, CGRectGetWidth(frame), CGRectGetHeight(frame) - originY} withButton:NO];
    [expenseOrderLargeItemView setTitle:_sections[section][@"key"]];
    [expenseOrderLargeItemView setContent:[CommonFuncs moneyStrByDouble:[_sections[section][@"price"] doubleValue]]];
    [sectionHeaderView addSubview:expenseOrderLargeItemView];
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect frame = (CGRect){0, 0, self.view.bounds.size.width, [self tableView:tableView heightForFooterInSection:section]};
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    if ([tableView isEqual:_sectionsTableView]) {
        [view setBackgroundColor:[UIColor room107GrayColorA]];
    }
    
    return view;
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
