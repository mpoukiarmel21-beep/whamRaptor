#import "WRListPickerVC.h"
#import "WRTheme.h"
#import "WRMapPickerVC.h"

@interface WRListPickerVC () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UISearchBar *search;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSArray<NSDictionary*>* all;
@property (nonatomic, strong) NSArray<NSDictionary*>* filtered;
@end
@implementation WRListPickerVC
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title=@"Choisir une ville"; self.view.backgroundColor=WRTheme.bg;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    self.all=[WRWorldCities allCities];
    self.filtered=self.all;
    self.search=[UISearchBar new]; self.search.placeholder=@"Rechercher…"; self.search.delegate=self;
    self.table=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.table.backgroundColor=WRTheme.bg; self.table.delegate=self; self.table.dataSource=self;
    [self.table registerClass:UITableViewCell.class forCellReuseIdentifier:@"c"];
    self.search.frame=CGRectMake(0,0,self.view.bounds.size.width,44);
    self.table.tableHeaderView=self.search;
    self.table.frame=self.view.bounds; self.table.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.table];
}
- (void)close{ [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)searchBar:(UISearchBar*)sb textDidChange:(NSString*)t{
    if (!t.length) self.filtered=self.all;
    else { NSString *q=t.lowercaseString; self.filtered=[self.all filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary*d, NSDictionary*b){ return [[d[@"city"] lowercaseString] containsString:q]||[[d[@"country"] lowercaseString] containsString:q]||[[d[@"countryCode"] lowercaseString] containsString:q]; }]]; }
    [self.table reloadData];
}
- (NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)s{ return self.filtered.count; }
- (UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)ip{
    UITableViewCell *c=[tv dequeueReusableCellWithIdentifier:@"c" forIndexPath:ip];
    NSDictionary *d=self.filtered[ip.row];
    c.backgroundColor=WRTheme.card; c.textLabel.textColor=WRTheme.text; c.detailTextLabel.textColor=WRTheme.subtext;
    c.textLabel.text=[NSString stringWithFormat:@"%@, %@", d[@"city"], d[@"countryCode"]];
    c.detailTextLabel.text=[NSString stringWithFormat:@"%@ · %@", d[@"timezone"], d[@"lang"]];
    c.textLabel.font=WRTheme.bodyFont; c.detailTextLabel.font=WRTheme.smallFont;
    // force subtitle style
    if (c.detailTextLabel==nil){ c=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"]; c.backgroundColor=WRTheme.card; c.textLabel.textColor=WRTheme.text; c.detailTextLabel.textColor=WRTheme.subtext; c.textLabel.text=[NSString stringWithFormat:@"%@, %@", d[@"city"], d[@"countryCode"]]; c.detailTextLabel.text=[NSString stringWithFormat:@"%@ · %@", d[@"timezone"], d[@"lang"]]; }
    return c;
}
- (void)tableView:(UITableView*)tv didSelectRowAtIndexPath:(NSIndexPath*)ip{
    NSDictionary *d=self.filtered[ip.row];
    WRLocation *loc=[WRLocation new]; loc.city=d[@"city"]; loc.country=d[@"country"]; loc.countryCode=d[@"countryCode"]; loc.timezoneName=d[@"timezone"]; loc.languageCode=d[@"lang"]; loc.localeIdentifier=d[@"locale"]?:[d[@"lang"] stringByAppendingString:@"_US"]; loc.latitude=[d[@"lat"] doubleValue]; loc.longitude=[d[@"lon"] doubleValue]; loc.horizontalAccuracy=15;
    if (self.onPick) self.onPick(loc);
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
