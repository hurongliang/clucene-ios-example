//
//  HURLBuildIndexViewController.m
//  clucene-ios-example
//
//  Created by Ron Hu on 6/6/14.
//  Copyright (c) 2014 hurongliang.com. All rights reserved.
//

#import "HURLBuildIndexViewController.h"
#import "HURLPathUtils.h"
#import "HURLCluceneHelper.h"

@interface HURLBuildIndexViewController ()
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;
@property (weak, nonatomic) IBOutlet UIButton *buildButton;

@property(strong,nonatomic)NSArray *fileList;
- (IBAction)buildButtonClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
- (IBAction)doneButtonClicked:(id)sender;

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
    self.fileTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.buildButton.layer setBorderColor:[UIColor blueColor].CGColor];
    [self.buildButton.layer setBorderWidth:2.0f];
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
    [self.indicator startAnimating];
    self.messageLabel.text = @"Buiding index ...";
    for(int index=0;index<self.fileList.count;index++){
        [HURLCluceneHelper indexFile:[self.fileList objectAtIndex:index] rebuildIndex:YES];
        UITableViewCell *cell = [self.fileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    self.messageLabel.text = @"All files have been indexed.";
    [self.indicator stopAnimating];
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
    static NSString *cellid = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.textLabel.text = [filePath lastPathComponent];
    return cell;
}
- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
