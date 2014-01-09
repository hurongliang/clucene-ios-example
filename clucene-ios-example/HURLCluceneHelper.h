//
//  HURLCluceneHelper.h
//  ios-clucene-sample
//
//  Created by Ron Hu on 1/8/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#define INDEX_FIELD_PATH @"path"
#define INDEX_FIELD_CONTENT @"content"

#import <Foundation/Foundation.h>

@interface HURLCluceneHelper : NSObject

+(void)indexFileWithFilePath:(NSString *)filePath rebuildIndex:(BOOL)rebuildIndex;
+(void)indexFileListWithFilePath:(NSArray *)filePathList rebuildIndex:(BOOL)rebuildIndex;
+(NSArray *)search:(NSString *)keyword;
+(NSString *)getDocumentPath;

@end
