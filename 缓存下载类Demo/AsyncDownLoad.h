//
//  AsyncDownLoad.h
//  缓存下载类Demo
// ***************下载类，设计成单例**********
//  Created by teddy on 14-10-15.
//  Copyright (c) 2014年 teddy. All rights reserved.
//

#import <Foundation/Foundation.h>

//文件下载完成的通知名
#define FILEWSDOWNLOADCOMPLETE @"FileDownloadComplete"

@interface AsyncDownLoad : NSObject

+ (AsyncDownLoad *)shareTheme;

//下载文件
- (void)downloadFilesurl:(NSString *)aFileUrl;

@end
