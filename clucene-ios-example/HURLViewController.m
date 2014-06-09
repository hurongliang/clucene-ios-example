//
//  HURLViewController.m
//  ios-clucene-sample
//
//  Created by Ron Hu on 1/6/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import "HURLViewController.h"
#import "HURLCluceneHelper.h"
#import "HURLContentViewController.h"
#import "HURLPathUtils.h"
#import "HURLSearchResultItem.h"

@interface HURLViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buildIndex:(UIBarButtonItem *)sender;

@end

@implementation HURLViewController{
    NSArray *resultList;
    HURLSearchResultItem *selectedSearchItem;
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
    HURLSearchResultItem *resultItem = [resultList objectAtIndex:indexPath.row];
    NSString *path = resultItem.filePath;
    NSString *fileName = resultItem.fileName;
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
    NSArray *filePathList = [HURLPathUtils getAllFiles];
    
    /* generate index file for all *.html files */
    [HURLCluceneHelper indexFileList:filePathList rebuildIndex:YES];
    
    NSLog(@"Build index success!");
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self doSearch:searchBar.text];
}
-(void)doSearch:(NSString *)searchText{
    if([searchText length]>=2){
        resultList = [HURLCluceneHelper searchFileList:[HURLPathUtils getAllFiles] withKeyword:searchText];
        NSLog(@"Search result count %ld",(unsigned long)resultList.count);
        [self.tableView reloadData];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedSearchItem = [resultList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showContent" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showContent"]){
        if(selectedSearchItem){
            HURLContentViewController *vc = segue.destinationViewController;
            vc.searchResult = selectedSearchItem;
        }
    }
}
@end
