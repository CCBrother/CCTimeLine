//
//  CCContentCell.m
//  CCTimeLine
//
//  Created by ZhangCc on 2018/8/6.
//  Copyright © 2018年 ZhangCc. All rights reserved.
//

#import "CCContentCell.h"
#import "CCModel.h"
#import "Masonry.h"
#import "SVProgressHUD.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define GET_IMAGE(imageName)       [UIImage imageNamed:imageName]

#define colorWithRGBA(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((0x##rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((0x##rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(0x##rgbValue & 0xFF)) / 255.0 alpha:alphaValue]
#define colorWithRGB(rgbValue)  colorWithRGBA(rgbValue, 1.0)

NSString *const CCContentCellID = @"CCContentCell";
static CGFloat LineSpacing = 5.0f;
static NSInteger MaxLineCount = 5;

@interface CCContentCell () {
    UIView *_bgView;
    UILabel *_titleLabel, *_dateLabel, *_contentLabel;
    UIButton *_foldingBtn, *_bullBtn, *_bearBtn, *_shareBtn;
}

@property (nonatomic, assign) BOOL isFolding;

@end

@implementation CCContentCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    CCContentCell *cell = [tableView dequeueReusableCellWithIdentifier:CCContentCellID];
    if (!cell) {
        cell = [[CCContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CCContentCellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildUI];
        [self setupLayout];
    }
    return self;
}

- (void)setModel:(Article *)model {
    _model = model;
    
    _dateLabel.text = [self dateWithtimeStamp:model.publishTime];
    _titleLabel.text = model.title;
    _contentLabel.text = model.content;
    
    if (_titleLabel.text.length > 0 && _titleLabel.text) {
        _titleLabel.attributedText = [self attributedStringWithContent:_titleLabel.text];
    }
    
    // 修改行间距，下面在计算文本高度的时候也要对应设置
    if (_contentLabel.text.length > 0 && _contentLabel.text) {
        _contentLabel.attributedText = [self attributedStringWithContent:_contentLabel.text];
    }
    
    CGFloat maxLayoutWidth = SCREEN_WIDTH - 14 - 7 - 23 - 20;
    // 获取文本内容宽度，计算展示全部文本所需高度
    CGFloat contentW = maxLayoutWidth;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:LineSpacing];//行间距
    
    CGRect contentRect = [_contentLabel.text
                          boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT)
                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                          attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f], NSParagraphStyleAttributeName : style}
                          context:nil];
    
    // 超过5行文字，显示折叠按钮
    if (contentRect.size.height > _contentLabel.font.lineHeight * MaxLineCount + LineSpacing * (MaxLineCount - 1)) {
        
        _foldingBtn.hidden = NO;
        self.isFolding = model.isFolding;
        // 按钮的折叠打开状态
        if (model.isFolding) {
            [_foldingBtn setImage:GET_IMAGE(@"express_up") forState:UIControlStateNormal];
            _contentLabel.numberOfLines = 0;
        }else{
            [_foldingBtn setImage:GET_IMAGE(@"express_down") forState:UIControlStateNormal];
            _contentLabel.numberOfLines = MaxLineCount;
        }
        
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(10);
            make.left.equalTo(_titleLabel);
            make.right.equalTo(self.contentView.mas_right).offset(-20);
        }];
        _contentLabel.preferredMaxLayoutWidth = maxLayoutWidth;
        
        [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_foldingBtn.mas_bottom).offset(10);
            make.left.equalTo(_dateLabel);
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-36).priorityHigh();
        }];
    }else{
        _foldingBtn.hidden = YES;
        _contentLabel.numberOfLines = 0;
        [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom).offset(20);
            make.left.equalTo(_dateLabel);
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-36).priorityHigh();
        }];
    }
    
    [_bullBtn setTitle:[NSString stringWithFormat:@"利好 %ld",(long)model.bullNum]  forState:UIControlStateNormal];
    [_bearBtn setTitle:[NSString stringWithFormat:@"利空 %ld",(long)model.bearNum]  forState:UIControlStateNormal];
    
    switch (model.bullOrBear) {
        case OpinionTypeBull: {
            _bullBtn.selected = YES;
            _bearBtn.selected = NO;
            [_bullBtn setTitleColor:colorWithRGB(fa0000) forState:UIControlStateSelected];
        }
            break;
        case OpinionTypeBear: {
            _bearBtn.selected = YES;
            _bullBtn.selected = NO;
            [_bearBtn setTitleColor:colorWithRGB(239140) forState:UIControlStateSelected];
        }
            break;
        case OpinionTypeNone: {
            _bullBtn.selected = NO;
            _bearBtn.selected = NO;
            [_bullBtn setTitleColor:colorWithRGB(999999) forState:UIControlStateNormal];
            [_bearBtn setTitleColor:colorWithRGB(999999) forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Event respons
// 折叠/展开
- (void)foldingAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(foldingCell:)]) {
        [self.delegate foldingCell:self];
    }

}

// 利好
- (void)bullAction:(UIButton *)sender {
    if (sender.selected || _bearBtn.selected) {
        [SVProgressHUD showInfoWithStatus:@"你已经点过了"];
    }else {
        if ([self.delegate respondsToSelector:@selector(opinionWithCell:bullOrBear:)]) {
            [self.delegate opinionWithCell:self bullOrBear:OpinionTypeBull];
        }
    }
}

