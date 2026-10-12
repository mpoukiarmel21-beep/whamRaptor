#import "WRL10n.h"
@implementation WRL10n
+ (NSString*)t:(NSString*)k {
    NSDictionary *m=@{
        @"appName":@"WhamRaptor",
        @"containers":@"Containers",
        @"newContainer":@"Nouveau container",
        @"create":@"Créer",
        @"cancel":@"Annuler",
        @"delete":@"Supprimer",
        @"rename":@"Renommer",
        @"location":@"Localisation",
        @"chooseCity":@"Choisir une ville",
        @"searchCity":@"Rechercher une ville…",
        @"noLocation":@"Aucune localisation",
        @"active":@"Actif",
        @"switchHint":@"Toucher pour activer — relance l'app",
        @"deleteConfirm":@"Supprimer ce container et ses données isolées ?",
        @"safeTitle":@"Mode sûr activé",
        @"safeMsg":@"3 crashs au lancement — protections désactivées, containers conservés.",
        @"enable":@"Réactiver",
    };
    return m[k] ?: k;
}
@end
