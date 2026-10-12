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
    self.view.backgroundColor=WRTheme.bg;
    UINavigationBarAppearance *app=[UINavigationBarAppearance new];
    [app configureWithOpaqueBackground]; app.backgroundColor=WRTheme.bg; app.titleTextAttributes=@{NSForegroundColorAttributeName: WRTheme.text};
    self.navigationController.navigationBar.standardAppearance=app;
    self.navigationController.navigationBar.scrollEdgeAppearance=app;
    self.navigationController.navigationBar.tintColor=WRTheme.accent;
    self.title=@"Choisir une ville"; 
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Fermer" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.all=[WRWorldCities allCities];
    self.filtered=self.all;
    // Search as header with proper contrast
    UIView *wrap=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,52)];
    wrap.backgroundColor=WRTheme.bg;
    self.search=[[UISearchBar alloc] initWithFrame:CGRectMake(8,6,wrap.bounds.size.width-16,40)];
    self.search.placeholder=@"Rechercher une ville…"; self.search.delegate=self;
    self.search.searchBarStyle=UISearchBarStyleMinimal; self.search.backgroundColor=UIColor.clearColor;
    self.search.tintColor=WRTheme.accent;
    UITextField *tf=[self.search valueForKey:@"searchField"];
    if (tf){ tf.textColor=WRTheme.text; tf.tintColor=WRTheme.accent; tf.backgroundColor=WRTheme.card; tf.layer.cornerRadius=10; tf.clipsToBounds=YES; tf.attributedPlaceholder=[[NSAttributedString alloc] initWithString:@"Rechercher une ville…" attributes:@{NSForegroundColorAttributeName: WRTheme.muted}]; }
    self.search.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [wrap addSubview:self.search];
    self.table=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.table.backgroundColor=WRTheme.bg; self.table.separatorColor=WRTheme.border;
    self.table.delegate=self; self.table.dataSource=self;
    self.table.tableHeaderView=wrap;
    self.table.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    // Use subtitle cells — register properly
    [self.view addSubview:self.table];
}
- (void)close{ [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)searchBar:(UISearchBar*)sb textDidChange:(NSString*)t{
    if (!t.length) self.filtered=self.all;
    else { NSString *q=t.lowercaseString; self.filtered=[self.all filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary*d, NSDictionary*b){ return [[d[@"city"] lowercaseString] containsString:q]||[[d[@"country"] lowercaseString] containsString:q]||[[d[@"countryCode"] lowercaseString] containsString:q]; }]]; }
    [self.table reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)sb{ [sb resignFirstResponder]; }
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tv{ return 1; }
- (NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)s{ return self.filtered.count; }
- (CGFloat)tableView:(UITableView*)tv heightForRowAtIndexPath:(NSIndexPath*)ip{ return 58; }
- (UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)ip{
    NSDictionary *d=self.filtered[ip.row];
    UITableViewCell *c=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    c.backgroundColor=WRTheme.card;
    c.textLabel.textColor=WRTheme.text; c.textLabel.font=WRTheme.bodyBoldFont;
    c.detailTextLabel.textColor=WRTheme.subtext; c.detailTextLabel.font=WRTheme.smallFont; c.detailTextLabel.numberOfLines=1;
    c.textLabel.text=[NSString stringWithFormat:@"%@, %@", d[@"city"], d[@"countryCode"]];
    c.detailTextLabel.text=[NSString stringWithFormat:@"%@  •  %@ / %@", d[@"timezone"], d[@"lang"], d[@"locale"]];
    c.accessoryType=UITableViewCellAccessoryDisclosureIndicator; c.tintColor=WRTheme.accent;
    return c;
}
- (void)tableView:(UITableView*)tv didSelectRowAtIndexPath:(NSIndexPath*)ip{
    [tv deselectRowAtIndexPath:ip animated:YES];
    NSDictionary *d=self.filtered[ip.row];
    WRLocation *loc=[WRLocation new]; loc.city=d[@"city"]; loc.country=d[@"country"]; loc.countryCode=d[@"countryCode"]; loc.timezoneName=d[@"timezone"]; loc.languageCode=d[@"lang"]; loc.localeIdentifier=d[@"locale"]?:[d[@"lang"] stringByAppendingString:@"_US"]; loc.latitude=[d[@"lat"] doubleValue]; loc.longitude=[d[@"lon"] doubleValue]; loc.horizontalAccuracy=15;
    if (self.onPick) self.onPick(loc);
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
