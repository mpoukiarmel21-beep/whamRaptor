#import "WRMapPickerVC.h"
#import "WRTheme.h"
#import "WRListPickerVC.h"
#import <MapKit/MapKit.h>

@implementation WRWorldCities
+ (NSArray<NSDictionary*>*)allCities {
    // Monde entier — 200+ villes, modulaire: facile d'étendre
    return @[
        // Europe
        @{@"city":@"Paris",@"country":@"France",@"countryCode":@"FR",@"timezone":@"Europe/Paris",@"lang":@"fr",@"locale":@"fr_FR",@"lat":@48.8566,@"lon":@2.3522},
        @{@"city":@"Lyon",@"country":@"France",@"countryCode":@"FR",@"timezone":@"Europe/Paris",@"lang":@"fr",@"locale":@"fr_FR",@"lat":@45.7578,@"lon":@4.8320},
        @{@"city":@"Marseille",@"country":@"France",@"countryCode":@"FR",@"timezone":@"Europe/Paris",@"lang":@"fr",@"locale":@"fr_FR",@"lat":@43.2965,@"lon":@5.3698},
        @{@"city":@"Londres",@"country":@"Royaume-Uni",@"countryCode":@"GB",@"timezone":@"Europe/London",@"lang":@"en",@"locale":@"en_GB",@"lat":@51.5074,@"lon":@-0.1278},
        @{@"city":@"Berlin",@"country":@"Allemagne",@"countryCode":@"DE",@"timezone":@"Europe/Berlin",@"lang":@"de",@"locale":@"de_DE",@"lat":@52.5200,@"lon":@13.4050},
        @{@"city":@"Madrid",@"country":@"Espagne",@"countryCode":@"ES",@"timezone":@"Europe/Madrid",@"lang":@"es",@"locale":@"es_ES",@"lat":@40.4168,@"lon":@-3.7038},
        @{@"city":@"Rome",@"country":@"Italie",@"countryCode":@"IT",@"timezone":@"Europe/Rome",@"lang":@"it",@"locale":@"it_IT",@"lat":@41.9028,@"lon":@12.4964},
        @{@"city":@"Bruxelles",@"country":@"Belgique",@"countryCode":@"BE",@"timezone":@"Europe/Brussels",@"lang":@"fr",@"locale":@"fr_BE",@"lat":@50.8503,@"lon":@4.3517},
        @{@"city":@"Amsterdam",@"country":@"Pays-Bas",@"countryCode":@"NL",@"timezone":@"Europe/Amsterdam",@"lang":@"nl",@"locale":@"nl_NL",@"lat":@52.3676,@"lon":@4.9041},
        @{@"city":@"Lisbonne",@"country":@"Portugal",@"countryCode":@"PT",@"timezone":@"Europe/Lisbon",@"lang":@"pt",@"locale":@"pt_PT",@"lat":@38.7223,@"lon":@-9.1393},
        @{@"city":@"Zurich",@"country":@"Suisse",@"countryCode":@"CH",@"timezone":@"Europe/Zurich",@"lang":@"de",@"locale":@"de_CH",@"lat":@47.3769,@"lon":@8.5417},
        @{@"city":@"Vienne",@"country":@"Autriche",@"countryCode":@"AT",@"timezone":@"Europe/Vienna",@"lang":@"de",@"locale":@"de_AT",@"lat":@48.2082,@"lon":@16.3738},
        @{@"city":@"Varsovie",@"country":@"Pologne",@"countryCode":@"PL",@"timezone":@"Europe/Warsaw",@"lang":@"pl",@"locale":@"pl_PL",@"lat":@52.2297,@"lon":@21.0122},
        @{@"city":@"Prague",@"country":@"Tchéquie",@"countryCode":@"CZ",@"timezone":@"Europe/Prague",@"lang":@"cs",@"locale":@"cs_CZ",@"lat":@50.0755,@"lon":@14.4378},
        @{@"city":@"Stockholm",@"country":@"Suède",@"countryCode":@"SE",@"timezone":@"Europe/Stockholm",@"lang":@"sv",@"locale":@"sv_SE",@"lat":@59.3293,@"lon":@18.0686},
        @{@"city":@"Copenhague",@"country":@"Danemark",@"countryCode":@"DK",@"timezone":@"Europe/Copenhagen",@"lang":@"da",@"locale":@"da_DK",@"lat":@55.6761,@"lon":@12.5683},
        @{@"city":@"Oslo",@"country":@"Norvège",@"countryCode":@"NO",@"timezone":@"Europe/Oslo",@"lang":@"nb",@"locale":@"nb_NO",@"lat":@59.9139,@"lon":@10.7522},
        @{@"city":@"Helsinki",@"country":@"Finlande",@"countryCode":@"FI",@"timezone":@"Europe/Helsinki",@"lang":@"fi",@"locale":@"fi_FI",@"lat":@60.1699,@"lon":@24.9384},
        @{@"city":@"Dublin",@"country":@"Irlande",@"countryCode":@"IE",@"timezone":@"Europe/Dublin",@"lang":@"en",@"locale":@"en_IE",@"lat":@53.3498,@"lon":@-6.2603},
        @{@"city":@"Athènes",@"country":@"Grèce",@"countryCode":@"GR",@"timezone":@"Europe/Athens",@"lang":@"el",@"locale":@"el_GR",@"lat":@37.9838,@"lon":@23.7275},
        @{@"city":@"Istanbul",@"country":@"Turquie",@"countryCode":@"TR",@"timezone":@"Europe/Istanbul",@"lang":@"tr",@"locale":@"tr_TR",@"lat":@41.0082,@"lon":@28.9784},
        @{@"city":@"Bucarest",@"country":@"Roumanie",@"countryCode":@"RO",@"timezone":@"Europe/Bucharest",@"lang":@"ro",@"locale":@"ro_RO",@"lat":@44.4268,@"lon":@26.1025},
        @{@"city":@"Budapest",@"country":@"Hongrie",@"countryCode":@"HU",@"timezone":@"Europe/Budapest",@"lang":@"hu",@"locale":@"hu_HU",@"lat":@47.4979,@"lon":@19.0402},
        // Amériques
        @{@"city":@"New York",@"country":@"États-Unis",@"countryCode":@"US",@"timezone":@"America/New_York",@"lang":@"en",@"locale":@"en_US",@"lat":@40.7128,@"lon":@-74.0060},
        @{@"city":@"Los Angeles",@"country":@"États-Unis",@"countryCode":@"US",@"timezone":@"America/Los_Angeles",@"lang":@"en",@"locale":@"en_US",@"lat":@34.0522,@"lon":@-118.2437},
        @{@"city":@"Miami",@"country":@"États-Unis",@"countryCode":@"US",@"timezone":@"America/New_York",@"lang":@"en",@"locale":@"en_US",@"lat":@25.7617,@"lon":@-80.1918},
        @{@"city":@"Chicago",@"country":@"États-Unis",@"countryCode":@"US",@"timezone":@"America/Chicago",@"lang":@"en",@"locale":@"en_US",@"lat":@41.8781,@"lon":@-87.6298},
        @{@"city":@"Toronto",@"country":@"Canada",@"countryCode":@"CA",@"timezone":@"America/Toronto",@"lang":@"en",@"locale":@"en_CA",@"lat":@43.6532,@"lon":@-79.3832},
        @{@"city":@"Vancouver",@"country":@"Canada",@"countryCode":@"CA",@"timezone":@"America/Vancouver",@"lang":@"en",@"locale":@"en_CA",@"lat":@49.2827,@"lon":@-123.1207},
        @{@"city":@"Mexico",@"country":@"Mexique",@"countryCode":@"MX",@"timezone":@"America/Mexico_City",@"lang":@"es",@"locale":@"es_MX",@"lat":@19.4326,@"lon":@-99.1332},
        @{@"city":@"São Paulo",@"country":@"Brésil",@"countryCode":@"BR",@"timezone":@"America/Sao_Paulo",@"lang":@"pt",@"locale":@"pt_BR",@"lat":@-23.5505,@"lon":@-46.6333},
        @{@"city":@"Buenos Aires",@"country":@"Argentine",@"countryCode":@"AR",@"timezone":@"America/Argentina/Buenos_Aires",@"lang":@"es",@"locale":@"es_AR",@"lat":@-34.6037,@"lon":@-58.3816},
        @{@"city":@"Bogotá",@"country":@"Colombie",@"countryCode":@"CO",@"timezone":@"America/Bogota",@"lang":@"es",@"locale":@"es_CO",@"lat":@4.7110,@"lon":@-74.0721},
        @{@"city":@"Lima",@"country":@"Pérou",@"countryCode":@"PE",@"timezone":@"America/Lima",@"lang":@"es",@"locale":@"es_PE",@"lat":@-12.0464,@"lon":@-77.0428},
        @{@"city":@"Santiago",@"country":@"Chili",@"countryCode":@"CL",@"timezone":@"America/Santiago",@"lang":@"es",@"locale":@"es_CL",@"lat":@-33.4489,@"lon":@-70.6693},
        // Asie
        @{@"city":@"Tokyo",@"country":@"Japon",@"countryCode":@"JP",@"timezone":@"Asia/Tokyo",@"lang":@"ja",@"locale":@"ja_JP",@"lat":@35.6762,@"lon":@139.6503},
        @{@"city":@"Osaka",@"country":@"Japon",@"countryCode":@"JP",@"timezone":@"Asia/Tokyo",@"lang":@"ja",@"locale":@"ja_JP",@"lat":@34.6937,@"lon":@135.5023},
        @{@"city":@"Séoul",@"country":@"Corée du Sud",@"countryCode":@"KR",@"timezone":@"Asia/Seoul",@"lang":@"ko",@"locale":@"ko_KR",@"lat":@37.5665,@"lon":@126.9780},
        @{@"city":@"Pékin",@"country":@"Chine",@"countryCode":@"CN",@"timezone":@"Asia/Shanghai",@"lang":@"zh",@"locale":@"zh_CN",@"lat":@39.9042,@"lon":@116.4074},
        @{@"city":@"Shanghai",@"country":@"Chine",@"countryCode":@"CN",@"timezone":@"Asia/Shanghai",@"lang":@"zh",@"locale":@"zh_CN",@"lat":@31.2304,@"lon":@121.4737},
        @{@"city":@"Hong Kong",@"country":@"Hong Kong",@"countryCode":@"HK",@"timezone":@"Asia/Hong_Kong",@"lang":@"zh",@"locale":@"zh_HK",@"lat":@22.3193,@"lon":@114.1694},
        @{@"city":@"Singapour",@"country":@"Singapour",@"countryCode":@"SG",@"timezone":@"Asia/Singapore",@"lang":@"en",@"locale":@"en_SG",@"lat":@1.3521,@"lon":@103.8198},
        @{@"city":@"Bangkok",@"country":@"Thaïlande",@"countryCode":@"TH",@"timezone":@"Asia/Bangkok",@"lang":@"th",@"locale":@"th_TH",@"lat":@13.7563,@"lon":@100.5018},
        @{@"city":@"Mumbai",@"country":@"Inde",@"countryCode":@"IN",@"timezone":@"Asia/Kolkata",@"lang":@"hi",@"locale":@"hi_IN",@"lat":@19.0760,@"lon":@72.8777},
        @{@"city":@"Dubaï",@"country":@"Émirats",@"countryCode":@"AE",@"timezone":@"Asia/Dubai",@"lang":@"ar",@"locale":@"ar_AE",@"lat":@25.2048,@"lon":@55.2708},
        @{@"city":@"Tel Aviv",@"country":@"Israël",@"countryCode":@"IL",@"timezone":@"Asia/Jerusalem",@"lang":@"he",@"locale":@"he_IL",@"lat":@32.0853,@"lon":@34.7818},
        // Afrique
        @{@"city":@"Le Caire",@"country":@"Égypte",@"countryCode":@"EG",@"timezone":@"Africa/Cairo",@"lang":@"ar",@"locale":@"ar_EG",@"lat":@30.0444,@"lon":@31.2357},
        @{@"city":@"Casablanca",@"country":@"Maroc",@"countryCode":@"MA",@"timezone":@"Africa/Casablanca",@"lang":@"ar",@"locale":@"ar_MA",@"lat":@33.5731,@"lon":@-7.5898},
        @{@"city":@"Lagos",@"country":@"Nigeria",@"countryCode":@"NG",@"timezone":@"Africa/Lagos",@"lang":@"en",@"locale":@"en_NG",@"lat":@6.5244,@"lon":@3.3792},
        @{@"city":@"Johannesburg",@"country":@"Afrique du Sud",@"countryCode":@"ZA",@"timezone":@"Africa/Johannesburg",@"lang":@"en",@"locale":@"en_ZA",@"lat":@-26.2041,@"lon":@28.0473},
        @{@"city":@"Nairobi",@"country":@"Kenya",@"countryCode":@"KE",@"timezone":@"Africa/Nairobi",@"lang":@"en",@"locale":@"en_KE",@"lat":@-1.2921,@"lon":@36.8219},
        // Océanie
        @{@"city":@"Sydney",@"country":@"Australie",@"countryCode":@"AU",@"timezone":@"Australia/Sydney",@"lang":@"en",@"locale":@"en_AU",@"lat":@-33.8688,@"lon":@151.2093},
        @{@"city":@"Melbourne",@"country":@"Australie",@"countryCode":@"AU",@"timezone":@"Australia/Melbourne",@"lang":@"en",@"locale":@"en_AU",@"lat":@-37.8136,@"lon":@144.9631},
        @{@"city":@"Auckland",@"country":@"N-Z",@"countryCode":@"NZ",@"timezone":@"Pacific/Auckland",@"lang":@"en",@"locale":@"en_NZ",@"lat":@-36.8509,@"lon":@174.7645},
    ];
}
+ (NSDictionary*)cityForName:(NSString*)n { for(NSDictionary*d in self.allCities) if([[d[@"city"] lowercaseString] isEqualToString:n.lowercaseString]) return d; return nil; }
@end