// 利空
- (void)bearAction:(UIButton *)sender {
    if (sender.selected || _bullBtn.selected) {
        [SVProgressHUD showInfoWithStatus:@"你已经点过了"];
    }else {
        if ([self.delegate respondsToSelector:@selector(opinionWithCell:bullOrBear:)]) {
            [self.delegate opinionWithCell:self bullOrBear:OpinionTypeBear];
        }
    }
}

// 分享
- (void)shareAction:(UIButton *)sender {
   [SVProgressHUD showInfoWithStatus:@"分享"];
}

#pragma mark - Init methods
- (void)buildUI {
    _pointView = [[UIView alloc] init];
    _pointView.backgroundColor = colorWithRGB(999999);
    _pointView.layer.cornerRadius = 3.5;
    _pointView.layer.masksToBounds = YES;
    [self.contentView addSubview:_pointView];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = colorWithRGB(999999);
    [self.contentView addSubview:_lineView];
    
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.textColor = colorWithRGB(666666);
    _dateLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.contentView addSubview:_dateLabel];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = colorWithRGB(333333);
    _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.textColor = colorWithRGB(666666);
    _contentLabel.font = [UIFont systemFontOfSize:15.0f];;
    [self.contentView addSubview:_contentLabel];
    
    _foldingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_foldingBtn setImage:GET_IMAGE(@"express_up") forState:UIControlStateNormal];
    [_foldingBtn addTarget:self action:@selector(foldingAction:) forControlEvents:UIControlEventTouchUpInside];
    _foldingBtn.hidden = YES;
    [self.contentView addSubview:_foldingBtn];
    
    _bgView = [[UIView alloc] init];
    [self.contentView addSubview:_bgView];
    
    // 利好
    _bullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bullBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];;
    [_bullBtn setImage:GET_IMAGE(@"express_good_normal") forState:UIControlStateNormal];
    [_bullBtn setImage:GET_IMAGE(@"express_good_selected") forState:UIControlStateSelected];
    [_bullBtn setTitleColor:colorWithRGB(999999) forState:UIControlStateNormal];
    _bullBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_bullBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_bullBtn addTarget:self action:@selector(bullAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_bullBtn];
    
    // 利空
    _bearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bearBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];;
    [_bearBtn setImage:GET_IMAGE(@"express_bad_normal") forState:UIControlStateNormal];
    [_bearBtn setImage:GET_IMAGE(@"express_bad_selected") forState:UIControlStateSelected];
    [_bearBtn setTitleColor:colorWithRGB(999999) forState:UIControlStateNormal];
    _bearBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_bearBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [_bearBtn addTarget:self action:@selector(bearAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_bearBtn];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareBtn setImage:GET_IMAGE(@"share_dig") forState:UIControlStateNormal];
    [_shareBtn setTitle:@"分享挖矿" forState:UIControlStateNormal];
    _shareBtn.titleLabel.font = [UIFont systemFontOfSize:11.0f];;
    [_shareBtn setTitleColor:colorWithRGB(999999) forState:UIControlStateNormal];
    [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [_shareBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_bgView addSubview:_shareBtn];
}

- (void)setupLayout {
    [_pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(14);
        make.left.equalTo(self.contentView.mas_left).offset(14);
        make.width.height.mas_offset(7);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.width.mas_offset(0.5);
        make.centerX.equalTo(_pointView);
    }];
    
    //时间
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_pointView.mas_right).offset(23);
        make.width.mas_offset(100);
        make.height.mas_offset(15);
        make.centerY.equalTo(_pointView);
    }];
    
    CGFloat maxLayoutWidth = SCREEN_WIDTH - 14 - 7 - 23 - 20;
    // 标题
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dateLabel.mas_bottom).offset(15);
        make.left.equalTo(_dateLabel);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
    }];
    _titleLabel.preferredMaxLayoutWidth = maxLayoutWidth;
    
    // 内容
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.left.equalTo(_titleLabel);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
    }];
    _contentLabel.preferredMaxLayoutWidth = maxLayoutWidth;
    
    // 折叠
    [_foldingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentLabel.mas_bottom).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
        make.width.height.mas_offset(22);
    }];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_foldingBtn.mas_bottom).offset(10);
        make.left.equalTo(_dateLabel);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-36).priorityHigh();
    }];
    
    [_bullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bgView);
        make.centerY.equalTo(_bgView);
        make.width.mas_equalTo(75);
        make.height.mas_equalTo(15);
    }];
    
    [_bearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bullBtn.mas_right).offset(15);
        make.centerY.equalTo(_bgView);
        make.width.mas_equalTo(65);
        make.height.equalTo(_bgView);
    }];
    
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bgView);
        make.centerY.equalTo(_bgView);
        make.width.mas_equalTo(75);
        make.height.equalTo(_bgView);
    }];
}

#pragma mark - Private methods
- (NSString *)dateWithtimeStamp:(NSString *)timeStamp {
    NSDate *today = [[NSDate alloc] init];
    NSString *todayString = [[today description] substringToIndex:10];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp.doubleValue / 1000.0]];
    NSString *dateString = [timeStr substringToIndex:10];
    //如果不是今天的时间，则显示全部
    if ([dateString isEqualToString:todayString]) {
        [dateFormatter setDateFormat:@"HH:mm"];
    } else {
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    }
    
    NSString *newDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp.doubleValue / 1000.0]];
    
    return newDateStr;
}

- (NSAttributedString *)attributedStringWithContent:(NSString *)content {
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",  content]];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:LineSpacing];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, content.length)];
    return attributedStr;
}


@end
