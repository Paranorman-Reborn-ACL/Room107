//
//  TemplateViewFuncs.m
//  room107
//
//  Created by ningxia on 16/3/24.
//  Copyright (c) 2016年 107room. All rights reserved.
//

#import "TemplateViewFuncs.h"
#import "NSDictionary+JSONString.h"
#import "NSString+JSONCategories.h"
#import "OneTemplateTableViewCell.h"
#import "TwoTemplateTableViewCell.h"
#import "ThreeTemplateTableViewCell.h"
#import "FourTemplateTableViewCell.h"
#import "FiveTemplateTableViewCell.h"
#import "SixTemplateTableViewCell.h"
#import "SevenTemplateTableViewCell.h"
#import "EightTemplateTableViewCell.h"
#import "NineTemplateTableViewCell.h"
#import "TenTemplateTableViewCell.h"
#import "ElevenTemplateTableViewCell.h"
#import "TwelveTemplateTableViewCell.h"
#import "ThirteenTemplateTableViewCell.h"
#import "FourteenTemplateTableViewCell.h"

@implementation TemplateViewFuncs

+ (CGSize)sixSubTemplateImageViewSize {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width - 11 - 11 - 22;
    return CGSizeMake(width, width * 2 / 3);
}

+ (CGSize)sixSubTemplateCellSize {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width - 11 - 11 - 22;
    return CGSizeMake(width, width * 2 / 3 + 58);
}

+ (CGSize)elevenTemplateTableViewCellWithInfo:(NSDictionary *)info {
    NSString *text = info[@"text"];
    NSString *subtext = info[@"subtext"];
    NSString *imageUrl = info[@"imageUrl"];
    CGFloat imageWidth = info[@"imageWidth"] ? [info[@"imageWidth"] floatValue] : 400;
    CGFloat imageHeight = info[@"imageHeight"] ? [info[@"imageHeight"] floatValue] : 200;
    
    CGFloat originX = 11.0f;
    CGFloat tableViewCellHeight = 11.0f;
    CGFloat elementWidth = [UIScreen mainScreen].bounds.size.width - 4 * originX;
    
    if (text && ![text isEqualToString:@""]) {
        CGRect contentRect = [text boundingRectWithSize:CGSizeMake(elementWidth, 38.5) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontThree]} context:nil];
        tableViewCellHeight = tableViewCellHeight + contentRect.size.height + 11;
    }
    if (imageUrl && ![imageUrl isEqualToString:@""]) {
        tableViewCellHeight = tableViewCellHeight + elementWidth * imageHeight / imageWidth + 11;
    }
    if (subtext && ![subtext isEqualToString:@""]) {
        CGRect contentRect = [subtext boundingRectWithSize:CGSizeMake(elementWidth, 43) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont room107SystemFontOne]} context:nil];
        tableViewCellHeight = tableViewCellHeight + contentRect.size.height + 11;
    }
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, tableViewCellHeight);
}

