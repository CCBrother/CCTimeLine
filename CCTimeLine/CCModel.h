//
//Created by ESJsonFormatForMac on 18/08/06.
//

#import <Foundation/Foundation.h>

@class Article;
@interface CCModel : NSObject

@property (nonatomic, strong) NSArray<Article *> *articleList;

@end
@interface Article : NSObject

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *publishTime;

@property (nonatomic, assign) NSInteger bearNum;

@property (nonatomic, assign) NSInteger ID;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger bullOrBear;

@property (nonatomic, assign) NSInteger bullNum;

@property (nonatomic, assign) BOOL isFolding;

@end

