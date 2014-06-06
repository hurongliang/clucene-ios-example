//
//  HURLCluceneHelper.m
//  ios-clucene-sample
//
//  Created by Ron Hu on 1/8/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include <cctype>
#include <string.h>
#include <algorithm>

#include "CLucene/StdHeader.h"
#include "CLucene/_clucene-config.h"

#include "CLucene.h"
#include "CLucene/util/CLStreams.h"
#include "CLucene/util/dirent.h"
#include "CLucene/config/repl_tchar.h"
#include "CLucene/util/Misc.h"
#include "CLucene/util/StringBuffer.h"
#import "HURLPathUtils.h"


using namespace std;
using namespace lucene::index;
using namespace lucene::analysis;
using namespace lucene::util;
using namespace lucene::store;
using namespace lucene::document;
using namespace lucene::search;
using namespace lucene::queryParser;

#import "HURLCluceneHelper.h"

@implementation HURLCluceneHelper
+(void)indexFileWithFilePath:(NSString *)filePath rebuildIndex:(BOOL)rebuildIndex{
    NSString *indexPath = [HURLPathUtils getIndexPath];
	const char *cIndexPath = [indexPath UTF8String];
    
    /* unlock index */
    IndexWriter* writer = nil;
	lucene::analysis::WhitespaceAnalyzer an;
	if (IndexReader::indexExists(cIndexPath)){
        if(IndexReader::isLocked(cIndexPath)){
            IndexReader::unlock(cIndexPath);
        }
	}
    writer = _CLNEW IndexWriter(cIndexPath, &an, rebuildIndex);
    
    writer->setMaxFieldLength(0x7FFFFFFFL);
    
    writer->setUseCompoundFile(false);
    
	Document doc;
    [self createDocument:filePath document:&doc];
    writer->addDocument( &doc);
	
    writer->setUseCompoundFile(true);
    writer->optimize();
	
    writer->close();
	_CLLDELETE(writer);
    
    NSLog(@"%@ indexed.",filePath);
}

+(void)indexFileListWithFilePath:(NSArray *)filePathList rebuildIndex:(BOOL)rebuildIndex{
    if(filePathList==nil && [filePathList count]==0){
        return;
    }
    
    NSString *indexPath = [HURLPathUtils getIndexPath];
	const char *cIndexPath = [indexPath UTF8String];
    
    /* unlock index */
    IndexWriter* writer = nil;
	lucene::analysis::WhitespaceAnalyzer an;
    if(rebuildIndex){
        if([[NSFileManager defaultManager] fileExistsAtPath:indexPath]){
            [[NSFileManager defaultManager] removeItemAtPath:indexPath error:nil];
        }
        writer = _CLNEW IndexWriter(cIndexPath, &an, true);
    }else{
        if (IndexReader::indexExists(cIndexPath)){
            if(IndexReader::isLocked(cIndexPath)){
                IndexReader::unlock(cIndexPath);
            }
        }
        writer = _CLNEW IndexWriter(cIndexPath, &an, false);
    }
    
    writer->setMaxFieldLength(0x7FFFFFFFL);
    
    writer->setUseCompoundFile(false);
    
    Document doc;
    for (NSString *filePath in filePathList) {
        doc.clear();
        [self createDocument:filePath document:&doc];
        writer->addDocument( &doc);
        NSLog(@"%@ indexed.",filePath);
    }
	
    writer->setUseCompoundFile(true);
    writer->optimize();
	
    writer->close();
	_CLLDELETE(writer);
    
}
+(void)createDocument:(NSString*)filePath document:(Document*) doc{
    const TCHAR* cFilePath = [self string2char:filePath];
    doc->add( *_CLNEW Field(_T("path"), cFilePath, Field::STORE_YES | Field::INDEX_UNTOKENIZED ));
    
    NSArray *parts = [filePath componentsSeparatedByString:@"/"];
    NSString *fileName = [parts objectAtIndex:parts.count-1];
    const TCHAR* cFileName = [self string2char:fileName];
    doc->add( *_CLNEW Field(_T("fileName"), cFileName, Field::STORE_YES | Field::INDEX_UNTOKENIZED ));
    
    NSString *content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const TCHAR* strbuffer = [self string2char:content];
    doc->add( *_CLNEW Field(_T("contents"), strbuffer, Field::STORE_YES | Field::INDEX_TOKENIZED) );
}

+(NSArray *)search:(NSString *)keyword{
    NSString *indexPath = [HURLPathUtils getIndexPath];
    
    NSMutableArray *resultList = [[NSMutableArray alloc] init];
    
    if(keyword==nil || keyword.length==0 || indexPath==nil || ![[NSFileManager defaultManager] fileExistsAtPath:indexPath]){
        return nil;
    }
    try{
        const char* cIndexPath = [indexPath UTF8String];
        
        IndexReader* reader = IndexReader::open(cIndexPath);
        IndexReader* newreader = reader->reopen();
        if ( newreader != reader ){
            _CLLDELETE(reader);
            reader = newreader;
        }
        
        standard::StandardAnalyzer analyzer;
        const TCHAR *cKeyword = [self string2char:keyword];
        Query* q = QueryParser::parse(cKeyword,_T("contents"),&analyzer);
        
        IndexSearcher s(reader);
        Hits* h = s.search(q);
        
        int hLength = h->length();
        for ( size_t i=0;i<hLength;i++ ){
            Document* doc = &h->doc(i);
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            const TCHAR* cFilePath = doc->get(_T("path"));
            NSString *filePath = [self tchar2string:cFilePath];
            [dict setObject:filePath forKey:@"path"];
            
            const TCHAR* cFileName = doc->get(_T("fileName"));
            NSString *fileName = [self tchar2string:cFileName];
            [dict setObject:fileName forKey:@"fileName"];
            
            [resultList addObject:dict];
        }
        
        _CLLDELETE(h);
        _CLLDELETE(q);
        
        s.close();
        reader->close();
        _CLLDELETE(reader);
    }catch (CLuceneError& e) {
        NSString *err = [self tchar2string:e.twhat()];
        NSLog(@"%@",err);
        return nil;
    }
    
    return resultList;
}
+(NSString*)tchar2string:(const TCHAR*) inStr{
    return [[NSString alloc] initWithBytes:inStr length:wcslen(inStr)*sizeof(TCHAR) encoding:NSUTF32LittleEndianStringEncoding];
    
}
+(const TCHAR*)string2char:(NSString *)str{
    return (const TCHAR*)[str cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
}
/*
+(const char*)wchar2char(const TCHAR* wchar){
    std::wstring_convert<std::codecvt_utf8<wchar_t>,wchar_t> convert;
    
    wchar_t const *ws = L"Steve Nash";
    std::string s = convert.to_bytes(ws);
    char const *cs = s.c_str();
}
 */
@end
