//
//  HURLBuildIndexViewController.m
//  clucene-ios-example
//
//  Created by Ron Hu on 6/6/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import "HURLBuildIndexViewController.h"
#import "HURLPathUtils.h"

@interface HURLBuildIndexViewController ()
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;
@property (weak, nonatomic) IBOutlet UIButton *buildButton;

@property(strong,nonatomic)NSArray *fileList;
- (IBAction)buildButtonClicked:(UIButton *)sender;

@end

@implementation HURLBuildIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fileList = [HURLPathUtils getAllFiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buildButtonClicked:(UIButton *)sender {
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.fileList count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Files to be indexed";
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *filePath = [self.fileList objectAtIndex:indexPath.row];
}
@end
