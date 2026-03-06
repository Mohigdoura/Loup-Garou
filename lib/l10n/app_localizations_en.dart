// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LOUP GAROU';

  @override
  String get settings => 'Settings';

  @override
  String get appSubtitle => 'The Werewolf Game';

  @override
  String get menuNewGame => 'New Game';

  @override
  String get menuShop => 'Shop';

  @override
  String get menuRules => 'RULES';

  @override
  String get rulesTitle => 'How to Play';

  @override
  String get rulesContent =>
      '🌙 OBJECTIVE\nVillage team: Eliminate all werewolves\nWerewolf team: Kill all villagers\n\n🌓 GAME FLOW\n1. Night Phase: Special roles act\n2. Day Phase: Discuss and vote\n3. Repeat until one team wins\n\n🐺 ROLES\nWerewolf: Kills villagers at night\nSeer: Sees one player\'s alignment\nProtector: Guards one player\nWitch: One heal, one poison\nHunter: Kills a wolf when eliminated\nAncient: 2 lives, sets talking order\n............................................\nAnd a lot more roles you unlock in the shop!\n\n';

  @override
  String get rulesGotIt => 'GOT IT';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get skip => 'SKIP';

  @override
  String get confirm => 'CONFIRM';

  @override
  String get noOne => 'no one';

  @override
  String get nightResultTag => 'NIGHT RESULT';

  @override
  String get diedToday => 'Died Today';

  @override
  String get ancientChooseStart => 'Ancient: Choose who starts';

  @override
  String get ancientChooseDirection => 'Ancient: Choose direction';

  @override
  String get directionClockwise => 'Clockwise (default)';

  @override
  String get directionCounter => 'Counter-clockwise (reverse)';

  @override
  String get seerPickTitle => 'Seer: choose someone to see';

  @override
  String get seerResultTitle => 'Seer Result';

  @override
  String seerResult(String player, String verdict) {
    return '$player $verdict';
  }

  @override
  String get seerIsWolf => 'is a wolf';

  @override
  String get seerIsNotWolf => 'is not a wolf';

  @override
  String get protectorPickTitle => 'Protector: choose who to protect';

  @override
  String get doctorPickTitle => 'Healer: choose who to heal';

  @override
  String get witchChooseAction => 'Witch: choose action';

  @override
  String witchDiedTonight(String names) {
    return 'Died tonight: $names';
  }

  @override
  String get witchUseHeal => 'Use heal potion';

  @override
  String witchChangeHeal(String target) {
    return 'Change heal ($target)';
  }

  @override
  String get witchUseKill => 'Use kill potion';

  @override
  String witchChangeKill(String target) {
    return 'Change kill ($target)';
  }

  @override
  String get witchHealPickTitle => 'Witch: choose someone to heal';

  @override
  String get witchKillPickTitle => 'Witch: choose someone to poison';

  @override
  String get barbieChooseSignal => 'Choose your daytime signal';

  @override
  String get barbiePickTitle => 'Barbie: choose who to kill';

  @override
  String barbieSelfKill(String name) {
    return '$name killed himself';
  }

  @override
  String barbieKilled(String name) {
    return '$name was killed';
  }

  @override
  String get barbieResultTag => 'Barbie RESULT';

  @override
  String get wolvesWakeTitle => 'Wolves';

  @override
  String get wolvesWakeName => 'The Wolves';

  @override
  String get wolvesPickTitle => 'Wolves: choose a victim';

  @override
  String get blackWolfPickTitle => 'Black werewolf: choose to silence';

  @override
  String get serialKillerPickTitle => 'Serial Killer: choose to kill';

  @override
  String get graveRobberPickTitle => 'Grave Robber: choose who to watch';

  @override
  String get characterNameAncient => 'Ancient';

  @override
  String get characterNameSeer => 'Seer';

  @override
  String get characterNameProtector => 'Protector';

  @override
  String get characterNameDoctor => 'Doctor';

  @override
  String get characterNameVillager => 'Villager';

  @override
  String get characterNameWitch => 'Witch';

  @override
  String get characterNameHunter => 'Hunter';

  @override
  String get characterNameAvenger => 'Avenger';

  @override
  String get characterNameLittlePrince => 'Little Prince';

  @override
  String get characterNameLittlePrincess => 'Little Princess';

  @override
  String get characterNameBarbie => 'Barbie';

  @override
  String get characterNameSimpleWolf => 'Simple Wolf';

  @override
  String get characterNameWhiteWolf => 'White Wolf';

  @override
  String get characterNameBlackWolf => 'Black Wolf';

  @override
  String get characterNameCursedChild => 'Cursed Child';

  @override
  String get characterNameClown => 'Clown';

  @override
  String get characterNameSerialKiller => 'Serial Killer';

  @override
  String get characterNameGraveRobber => 'Grave Robber';

  @override
  String get abilityAncient =>
      'has two lives and if killed no one on the villagers team can use his ability and can decide who starts the talking and in which order';

  @override
  String get abilitySeer => 'View one player\'s alignment each night.';

  @override
  String get abilityProtector =>
      'Protect one player from being killed by wolves each night.';

  @override
  String get abilityDoctor =>
      'Heals one player each night (like the protector but isn\'t limited to wolves victim).';

  @override
  String get abilityVillager => 'No special ability, just your vote.';

  @override
  String get abilityWitch => 'One heal potion and one kill potion per game.';

  @override
  String get abilityHunter => 'If killed, take the first wolf down with you.';

  @override
  String get abilityAvenger => 'If killed, take the next player down with you.';

  @override
  String get abilityLittlePrince =>
      'If voted out, reveals his role and stays in the game.';

  @override
  String get abilityLittlePrincess =>
      'can\'t be killed by wolves, she always survives.';

  @override
  String get abilityBarbie =>
      'can make everyone sleep during daytime and chooses who to kill.';

  @override
  String get abilitySimpleWolf => 'Vote to kill one player every night.';

  @override
  String get abilityWhiteWolf =>
      'Vote to kill one player every night and can\'t be seen by the seer.';

  @override
  String get abilityBlackWolf =>
      'Vote to kill one player every night and silences a player once a night.';

  @override
  String get abilityCursedChild => 'When killed by wolves becomes one of them.';

  @override
  String get abilityClown => 'When voted out wins.';

  @override
  String get abilitySerialKiller =>
      'Each night you kill another player. If you are the last player alive you win';

  @override
  String get abilityGraveRobber =>
      'Can choose a player each night, if that player dies he takes his role.';

  @override
  String wakePhaseTitle(String title) {
    return 'Wake the $title';
  }

  @override
  String wakePhaseMessage(String name) {
    return 'Please wake $name and perform their action.';
  }

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get noneOption => 'None';

  @override
  String get dayActionBadge => 'DAY ACTION';

  @override
  String get pickSignalDoneButton => 'Done';

  @override
  String get defaultResultButton => 'OK';

  @override
  String get nightResultsTitle => 'Night Results';

  @override
  String get nightResultsNothingHappened => 'Nothing happened tonight.';

  @override
  String get nightResultsWhatHappened => 'What happened tonight:';

  @override
  String get nightResultsEventKilled => 'KILLED';

  @override
  String get nightResultsContinueToDay => 'CONTINUE TO DAY';

  @override
  String nightPageTitle(int count) {
    return 'Night $count';
  }

  @override
  String get nightPageSubtitle => 'The village sleeps...';

  @override
  String get nightPagePlayerDead => ' • DEAD';

  @override
  String nightPagePlayerLives(int count) {
    return 'Lives: $count';
  }

  @override
  String get nightPageRunNightButton => 'RUN NIGHT PHASE';

  @override
  String get voteDialogTitle => 'Vote: Choose who to eliminate';

  @override
  String get voteSkipTie => 'Skip / Tie - No elimination';

  @override
  String get voteResultTitle => 'Vote Result';

  @override
  String voteResultMessage(String playerName, String result) {
    return '$playerName $result';
  }

  @override
  String get voteResultIsWolf => 'is a wolf';

  @override
  String get voteResultIsLittlePrince => 'is the little prince';

  @override
  String get voteResultIsSerialKiller => 'is the serial killer';

  @override
  String get voteResultNotWolf => 'is not a wolf';

  @override
  String get ok => 'OK';

  @override
  String dayTitle(int dayNumber) {
    return 'Day $dayNumber';
  }

  @override
  String get daySubtitle => 'Time to deliberate';

  @override
  String get talkingOrder => 'Talking Order';

  @override
  String playerStatusDead(String characterName) {
    return '$characterName • DEAD';
  }

  @override
  String playerStatusSilenced(String characterName) {
    return '$characterName • SILENCED';
  }

  @override
  String get dayAbilityTooltip => 'Day Ability';

  @override
  String get voteToEliminate => 'VOTE TO ELIMINATE';

  @override
  String get skipVote => 'SKIP VOTE';

  @override
  String get shopTitle => 'Character Shop';

  @override
  String get shopSubtitle => 'Unlock new roles';

  @override
  String get shopAvailableCharacters => 'Available Characters';

  @override
  String get shopAllUnlockedTitle => 'All Characters Unlocked!';

  @override
  String get shopAllUnlockedSubtitle => 'You own every character in the game';

  @override
  String get adminAccessTitle => 'Admin Access';

  @override
  String get adminCodeHint => 'Enter code';

  @override
  String get adminAllRolesUnlocked => 'All roles unlocked!';

  @override
  String get adminInvalidCode => 'Invalid code';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get earnCoinsTitle => 'Earn Free Coins';

  @override
  String get watchAdLabel => 'Watch a short ad';

  @override
  String get watchAdSubtitle => 'Earn coins instantly';

  @override
  String get watchAdButton => 'Watch Ad';

  @override
  String get adNotReady => 'Ad not ready yet. Please try again.';

  @override
  String coinsAdded(int amount) {
    return '🎉 $amount coins added!';
  }

  @override
  String get gameOverTitle => 'Game Over';

  @override
  String gameOverWinner(String name) {
    return 'The winner is: $name';
  }

  @override
  String gameOverWinners(String names) {
    return 'The winners are: $names';
  }

  @override
  String get backToMenu => 'BACK TO MENU';

  @override
  String get roleCardTapHint => 'Tap to view abilities';

  @override
  String get gettingUpdates => 'Getting latest updates...';

  @override
  String get roleCardAbilityLabel => 'Ability';

  @override
  String rolePurchased(String roleName) {
    return '$roleName purchased!';
  }

  @override
  String get close => 'Close';

  @override
  String get buy => 'Buy';

  @override
  String get giveToNarratorTitle => 'Ready to Begin';

  @override
  String get giveToNarratorInstruction => 'Pass the phone to\nthe Narrator';

  @override
  String get giveToNarratorDescription =>
      'The Narrator will guide the game\nthrough night and day phases';

  @override
  String get giveToNarratorStartButton => 'START GAME';

  @override
  String get addPlayers => 'Add Players';

  @override
  String playersAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players added',
      one: '$count player added',
    );
    return '$_temp0';
  }

  @override
  String get typeAName => 'Type a name…';

  @override
  String get duplicatePlayerError => 'Player name already exists!';

  @override
  String get editName => 'Edit Name';

  @override
  String get enterPlayerName => 'Enter player name';

  @override
  String get save => 'Save';

  @override
  String get pickFromSavedPlayers => 'Pick from saved players';

  @override
  String minPlayersNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minimum $count more players needed',
      one: 'Minimum $count more player needed',
    );
    return '$_temp0';
  }

  @override
  String get noPlayersYet => 'No players added yet';

  @override
  String get noPlayersHint =>
      'Type a name or tap 👥 to pick from saved players';

  @override
  String get savedPlayers => 'Saved Players';

  @override
  String addCount(int count) {
    return 'Add $count';
  }

  @override
  String get allSavedAlreadyAdded =>
      'All saved players are already added\nor no history yet.';

  @override
  String get selectAll => 'Select All';

  @override
  String get addSelected => 'Add Selected';

  @override
  String continueWithPlayers(int count) {
    return 'CONTINUE WITH $count PLAYERS';
  }

  @override
  String get addAtLeast5Players => 'ADD AT LEAST 5 PLAYERS';

  @override
  String get exitGameDialogTitle => 'Exit Game?';

  @override
  String get exitGameDialogContent =>
      'Are you sure you want to exit the game? Your progress will be lost.';

  @override
  String get exitGameDialogCancel => 'Cancel';

  @override
  String get exitGameDialogConfirm => 'Exit';

  @override
  String get roleSelectionTitle => 'Select Roles';

  @override
  String roleSelectionProgressSuffix(int total) {
    return ' / $total';
  }

  @override
  String get roleSelectionShopBanner => 'WANT MORE ROLES? VISIT THE SHOP';

  @override
  String get roleSelectionStartGame => 'START GAME';

  @override
  String roleSelectionSelectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ROLES',
      one: 'ROLE',
    );
    return 'SELECT $count MORE $_temp0';
  }

  @override
  String get roleAssignment => 'Role Assignment';

  @override
  String playerXofY(int current, int total) {
    return 'Player $current of $total';
  }

  @override
  String get tapToReveal => 'Tap to reveal';

  @override
  String get abilityLabel => 'ABILITY';

  @override
  String get nextPlayer => 'NEXT PLAYER';

  @override
  String get done => 'DONE';

  @override
  String get skipToGame => 'Skip to game';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageLabel => 'App Language';

  @override
  String get settingsLanguageDesc => 'Choose your preferred language';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsWipeData => 'Wipe All Data';

  @override
  String get settingsWipeDataDesc =>
      'Permanently delete all game data and progress';

  @override
  String get settingsWipeConfirmTitle => 'Are you sure?';

  @override
  String get settingsWipeConfirmMessage =>
      'This will permanently erase all your game data, scores, and progress. This action cannot be undone.';

  @override
  String get settingsWipeConfirm => 'Yes, wipe it';
}
