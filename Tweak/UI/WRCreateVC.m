#import "WRCreateVC.h"
#import "WRTheme.h"
#import "WRContainerStore.h"
#import "WRMapPickerVC.h"
#import "WRAppRelaunch.h"

@interface WRCreateVC ()
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UIView *locationCard;
@property (nonatomic, strong) WRLocation *pickedLocation;
@end
@implementation WRCreateVC
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor=WRTheme.bg;
    UINavigationBarAppearance *app=[UINavigationBarAppearance new];
    [app configureWithOpaqueBackground]; app.backgroundColor=WRTheme.bg; app.titleTextAttributes=@{NSForegroundColorAttributeName: WRTheme.text};
    self.navigationController.navigationBar.standardAppearance=app;
    self.navigationController.navigationBar.scrollEdgeAppearance=app;
    self.navigationController.navigationBar.tintColor=WRTheme.accent;
    self.title=@"Nouveau container";
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Annuler" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Créer" style:UIBarButtonItemStyleDone target:self action:@selector(create)];

    UIScrollView *sv=[[UIScrollView alloc] initWithFrame:self.view.bounds]; sv.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    sv.backgroundColor=WRTheme.bg; sv.keyboardDismissMode=UIScrollViewKeyboardDismissModeInteractive;
    sv.contentInset=UIEdgeInsetsMake(0,0,24,0);
    [self.view addSubview:sv];

    UILabel *hint=[[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.view.bounds.size.width-32, 36)];
    hint.text=@"Chaque container = nouvel appareil isolé.\nNombre illimité — comptes séparés."; hint.numberOfLines=2;
    hint.textColor=WRTheme.subtext; hint.font=WRTheme.smallFont; hint.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [sv addSubview:hint];

    UILabel *nameTitle=[[UILabel alloc] initWithFrame:CGRectMake(16, 60, self.view.bounds.size.width-32, 18)];
    nameTitle.text=@"NOM DU CONTAINER"; nameTitle.font=WRTheme.captionFont; nameTitle.textColor=WRTheme.muted;
    nameTitle.autoresizingMask=UIViewAutoresizingFlexibleWidth; [sv addSubview:nameTitle];

    UIView *fieldWrap=[[UIView alloc] initWithFrame:CGRectMake(16, 82, self.view.bounds.size.width-32, 48)];
    fieldWrap.backgroundColor=WRTheme.card; fieldWrap.layer.cornerRadius=12; fieldWrap.clipsToBounds=YES;
    fieldWrap.layer.borderColor=WRTheme.border.CGColor; fieldWrap.layer.borderWidth=1; fieldWrap.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    self.nameField=[[UITextField alloc] initWithFrame:CGRectMake(14, 0, fieldWrap.bounds.size.width-28, 48)];
    self.nameField.placeholder=@"Ex: Paris 1, Tokyo FR…"; self.nameField.textColor=WRTheme.text; self.nameField.font=WRTheme.bodyFont;
    self.nameField.attributedPlaceholder=[[NSAttributedString alloc] initWithString:@"Ex: Paris 1, Tokyo FR…" attributes:@{NSForegroundColorAttributeName: WRTheme.muted}];
    self.nameField.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; self.nameField.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.nameField.returnKeyType=UIReturnKeyDone; self.nameField.delegate=(id)self;
    [fieldWrap addSubview:self.nameField]; [sv addSubview:fieldWrap];

    UIButton *locBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    locBtn.frame=CGRectMake(16, 146, self.view.bounds.size.width-32, 48);
    locBtn.backgroundColor=WRTheme.card; locBtn.layer.cornerRadius=12; locBtn.clipsToBounds=YES;
    locBtn.layer.borderColor=WRTheme.accent.CGColor; locBtn.layer.borderWidth=1.2;
    locBtn.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [locBtn setTitle:@"  📍  Choisir localisation  —  carte monde" forState:UIControlStateNormal];
    [locBtn setTitleColor:WRTheme.accent forState:UIControlStateNormal]; locBtn.titleLabel.font=WRTheme.bodyBoldFont;
    [locBtn addTarget:self action:@selector(pickLocation) forControlEvents:UIControlEventTouchUpInside];
    [sv addSubview:locBtn];

    self.locationCard=[[UIView alloc] initWithFrame:CGRectMake(16, 206, self.view.bounds.size.width-32, 56)];
    self.locationCard.backgroundColor=[WRTheme.card colorWithAlphaComponent:0.95];
    self.locationCard.layer.cornerRadius=12; self.locationCard.clipsToBounds=YES;
    self.locationCard.layer.borderColor=WRTheme.border.CGColor; self.locationCard.layer.borderWidth=1;
    self.locationCard.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    self.locationLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 8, self.locationCard.bounds.size.width-24, 40)];
    self.locationLabel.text=@"Aucune localisation — GPS réel utilisé"; self.locationLabel.textColor=WRTheme.muted;
    self.locationLabel.font=WRTheme.smallFont; self.locationLabel.numberOfLines=2;
    self.locationLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.locationCard addSubview:self.locationLabel]; [sv addSubview:self.locationCard];

    UILabel *foot=[[UILabel alloc] initWithFrame:CGRectMake(16, 276, self.view.bounds.size.width-32, 34)];
    foot.text=@"Tu pourras changer la ville plus tard depuis le panel."; foot.font=WRTheme.captionFont; foot.textColor=WRTheme.muted;
    foot.numberOfLines=2; foot.autoresizingMask=UIViewAutoresizingFlexibleWidth; [sv addSubview:foot];
    sv.contentSize=CGSizeMake(self.view.bounds.size.width, 330);
    [self.nameField becomeFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField*)tf{ [tf resignFirstResponder]; return YES; }
- (void)cancel{ [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)pickLocation{
    [self.nameField resignFirstResponder];
    WRMapPickerVC *vc=[WRMapPickerVC new];
    __weak typeof(self) w=self;
    vc.onPick=^(WRLocation *loc){
        w.pickedLocation=loc;
        w.locationLabel.text=[NSString stringWithFormat:@"📍 %@, %@  •  %@ / %@", loc.city, loc.countryCode, loc.timezoneName, loc.languageCode];
        w.locationLabel.textColor=WRTheme.text;
        w.locationCard.layer.borderColor=WRTheme.accent.CGColor;
    };
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)create{
    [self.nameField resignFirstResponder];
    NSString *name=[self.nameField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!name.length) name=[NSString stringWithFormat:@"Container %lu",(unsigned long)WRContainerStore.shared.allContainers.count+1];
    WRContainer *c=[WRContainerStore.shared createContainerWithName:name];
    if (self.pickedLocation){ c.location=self.pickedLocation; c.hasLocation=YES; [WRContainerStore.shared updateContainer:c]; }
    [WRContainerStore.shared setActiveContainerID:c.containerID];
    UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Container créé" message:[NSString stringWithFormat:@"%@\n%@\n\nRelance pour activer l'isolation (nouvel appareil).", c.name, c.displaySubtitle?:(c.hasLocation?c.location.city:@"Appareil propre")] preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Relancer maintenant" style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ [self dismissViewControllerAnimated:YES completion:^{ [WRAppRelaunch relaunch]; }]; }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Plus tard" style:UIAlertActionStyleCancel handler:^(UIAlertAction*_){ [self dismissViewControllerAnimated:YES completion:nil]; }]];
    [self presentViewController:a animated:YES completion:nil];
}
@end
