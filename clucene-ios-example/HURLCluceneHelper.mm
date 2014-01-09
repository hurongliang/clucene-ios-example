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
    NSString *indexPath = [self getIndexPath];
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
    //IndexWriter* writer = _CLNEW IndexWriter(cIndexPath, &an, true);
    
    writer->setMaxFieldLength(0x7FFFFFFFL); // LUCENE_INT32_MAX_SHOULDBE
    
    writer->setUseCompoundFile(false);
    
	Document doc;
    [self createDocument:filePath document:&doc];
//    createDocument(filePath, &doc);
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
    
    NSString *indexPath = [self getIndexPath];
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
    //IndexWriter* writer = _CLNEW IndexWriter(cIndexPath, &an, true);
    
    writer->setMaxFieldLength(0x7FFFFFFFL); // LUCENE_INT32_MAX_SHOULDBE
    
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
    const char* f = [filePath UTF8String];
    // Add the path of the file as a field named "path".  Use an indexed and stored field, so
    // that the index stores the path, and so that the path is searchable.
    TCHAR tf[CL_MAX_DIR];
    STRCPY_AtoT(tf,f,CL_MAX_DIR);
    doc->add( *_CLNEW Field(_T("path"), tf, Field::STORE_YES | Field::INDEX_UNTOKENIZED ) );
    NSArray *parts = [filePath componentsSeparatedByString:@"/"];
    NSString *fileName = [parts objectAtIndex:parts.count-1];
    const char* fn = [fileName UTF8String];
    TCHAR tfn[CL_MAX_DIR];
    STRCPY_AtoT(tfn,fn,CL_MAX_DIR);
    doc->add( *_CLNEW Field(_T("fileName"), tfn, Field::STORE_YES | Field::INDEX_UNTOKENIZED ) );
    
    // Add the last modified date of the file a field named "modified". Again, we make it
    // searchable, but no attempt is made to tokenize the field into words.
    //doc->add( *_CLNEW Field(_T("modified"), DateTools::timeToString(f->lastModified()), Field::STORE_YES | Field::INDEX_NO));
    
    // Add the contents of the file a field named "contents".  This time we use a tokenized
	// field so that the text can be searched for words in it.
    
    // Here we read the data without any encoding. If you want to use special encoding
    // see the contrib/jstreams - they contain various types of stream readers
    FILE* fh = fopen(f,"r");
	if ( fh != NULL ){
		StringBuffer str;
		char abuf[1024];
		TCHAR tbuf[1024];
		size_t r;
		do{
			r = fread(abuf,1,1023,fh);
			abuf[r]=0;
			STRCPY_AtoT(tbuf,abuf,r);
			tbuf[r]=0;
			str.append(tbuf);
		}while(r>0);
		fclose(fh);
        
		doc->add( *_CLNEW Field(_T("contents"), str.getBuffer(), Field::STORE_YES | Field::INDEX_TOKENIZED) );
	}
    
    /*
    const TCHAR* cFilePath = [self string2char:filePath];
    doc->add( *_CLNEW Field(_T("path"), cFilePath, Field::STORE_YES | Field::INDEX_UNTOKENIZED ));
    
    NSString *content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const TCHAR* strbuffer = [self string2char:content];
    doc->add( *_CLNEW Field(_T("contents"), strbuffer, Field::STORE_YES | Field::INDEX_TOKENIZED) );*/
}

+(NSArray *)search:(NSString *)keyword{
    NSString *indexPath = [self getIndexPath];
    
    NSMutableArray *resultList = [[NSMutableArray alloc] init];
    
    if(keyword==nil || keyword.length==0 || indexPath==nil || ![[NSFileManager defaultManager] fileExistsAtPath:indexPath]){
        return nil;
    }
    try{
        const char* text = [keyword UTF8String];
        const char* index = [indexPath UTF8String];
        standard::StandardAnalyzer analyzer;
        TCHAR* buf;
        
        IndexReader* reader = IndexReader::open(index);
        IndexReader* newreader = reader->reopen();
        if ( newreader != reader ){
            _CLLDELETE(reader);
            reader = newreader;
        }
        IndexSearcher s(reader);
        int length = strlen(text);
        TCHAR *tline = (TCHAR*)calloc(length, sizeof(TCHAR));
        STRCPY_AtoT(tline,text,length);
        const TCHAR* content = _T("contents");
        Query* q = QueryParser::parse(tline,content,&analyzer);
        
        buf = q->toString(content);
        _CLDELETE_LCARRAY(buf);
        
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
+(NSString *)getDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
+(NSString*)tchar2string:(const wchar_t*) inStr{
    return [[NSString alloc] initWithBytes:inStr length:wcslen(inStr)*sizeof(TCHAR) encoding:NSUTF8StringEncoding];
    /*setlocale(LC_CTYPE, "UTF-8");
    int strLength = wcslen(inStr);
    int bufferSize = (strLength+1)*4;
    char *stTmp = (char*)malloc(bufferSize);
    memset(stTmp, 0, bufferSize);
    wcstombs(stTmp, inStr, strLength);
    NSString* ret = [[NSString alloc] initWithBytes:stTmp length:strlen(stTmp) encoding:NSUTF8StringEncoding];
    free(stTmp);
    return ret;*/
}
+(const TCHAR*)string2char:(NSString *)str{
    return (const TCHAR*)[str cStringUsingEncoding:NSUTF8StringEncoding];
}
@end
