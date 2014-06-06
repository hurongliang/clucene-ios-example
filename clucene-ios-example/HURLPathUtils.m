//
//  PathUtils.m
//  clucene-ios-example
//
//  Created by Ron Hu on 6/6/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import "HURLPathUtils.h"

@implementation HURLPathUtils

+(NSString *)getDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+(NSString *)getIndexPath{
    NSString *docPath = [self getDocumentPath];
    NSString *indexPath = [docPath stringByAppendingPathComponent:@"index"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:indexPath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:indexPath withIntermediateDirectories:NO attributes:nil error:&error];
        if(error){
            NSLog(@"Failed to create folder %@: %@",indexPath,error.description);
        }
    }
    return indexPath;
}
+(NSArray *)getAllFiles{
    NSString *documentPath = [self getDocumentPath];
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"data"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    /* create data folder */
    if(![fileManager fileExistsAtPath:dataPath]){
        [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    /* copy *.html files to data folder */
    NSMutableArray *filePathList = [[NSMutableArray alloc] init];
    NSArray *fileNameList = [[NSArray alloc] initWithObjects:@"a.txt",@"b.txt",@"c.txt",@"d.txt",@"e.txt", nil];
    for(NSString *fileName in fileNameList){
        NSString *filePath = [dataPath stringByAppendingPathComponent:fileName];
        if (![fileManager fileExistsAtPath: filePath]){
            NSError *error;
            NSString *bundle = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            [fileManager copyItemAtPath:bundle toPath:filePath error:&error];
            if(error){
                NSLog(@"%@",error.description);
            }else{
                [filePathList addObject:filePath];
            }
        }else{
            [filePathList addObject:filePath];
        }
    }
    
    return filePathList;
}
@end
