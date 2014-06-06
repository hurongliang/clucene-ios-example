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

@interface HURLViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buildIndex:(UIBarButtonItem *)sender;

@end

@implementation HURLViewController{
    NSArray *resultList;
    NSString *showFilePath;
    NSString *showFileName;
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
    NSArray *filePathList = [HURLPathUtils getAllFiles];
    
    /* generate index file for all *.html files */
    [HURLCluceneHelper indexFileListWithFilePath:filePathList rebuildIndex:YES];
    
    NSLog(@"Build index success!");
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [resultList objectAtIndex:indexPath.row];
    showFilePath = [dict objectForKey:@"path"];
    showFileName = [dict objectForKey:@"fileName"];
    [self performSegueWithIdentifier:@"showContent" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showContent"]){
        if(showFilePath){
            HURLContentViewController *vc = segue.destinationViewController;
            vc.filePath = showFilePath;
            vc.fileName = showFileName;
            vc.searchText = self.searchBar.text;
        }
    }
}
@end
