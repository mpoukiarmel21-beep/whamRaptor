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
@end
@implementation WRPanelVC
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor=WRTheme.bg;
    // Nav bar premium
    self.title=@"WhamRaptor";
    UINavigationBarAppearance *app=[UINavigationBarAppearance new];
    [app configureWithOpaqueBackground]; app.backgroundColor=WRTheme.bg; app.titleTextAttributes=@{NSForegroundColorAttributeName: WRTheme.text};
    self.navigationController.navigationBar.standardAppearance=app;
    self.navigationController.navigationBar.scrollEdgeAppearance=app;
    self.navigationController.navigationBar.tintColor=WRTheme.accent;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Fermer" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"＋ Nouveau" style:UIBarButtonItemStylePlain target:self action:@selector(newContainer)];

    // Header as section, not tableHeaderView (so it scrolls correctly with AutoLayout)
    self.table=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.table.backgroundColor=WRTheme.bg;
    self.table.separatorColor=WRTheme.border;
    self.table.delegate=self; self.table.dataSource=self;
    self.table.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:self.table];
    [NSLayoutConstraint activateConstraints:@[
        [self.table.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.table.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.table.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.table.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    // Pull to refresh (optional but nice)
    self.table.refreshControl=[UIRefreshControl new];
    self.table.refreshControl.tintColor=WRTheme.accent;
    [self.table.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}
- (void)refresh{ [self.table reloadData]; [self.table.refreshControl endRefreshing]; }
- (void)viewWillAppear:(BOOL)a{ [super viewWillAppear:a]; [self.table reloadData]; }
- (void)done{ [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)newContainer{
    WRCreateVC *vc=[WRCreateVC new];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

// MARK: DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tv{ return 2; }
- (NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)s{
    if (s==0) return 1; // header card
    return MAX(1, (NSInteger)WRContainerStore.shared.allContainers.count);
}
- (NSString*)tableView:(UITableView*)tv titleForHeaderInSection:(NSInteger)s{
    return s==0 ? nil : @"Containers  •  tap pour activer (relance)";
}
- (UIView*)tableView:(UITableView*)tv viewForHeaderInSection:(NSInteger)s{
    if (s==0) return nil;
    UILabel *l=[UILabel new]; l.text=@"  Containers  •  tap pour activer (relance)"; l.font=WRTheme.captionFont; l.textColor=WRTheme.muted;
    UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0,0,tv.bounds.size.width,28)]; v.backgroundColor=UIColor.clearColor;
    l.frame=CGRectMake(16,4,v.bounds.size.width-32,20); l.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [v addSubview:l]; return v;
}
- (CGFloat)tableView:(UITableView*)tv heightForHeaderInSection:(NSInteger)s{ return s==0? 12 : 30; }
- (CGFloat)tableView:(UITableView*)tv heightForFooterInSection:(NSInteger)s{ return 6; }

- (UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)ip{
    if (ip.section==0){
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.backgroundColor=WRTheme.card;
        cell.layer.cornerRadius=12; cell.clipsToBounds=YES;
        WRContainer *active=WRContainerStore.shared.activeContainer;
        NSArray *all=WRContainerStore.shared.allContainers;
        cell.textLabel.textColor=WRTheme.text; cell.textLabel.font=WRTheme.bodyBoldFont;
        cell.detailTextLabel.textColor=WRTheme.subtext; cell.detailTextLabel.font=WRTheme.smallFont;
        if (active){
            cell.textLabel.text=[NSString stringWithFormat:@"● Actif : %@", active.name];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@  •  %@ compte(s) isolé(s)", active.displaySubtitle?:(active.hasLocation?active.location.city:@"—"), @(all.count)];
        } else {
            cell.textLabel.text=@"App principale (aucun container actif)";
            cell.detailTextLabel.text=all.count? [NSString stringWithFormat:@"%lu container(s) prêts — choisis-en un", (unsigned long)all.count] : @"Crée ton premier container ci-dessus";
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryNone;
        return cell;
    }
    NSArray *all=WRContainerStore.shared.allContainers;
    if (!all.count){
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.backgroundColor=WRTheme.card; cell.textLabel.textColor=WRTheme.muted; cell.textLabel.font=WRTheme.bodyFont;
        cell.textLabel.text=@"Aucun container — tape ＋ Nouveau"; cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    WRContainer *c=all[ip.row];
    BOOL isActive=[c.containerID isEqualToString:WRContainerStore.shared.activeContainer.containerID];
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.backgroundColor=isActive ? WRTheme.cardSel : WRTheme.card;
    cell.layer.cornerRadius=12; cell.clipsToBounds=YES;
    cell.textLabel.textColor=WRTheme.text; cell.textLabel.font=WRTheme.bodyBoldFont;
    cell.detailTextLabel.textColor=WRTheme.subtext; cell.detailTextLabel.font=WRTheme.smallFont;
    cell.detailTextLabel.numberOfLines=2;
    NSString *badge=isActive ? @"● ACTIF  " : @"";
    cell.textLabel.text=[NSString stringWithFormat:@"%@%@", badge, c.name];
    NSString *loc=c.hasLocation ? [NSString stringWithFormat:@"📍 %@, %@  •  %@ / %@", c.location.city, c.location.countryCode, c.location.timezoneName, c.location.languageCode] : @"📍 Aucune localisation — GPS réel";
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@\n%@", c.displaySubtitle.length?c.displaySubtitle:loc, isActive? @"Tap pour options" : @"Tap pour activer"];
    cell.accessoryType=isActive ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryDisclosureIndicator;
    cell.tintColor=WRTheme.accent;
    return cell;
}
- (CGFloat)tableView:(UITableView*)tv heightForRowAtIndexPath:(NSIndexPath*)ip{
    return ip.section==0 ? 72 : 74;
}
- (void)tableView:(UITableView*)tv didSelectRowAtIndexPath:(NSIndexPath*)ip{
    [tv deselectRowAtIndexPath:ip animated:YES];
    if (ip.section==0) return;
    NSArray *all=WRContainerStore.shared.allContainers; if (!all.count) { [self newContainer]; return; }
    WRContainer *c=all[ip.row];
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
    UIAlertController *a=[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Activer %@ ?", c.name] message:@"L'app va se relancer avec le stockage isolé de ce container (nouveau appareil)." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Activer & relancer" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ [WRContainerStore.shared setActiveContainerID:c.containerID]; [WRAppRelaunch relaunch]; }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)changeLocationFor:(WRContainer*)c{
    WRMapPickerVC *vc=[WRMapPickerVC new];
    __weak typeof(self) w=self;
    vc.onPick=^(WRLocation *loc){ c.location=loc; c.hasLocation=YES; [WRContainerStore.shared updateContainer:c]; [w.table reloadData]; };
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)wr_rename:(WRContainer*)c{
    UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Renommer" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField*f){ f.text=c.name; f.clearButtonMode=UITextFieldViewModeWhileEditing; }];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ NSString*t=a.textFields.firstObject.text; if(t.length){ c.name=t; [WRContainerStore.shared updateContainer:c]; [self.table reloadData]; }}]];
    [a addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)confirmDelete:(WRContainer*)c{
    UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Supprimer ?" message:[WRL10n t:@"deleteConfirm"] preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Supprimer" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*_){
        BOOL wasActive=[c.containerID isEqualToString:WRContainerStore.shared.activeContainer.containerID];
        [WRContainerStore.shared deleteContainerID:c.containerID]; [self.table reloadData];
        if(wasActive){
            UIAlertController *b=[UIAlertController alertControllerWithTitle:@"Container supprimé" message:@"Relance pour revenir à l'app principale (Instagram propre)." preferredStyle:UIAlertControllerStyleAlert];
            [b addAction:[UIAlertAction actionWithTitle:@"Relancer" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ [WRAppRelaunch relaunch]; }]];
            [b addAction:[UIAlertAction actionWithTitle:@"Plus tard" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:b animated:YES completion:nil];
        }
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (UISwipeActionsConfiguration*)tableView:(UITableView*)tv trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath*)ip{
    if (ip.section==0) return nil;
    NSArray *all=WRContainerStore.shared.allContainers; if (!all.count) return nil;
    WRContainer *c=all[ip.row];
    UIContextualAction *del=[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Supprimer" handler:^(UIContextualAction*a,UIView*v,void(^comp)(BOOL)){ [self confirmDelete:c]; comp(NO); }];
    UIContextualAction *loc=[UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"📍 Localisation" handler:^(UIContextualAction*a,UIView*v,void(^comp)(BOOL)){ [self changeLocationFor:c]; comp(NO); }];
    loc.backgroundColor=WRTheme.accent;
    return [UISwipeActionsConfiguration configurationWithActions:@[del, loc]];
}
@end
