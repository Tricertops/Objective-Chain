//
//  CAEListViewController.m
//  Chain Examples
//
//  Created by Martin Kiss on 14.1.14.
//  Copyright (c) 2014 iMartin Kiss. All rights reserved.
//

#import "CAEListViewController.h"
#import "CAEExampleViewController.h"





@interface CAEListViewController ()


@property (nonatomic, readonly, strong) NSArray *exampleClasses;


@end










@implementation CAEListViewController





#pragma mark Creating & Loading


- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Objective-Chain   Examples";
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem.title = @"Examples";
        
        NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:OCAKPUnsafe(exampleDate) ascending:YES];
        self->_exampleClasses = [[CAEExampleViewController allSubclasses] sortedArrayUsingDescriptors:@[ sortByDate ]];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *footnote = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100)];
    footnote.textColor = [UIColor darkGrayColor];
    footnote.numberOfLines = 0;
    footnote.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[UIFont smallSystemFontSize]];
    footnote.textAlignment = NSTextAlignmentCenter;
    footnote.text =
    @"github.com/iMartinKiss/Objective-Chain" @"\n"
    @"\n"
    @"Copyright © 2014 Martin Kiss" @"\n"
    @"Licensed under MIT License";
    self.tableView.tableFooterView = footnote;
}





#pragma mark tTable View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.exampleClasses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CAEListCellIdentifier = @"CAEListCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CAEListCellIdentifier];
    if ( ! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CAEListCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Class exampleClass = [self.exampleClasses objectAtIndex:indexPath.row];
    cell.textLabel.text = [exampleClass exampleTitle];
    cell.detailTextLabel.text = [exampleClass exampleSubtitle];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class exampleClass = [self.exampleClasses objectAtIndex:indexPath.row];
    CAEExampleViewController *example = [[exampleClass alloc] init];
    [self.navigationController pushViewController:example animated:YES];
}





@end
