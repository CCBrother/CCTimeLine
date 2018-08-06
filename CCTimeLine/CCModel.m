//
//Created by ESJsonFormatForMac on 18/08/06.
//

#import "CCModel.h"
@implementation CCModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{
    return @{@"articleList" : [Article class]};
}


@end

@implementation Article


+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper{
    return @{@"ID":@"id"};
}

@end


