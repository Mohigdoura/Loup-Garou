import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Main title of the app displayed on the home screen
  ///
  /// In en, this message translates to:
  /// **'LOUP GAROU'**
  String get appTitle;

  /// the word settings for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Subtitle displayed under the main title
  ///
  /// In en, this message translates to:
  /// **'The Werewolf Game'**
  String get appSubtitle;

  /// Label for the New Game button on the main menu
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get menuNewGame;

  /// Label for the Shop button on the main menu
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get menuShop;

  /// Label for the Rules button on the main menu
  ///
  /// In en, this message translates to:
  /// **'RULES'**
  String get menuRules;

  /// Title of the rules dialog
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get rulesTitle;

  /// Full rules text displayed in the How to Play dialog
  ///
  /// In en, this message translates to:
  /// **'🌙 OBJECTIVE\nVillage team: Eliminate all werewolves\nWerewolf team: Kill all villagers\n\n🌓 GAME FLOW\n1. Night Phase: Special roles act\n2. Day Phase: Discuss and vote\n3. Repeat until one team wins\n\n🐺 ROLES\nWerewolf: Kills villagers at night\nSeer: Sees one player\'s alignment\nProtector: Guards one player\nWitch: One heal, one poison\nHunter: Kills a wolf when eliminated\nAncient: 2 lives, sets talking order\n............................................\nAnd a lot more roles you unlock in the shop!\n\n'**
  String get rulesContent;

  /// Dismiss button label in the rules dialog
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get rulesGotIt;

  /// Generic dismiss button label
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// Generic skip button label
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// Generic confirm button label
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// Displayed when no player was killed tonight
  ///
  /// In en, this message translates to:
  /// **'no one'**
  String get noOne;

  /// Badge shown on night result dialogs
  ///
  /// In en, this message translates to:
  /// **'NIGHT RESULT'**
  String get nightResultTag;

  /// Title for daytime kill result dialog
  ///
  /// In en, this message translates to:
  /// **'Died Today'**
  String get diedToday;

  /// Dialog title for Ancient choosing the starting player
  ///
  /// In en, this message translates to:
  /// **'Ancient: Choose who starts'**
  String get ancientChooseStart;

  /// Dialog title for Ancient choosing talking direction
  ///
  /// In en, this message translates to:
  /// **'Ancient: Choose direction'**
  String get ancientChooseDirection;

  /// Clockwise direction option
  ///
  /// In en, this message translates to:
  /// **'Clockwise (default)'**
  String get directionClockwise;

  /// Counter-clockwise direction option
  ///
  /// In en, this message translates to:
  /// **'Counter-clockwise (reverse)'**
  String get directionCounter;

  /// Title when Seer picks a player to inspect
  ///
  /// In en, this message translates to:
  /// **'Seer: choose someone to see'**
  String get seerPickTitle;

  /// Title of the Seer result dialog
  ///
  /// In en, this message translates to:
  /// **'Seer Result'**
  String get seerResultTitle;

  /// Seer result message e.g. 'John is a wolf'
  ///
  /// In en, this message translates to:
  /// **'{player} {verdict}'**
  String seerResult(String player, String verdict);

  /// Verdict when the inspected player is a wolf
  ///
  /// In en, this message translates to:
  /// **'is a wolf'**
  String get seerIsWolf;

  /// Verdict when the inspected player is not a wolf
  ///
  /// In en, this message translates to:
  /// **'is not a wolf'**
  String get seerIsNotWolf;

  /// Title when Protector picks a player to protect
  ///
  /// In en, this message translates to:
  /// **'Protector: choose who to protect'**
  String get protectorPickTitle;

  /// Title when Doctor picks a player to heal
  ///
  /// In en, this message translates to:
  /// **'Healer: choose who to heal'**
  String get doctorPickTitle;

  /// Title of the Witch action dialog
  ///
  /// In en, this message translates to:
  /// **'Witch: choose action'**
  String get witchChooseAction;

  /// Shows who died tonight in the Witch dialog
  ///
  /// In en, this message translates to:
  /// **'Died tonight: {names}'**
  String witchDiedTonight(String names);

  /// Witch button: use the heal potion
  ///
  /// In en, this message translates to:
  /// **'Use heal potion'**
  String get witchUseHeal;

  /// Witch button: change the current heal target
  ///
  /// In en, this message translates to:
  /// **'Change heal ({target})'**
  String witchChangeHeal(String target);

  /// Witch button: use the kill potion
  ///
  /// In en, this message translates to:
  /// **'Use kill potion'**
  String get witchUseKill;

  /// Witch button: change the current kill target
  ///
  /// In en, this message translates to:
  /// **'Change kill ({target})'**
  String witchChangeKill(String target);

  /// Title when Witch picks a player to heal
  ///
  /// In en, this message translates to:
  /// **'Witch: choose someone to heal'**
  String get witchHealPickTitle;

  /// Title when Witch picks a player to poison
  ///
  /// In en, this message translates to:
  /// **'Witch: choose someone to poison'**
  String get witchKillPickTitle;

  /// Prompt for Barbie choosing her signal on night 1
  ///
  /// In en, this message translates to:
  /// **'Choose your daytime signal'**
  String get barbieChooseSignal;

  /// Title when Barbie picks a daytime kill target
  ///
  /// In en, this message translates to:
  /// **'Barbie: choose who to kill'**
  String get barbiePickTitle;

  /// Message shown when Barbie kills herself by targeting the Ancient
  ///
  /// In en, this message translates to:
  /// **'{name} killed himself'**
  String barbieSelfKill(String name);

  /// Message shown when Barbie kills a player
  ///
  /// In en, this message translates to:
  /// **'{name} was killed'**
  String barbieKilled(String name);

  /// Badge on Barbie's result dialog
  ///
  /// In en, this message translates to:
  /// **'Barbie RESULT'**
  String get barbieResultTag;

  /// Wake phase title for the wolf team
  ///
  /// In en, this message translates to:
  /// **'Wolves'**
  String get wolvesWakeTitle;

  /// Wake phase display name for the wolf team
  ///
  /// In en, this message translates to:
  /// **'The Wolves'**
  String get wolvesWakeName;

  /// Title when wolves pick a nightly victim
  ///
  /// In en, this message translates to:
  /// **'Wolves: choose a victim'**
  String get wolvesPickTitle;

  /// Title when Black Wolf picks a player to silence
  ///
  /// In en, this message translates to:
  /// **'Black werewolf: choose to silence'**
  String get blackWolfPickTitle;

  /// Title when Serial Killer picks a nightly victim
  ///
  /// In en, this message translates to:
  /// **'Serial Killer: choose to kill'**
  String get serialKillerPickTitle;

  /// Title when Grave Robber picks a player to watch
  ///
  /// In en, this message translates to:
  /// **'Grave Robber: choose who to watch'**
  String get graveRobberPickTitle;

  /// No description provided for @characterNameAncient.
  ///
  /// In en, this message translates to:
  /// **'Ancient'**
  String get characterNameAncient;

  /// No description provided for @characterNameSeer.
  ///
  /// In en, this message translates to:
  /// **'Seer'**
  String get characterNameSeer;

  /// No description provided for @characterNameProtector.
  ///
  /// In en, this message translates to:
  /// **'Protector'**
  String get characterNameProtector;

  /// No description provided for @characterNameDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get characterNameDoctor;

  /// No description provided for @characterNameVillager.
  ///
  /// In en, this message translates to:
  /// **'Villager'**
  String get characterNameVillager;

  /// No description provided for @characterNameWitch.
  ///
  /// In en, this message translates to:
  /// **'Witch'**
  String get characterNameWitch;

  /// No description provided for @characterNameHunter.
  ///
  /// In en, this message translates to:
  /// **'Hunter'**
  String get characterNameHunter;

  /// No description provided for @characterNameAvenger.
  ///
  /// In en, this message translates to:
  /// **'Avenger'**
  String get characterNameAvenger;

  /// No description provided for @characterNameLittlePrince.
  ///
  /// In en, this message translates to:
  /// **'Little Prince'**
  String get characterNameLittlePrince;

  /// No description provided for @characterNameLittlePrincess.
  ///
  /// In en, this message translates to:
  /// **'Little Princess'**
  String get characterNameLittlePrincess;

  /// No description provided for @characterNameBarbie.
  ///
  /// In en, this message translates to:
  /// **'Barbie'**
  String get characterNameBarbie;

  /// No description provided for @characterNameSimpleWolf.
  ///
  /// In en, this message translates to:
  /// **'Simple Wolf'**
  String get characterNameSimpleWolf;

  /// No description provided for @characterNameWhiteWolf.
  ///
  /// In en, this message translates to:
  /// **'White Wolf'**
  String get characterNameWhiteWolf;

  /// No description provided for @characterNameBlackWolf.
  ///
  /// In en, this message translates to:
  /// **'Black Wolf'**
  String get characterNameBlackWolf;

  /// No description provided for @characterNameCursedChild.
  ///
  /// In en, this message translates to:
  /// **'Cursed Child'**
  String get characterNameCursedChild;

  /// No description provided for @characterNameClown.
  ///
  /// In en, this message translates to:
  /// **'Clown'**
  String get characterNameClown;

  /// No description provided for @characterNameSerialKiller.
  ///
  /// In en, this message translates to:
  /// **'Serial Killer'**
  String get characterNameSerialKiller;

  /// No description provided for @characterNameGraveRobber.
  ///
  /// In en, this message translates to:
  /// **'Grave Robber'**
  String get characterNameGraveRobber;

  /// No description provided for @abilityAncient.
  ///
  /// In en, this message translates to:
  /// **'has two lives and if killed no one on the villagers team can use his ability and can decide who starts the talking and in which order'**
  String get abilityAncient;

  /// No description provided for @abilitySeer.
  ///
  /// In en, this message translates to:
  /// **'View one player\'s alignment each night.'**
  String get abilitySeer;

  /// No description provided for @abilityProtector.
  ///
  /// In en, this message translates to:
  /// **'Protect one player from being killed by wolves each night.'**
  String get abilityProtector;

  /// No description provided for @abilityDoctor.
  ///
  /// In en, this message translates to:
  /// **'Heals one player each night (like the protector but isn\'t limited to wolves victim).'**
  String get abilityDoctor;

  /// No description provided for @abilityVillager.
  ///
  /// In en, this message translates to:
  /// **'No special ability, just your vote.'**
  String get abilityVillager;

  /// No description provided for @abilityWitch.
  ///
  /// In en, this message translates to:
  /// **'One heal potion and one kill potion per game.'**
  String get abilityWitch;

  /// No description provided for @abilityHunter.
  ///
  /// In en, this message translates to:
  /// **'If killed, take the first wolf down with you.'**
  String get abilityHunter;

  /// No description provided for @abilityAvenger.
  ///
  /// In en, this message translates to:
  /// **'If killed, take the next player down with you.'**
  String get abilityAvenger;

  /// No description provided for @abilityLittlePrince.
  ///
  /// In en, this message translates to:
  /// **'If voted out, reveals his role and stays in the game.'**
  String get abilityLittlePrince;

  /// No description provided for @abilityLittlePrincess.
  ///
  /// In en, this message translates to:
  /// **'can\'t be killed by wolves, she always survives.'**
  String get abilityLittlePrincess;

  /// No description provided for @abilityBarbie.
  ///
  /// In en, this message translates to:
  /// **'can make everyone sleep during daytime and chooses who to kill.'**
  String get abilityBarbie;

  /// No description provided for @abilitySimpleWolf.
  ///
  /// In en, this message translates to:
  /// **'Vote to kill one player every night.'**
  String get abilitySimpleWolf;

  /// No description provided for @abilityWhiteWolf.
  ///
  /// In en, this message translates to:
  /// **'Vote to kill one player every night and can\'t be seen by the seer.'**
  String get abilityWhiteWolf;

  /// No description provided for @abilityBlackWolf.
  ///
  /// In en, this message translates to:
  /// **'Vote to kill one player every night and silences a player once a night.'**
  String get abilityBlackWolf;

  /// No description provided for @abilityCursedChild.
  ///
  /// In en, this message translates to:
  /// **'When killed by wolves becomes one of them.'**
  String get abilityCursedChild;

  /// No description provided for @abilityClown.
  ///
  /// In en, this message translates to:
  /// **'When voted out wins.'**
  String get abilityClown;

  /// No description provided for @abilitySerialKiller.
  ///
  /// In en, this message translates to:
  /// **'Each night you kill another player. If you are the last player alive you win'**
  String get abilitySerialKiller;

  /// No description provided for @abilityGraveRobber.
  ///
  /// In en, this message translates to:
  /// **'Can choose a player each night, if that player dies he takes his role.'**
  String get abilityGraveRobber;

  /// Title shown in the wake phase dialog
  ///
  /// In en, this message translates to:
  /// **'Wake the {title}'**
  String wakePhaseTitle(String title);

  /// Body message in the wake phase dialog
  ///
  /// In en, this message translates to:
  /// **'Please wake {name} and perform their action.'**
  String wakePhaseMessage(String name);

  /// Label for the continue button
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// Option representing no selection in a picker list
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneOption;

  /// Badge label shown on day-action dialogs
  ///
  /// In en, this message translates to:
  /// **'DAY ACTION'**
  String get dayActionBadge;

  /// Done button label in the signal picker dialog
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pickSignalDoneButton;

  /// Default label for the result dialog confirm button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get defaultResultButton;

  /// Title of the night results dialog
  ///
  /// In en, this message translates to:
  /// **'Night Results'**
  String get nightResultsTitle;

  /// Shown in the night results dialog when no events occurred
  ///
  /// In en, this message translates to:
  /// **'Nothing happened tonight.'**
  String get nightResultsNothingHappened;

  /// Subtitle in the night results dialog listing events
  ///
  /// In en, this message translates to:
  /// **'What happened tonight:'**
  String get nightResultsWhatHappened;

  /// Result label shown when a player was killed during the night
  ///
  /// In en, this message translates to:
  /// **'KILLED'**
  String get nightResultsEventKilled;

  /// Button label to proceed from night results to the day phase
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO DAY'**
  String get nightResultsContinueToDay;

  /// Header title on the night page
  ///
  /// In en, this message translates to:
  /// **'Night {count}'**
  String nightPageTitle(int count);

  /// Subtitle shown under the night count in the header
  ///
  /// In en, this message translates to:
  /// **'The village sleeps...'**
  String get nightPageSubtitle;

  /// Suffix appended to a player's role name when they are dead
  ///
  /// In en, this message translates to:
  /// **' • DEAD'**
  String get nightPagePlayerDead;

  /// Player lives indicator in the player list
  ///
  /// In en, this message translates to:
  /// **'Lives: {count}'**
  String nightPagePlayerLives(int count);

  /// Label for the button that starts the night phase
  ///
  /// In en, this message translates to:
  /// **'RUN NIGHT PHASE'**
  String get nightPageRunNightButton;

  /// Title of the vote dialog where players pick someone to eliminate
  ///
  /// In en, this message translates to:
  /// **'Vote: Choose who to eliminate'**
  String get voteDialogTitle;

  /// Option in the vote dialog to skip or declare a tie
  ///
  /// In en, this message translates to:
  /// **'Skip / Tie - No elimination'**
  String get voteSkipTie;

  /// Title of the dialog shown after a vote
  ///
  /// In en, this message translates to:
  /// **'Vote Result'**
  String get voteResultTitle;

  /// Body of the vote result dialog, combining player name and role reveal
  ///
  /// In en, this message translates to:
  /// **'{playerName} {result}'**
  String voteResultMessage(String playerName, String result);

  /// Role reveal when the eliminated player is a wolf
  ///
  /// In en, this message translates to:
  /// **'is a wolf'**
  String get voteResultIsWolf;

  /// Role reveal when the eliminated player is the Little Prince
  ///
  /// In en, this message translates to:
  /// **'is the little prince'**
  String get voteResultIsLittlePrince;

  /// Role reveal when the eliminated player is the Serial Killer
  ///
  /// In en, this message translates to:
  /// **'is the serial killer'**
  String get voteResultIsSerialKiller;

  /// Role reveal when the eliminated player is an innocent villager
  ///
  /// In en, this message translates to:
  /// **'is not a wolf'**
  String get voteResultNotWolf;

  /// Generic confirmation button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Header showing the current day number
  ///
  /// In en, this message translates to:
  /// **'Day {dayNumber}'**
  String dayTitle(int dayNumber);

  /// Subtitle shown under the day header
  ///
  /// In en, this message translates to:
  /// **'Time to deliberate'**
  String get daySubtitle;

  /// Section header for the list of players in speaking order
  ///
  /// In en, this message translates to:
  /// **'Talking Order'**
  String get talkingOrder;

  /// Player status subtitle when the player is dead
  ///
  /// In en, this message translates to:
  /// **'{characterName} • DEAD'**
  String playerStatusDead(String characterName);

  /// Player status subtitle when the player is silenced
  ///
  /// In en, this message translates to:
  /// **'{characterName} • SILENCED'**
  String playerStatusSilenced(String characterName);

  /// Tooltip for the day ability icon button on a player tile
  ///
  /// In en, this message translates to:
  /// **'Day Ability'**
  String get dayAbilityTooltip;

  /// Label on the main vote button
  ///
  /// In en, this message translates to:
  /// **'VOTE TO ELIMINATE'**
  String get voteToEliminate;

  /// Label on the skip vote button
  ///
  /// In en, this message translates to:
  /// **'SKIP VOTE'**
  String get skipVote;

  /// Title shown in the shop page header
  ///
  /// In en, this message translates to:
  /// **'Character Shop'**
  String get shopTitle;

  /// Subtitle shown under the shop page header
  ///
  /// In en, this message translates to:
  /// **'Unlock new roles'**
  String get shopSubtitle;

  /// Section header for the list of purchasable characters
  ///
  /// In en, this message translates to:
  /// **'Available Characters'**
  String get shopAvailableCharacters;

  /// Empty state title when every character has been purchased
  ///
  /// In en, this message translates to:
  /// **'All Characters Unlocked!'**
  String get shopAllUnlockedTitle;

  /// Empty state subtitle when every character has been purchased
  ///
  /// In en, this message translates to:
  /// **'You own every character in the game'**
  String get shopAllUnlockedSubtitle;

  /// Title of the admin code dialog
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get adminAccessTitle;

  /// Hint text for the admin code input field
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get adminCodeHint;

  /// Snackbar message shown after successfully using the admin code
  ///
  /// In en, this message translates to:
  /// **'All roles unlocked!'**
  String get adminAllRolesUnlocked;

  /// Snackbar message shown when the admin code is wrong
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get adminInvalidCode;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Title of the earn coins dialog
  ///
  /// In en, this message translates to:
  /// **'Earn Free Coins'**
  String get earnCoinsTitle;

  /// Primary label in the watch-ad option tile
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad'**
  String get watchAdLabel;

  /// Secondary description in the watch-ad option tile
  ///
  /// In en, this message translates to:
  /// **'Earn coins instantly'**
  String get watchAdSubtitle;

  /// Label on the Watch Ad confirmation button
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAdButton;

  /// Snackbar message shown when the rewarded ad has not loaded yet
  ///
  /// In en, this message translates to:
  /// **'Ad not ready yet. Please try again.'**
  String get adNotReady;

  /// Snackbar message shown after earning coins from a rewarded ad
  ///
  /// In en, this message translates to:
  /// **'🎉 {amount} coins added!'**
  String coinsAdded(int amount);

  /// Title of the game over dialog
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOverTitle;

  /// Game over message when there is exactly one winner
  ///
  /// In en, this message translates to:
  /// **'The winner is: {name}'**
  String gameOverWinner(String name);

  /// Game over message when there are multiple winners
  ///
  /// In en, this message translates to:
  /// **'The winners are: {names}'**
  String gameOverWinners(String names);

  /// Button label to return to the main menu from the game over dialog
  ///
  /// In en, this message translates to:
  /// **'BACK TO MENU'**
  String get backToMenu;

  /// Hint text shown under the role name on the role card
  ///
  /// In en, this message translates to:
  /// **'Tap to view abilities'**
  String get roleCardTapHint;

  /// Getting latest update for patching
  ///
  /// In en, this message translates to:
  /// **'Getting latest updates...'**
  String get gettingUpdates;

  /// Section label above the role ability description in the buy dialog
  ///
  /// In en, this message translates to:
  /// **'Ability'**
  String get roleCardAbilityLabel;

  /// Snackbar message shown after successfully buying a role
  ///
  /// In en, this message translates to:
  /// **'{roleName} purchased!'**
  String rolePurchased(String roleName);

  /// Generic close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Buy button label in the role purchase dialog
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// Title shown on the Give to Narrator page
  ///
  /// In en, this message translates to:
  /// **'Ready to Begin'**
  String get giveToNarratorTitle;

  /// Main instruction asking players to hand the phone to the Narrator
  ///
  /// In en, this message translates to:
  /// **'Pass the phone to\nthe Narrator'**
  String get giveToNarratorInstruction;

  /// Supporting description of the Narrator's role
  ///
  /// In en, this message translates to:
  /// **'The Narrator will guide the game\nthrough night and day phases'**
  String get giveToNarratorDescription;

  /// Label for the start game button
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get giveToNarratorStartButton;

  /// Title on the names selection page
  ///
  /// In en, this message translates to:
  /// **'Add Players'**
  String get addPlayers;

  /// Subtitle showing how many players have been added
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} player added} other{{count} players added}}'**
  String playersAdded(int count);

  /// Hint text in the name input field
  ///
  /// In en, this message translates to:
  /// **'Type a name…'**
  String get typeAName;

  /// Snackbar message when a duplicate name is entered
  ///
  /// In en, this message translates to:
  /// **'Player name already exists!'**
  String get duplicatePlayerError;

  /// Title of the edit name dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// Hint text in the edit name dialog text field
  ///
  /// In en, this message translates to:
  /// **'Enter player name'**
  String get enterPlayerName;

  /// Save button label in the edit name dialog
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Tooltip for the saved players button
  ///
  /// In en, this message translates to:
  /// **'Pick from saved players'**
  String get pickFromSavedPlayers;

  /// Notice shown when fewer than 5 players have been added
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Minimum {count} more player needed} other{Minimum {count} more players needed}}'**
  String minPlayersNeeded(int count);

  /// Empty state heading in the player list
  ///
  /// In en, this message translates to:
  /// **'No players added yet'**
  String get noPlayersYet;

  /// Empty state hint below the heading
  ///
  /// In en, this message translates to:
  /// **'Type a name or tap 👥 to pick from saved players'**
  String get noPlayersHint;

  /// Title of the saved players bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Saved Players'**
  String get savedPlayers;

  /// Button label showing how many selected players will be added
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String addCount(int count);

  /// Empty state text in the saved players sheet
  ///
  /// In en, this message translates to:
  /// **'All saved players are already added\nor no history yet.'**
  String get allSavedAlreadyAdded;

  /// Select-all button in the saved players sheet
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Add-selected button label when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// Continue button label when enough players are added
  ///
  /// In en, this message translates to:
  /// **'CONTINUE WITH {count} PLAYERS'**
  String continueWithPlayers(int count);

  /// Continue button label when not enough players are added
  ///
  /// In en, this message translates to:
  /// **'ADD AT LEAST 5 PLAYERS'**
  String get addAtLeast5Players;

  /// Title of the confirmation dialog when the user tries to exit the game
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get exitGameDialogTitle;

  /// Body text of the exit game confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the game? Your progress will be lost.'**
  String get exitGameDialogContent;

  /// Cancel button label in the exit game dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get exitGameDialogCancel;

  /// Confirm exit button label in the exit game dialog
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitGameDialogConfirm;

  /// Title shown in the header of the role selection page
  ///
  /// In en, this message translates to:
  /// **'Select Roles'**
  String get roleSelectionTitle;

  /// Suffix shown next to the current role count, e.g. '/ 6'
  ///
  /// In en, this message translates to:
  /// **' / {total}'**
  String roleSelectionProgressSuffix(int total);

  /// Banner text that links to the shop for more roles
  ///
  /// In en, this message translates to:
  /// **'WANT MORE ROLES? VISIT THE SHOP'**
  String get roleSelectionShopBanner;

  /// Label on the start game button when role selection is complete
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get roleSelectionStartGame;

  /// Label on the bottom button when more roles still need to be selected
  ///
  /// In en, this message translates to:
  /// **'SELECT {count} MORE {count, plural, one{ROLE} other{ROLES}}'**
  String roleSelectionSelectMore(int count);

  /// Title on the picker page
  ///
  /// In en, this message translates to:
  /// **'Role Assignment'**
  String get roleAssignment;

  /// Current player index out of total
  ///
  /// In en, this message translates to:
  /// **'Player {current} of {total}'**
  String playerXofY(int current, int total);

  /// Prompt on the back of the role card
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get tapToReveal;

  /// Section label above the ability description on the card
  ///
  /// In en, this message translates to:
  /// **'ABILITY'**
  String get abilityLabel;

  /// Button to advance to the next player
  ///
  /// In en, this message translates to:
  /// **'NEXT PLAYER'**
  String get nextPlayer;

  /// Button label on the last player's turn
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// Debug-mode skip button
  ///
  /// In en, this message translates to:
  /// **'Skip to game'**
  String get skipToGame;

  /// Section title for language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Label for the language selector row
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsLanguageLabel;

  /// Description under the language selector label
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settingsLanguageDesc;

  /// Section title for destructive actions
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// Label for the wipe data row
  ///
  /// In en, this message translates to:
  /// **'Wipe All Data'**
  String get settingsWipeData;

  /// Description under the wipe data label
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all game data and progress'**
  String get settingsWipeDataDesc;

  /// Title of the wipe data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get settingsWipeConfirmTitle;

  /// Body of the wipe data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will permanently erase all your game data, scores, and progress. This action cannot be undone.'**
  String get settingsWipeConfirmMessage;

  /// Confirm button in the wipe data dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, wipe it'**
  String get settingsWipeConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
