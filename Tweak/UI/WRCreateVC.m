#import "WRCreateVC.h"
#import "WRTheme.h"
#import "WRContainerStore.h"
#import "WRMapPickerVC.h"
#import "WRAppRelaunch.h"
@interface WRCreateVC ()
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) WRLocation *pickedLocation;
@end
@implementation WRCreateVC
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title=@"Nouveau container"; self.view.backgroundColor=WRTheme.bg;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Créer" style:UIBarButtonItemStyleDone target:self action:@selector(create)];

    UILabel *hint=[[UILabel alloc] initWithFrame:CGRectMake(16, 100, self.view.bounds.size.width-32, 40)];
    hint.text=@"Chaque container = appareil + stockage isolé.\nNombre illimité."; hint.numberOfLines=2; hint.textColor=WRTheme.subtext; hint.font=WRTheme.smallFont;
    hint.autoresizingMask=UIViewAutoresizingFlexibleWidth; [self.view addSubview:hint];

    self.nameField=[[UITextField alloc] initWithFrame:CGRectMake(16, 150, self.view.bounds.size.width-32, 44)];
    self.nameField.placeholder=@"Nom du container (ex: Paris 1)"; self.nameField.borderStyle=UITextBorderStyleRoundedRect;
    self.nameField.backgroundColor=WRTheme.card; self.nameField.textColor=WRTheme.text; self.nameField.attributedPlaceholder=[[NSAttributedString alloc] initWithString:self.nameField.placeholder attributes:@{NSForegroundColorAttributeName: WRTheme.subtext}];
    self.nameField.autoresizingMask=UIViewAutoresizingFlexibleWidth; [self.view addSubview:self.nameField];

    UIButton *locBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    locBtn.frame=CGRectMake(16, 210, self.view.bounds.size.width-32, 44);
    locBtn.backgroundColor=WRTheme.card; [locBtn setTitle:@"📍 Choisir localisation (carte monde)" forState:UIControlStateNormal];
    [locBtn setTitleColor:WRTheme.accent forState:UIControlStateNormal]; locBtn.layer.cornerRadius=10; locBtn.clipsToBounds=YES;
    locBtn.autoresizingMask=UIViewAutoresizingFlexibleWidth; [locBtn addTarget:self action:@selector(pickLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locBtn];

    self.locationLabel=[[UILabel alloc] initWithFrame:CGRectMake(16, 262, self.view.bounds.size.width-32, 36)];
    self.locationLabel.text=@"Aucune localisation — GPS réel utilisé"; self.locationLabel.textColor=WRTheme.subtext; self.locationLabel.font=WRTheme.smallFont; self.locationLabel.numberOfLines=2; self.locationLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.locationLabel];
}
- (void)cancel{ [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)pickLocation{
    WRMapPickerVC *vc=[WRMapPickerVC new];
    __weak typeof(self) w=self;
    vc.onPick=^(WRLocation *loc){ w.pickedLocation=loc; w.locationLabel.text=[NSString stringWithFormat:@"%@, %@ — %@ / %@ (%.3f, %.3f)", loc.city, loc.countryCode, loc.timezoneName, loc.languageCode, loc.latitude, loc.longitude]; w.locationLabel.textColor=WRTheme.text; };
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)create{
    NSString *name=self.nameField.text;
    if (!name.length) name=[NSString stringWithFormat:@"Container %lu",(unsigned long)WRContainerStore.shared.allContainers.count+1];
    WRContainer *c=[WRContainerStore.shared createContainerWithName:name];
    if (self.pickedLocation){ c.location=self.pickedLocation; c.hasLocation=YES; [WRContainerStore.shared updateContainer:c]; }
    [WRContainerStore.shared setActiveContainerID:c.containerID];
    UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Container créé" message:[NSString stringWithFormat:@"%@ — %@\nRelance pour activer l'isolation.", c.name, c.displaySubtitle] preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Relancer maintenant" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ [self dismissViewControllerAnimated:YES completion:^{ [WRAppRelaunch relaunch]; }]; }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Plus tard" style:UIAlertActionStyleCancel handler:^(UIAlertAction*_){ [self dismissViewControllerAnimated:YES completion:nil]; }]];
    [self presentViewController:a animated:YES completion:nil];
}
@end