+ (NSMutableArray *)cardsDataConvert:(NSArray *)cards {
    NSMutableArray *mutableCards = [cards mutableCopy];
    
    //不能一边遍历数组，又同时修改这个数组里面的内容，否则导致崩溃，此处遍历cards，修改mutableCards
    for (NSDictionary *card in cards) {
        switch ([card[@"type"] intValue]) {
            case TemplateTypeTwelve:
            case TemplateTypeThirteen:
            {
                NSArray *keys = [card allKeys];
                if ([CommonFuncs arrayHasThisContent:keys andObject:@"text"]) {
                    NSMutableDictionary *subcard = [[NSMutableDictionary alloc] init];
                    for (NSUInteger i = 0; i < keys.count; i++) {
                        if ([[keys objectAtIndex:i] isEqualToString:@"cards"]) {
                            continue;
                        }
                        [subcard setObject:[card objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
                    }
                    
                    //将NSArray、NSDictionary转为NSMutableArray、NSMutableDictionary，方便更改数据
                    NSMutableArray *subcards = [card[@"cards"] mutableCopy];
                    if (subcards.count > 0) {
                        [subcards insertObject:[subcard JSONString] atIndex:0];
                        NSMutableDictionary *mutableCard = [card mutableCopy];
                        [mutableCard setObject:subcards forKey:@"cards"];
                        [mutableCards replaceObjectAtIndex:[cards indexOfObject:card] withObject:mutableCard];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    
    return mutableCards;
}

+ (void)deleteCardByCardID:(NSNumber *)cardID andTableView:(UITableView *)tableView andData:(id)data {
    if ([data isKindOfClass:[NSMutableArray class]] && [data count] > 0) {
        NSArray *sections = [data copy];
        for (NSDictionary *sectionDic in sections) {
            if ([sectionDic[@"id"] longLongValue] == [cardID longLongValue]) {
                NSUInteger section = [data indexOfObject:sectionDic];
                [data removeObject:sectionDic];
                if ([data count] > 0) {
                    [tableView deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    [tableView reloadData];
                }
                
                break;
            }
        }
    }
}

+ (NSInteger)numberOfRowsByData:(id)data {
    switch ([data[@"type"] intValue]) {
        case TemplateTypeTwelve:
        case TemplateTypeThirteen:
            return [data[@"cards"] count];
            break;
        default:
            return 1;
            break;
    }
}

+ (void)goToTargetPageByData:(id)data atIndex:(NSUInteger)index andViewController:(UIViewController *)viewController {
    switch ([data[@"type"] intValue]) {
        case TemplateTypeTwelve:
        case TemplateTypeThirteen:
            if ([data[@"cards"] count] > index) {
                // 将JSON格式的NSString转为标准的JSON
                [self goToTargetPageByData:[[data[@"cards"] objectAtIndex:index] JSONValue] andViewController:viewController];
            }
            break;
        default:
            [self goToTargetPageByData:data andViewController:viewController];
            break;
    }
}

+ (void)goToTargetPageByData:(id)data andViewController:(UIViewController *)viewController {
    switch ([data[@"type"] intValue]) {
        case TemplateTypeTwo:
        case TemplateTypeSeven:
        case TemplateTypeNine:
        case TemplateTypeTen:
        {
            NSArray *targetURLs = data[@"targetUrl"];
            if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
                for (NSString *targetURL in targetURLs) {
                    [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
                }
            }
        }
            break;
        case TemplateTypeEight:
        {
            NSArray *targetURLs = data[@"targetUrl"];
            if ([data[@"isEnable"] boolValue] && targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
                for (NSString *targetURL in targetURLs) {
                    [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
                }
            }
        }
            break;
        case TemplateTypeEleven:
        {
            NSArray *targetURLs = data[@"images"][0][@"targetUrl"];
            if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
                for (NSString *targetURL in targetURLs) {
                    [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
                }
            }
        }
            break;
        default:
            break;
    }
}

+ (Room107TableViewCell *)tableViewCellByData:(id)data atIndex:(NSUInteger)index andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    switch ([data[@"type"] intValue]) {
        case TemplateTypeTwelve:
        case TemplateTypeThirteen:
            if ([data[@"cards"] count] > index) {
                // 将JSON格式的NSString转为标准的JSON
                return [self tableViewCellByData:[[data[@"cards"] objectAtIndex:index] JSONValue] andTableView:tableView andViewController:viewController];
            } else {
                return [Room107TableViewCell new];
            }
            break;
        default:
            return [self tableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
    }
}

+ (Room107TableViewCell *)tableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    switch ([data[@"type"] intValue]) {
        case TemplateTypeOne:
            return [self oneTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeTwo:
            return [self twoTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeThree:
            return [self threeTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeFour:
            return [self fourTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeFive:
            return [self fiveTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeSix:
            return [self sixTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeSeven:
            return [self sevenTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeEight:
            return [self eightTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeNine:
            return [self nineTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeTen:
            return [self tenTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeEleven:
            return [self elevenTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeTwelve:
            return [self twelveTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeThirteen:
            return [self thirteenTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        case TemplateTypeFourteen:
            return [self fourteenTemplateTableViewCellByData:data andTableView:tableView andViewController:viewController];
            break;
        default:
            return [Room107TableViewCell new];
            break;
    }
    
    return [Room107TableViewCell new];
}

+ (CGFloat)heightForTableViewCellByData:(id)data atIndex:(NSUInteger)index {
    switch ([data[@"type"] intValue]) {
        case TemplateTypeTwelve:
        case TemplateTypeThirteen:
            if ([data[@"cards"] count] > index) {
                // 将JSON格式的NSString转为标准的JSON
                return [self heightForRowTableViewCellByData:[[data[@"cards"] objectAtIndex:index] JSONValue]];
            } else {
                return 0;
            }
            break;
        default:
            return [self heightForRowTableViewCellByData:data];
            break;
    }
}

+ (CGFloat)heightForRowTableViewCellByData:(id)data {
    switch ([data[@"type"] intValue]) {
        case TemplateTypeOne:
            return oneTemplateTableViewCellheight;
            break;
        case TemplateTypeTwo:
            return twoTemplateTableViewCellHeight;
            break;
        case TemplateTypeThree:
        {
            id imageData = [data[@"images"] count] > 0 ? data[@"images"][0] : @{@"imageWidth":@16, @"imageHeight":@9};
            CGFloat width = imageData[@"imageWidth"] ? [imageData[@"imageWidth"] floatValue] : 16;
            CGFloat height = imageData[@"imageHeight"] ? [imageData[@"imageHeight"] floatValue] : 9;
            return [CommonFuncs mainScreenSize].width * height / width;
        }
            break;
        case TemplateTypeFour:
            return fourTemplateTableViewCellHeight;
            break;
        case TemplateTypeFive:
        {
            id imageData = [data[@"images"] count] > 0 ? data[@"images"][0] : @{@"imageWidth":@840, @"imageHeight":@200};
            CGFloat width = imageData[@"imageWidth"] ? [imageData[@"imageWidth"] floatValue] : 840;
            CGFloat height = imageData[@"imageHeight"] ? [imageData[@"imageHeight"] floatValue] : 200;
            return fiveTemplateTableViewCellMinHeight + [CommonFuncs mainScreenSize].width * height / width;
        }
            break;
        case TemplateTypeSix:
            return sixTemplateTableViewCellMinHeight + [self sixSubTemplateCellSize].height;
            break;
        case TemplateTypeSeven:
            return sevenTemplateTableViewCellHeight;
            break;
        case TemplateTypeEight:
            return eightTemplateTableViewCellHeight;
            break;
        case TemplateTypeNine:
            return nineTemplateTableViewCellHeight;
            break;
        case TemplateTypeTen:
            return tenTemplateTableViewCellHeight;
            break;
        case TemplateTypeEleven:
        {
            id templateData = [data[@"images"] count] > 0 ? data[@"images"][0] : @{@"imageWidth":@840, @"imageHeight":@200};
            return [self elevenTemplateTableViewCellWithInfo:templateData].height;
        }
            break;
        case TemplateTypeTwelve:
            return twelveTemplateTableViewCellHeight;
            break;
        case TemplateTypeThirteen:
            return thirteenTemplateTableViewCellHeight;
            break;
        case TemplateTypeFourteen:
            return fourteenTemplateTableViewCellHeight;
            break;
        default:
            return 0;
            break;
    }
    
    return 0;
}

+ (OneTemplateTableViewCell *)oneTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    OneTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneTemplateTableViewCell"];
    if(!cell) {
        cell = [[OneTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OneTemplateTableViewCell"];
    }
    [cell setTemplateDataArray:data[@"buttons"]];
    [cell setViewDidClickHandler:^(NSArray *targetURLs) {
        if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *targetURL in targetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
            }
        }
    }];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (TwoTemplateTableViewCell *)twoTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    TwoTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoTemplateTableViewCell"];
    if (!cell) {
        cell = [[TwoTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwoTemplateTableViewCell"];
    }
    [cell setTwoTemplateInfo:data];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (ThreeTemplateTableViewCell *)threeTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    ThreeTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreeTemplateTableViewCell"];
    if (!cell) {
        cell = [[ThreeTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThreeTemplateTableViewCell"];
    }
    
    [cell setTemplateDataArray:data[@"images"]];
    [cell setImageViewDidClickHandler:^(NSArray *targetURLs) {
        if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *targetURL in targetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
            }
        }
    }];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (FourTemplateTableViewCell *)fourTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    FourTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FourTemplateTableViewCell"];
    if (!cell) {
        cell = [[FourTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FourTemplateTableViewCell"];
    }
    
    [cell setTemplateDataArray:data[@"buttons"]];
    [cell setHoldTargetURL:data[@"holdTargetUrl"]];
    [cell setViewDidClickHandler:^(NSArray *targetURLs) {
        if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *targetURL in targetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
            }
        }
    }];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (FiveTemplateTableViewCell *)fiveTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    FiveTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FiveTemplateTableViewCell"];
    if (!cell) {
        cell = [[FiveTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FiveTemplateTableViewCell"];
    }
    
    id imageData = [data[@"images"] count] > 0 ? data[@"images"][0] : @{@"imageWidth":@840, @"imageHeight":@200};
    CGFloat width = imageData[@"imageWidth"] ? [imageData[@"imageWidth"] floatValue] : 840;
    CGFloat height = imageData[@"imageHeight"] ? [imageData[@"imageHeight"] floatValue] : 200;
    [cell setScrollImageViewFrame:(CGRect){CGPointZero, CGRectGetWidth(tableView.bounds), [CommonFuncs mainScreenSize].width * height / width}];
    [cell setTemplateDataArray:data[@"images"]];
    [cell setImageViewDidClickHandler:^(NSArray *targetURLs) {
        if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *targetURL in targetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
            }
        }
    }];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (SixTemplateTableViewCell *)sixTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    SixTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SixTemplateTableViewCell"];
    if (!cell) {
        cell = [[SixTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SixTemplateTableViewCell"];
    }
    
    [cell setTemplateDataArray:data[@"buttons"]];
    [cell setViewDidClickHandler:^(NSArray *targetURLs) {
        if (targetURLs && [targetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *targetURL in targetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:targetURL params:nil context:viewController];
            }
        }
    }];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (SevenTemplateTableViewCell *)sevenTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    SevenTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SevenTemplateTableViewCell"];
    if (!cell) {
        cell = [[SevenTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SevenTemplateTableViewCell"];
    }
    [cell setSevenTemplateInfo:data];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (EightTemplateTableViewCell *)eightTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    EightTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EightTemplateTableViewCell"];
    if (!cell) {
        cell = [[EightTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EightTemplateTableViewCell"];
    }
    [cell setTemplateDataDictionary:data];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (NineTemplateTableViewCell *)nineTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    NineTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NineTemplateTableViewCell"];
    if (!cell) {
        cell = [[NineTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NineTemplateTableViewCell"];
    }
    [cell setTemplateDataDictionary:data];
    [cell setHoldTargetURL:data[@"holdTargetUrl"]];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (TenTemplateTableViewCell *)tenTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    TenTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TenTemplateTableViewCell"];
    if (!cell) {
        cell = [[TenTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TenTemplateTableViewCell"];
    }
    [cell setTenTemplateInfo:data];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (ElevenTemplateTableViewCell *)elevenTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    ElevenTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ElevenTemplateTableViewCell"];
    if (!cell) {
        cell = [[ElevenTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ElevenTemplateTableViewCell"];
    }
    if (data[@"images"] && [data[@"images"] isKindOfClass:[NSArray class]] && [data[@"images"] count] > 0) {
        [cell setElevenTemplateInfo:data[@"images"][0]];
        [cell setHoldTargetURL:data[@"images"][0][@"holdTargetUrl"]];
    }
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (TwelveTemplateTableViewCell *)twelveTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    TwelveTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwelveTemplateTableViewCell"];
    if (!cell) {
        cell = [[TwelveTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwelveTemplateTableViewCell"];
    }
    [cell setTemplateDataDictionary:data];
    [cell setHoldTargetURL:data[@"holdTargetUrl"]];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (ThirteenTemplateTableViewCell *)thirteenTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    ThirteenTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThirteenTemplateTableViewCell"];
    if (!cell) {
        cell = [[ThirteenTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThirteenTemplateTableViewCell"];
    }
    [cell setTemplateDataDictionary:data];
    [cell setHoldTargetURL:data[@"holdTargetUrl"]];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

+ (FourteenTemplateTableViewCell *)fourteenTemplateTableViewCellByData:(id)data andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController {
    FourteenTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FourteenTemplateTableViewCell"];
    if (!cell) {
        cell = [[FourteenTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FourteenTemplateTableViewCell"];
    }
    [cell setFourteenTemplateInfo:data];
    [cell setViewDidLongPressHandler:^(NSArray *holdTargetURLs) {
        if (holdTargetURLs && [holdTargetURLs isKindOfClass:[NSArray class]]) {
            for (NSString *holdTargetURL in holdTargetURLs) {
                [[NXURLHandler sharedInstance] handleOpenURL:holdTargetURL params:nil context:viewController];
            }
        }
    }];
    
    return cell;
}

@end
