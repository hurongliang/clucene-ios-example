//
//  HURLViewController.m
//  ios-clucene-sample
//
//  Created by Ron Hu on 1/6/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import "HURLViewController.h"
#import "HURLCluceneHelper.h"

@interface HURLViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buildIndex:(UIBarButtonItem *)sender;

@end

@implementation HURLViewController{
    NSArray *resultList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [resultList objectAtIndex:indexPath.row];
    NSString *path = [dict objectForKey:@"path"];
    NSString *fileName = [dict objectForKey:@"fileName"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSLog(@"path = %@",path);
    NSLog(@"fileName = %@",fileName);
    cell.textLabel.text = fileName;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [resultList count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (IBAction)buildIndex:(UIBarButtonItem *)sender {
    NSString *documentPath = [HURLCluceneHelper getDocumentPath];
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
    
    /* generate index file for all *.html files */
    [HURLCluceneHelper indexFileListWithFilePath:filePathList rebuildIndex:YES];
    
    NSLog(@"Build index success!");
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self doSearch:searchBar.text];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self doSearch:searchBar.text];
}
-(void)doSearch:(NSString *)searchText{
    if([searchText length]>=2){
        resultList = [HURLCluceneHelper search:searchText];
        NSLog(@"Search result count %d",resultList.count);
        [self.tableView reloadData];
    }
}
@end
