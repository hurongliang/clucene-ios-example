//
//  HURLSearchViewController.m
//  ios-clucene-sample
//
//  Created by Ron Hu on 1/6/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import "HURLSearchViewController.h"
#import "HURLCluceneHelper.h"
#import "HURLContentViewController.h"
#import "HURLPathUtils.h"
#import "HURLSearchResultItem.h"

@interface HURLSearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buildIndex:(UIBarButtonItem *)sender;

@end

@implementation HURLSearchViewController{
    NSArray *resultList;
    HURLSearchResultItem *selectedSearchItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    HURLSearchResultItem *resultItem = [resultList objectAtIndex:indexPath.row];
    NSLog(@"%@",resultItem.filePath);
    cell.textLabel.text = resultItem.fileName;
    cell.detailTextLabel.text = resultItem.summary;
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
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length>=2){
        [self doSearch:searchText];
    }
}
-(void)doSearch:(NSString *)searchText{
    if([searchText length]>=2){
        resultList = [HURLCluceneHelper searchFileList:[HURLPathUtils getAllFiles] withKeyword:searchText];
        NSLog(@"Found %ld matched files.",(unsigned long)resultList.count);
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
