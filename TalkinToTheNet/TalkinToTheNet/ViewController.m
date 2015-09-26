//
//  ViewController.m
//  TalkinToTheNet
//
//  Created by Michael Kavouras on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "ViewController.h"
#import "Place.h"
#import "APIManager.h"
#import "DetailViewController.h"


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *searchLocationTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *places;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.searchLocationTextField setDelegate:self];
}


- (void) makeFourSquareAPIRequest:(NSString*) searchTerm andLocation:(NSString*) location callbackBlock:(void(^)())block{
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?near=%@&query=%@&client_id=V4EZD2DVUA5S4EW4UWUFJQRCRO3L0QEBRZ2MNOA2IAVF2VXY&client_secret=J1KFSATHO1PDRRLDSQCEBSZ0ULLBVK20YC1WYIN3T53LXXPX&v=20150924", location, searchTerm];
    
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL   URLWithString:encodedString];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.places = [[NSMutableArray alloc]init];
            
            NSArray *results = [[json objectForKey:@"response"] objectForKey:@"venues"];
            
            
            for (NSDictionary *result in results) {
                Place *object = [[Place alloc]init];
                object.name = [result objectForKey:@"name"];
                NSString *address = [[result objectForKey:@"location"] objectForKey:@"address"];
                NSString *city = [[result objectForKey:@"location"] objectForKey:@"city"];
                NSString *state = [[result objectForKey:@"location"] objectForKey:@"state"];
                NSString *postalCode = [[result objectForKey:@"location"] objectForKey:@"postalCode"];
                
                object.address = [NSString stringWithFormat:@"%@ %@, %@ %@", address, city, state, postalCode];
                NSString *latitude = [[[result objectForKey:@"location"] objectForKey:@"lat"] stringValue];
                NSString *longitude = [[[result objectForKey:@"location"] objectForKey:@"lng"] stringValue];
                object.checkIns = [[[result objectForKey:@"stats"] objectForKey:@"checkinsCount"] stringValue];
                
                object.location = [latitude stringByAppendingString:[NSString stringWithFormat:@",%@", longitude]];
                
                [self.places addObject:object];
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
    
    return self.places.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    Place *result = [self.places objectAtIndex:indexPath.row];
    
    
    cell.textLabel.text = result.name;
    cell.detailTextLabel.text = result.address;
    

    return cell;
}
# pragma mark - text field delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    
    NSString * query = self.searchTextField.text;
    
    [self makeFourSquareAPIRequest:query andLocation:textField.text callbackBlock:^{
        [self.tableView reloadData];
    }];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailViewController *viewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"DetailIdentifier"];
    viewController.fourSquareObject = [self.places objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}

@end
