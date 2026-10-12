#import "WRPanelVC.h"
#import "WRTheme.h"
#import "WRL10n.h"
#import "WRContainerStore.h"
#import "WRCreateVC.h"
#import "WRMapPickerVC.h"
#import "WRActionSheet.h"
#import "WRAppRelaunch.h"

@interface WRPanelVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UILabel *headerLabel;
@end
@implementation WRPanelVC
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title=[WRL10n t:@"appName"]; self.view.backgroundColor=WRTheme.bg;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"＋" style:UIBarButtonItemStylePlain target:self action:@selector(newContainer)];

    UIView *hdr=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,56)];
    hdr.backgroundColor=WRTheme.card;
    self.headerLabel=[[UILabel alloc] initWithFrame:CGRectMake(16, 12, hdr.bounds.size.width-32, 32)];
    self.headerLabel.font=WRTheme.smallFont; self.headerLabel.textColor=WRTheme.subtext;
    [hdr addSubview:self.headerLabel];
    self.table=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.table.backgroundColor=WRTheme.bg; self.table.delegate=self; self.table.dataSource=self;
    self.table.tableHeaderView=hdr; self.table.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.table registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.table];
    [self reloadHeader];
}
- (void)viewWillAppear:(BOOL)a{ [super viewWillAppear:a]; [self reloadHeader]; [self.table reloadData]; }
- (void)reloadHeader{
    NSArray *all=WRContainerStore.shared.allContainers;
    WRContainer *active=WRContainerStore.shared.activeContainer;
    self.headerLabel.text=[NSString stringWithFormat:@"%lu container(s) · Actif: %@", (unsigned long)all.count, active?active.name:@"— App principale"];
}
- (void)done{ [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)newContainer{
    WRCreateVC *vc=[WRCreateVC new];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)s{ return WRContainerStore.shared.allContainers.count; }
- (UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)ip{
    UITableViewCell *cell=[tv dequeueReusableCellWithIdentifier:@"cell" forIndexPath:ip];
    if (!cell) cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    WRContainer *c=WRContainerStore.shared.allContainers[ip.row];
    BOOL isActive=[c.containerID isEqualToString:WRContainerStore.shared.activeContainer.containerID];
    cell.backgroundColor=isActive? [WRTheme.accent colorWithAlphaComponent:0.18] : WRTheme.card;
    cell.textLabel.textColor=WRTheme.text; cell.detailTextLabel.textColor=WRTheme.subtext;
    cell.textLabel.font=WRTheme.bodyFont; cell.detailTextLabel.font=WRTheme.smallFont;
    cell.textLabel.text=[NSString stringWithFormat:@"%@%@", isActive?@"● ":@"", c.name];
    cell.detailTextLabel.text=c.displaySubtitle;
    if (!c.displaySubtitle.length) cell.detailTextLabel.text=c.hasLocation? [NSString stringWithFormat:@"%@ · %@", c.location.city, c.location.timezoneName] : @"Aucune localisation";
    cell.accessoryType=isActive? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryDisclosureIndicator;
    // location button as accessory view if not active?
    UIButton *locBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [locBtn setTitle:@"📍" forState:UIControlStateNormal]; locBtn.frame=CGRectMake(0,0,36,36);
    locBtn.tag=ip.row; [locBtn addTarget:self action:@selector(changeLocation:) forControlEvents:UIControlEventTouchUpInside];
    // keep disclosure but allow location tap via swipe action instead if needed
    // We'll show location via long-press menu; for now add as trailing swipe
    return cell;
}
- (void)tableView:(UITableView*)tv didSelectRowAtIndexPath:(NSIndexPath*)ip{
    [tv deselectRowAtIndexPath:ip animated:YES];
    WRContainer *c=WRContainerStore.shared.allContainers[ip.row];
    BOOL isActive=[c.containerID isEqualToString:WRContainerStore.shared.activeContainer.containerID];
    if (isActive){
        [WRActionSheet showFrom:self title:c.name actions:@[
            @{@"title":@"📍 Changer localisation",@"style":@"default",@"block":^{ [self changeLocationFor:c]; }},
            @{@"title":@"✏️ Renommer",@"style":@"default",@"block":^{ [self wr_rename:c]; }},
            @{@"title":@"🗑 Supprimer",@"style":@"destructive",@"block":^{ [self confirmDelete:c]; }},
            @{@"title":@"Annuler",@"style":@"cancel",@"block":^{}},
        ]];
        return;
    }
    UIAlertController *a=[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Activer %@ ?", c.name] message:@"L'app va se relancer avec le stockage isolé de ce container." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Activer & relancer" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ [WRContainerStore.shared setActiveContainerID:c.containerID]; [WRAppRelaunch relaunch]; }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)changeLocation:(UIButton*)b{
    WRContainer *c=WRContainerStore.shared.allContainers[b.tag];
    [self changeLocationFor:c];
}
- (void)changeLocationFor:(WRContainer*)c{
    WRMapPickerVC *vc=[WRMapPickerVC new];
    vc.onPick=^(WRLocation *loc){ c.location=loc; c.hasLocation=YES; [WRContainerStore.shared updateContainer:c]; [self.table reloadData]; [self reloadHeader]; };
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)wr_rename:(WRContainer*)c{
    UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Renommer" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField*f){ f.text=c.name; }];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ NSString*t=a.textFields.firstObject.text; if(t.length){ c.name=t; [WRContainerStore.shared updateContainer:c]; [self.table reloadData]; [self reloadHeader]; }}]];
    [a addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)confirmDelete:(WRContainer*)c{
    UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Supprimer ?" message:[WRL10n t:@"deleteConfirm"] preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Supprimer" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*_){ BOOL wasActive=[c.containerID isEqualToString:WRContainerStore.shared.activeContainer.containerID]; [WRContainerStore.shared deleteContainerID:c.containerID]; [self reloadHeader]; [self.table reloadData]; if(wasActive){ UIAlertController *b=[UIAlertController alertControllerWithTitle:@"Container supprimé" message:@"Relance pour revenir à l'app principale." preferredStyle:UIAlertControllerStyleAlert]; [b addAction:[UIAlertAction actionWithTitle:@"Relancer" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ [WRAppRelaunch relaunch]; }]]; [b addAction:[UIAlertAction actionWithTitle:@"Plus tard" style:UIAlertActionStyleCancel handler:nil]]; [self presentViewController:b animated:YES completion:nil]; }}]];
    [a addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (UISwipeActionsConfiguration*)tableView:(UITableView*)tv trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath*)ip{
    WRContainer *c=WRContainerStore.shared.allContainers[ip.row];
    UIContextualAction *del=[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Supprimer" handler:^(UIContextualAction*a,UIView*v,void(^comp)(BOOL)){ [self confirmDelete:c]; comp(NO); }];
    UIContextualAction *loc=[UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"📍" handler:^(UIContextualAction*a,UIView*v,void(^comp)(BOOL)){ [self changeLocationFor:c]; comp(NO); }];
    loc.backgroundColor=WRTheme.accent;
    return [UISwipeActionsConfiguration configurationWithActions:@[del, loc]];
}
@end
