//
//  AsyncDownLoad.m
//  缓存下载类Demo
//
//  Created by teddy on 14-10-15.
//  Copyright (c) 2014年 teddy. All rights reserved.
//

#import "AsyncDownLoad.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation AsyncDownLoad

#pragma mark-单例
+ (AsyncDownLoad *)shareTheme
{
    static dispatch_once_t onceToken;
    static AsyncDownLoad *loadFile = nil;
    dispatch_once(&onceToken ,^{
        loadFile = [[AsyncDownLoad alloc] init];
    });
    return loadFile;
}

- (void) downloadFilesurl:(NSString *)aFileUrl
{
    /*
     *1.先判断在本地是否存在文件
     *2，若是文件存在，那么直接提交通知，告诉接收者文件已下载完成
     *3，若是文件不存在，那么开始下载文件
    */
    //得到文件的Url地址
    NSString *filepath = [self cacheFileImage:aFileUrl];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filepath]) {
        //若是存在文件
        [[NSNotificationCenter defaultCenter] postNotificationName:FILEWSDOWNLOADCOMPLETE object:filepath];
    } else {
        //若是不存在，则下载文件
        [self loadFileFromUrl:[NSURL URLWithString:aFileUrl] fileInfoDic:nil];
    }
    
}

//先通过请求获得文件的全路径
- (NSString *)cacheFileImage:(NSString *)fileName
{
    //缓存文件路劲
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    //存在缓存中得文件的文件夹路径
    cacheFolder = [cacheFolder stringByAppendingPathComponent:@"音频类文件"];
    //创建文件管理对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheFolder]) {
        //如果文件夹不存在
        NSError *error = nil;
        //创建文件夹
        [fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建文件夹失败");
            return nil;
        }
    }
    
    NSArray *paths = [fileName componentsSeparatedByString:@"/"];
    if (paths.count== 0) {
        return nil;
    }
    //文件的路径
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",cacheFolder,[paths lastObject]];
    return filePath;
}

//下载文件并带缓存
- (void)loadFileFromUrl:(NSURL *)url fileInfoDic:(NSDictionary *)dic
{
    __block ASIHTTPRequest *request = nil; //在block快中引用局部变量，需要在前面加__block修饰，否则在使用的过程会被当成常量来使用
    if (url) {
        request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        [request setTimeOutSeconds:60];//设置下载超时时间
        
        //设置缓存
        ASIDownloadCache *loadcache = [ASIDownloadCache sharedCache];
        [request setDownloadCache:loadcache];
        //设置储存策略
        [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
        
        //设置缓存保存数据时间
        [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy]; //永久保存
        [request setShouldContinueWhenAppEntersBackground:YES]; //设置后台运行
        //设置缓存路径（绝对路径）
        [request setDownloadDestinationPath:[self cacheFileImage:[url absoluteString]]];
    }
    else
    {
        return;
    }
    
    //下载完成
    [request setCompletionBlock:^{
        //提交通知
        [[NSNotificationCenter defaultCenter] postNotificationName:FILEWSDOWNLOADCOMPLETE object:[self cacheFileImage:[url absoluteString]] userInfo:nil];
        NSLog(@"下载完成");
    }];
    
    //下载失败
    [request setFailedBlock:^{
        NSError *error = request.error;
        NSLog(@"error reason:%@",error);
    }];
    
    [request startAsynchronous]; //发送异步请求
}
@end