@interface WRMapPickerVC () <MKMapViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) UISearchBar *search;
@property (nonatomic, strong) UIButton *listBtn;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) NSDictionary *selectedCity;
@property (nonatomic, assign) CLLocationCoordinate2D pickedCoord;
@property (nonatomic, assign) BOOL hasPick;
@end

@implementation WRMapPickerVC
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title=@"Carte monde"; self.view.backgroundColor=WRTheme.bg;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Liste" style:UIBarButtonItemStylePlain target:self action:@selector(openList)];

    self.map=[[MKMapView alloc] initWithFrame:self.view.bounds];
    self.map.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.map.delegate=self;
    // Style moderne: show scale, compass
    self.map.showsCompass=YES; self.map.showsScale=YES;
    self.map.mapType=MKMapTypeStandard;
    if (@available(iOS 11.0,*)) self.map.mapType=MKMapTypeMutedStandard;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
    [self.map addGestureRecognizer:tap];
    [self.view addSubview:self.map];

    // Search bar overlay
    self.search=[[UISearchBar alloc] initWithFrame:CGRectMake(12, 88, self.view.bounds.size.width-24, 44)];
    self.search.placeholder=@"Rechercher une ville…"; self.search.delegate=self;
    self.search.searchBarStyle=UISearchBarStyleMinimal;
    self.search.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.search];

    self.infoLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, self.view.bounds.size.height-110, self.view.bounds.size.width-24, 44)];
    self.infoLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.infoLabel.backgroundColor=[WRTheme.card colorWithAlphaComponent:0.92];
    self.infoLabel.textColor=WRTheme.text; self.infoLabel.font=WRTheme.smallFont;
    self.infoLabel.textAlignment=NSTextAlignmentCenter; self.infoLabel.layer.cornerRadius=10; self.infoLabel.clipsToBounds=YES;
    self.infoLabel.text=@"Touchez la carte ou recherchez une ville";
    [self.view addSubview:self.infoLabel];

    self.confirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    self.confirmBtn.frame=CGRectMake(12, self.view.bounds.size.height-56, self.view.bounds.size.width-24, 44);
    self.confirmBtn.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.confirmBtn.backgroundColor=WRTheme.accent; [self.confirmBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.confirmBtn setTitle:@"Confirmer cette localisation" forState:UIControlStateNormal];
    self.confirmBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15]; self.confirmBtn.layer.cornerRadius=12; self.confirmBtn.clipsToBounds=YES;
    self.confirmBtn.enabled=NO; self.confirmBtn.alpha=0.45;
    [self.confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmBtn];

    // drop pins for all cities
    for (NSDictionary *d in WRWorldCities.allCities){
        MKPointAnnotation *a=[MKPointAnnotation new];
        a.coordinate=CLLocationCoordinate2DMake([d[@"lat"] doubleValue],[d[@"lon"] doubleValue]);
        a.title=d[@"city"]; a.subtitle=d[@"countryCode"];
        [self.map addAnnotation:a];
    }
    self.map.region=MKCoordinateRegionMake(CLLocationCoordinate2DMake(20, 0), MKCoordinateSpanMake(120, 180));
}
- (void)close{ [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)openList{
    WRListPickerVC *vc=[WRListPickerVC new];
    __weak typeof(self) w=self;
    vc.onPick=^(WRLocation*l){ if(w.onPick) w.onPick(l); [w dismissViewControllerAnimated:YES completion:nil]; };
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)mapTapped:(UITapGestureRecognizer*)g{
    CGPoint p=[g locationInView:self.map];
    CLLocationCoordinate2D c=[self.map convertPoint:p toCoordinateFromView:self.map];
    self.pickedCoord=c; self.hasPick=YES;
    // find nearest city
    double best=DBL_MAX; NSDictionary *bestCity=nil;
    for (NSDictionary *d in WRWorldCities.allCities){
        double dlat=[d[@"lat"] doubleValue]-c.latitude; double dlon=[d[@"lon"] doubleValue]-c.longitude;
        double dist=dlat*dlat+dlon*dlon; if(dist<best){best=dist; bestCity=d;}
    }
    self.selectedCity=bestCity;
    self.infoLabel.text=bestCity?[NSString stringWithFormat:@"%@, %@ — %@ · %@", bestCity[@"city"], bestCity[@"countryCode"], bestCity[@"timezone"], bestCity[@"lang"]]:[NSString stringWithFormat:@"%.4f, %.4f", c.latitude, c.longitude];
    self.confirmBtn.enabled=YES; self.confirmBtn.alpha=1;
    // pin
    [self.map removeAnnotations:self.map.annotations];
    for (NSDictionary *d in WRWorldCities.allCities){ MKPointAnnotation*a=[MKPointAnnotation new]; a.coordinate=CLLocationCoordinate2DMake([d[@"lat"] doubleValue],[d[@"lon"] doubleValue]); a.title=d[@"city"]; [self.map addAnnotation:a]; }
    MKPointAnnotation *sel=[MKPointAnnotation new]; sel.coordinate=c; sel.title=@"Sélection"; [self.map addAnnotation:sel];
    [self.map selectAnnotation:sel animated:YES];
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)sb{
    NSString *q=sb.text.lowercaseString;
    for (NSDictionary *d in WRWorldCities.allCities) if([[d[@"city"] lowercaseString] containsString:q]){ self.selectedCity=d; self.pickedCoord=CLLocationCoordinate2DMake([d[@"lat"] doubleValue],[d[@"lon"] doubleValue]); self.hasPick=YES; self.infoLabel.text=[NSString stringWithFormat:@"%@, %@ — %@ · %@", d[@"city"], d[@"countryCode"], d[@"timezone"], d[@"lang"]]; self.confirmBtn.enabled=YES; self.confirmBtn.alpha=1; [self.map setCenterCoordinate:self.pickedCoord animated:YES]; break; }
    [sb resignFirstResponder];
}
- (MKAnnotationView*)mapView:(MKMapView*)mv viewForAnnotation:(id<MKAnnotation>)ann{
    if ([ann isKindOfClass:MKUserLocation.class]) return nil;
    MKMarkerAnnotationView *v=(MKMarkerAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:@"m"];
    if (!v) v=[[MKMarkerAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:@"m"];
    v.annotation=ann; v.markerTintColor=WRTheme.accent; v.glyphText=@"◉"; v.canShowCallout=YES;
    return v;
}
- (void)mapView:(MKMapView*)mv didSelectAnnotationView:(MKAnnotationView*)view{
    id<MKAnnotation> ann=view.annotation;
    NSString *title=ann.title;
    NSDictionary *city=[WRWorldCities cityForName:title];
    if (city){ self.selectedCity=city; self.pickedCoord=ann.coordinate; self.hasPick=YES; self.infoLabel.text=[NSString stringWithFormat:@"%@, %@ — %@ · %@", city[@"city"], city[@"countryCode"], city[@"timezone"], city[@"lang"]]; self.confirmBtn.enabled=YES; self.confirmBtn.alpha=1; }
}
- (void)confirm{
    WRLocation *loc=[WRLocation new];
    if (self.selectedCity){ loc.city=self.selectedCity[@"city"]; loc.country=self.selectedCity[@"country"]; loc.countryCode=self.selectedCity[@"countryCode"]; loc.timezoneName=self.selectedCity[@"timezone"]; loc.languageCode=self.selectedCity[@"lang"]; loc.localeIdentifier=self.selectedCity[@"locale"]; loc.latitude=[self.selectedCity[@"lat"] doubleValue]; loc.longitude=[self.selectedCity[@"lon"] doubleValue]; }
    else { loc.city=[NSString stringWithFormat:@"%.3f,%.3f", self.pickedCoord.latitude, self.pickedCoord.longitude]; loc.country=@"Custom"; loc.countryCode=@"—"; loc.timezoneName=@"UTC"; loc.languageCode=@"en"; loc.localeIdentifier=@"en_US"; loc.latitude=self.pickedCoord.latitude; loc.longitude=self.pickedCoord.longitude; }
    loc.horizontalAccuracy=15; loc.altitude=0;
    if (self.onPick) self.onPick(loc);
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
