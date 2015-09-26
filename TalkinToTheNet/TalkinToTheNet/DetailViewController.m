//
//  DetailViewController.m
//  TalkinToTheNet
//
//  Created by Chris David on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "DetailViewController.h"


@interface DetailViewController ()  <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *checkIns;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *stations;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.name.text = self.fourSquareObject.name;
    self.address.text = self.fourSquareObject.address;
    self.checkIns.text = self.fourSquareObject.checkIns;
    
    [self GoogleAPIRequestBlock:^{
        [self.tableView reloadData];
    }];
}
- (void) GoogleAPIRequestBlock:(void(^)())block{
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@&rankby=distance&types=subway_station|transit_station&key=AIzaSyAWnqNcCoTk_j7oZabHJkVZW0ULVFg5uZ0", self.fourSquareObject.location];
    
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL   URLWithString:encodedString];
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.stations = [[NSMutableArray alloc]init];
            
            NSArray *results = [json objectForKey:@"results"];
            
            for (NSDictionary *result in results) {
                
                [self.stations addObject:[result objectForKey:@"name"]];
            }
            block();
        }
        
    }];
    
}
# pragma mark -tableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.stations.count;    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCellIdentifier" forIndexPath:indexPath];
    
    NSString * station = [self.stations objectAtIndex:indexPath.row];
    
    
    
    cell.textLabel.text = station;

    return cell;
}



@end
