//
//  JFObjcTool.m
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/15.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

#import "JFObjcTool.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation JFObjcTool

+ (NSString *)jf_md5:(NSString *)string {
    
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
