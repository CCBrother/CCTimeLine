//
//  ViewController.m
//  CCTimeLine
//
//  Created by ZhangCc on 2018/8/6.
//  Copyright © 2018年 ZhangCc. All rights reserved.
//

#import "ViewController.h"
#import "MJExtension.h"
#import "CCModel.h"
#import "CCContentCell.h"
#import "Masonry.h"
#import "UITableView+FDTemplateLayoutCell.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, CCContentCellDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setStatusBarBackgroundColor:[UIColor whiteColor]];
    [self loadData];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[CCContentCell class] forCellReuseIdentifier:CCContentCellID];
}

 - (void)setStatusBarBackgroundColor:(UIColor *)color {
     UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
     if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
         statusBar.backgroundColor = color;
     }
 }

- (void)loadData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    CCModel *model = [CCModel mj_objectWithKeyValues:data];
   
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in model.articleList) {
        Article *model = [Article mj_objectWithKeyValues:dict];
        [array addObject:model];
    }
    self.dataArray = array;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(-0.1, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:CCContentCellID cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCContentCell *cell = [CCContentCell cellWithTableView:tableView];
    cell.delegate = self;
    if (indexPath.row == 0) {
        [cell.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.pointView.mas_bottom);
            make.bottom.equalTo(cell);
            make.width.mas_offset(0.5);
            make.centerX.equalTo(cell.pointView);
        }];
    }else {
        [cell.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell);
            make.bottom.equalTo(cell);
            make.width.mas_offset(0.5);
            make.centerX.equalTo(cell.pointView);
        }];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(CCContentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //使用Masonry进行布局的话，这里要设置为NO
    cell.fd_enforceFrameLayout = NO;
    cell.model = self.dataArray[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREEN_WIDTH - 30, 44)];
    timeLabel.font = [UIFont systemFontOfSize:15.0f];
    timeLabel.textColor = [UIColor blackColor];
   
    timeLabel.text = [self dateShow];
    
    [headerView addSubview:timeLabel];
    return headerView;
}

#pragma mark - Event respons
- (void)foldingCell:(CCContentCell *)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    Article *model = self.dataArray[indexPath.row];
    model.isFolding = !model.isFolding;
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)opinionWithCell:(CCContentCell *)cell bullOrBear:(NSInteger)value {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    Article *model = self.dataArray[indexPath.row];
    model.bullOrBear = value;
    if (value == OpinionTypeBear) {
        model.bearNum++;
    } else if (value == OpinionTypeBull) {
        model.bullNum++;
    }
    [self configureCell:cell atIndexPath:indexPath];
}

#pragma mark - Private methods
// 日期 + 星期
- (NSString *)dateShow {
    NSDate *today = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日"];
    NSString *dateStr = [dateFormatter stringFromDate:today];
    NSString *newDateStr = [NSString stringWithFormat:@"今天 %@",dateStr];;
    NSString *weekDay = [self weekWithdate:today];
    //当天显示格式 今天 + MM月dd日 + 星期
    return [NSString stringWithFormat:@"%@ %@", newDateStr, weekDay];
}

// 星期
- (NSString *)weekWithdate:(NSDate *)date {
    //返回星期几
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    NSString *weekday = [weekdays objectAtIndex:theComponents.weekday];
    return weekday;
}

@end
