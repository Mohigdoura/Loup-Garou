// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'LOUP GAROU';

  @override
  String get settings => 'Paramètres';

  @override
  String get appSubtitle => 'Le Jeu des Loups';

  @override
  String get menuNewGame => 'Nouvelle Partie';

  @override
  String get menuShop => 'Boutique';

  @override
  String get menuRules => 'RÈGLES';

  @override
  String get rulesTitle => 'Comment Jouer';

  @override
  String get rulesContent =>
      '🌙 OBJECTIF\nVillageois : Éliminez tous les loups\nLoups : Tuez tous les villageois\n\n🌓 DÉROULEMENT\n1. Phase Nuit : Les rôles spéciaux agissent\n2. Phase Jour : Débattez et votez\n3. Répétez jusqu\'à la victoire d\'une équipe\n\n🐺 RÔLES\nLoup : Tue les villageois la nuit\nVoyante : Voit l\'alignement d\'un joueur\nProtecteur : Protège un joueur\nSorcière : Un soin, un poison\nChasseur : Tue un loup à sa mort\nAncien : 2 vies, fixe l\'ordre de parole\n............................................\nEt bien d\'autres rôles à débloquer !\n\n';

  @override
  String get rulesGotIt => 'COMPRIS';

  @override
  String get gotIt => 'COMPRIS';

  @override
  String get skip => 'PASSER';

  @override
  String get confirm => 'CONFIRMER';

  @override
  String get noOne => 'personne';

  @override
  String get nightResultTag => 'RÉSULTAT NUIT';

  @override
  String get diedToday => 'Mort Aujourd\'hui';

  @override
  String get ancientChooseStart => 'Ancien : Choisir qui commence';

  @override
  String get ancientChooseDirection => 'Ancien : Choisir la direction';

  @override
  String get directionClockwise => 'Sens horaire (défaut)';

  @override
  String get directionCounter => 'Sens anti-horaire (inverse)';

  @override
  String get seerPickTitle => 'Voyante : choisir un joueur à voir';

  @override
  String get seerResultTitle => 'Résultat Voyante';

  @override
  String seerResult(String player, String verdict) {
    return '$player $verdict';
  }

  @override
  String get seerIsWolf => 'est un loup';

  @override
  String get seerIsNotWolf => 'n\'est pas un loup';

  @override
  String get protectorPickTitle => 'Protecteur : choisir qui protéger';

  @override
  String get doctorPickTitle => 'Guérisseur : choisir qui soigner';

  @override
  String get witchChooseAction => 'Sorcière : choisir une action';

  @override
  String witchDiedTonight(String names) {
    return 'Mort cette nuit : $names';
  }

  @override
  String get witchUseHeal => 'Utiliser la potion de soin';

  @override
  String witchChangeHeal(String target) {
    return 'Changer le soin ($target)';
  }

  @override
  String get witchUseKill => 'Utiliser la potion de mort';

  @override
  String witchChangeKill(String target) {
    return 'Changer la cible ($target)';
  }

  @override
  String get witchHealPickTitle => 'Sorcière : choisir qui soigner';

  @override
  String get witchKillPickTitle => 'Sorcière : choisir qui empoisonner';

  @override
  String get barbieChooseSignal => 'Choisissez votre signal de jour';

  @override
  String get barbiePickTitle => 'Barbie : choisir qui tuer';

  @override
  String barbieSelfKill(String name) {
    return '$name s\'est suicidé';
  }

  @override
  String barbieKilled(String name) {
    return '$name a été tué';
  }

  @override
  String get barbieResultTag => 'RÉSULTAT Barbie';

  @override
  String get wolvesWakeTitle => 'Loups';

  @override
  String get wolvesWakeName => 'Les Loups';

  @override
  String get wolvesPickTitle => 'Loups : choisir une victime';

  @override
  String get blackWolfPickTitle => 'Loup Noir : choisir qui réduire au silence';

  @override
  String get serialKillerPickTitle => 'Tueur en Série : choisir qui tuer';

  @override
  String get graveRobberPickTitle => 'Fossoyeur : choisir qui surveiller';

  @override
  String get characterNameAncient => 'Ancien';

  @override
  String get characterNameSeer => 'Voyante';

  @override
  String get characterNameProtector => 'Protecteur';

  @override
  String get characterNameDoctor => 'Guérisseur';

  @override
  String get characterNameVillager => 'Villageois';

  @override
  String get characterNameWitch => 'Sorcière';

  @override
  String get characterNameHunter => 'Chasseur';

  @override
  String get characterNameAvenger => 'Vengeur';

  @override
  String get characterNameLittlePrince => 'Petit Prince';

  @override
  String get characterNameLittlePrincess => 'Petite Princesse';

  @override
  String get characterNameBarbie => 'Barbie';

  @override
  String get characterNameSimpleWolf => 'Loup Simple';

  @override
  String get characterNameWhiteWolf => 'Loup Blanc';

  @override
  String get characterNameBlackWolf => 'Loup Noir';

  @override
  String get characterNameCursedChild => 'Enfant Maudit';

  @override
  String get characterNameClown => 'Clown';

  @override
  String get characterNameSerialKiller => 'Tueur en Série';

  @override
  String get characterNameGraveRobber => 'Fossoyeur';

  @override
  String get abilityAncient =>
      'a deux vies et si tué, les villageois perdent leurs capacités ; il décide qui parle en premier et dans quel ordre.';

  @override
  String get abilitySeer => 'Voit l\'alignement d\'un joueur chaque nuit.';

  @override
  String get abilityProtector => 'Protège un joueur des loups chaque nuit.';

  @override
  String get abilityDoctor =>
      'Soigne un joueur chaque nuit (comme le protecteur mais pas limité aux victimes des loups).';

  @override
  String get abilityVillager => 'Aucune capacité spéciale, juste votre vote.';

  @override
  String get abilityWitch =>
      'Une potion de soin et une potion de mort par partie.';

  @override
  String get abilityHunter => 'Si tué, emporte le premier loup avec lui.';

  @override
  String get abilityAvenger => 'Si tué, emporte le prochain joueur avec lui.';

  @override
  String get abilityLittlePrince =>
      'Si éliminé par vote, révèle son rôle et reste en jeu.';

  @override
  String get abilityLittlePrincess =>
      'ne peut pas être tuée par les loups, elle survit toujours.';

  @override
  String get abilityBarbie =>
      'peut endormir tout le monde de jour et choisit qui tuer.';

  @override
  String get abilitySimpleWolf => 'Vote pour tuer un joueur chaque nuit.';

  @override
  String get abilityWhiteWolf =>
      'Vote pour tuer un joueur chaque nuit et est invisible à la voyante.';

  @override
  String get abilityBlackWolf =>
      'Vote pour tuer chaque nuit et réduit un joueur au silence une fois par nuit.';

  @override
  String get abilityCursedChild =>
      'S\'il est tué par les loups, il rejoint leur camp.';

  @override
  String get abilityClown => 'S\'il est éliminé par vote, il gagne la partie.';

  @override
  String get abilitySerialKiller =>
      'Tue un joueur chaque nuit. S\'il est le dernier survivant, il gagne.';

  @override
  String get abilityGraveRobber =>
      'Surveille un joueur chaque nuit ; s\'il meurt, il prend son rôle.';

  @override
  String wakePhaseTitle(String title) {
    return 'Réveillez le $title';
  }

  @override
  String wakePhaseMessage(String name) {
    return 'Réveillez $name et effectuez son action.';
  }

  @override
  String get continueButton => 'CONTINUER';

  @override
  String get noneOption => 'Aucun';

  @override
  String get dayActionBadge => 'ACTION DE JOUR';

  @override
  String get pickSignalDoneButton => 'Terminé';

  @override
  String get defaultResultButton => 'OK';

  @override
  String get nightResultsTitle => 'Résultats de la Nuit';

  @override
  String get nightResultsNothingHappened => 'Rien ne s\'est passé cette nuit.';

  @override
  String get nightResultsWhatHappened => 'Ce qui s\'est passé cette nuit :';

  @override
  String get nightResultsEventKilled => 'TUÉS';

  @override
  String get nightResultsContinueToDay => 'PASSER AU JOUR';

  @override
  String nightPageTitle(int count) {
    return 'Nuit $count';
  }

  @override
  String get nightPageSubtitle => 'Le village s\'endort...';

  @override
  String get nightPagePlayerDead => ' • MORT';

  @override
  String nightPagePlayerLives(int count) {
    return 'Vies : $count';
  }

  @override
  String get nightPageRunNightButton => 'LANCER LA PHASE NUIT';

  @override
  String get voteDialogTitle => 'Vote : Choisir qui éliminer';

  @override
  String get voteSkipTie => 'Passer / Égalité - Pas d\'élimination';

  @override
  String get voteResultTitle => 'Résultat du Vote';

  @override
  String voteResultMessage(String playerName, String result) {
    return '$playerName $result';
  }

  @override
  String get voteResultIsWolf => 'est un loup';

  @override
  String get voteResultIsLittlePrince => 'est le petit prince';

  @override
  String get voteResultIsSerialKiller => 'est le tueur en série';

  @override
  String get voteResultNotWolf => 'n\'est pas un loup';

  @override
  String get ok => 'OK';

  @override
  String dayTitle(int dayNumber) {
    return 'Jour $dayNumber';
  }

  @override
  String get daySubtitle => 'Place au débat';

  @override
  String get talkingOrder => 'Ordre de Parole';

  @override
  String playerStatusDead(String characterName) {
    return '$characterName • MORT';
  }

  @override
  String playerStatusSilenced(String characterName) {
    return '$characterName • RÉDUIT AU SILENCE';
  }

  @override
  String get dayAbilityTooltip => 'Capacité de Jour';

  @override
  String get voteToEliminate => 'VOTER POUR ÉLIMINER';

  @override
  String get skipVote => 'PASSER LE VOTE';

  @override
  String get shopTitle => 'Boutique des Rôles';

  @override
  String get shopSubtitle => 'Débloquez de nouveaux rôles';

  @override
  String get shopAvailableCharacters => 'Personnages Disponibles';

  @override
  String get shopAllUnlockedTitle => 'Tous les Personnages Débloqués !';

  @override
  String get shopAllUnlockedSubtitle => 'Vous possédez tous les personnages';

  @override
  String get adminAccessTitle => 'Accès Admin';

  @override
  String get adminCodeHint => 'Entrez le code';

  @override
  String get adminAllRolesUnlocked => 'Tous les rôles débloqués !';

  @override
  String get adminInvalidCode => 'Code invalide';

  @override
  String get cancel => 'Annuler';

  @override
  String get submit => 'Valider';

  @override
  String get earnCoinsTitle => 'Gagner des Pièces';

  @override
  String get watchAdLabel => 'Regarder une courte pub';

  @override
  String get watchAdSubtitle => 'Gagnez des pièces instantanément';

  @override
  String get watchAdButton => 'Voir la pub';

  @override
  String get adNotReady => 'Pub non disponible. Réessayez plus tard.';

  @override
  String coinsAdded(int amount) {
    return '🎉 $amount pièces ajoutées !';
  }

  @override
  String get gameOverTitle => 'Partie Terminée';

  @override
  String gameOverWinner(String name) {
    return 'Le gagnant est : $name';
  }

  @override
  String gameOverWinners(String names) {
    return 'Les gagnants sont : $names';
  }

  @override
  String get backToMenu => 'RETOUR AU MENU';

  @override
  String get roleCardTapHint => 'Appuyez pour voir les capacités';

  @override
  String get gettingUpdates => 'Récupération des mises à jour...';

  @override
  String get roleCardAbilityLabel => 'Capacité';

  @override
  String rolePurchased(String roleName) {
    return '$roleName acheté !';
  }

  @override
  String get close => 'Fermer';

  @override
  String get buy => 'Acheter';

  @override
  String get giveToNarratorTitle => 'Prêt à Commencer';

  @override
  String get giveToNarratorInstruction => 'Passez le téléphone\nau Narrateur';

  @override
  String get giveToNarratorDescription =>
      'Le Narrateur guidera la partie\npendant les phases nuit et jour';

  @override
  String get giveToNarratorStartButton => 'DÉMARRER LA PARTIE';

  @override
  String get addPlayers => 'Ajouter des Joueurs';

  @override
  String playersAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joueurs ajoutés',
      one: '$count joueur ajouté',
    );
    return '$_temp0';
  }

  @override
  String get typeAName => 'Tapez un nom…';

  @override
  String get duplicatePlayerError => 'Ce nom de joueur existe déjà !';

  @override
  String get editName => 'Modifier le Nom';

  @override
  String get enterPlayerName => 'Entrez le nom du joueur';

  @override
  String get save => 'Sauvegarder';

  @override
  String get pickFromSavedPlayers => 'Choisir parmi les joueurs sauvegardés';

  @override
  String minPlayersNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minimum $count joueurs supplémentaires requis',
      one: 'Minimum $count joueur supplémentaire requis',
    );
    return '$_temp0';
  }

  @override
  String get noPlayersYet => 'Aucun joueur ajouté';

  @override
  String get noPlayersHint => 'Tapez un nom ou appuyez sur 👥 pour choisir';

  @override
  String get savedPlayers => 'Joueurs Sauvegardés';

  @override
  String addCount(int count) {
    return 'Ajouter $count';
  }

  @override
  String get allSavedAlreadyAdded =>
      'Tous les joueurs sauvegardés sont déjà ajoutés\nou aucun historique.';

  @override
  String get selectAll => 'Tout Sélectionner';

  @override
  String get addSelected => 'Ajouter la Sélection';

  @override
  String continueWithPlayers(int count) {
    return 'CONTINUER AVEC $count JOUEURS';
  }

  @override
  String get addAtLeast5Players => 'AJOUTEZ AU MOINS 5 JOUEURS';

  @override
  String get exitGameDialogTitle => 'Quitter la Partie ?';

  @override
  String get exitGameDialogContent =>
      'Voulez-vous vraiment quitter ? Votre progression sera perdue.';

  @override
  String get exitGameDialogCancel => 'Annuler';

  @override
  String get exitGameDialogConfirm => 'Quitter';

  @override
  String get roleSelectionTitle => 'Choisir les Rôles';

  @override
  String roleSelectionProgressSuffix(int total) {
    return ' / $total';
  }

  @override
  String get roleSelectionShopBanner => 'PLUS DE RÔLES ? VISITEZ LA BOUTIQUE';

  @override
  String get roleSelectionStartGame => 'DÉMARRER LA PARTIE';

  @override
  String roleSelectionSelectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'RÔLES',
      one: 'RÔLE',
    );
    return 'SÉLECTIONNEZ $count $_temp0 DE PLUS';
  }

  @override
  String get roleAssignment => 'Attribution des Rôles';

  @override
  String playerXofY(int current, int total) {
    return 'Joueur $current sur $total';
  }

  @override
  String get tapToReveal => 'Appuyez pour révéler';

  @override
  String get abilityLabel => 'CAPACITÉ';

  @override
  String get nextPlayer => 'JOUEUR SUIVANT';

  @override
  String get done => 'TERMINÉ';

  @override
  String get skipToGame => 'Passer au jeu';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageLabel => 'Langue de l\'application';

  @override
  String get settingsLanguageDesc => 'Choisissez votre langue préférée';

  @override
  String get settingsDangerZone => 'Zone Dangereuse';

  @override
  String get settingsWipeData => 'Effacer les données';

  @override
  String get settingsWipeDataDesc =>
      'Supprimer définitivement toutes les données et la progression du jeu';

  @override
  String get settingsWipeConfirmTitle => 'Êtes-vous sûr ?';

  @override
  String get settingsWipeConfirmMessage =>
      'Cela effacera définitivement toutes vos données de jeu, scores et progression. Cette action est irréversible.';

  @override
  String get settingsWipeConfirm => 'Oui, effacer';
}
