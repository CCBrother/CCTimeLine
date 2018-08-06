//
//  CCContentCell.h
//  CCTimeLine
//
//  Created by ZhangCc on 2018/8/6.
//  Copyright © 2018年 ZhangCc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CCContentCellID;

typedef NS_ENUM(NSInteger, OpinionType) {
    OpinionTypeBear = -1,
    OpinionTypeNone,
    OpinionTypeBull
};

@class CCContentCell;
@protocol CCContentCellDelegate <NSObject>
@optional

// 折叠/展开 cell
- (void)foldingCell:(CCContentCell *)cell;

// 利好/利空 1利好 -1利空
- (void)opinionWithCell:(CCContentCell *)cell bullOrBear:(NSInteger)value;

@end

@class Article;
@interface CCContentCell : UITableViewCell

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *pointView;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) Article *model;

@property (nonatomic, weak) id<CCContentCellDelegate> delegate;

@end
