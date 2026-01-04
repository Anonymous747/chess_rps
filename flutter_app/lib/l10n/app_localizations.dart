import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Chess Arena'**
  String get appName;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Russian language name
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// Account section header
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// Gameplay section header
  ///
  /// In en, this message translates to:
  /// **'GAMEPLAY'**
  String get gameplay;

  /// Audio section header
  ///
  /// In en, this message translates to:
  /// **'AUDIO & SYNC'**
  String get audioAndSync;

  /// Privacy section header
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get privacy;

  /// Board theme setting
  ///
  /// In en, this message translates to:
  /// **'Board Theme'**
  String get boardTheme;

  /// Piece set setting
  ///
  /// In en, this message translates to:
  /// **'Piece Set'**
  String get pieceSet;

  /// Auto-queen toggle setting
  ///
  /// In en, this message translates to:
  /// **'Auto-Queen'**
  String get autoQueen;

  /// Auto-queen setting description
  ///
  /// In en, this message translates to:
  /// **'Automatically promote to Queen'**
  String get autoQueenDescription;

  /// Confirm moves toggle setting
  ///
  /// In en, this message translates to:
  /// **'Confirm Moves'**
  String get confirmMoves;

  /// Master volume setting
  ///
  /// In en, this message translates to:
  /// **'Master Volume'**
  String get masterVolume;

  /// Push notifications toggle setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Privacy policy setting
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Online status toggle setting
  ///
  /// In en, this message translates to:
  /// **'Online Status'**
  String get onlineStatus;

  /// Online status setting description
  ///
  /// In en, this message translates to:
  /// **'Visible to friends only'**
  String get onlineStatusDescription;

  /// Log out button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Membership button
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// General section header
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// Grandmaster rank title
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get grandmaster;

  /// Rating position text with placeholder
  ///
  /// In en, this message translates to:
  /// **'Rating Position: #{position}'**
  String ratingPosition(int position);

  /// Error loading settings
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// Error message when language settings fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading language settings'**
  String get errorLoadingLanguageSettings;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// App version text
  ///
  /// In en, this message translates to:
  /// **'Chess Arena v2.4.1 (Build 890)'**
  String get appVersion;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Events navigation label
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// Chat navigation label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Rating card title
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Collection card title
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// Friends card title
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Collection card subtitle
  ///
  /// In en, this message translates to:
  /// **'Skins & Boards'**
  String get skinsAndBoards;

  /// Online status label
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Settings card subtitle
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Variation games card title
  ///
  /// In en, this message translates to:
  /// **'Variation Games'**
  String get variationGames;

  /// Variation games card description
  ///
  /// In en, this message translates to:
  /// **'RPS, Blitz, Bullet & Chaos Modes'**
  String get variationGamesDescription;

  /// Tournament games card title
  ///
  /// In en, this message translates to:
  /// **'Tournament Games'**
  String get tournamentGames;

  /// Tournament games card description
  ///
  /// In en, this message translates to:
  /// **'Compete in daily events and win exclusive skins.'**
  String get tournamentGamesDescription;

  /// Featured badge text
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get featured;

  /// Live badge text
  ///
  /// In en, this message translates to:
  /// **'• LIVE'**
  String get live;

  /// Level text with placeholder
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// Novice rank title
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get novice;

  /// MMR rating text with placeholder
  ///
  /// In en, this message translates to:
  /// **'{rating} MMR'**
  String mmr(int rating);

  /// App title on game selection
  ///
  /// In en, this message translates to:
  /// **'Chess RPS'**
  String get chessRps;

  /// Game mode selection title
  ///
  /// In en, this message translates to:
  /// **'Select Game Mode'**
  String get selectGameMode;

  /// Classical chess mode option
  ///
  /// In en, this message translates to:
  /// **'Classical Mode'**
  String get classicalMode;

  /// Rock Paper Scissors mode option
  ///
  /// In en, this message translates to:
  /// **'RPS Mode'**
  String get rpsMode;

  /// Opponent selection title
  ///
  /// In en, this message translates to:
  /// **'Select Opponent'**
  String get selectOpponent;

  /// Opponent selection description
  ///
  /// In en, this message translates to:
  /// **'Choose who you want to play with'**
  String get chooseOpponentDescription;

  /// Play against AI option
  ///
  /// In en, this message translates to:
  /// **'Play with AI'**
  String get playWithAI;

  /// Coming soon text for unavailable features
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Play online option
  ///
  /// In en, this message translates to:
  /// **'Play Online'**
  String get playOnline;

  /// Error message when matchmaking fails
  ///
  /// In en, this message translates to:
  /// **'Failed to find match: {error}'**
  String failedToFindMatch(String error);

  /// Message when player wins RPS
  ///
  /// In en, this message translates to:
  /// **'You won RPS! Make your move'**
  String get youWonRps;

  /// Message when opponent wins RPS
  ///
  /// In en, this message translates to:
  /// **'Opponent won RPS. Waiting...'**
  String get opponentWonRps;

  /// Draw game result
  ///
  /// In en, this message translates to:
  /// **'Draw!'**
  String get draw;

  /// Victory game result
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get victory;

  /// Defeat game result
  ///
  /// In en, this message translates to:
  /// **'Defeat'**
  String get defeat;

  /// Stalemate result message
  ///
  /// In en, this message translates to:
  /// **'The game ended in a stalemate.\nNeither player wins.'**
  String get stalemateMessage;

  /// Draw result message
  ///
  /// In en, this message translates to:
  /// **'The game ended in a draw.'**
  String get drawMessage;

  /// Checkmate victory message
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You won by checkmate!'**
  String get checkmateWin;

  /// General victory message
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You won!'**
  String get winMessage;

  /// Checkmate loss message
  ///
  /// In en, this message translates to:
  /// **'You were checkmated.\nBetter luck next time!'**
  String get checkmateLoss;

  /// General loss message
  ///
  /// In en, this message translates to:
  /// **'You lost the game.\nBetter luck next time!'**
  String get lossMessage;

  /// Experience label
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// XP gained text with placeholder
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpGained(int xp);

  /// Return to menu button
  ///
  /// In en, this message translates to:
  /// **'Return to Menu'**
  String get returnToMenu;

  /// Finish game dialog title
  ///
  /// In en, this message translates to:
  /// **'Finish Game?'**
  String get finishGame;

  /// Warning label
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Finish game warning message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish this game?\nYour progress will be lost.'**
  String get finishGameWarning;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Side selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Side'**
  String get chooseYourSide;

  /// Side selection description
  ///
  /// In en, this message translates to:
  /// **'White always moves first'**
  String get whiteMovesFirst;

  /// White side option
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// Black side option
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// Randomize side option
  ///
  /// In en, this message translates to:
  /// **'Randomize'**
  String get randomize;

  /// Player moves first indicator
  ///
  /// In en, this message translates to:
  /// **'Moves First'**
  String get movesFirst;

  /// AI moves first indicator
  ///
  /// In en, this message translates to:
  /// **'AI Moves First'**
  String get aiMovesFirst;

  /// AI difficulty selection title
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// AI difficulty selection description
  ///
  /// In en, this message translates to:
  /// **'Choose the AI difficulty level'**
  String get chooseAIDifficulty;

  /// Beginner difficulty level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Beginner difficulty description
  ///
  /// In en, this message translates to:
  /// **'Perfect for learning the basics'**
  String get beginnerDescription;

  /// Easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// Easy difficulty description
  ///
  /// In en, this message translates to:
  /// **'A gentle challenge'**
  String get easyDescription;

  /// Medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Medium difficulty description
  ///
  /// In en, this message translates to:
  /// **'A balanced opponent'**
  String get mediumDescription;

  /// Hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// Hard difficulty description
  ///
  /// In en, this message translates to:
  /// **'A tough challenge'**
  String get hardDescription;

  /// Expert difficulty level
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// Expert difficulty description
  ///
  /// In en, this message translates to:
  /// **'Maximum difficulty'**
  String get expertDescription;

  /// Login screen welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// Phone number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// Phone number minimum digits error
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain at least 10 digits'**
  String get phoneNumberMinDigits;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Password minimum length hint
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMinLength;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password minimum characters error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinCharacters;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// Confirm password validation error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign up prompt text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Create account title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Sign up screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpToGetStarted;

  /// Waiting room title
  ///
  /// In en, this message translates to:
  /// **'Waiting for Opponent'**
  String get waitingForOpponent;

  /// Connecting status
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Room code label
  ///
  /// In en, this message translates to:
  /// **'Room Code'**
  String get roomCode;

  /// Connecting to room message
  ///
  /// In en, this message translates to:
  /// **'Connecting to room...'**
  String get connectingToRoom;

  /// Please wait message
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// Waiting for opponent message
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent...'**
  String get waitingForOpponentMessage;

  /// Searching for opponent message
  ///
  /// In en, this message translates to:
  /// **'We are searching for an opponent for you...'**
  String get searchingForOpponent;

  /// Failed to connect error message
  ///
  /// In en, this message translates to:
  /// **'Failed to connect: {error}'**
  String failedToConnect(String error);

  /// Events screen season title
  ///
  /// In en, this message translates to:
  /// **'Season 4: Shadow Gambit'**
  String get season4ShadowGambit;

  /// Live event badge
  ///
  /// In en, this message translates to:
  /// **'LIVE NOW'**
  String get liveNow;

  /// Grand Prix event title
  ///
  /// In en, this message translates to:
  /// **'Grand Prix 2024'**
  String get grandPrix2024;

  /// Grand Prix event description
  ///
  /// In en, this message translates to:
  /// **'The ultimate rapid chess showdown. Watch grandmasters battle for the throne.'**
  String get grandPrixDescription;

  /// Watch stream button
  ///
  /// In en, this message translates to:
  /// **'Watch Stream'**
  String get watchStream;

  /// Details button
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// All events filter tab
  ///
  /// In en, this message translates to:
  /// **'All Events'**
  String get allEvents;

  /// Challenges filter tab
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// Community filter tab
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// Weekly Blitz event name
  ///
  /// In en, this message translates to:
  /// **'Weekly Blitz'**
  String get weeklyBlitz;

  /// Event start time
  ///
  /// In en, this message translates to:
  /// **'Starts in {time}'**
  String startsIn(String time);

  /// Blitz arena format
  ///
  /// In en, this message translates to:
  /// **'{time} Blitz Arena'**
  String blitzArena(String time);

  /// Event prize amount
  ///
  /// In en, this message translates to:
  /// **'{amount} Prize'**
  String prize(String amount);

  /// Event participants count
  ///
  /// In en, this message translates to:
  /// **'{current}/{max}'**
  String participants(String current, String max);

  /// Registration open status
  ///
  /// In en, this message translates to:
  /// **'Registration Open'**
  String get registrationOpen;

  /// Daily challenge badge
  ///
  /// In en, this message translates to:
  /// **'DAILY CHALLENGE'**
  String get dailyChallenge;

  /// Mate in 3 puzzle title
  ///
  /// In en, this message translates to:
  /// **'Mate in 3 Puzzle'**
  String get mateIn3Puzzle;

  /// Solve puzzle description
  ///
  /// In en, this message translates to:
  /// **'Solve today\'s hardest puzzle to earn points.'**
  String get solvePuzzleDescription;

  /// Club Wars event name
  ///
  /// In en, this message translates to:
  /// **'Club Wars'**
  String get clubWars;

  /// Team vs Team event description
  ///
  /// In en, this message translates to:
  /// **'Team vs Team • Starts in {days} days'**
  String teamVsTeam(int days);

  /// Join button
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Top standings section title
  ///
  /// In en, this message translates to:
  /// **'Top Standings'**
  String get topStandings;

  /// View all button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No standings available message
  ///
  /// In en, this message translates to:
  /// **'No standings available'**
  String get noStandingsAvailable;

  /// Failed to load standings error
  ///
  /// In en, this message translates to:
  /// **'Failed to load standings'**
  String get failedToLoadStandings;

  /// Player column header
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// Tournaments screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Compete and climb the rankings'**
  String get competeAndClimb;

  /// All modes filter option
  ///
  /// In en, this message translates to:
  /// **'All Modes'**
  String get allModes;

  /// Classical game mode
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get classical;

  /// All status filter option
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// In progress status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Finished status
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No tournaments found message
  ///
  /// In en, this message translates to:
  /// **'No tournaments found'**
  String get noTournamentsFound;

  /// Create new tournament prompt
  ///
  /// In en, this message translates to:
  /// **'Create a new tournament to get started'**
  String get createNewTournament;

  /// Failed to load tournaments error
  ///
  /// In en, this message translates to:
  /// **'Failed to load tournaments: {error}'**
  String failedToLoadTournaments(String error);

  /// Single elimination format
  ///
  /// In en, this message translates to:
  /// **'Single Elim'**
  String get singleElim;

  /// Double elimination format
  ///
  /// In en, this message translates to:
  /// **'Double Elim'**
  String get doubleElim;

  /// Swiss format
  ///
  /// In en, this message translates to:
  /// **'Swiss'**
  String get swiss;

  /// Round robin format
  ///
  /// In en, this message translates to:
  /// **'Round Robin'**
  String get roundRobin;

  /// Registration ended message
  ///
  /// In en, this message translates to:
  /// **'Registration ended'**
  String get registrationEnded;

  /// Starts in days
  ///
  /// In en, this message translates to:
  /// **'Starts in {days} day{plural}'**
  String startsInDays(int days, String plural);

  /// Starts in hours
  ///
  /// In en, this message translates to:
  /// **'Starts in {hours} hour{plural}'**
  String startsInHours(int hours, String plural);

  /// Starts in minutes
  ///
  /// In en, this message translates to:
  /// **'Starts in {minutes} minute{plural}'**
  String startsInMinutes(int minutes, String plural);

  /// Ends in days
  ///
  /// In en, this message translates to:
  /// **'Ends in {days} day{plural}'**
  String endsInDays(int days, String plural);

  /// Ends in hours
  ///
  /// In en, this message translates to:
  /// **'Ends in {hours} hour{plural}'**
  String endsInHours(int hours, String plural);

  /// Ends in minutes
  ///
  /// In en, this message translates to:
  /// **'Ends in {minutes} minute{plural}'**
  String endsInMinutes(int minutes, String plural);

  /// Soon time indicator
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get soon;

  /// Cancelled status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Player profile header
  ///
  /// In en, this message translates to:
  /// **'PLAYER PROFILE'**
  String get playerProfile;

  /// Error loading profile message
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// Win rate stat label
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// Streak stat label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Best value label
  ///
  /// In en, this message translates to:
  /// **'Best: {value}'**
  String best(String value);

  /// Games count
  ///
  /// In en, this message translates to:
  /// **'{count} Games'**
  String games(int count);

  /// Performance section title
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// Weekly time filter
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly time filter
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No performance data message
  ///
  /// In en, this message translates to:
  /// **'No performance data for {period} period'**
  String noPerformanceData(String period);

  /// No performance data yet message
  ///
  /// In en, this message translates to:
  /// **'No performance data yet'**
  String get noPerformanceDataYet;

  /// Error loading performance data
  ///
  /// In en, this message translates to:
  /// **'Error loading performance data'**
  String get errorLoadingPerformance;

  /// Achievements section title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Grandmaster achievement title
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get grandmasterAchievement;

  /// Reach 2500 MMR achievement description
  ///
  /// In en, this message translates to:
  /// **'Reach 2500 MMR'**
  String get reach2500MMR;

  /// On Fire achievement title
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get onFire;

  /// 10 win streak achievement description
  ///
  /// In en, this message translates to:
  /// **'10 Win Streak'**
  String get winStreak10;

  /// Puzzle Master achievement title
  ///
  /// In en, this message translates to:
  /// **'Puzzle Master'**
  String get puzzleMaster;

  /// Solve 1000 puzzles achievement description
  ///
  /// In en, this message translates to:
  /// **'Solve 1000 Puzzles'**
  String get solve1000Puzzles;

  /// Showcase section title
  ///
  /// In en, this message translates to:
  /// **'Showcase'**
  String get showcase;

  /// Void Spirit Knight showcase item
  ///
  /// In en, this message translates to:
  /// **'Void Spirit Knight'**
  String get voidSpiritKnight;

  /// Legendary skin label
  ///
  /// In en, this message translates to:
  /// **'Legendary Skin'**
  String get legendarySkin;

  /// Nebula Queen showcase item
  ///
  /// In en, this message translates to:
  /// **'Nebula Queen'**
  String get nebulaQueen;

  /// Epic skin label
  ///
  /// In en, this message translates to:
  /// **'Epic Skin'**
  String get epicSkin;

  /// Enter name hint
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// Name cannot be empty error
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// Profile name updated message
  ///
  /// In en, this message translates to:
  /// **'Profile name updated'**
  String get profileNameUpdated;

  /// Failed to update profile name error
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile name'**
  String get failedToUpdateProfileName;

  /// Add friends dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Friends'**
  String get addFriends;

  /// Search for friends message
  ///
  /// In en, this message translates to:
  /// **'Search for friends'**
  String get searchForFriends;

  /// Enter at least 3 characters hint
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters to search for users'**
  String get enterAtLeast3Characters;

  /// Error searching users
  ///
  /// In en, this message translates to:
  /// **'Error searching users'**
  String get errorSearchingUsers;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Already friends status
  ///
  /// In en, this message translates to:
  /// **'Already friends'**
  String get alreadyFriends;

  /// Request pending status
  ///
  /// In en, this message translates to:
  /// **'Request pending'**
  String get requestPending;

  /// Not friends status
  ///
  /// In en, this message translates to:
  /// **'Not friends'**
  String get notFriends;

  /// Friend request sent message
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSent;

  /// Failed to send request error
  ///
  /// In en, this message translates to:
  /// **'Failed to send request: {error}'**
  String failedToSendRequest(String error);

  /// Search by phone or ID hint
  ///
  /// In en, this message translates to:
  /// **'Search by phone number or user ID (min 3 characters)...'**
  String get searchByPhoneOrId;

  /// Search users tab
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// My friends tab
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get myFriends;

  /// Requests section header
  ///
  /// In en, this message translates to:
  /// **'REQUESTS'**
  String get requests;

  /// Pending requests count
  ///
  /// In en, this message translates to:
  /// **'{count} Pending'**
  String pending(int count);

  /// Sent you a request message
  ///
  /// In en, this message translates to:
  /// **'Sent you a request • {timeAgo}'**
  String sentYouARequest(String timeAgo);

  /// Friend request accepted message
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get friendRequestAccepted;

  /// Failed to accept request error
  ///
  /// In en, this message translates to:
  /// **'Failed to accept request: {error}'**
  String failedToAcceptRequest(String error);

  /// Friend request declined message
  ///
  /// In en, this message translates to:
  /// **'Friend request declined'**
  String get friendRequestDeclined;

  /// Failed to decline request error
  ///
  /// In en, this message translates to:
  /// **'Failed to decline request: {error}'**
  String failedToDeclineRequest(String error);

  /// No friends yet message
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// Add friends to challenge message
  ///
  /// In en, this message translates to:
  /// **'Add friends to challenge them to games'**
  String get addFriendsToChallenge;

  /// Error loading friends
  ///
  /// In en, this message translates to:
  /// **'Error loading friends'**
  String get errorLoadingFriends;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// In game status
  ///
  /// In en, this message translates to:
  /// **'In Game'**
  String get inGame;

  /// Online friends section header
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get onlineFriends;

  /// Offline friends section header
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offlineFriends;

  /// No users found message
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// Try different query message
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different query. Make sure to enter at least 3 characters.'**
  String get tryDifferentQuery;

  /// Discover users section header
  ///
  /// In en, this message translates to:
  /// **'DISCOVER USERS'**
  String get discoverUsers;

  /// Users count
  ///
  /// In en, this message translates to:
  /// **'{count} users'**
  String users(int count);

  /// No users available message
  ///
  /// In en, this message translates to:
  /// **'No users available'**
  String get noUsersAvailable;

  /// Try searching for users message
  ///
  /// In en, this message translates to:
  /// **'Try searching for specific users'**
  String get trySearchingForUsers;

  /// Error loading users
  ///
  /// In en, this message translates to:
  /// **'Error loading users'**
  String get errorLoadingUsers;

  /// Enter phone or user ID hint
  ///
  /// In en, this message translates to:
  /// **'Enter phone number or user ID'**
  String get enterPhoneNumberOrUserId;

  /// Rating overview title
  ///
  /// In en, this message translates to:
  /// **'Rating Overview'**
  String get ratingOverview;

  /// Error loading rating error
  ///
  /// In en, this message translates to:
  /// **'Error loading rating'**
  String get errorLoadingRating;

  /// Go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Current level label
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// History section title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Mode breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Mode Breakdown'**
  String get modeBreakdown;

  /// Standard chess description
  ///
  /// In en, this message translates to:
  /// **'Standard Chess'**
  String get standardChess;

  /// Rock Paper Scissors description
  ///
  /// In en, this message translates to:
  /// **'Rock Paper Scissors'**
  String get rockPaperScissors;

  /// Pieces tab label
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// Boards tab label
  ///
  /// In en, this message translates to:
  /// **'Boards'**
  String get boards;

  /// Avatars tab label
  ///
  /// In en, this message translates to:
  /// **'Avatars'**
  String get avatars;

  /// Effects tab label
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get effects;

  /// Available piece sets title
  ///
  /// In en, this message translates to:
  /// **'Available Piece Sets ({count})'**
  String availablePieceSets(int count);

  /// Selected item label
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String selected(String name);

  /// Select button
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Available avatars title
  ///
  /// In en, this message translates to:
  /// **'Available Avatars (20)'**
  String get availableAvatars;

  /// Available board themes title
  ///
  /// In en, this message translates to:
  /// **'Available Board Themes ({count})'**
  String availableBoardThemes(int count);

  /// Available effects title
  ///
  /// In en, this message translates to:
  /// **'Available Effects ({count})'**
  String availableEffects(int count);

  /// Selected classic label
  ///
  /// In en, this message translates to:
  /// **'Selected: Classic'**
  String get selectedClassic;

  /// My category items title
  ///
  /// In en, this message translates to:
  /// **'My {category}'**
  String myPieces(String category);

  /// Sort by rarity label
  ///
  /// In en, this message translates to:
  /// **'Sort by: Rarity'**
  String get sortByRarity;

  /// Equipped badge
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get equipped;

  /// Unlock at level label
  ///
  /// In en, this message translates to:
  /// **'Unlock at Lvl {level}'**
  String unlockAtLevel(int level);

  /// Item equipped message
  ///
  /// In en, this message translates to:
  /// **'{name} equipped!'**
  String equippedItem(String name);

  /// Failed to equip error
  ///
  /// In en, this message translates to:
  /// **'Failed to equip: {error}'**
  String failedToEquip(String error);

  /// Customize button
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// Get more button
  ///
  /// In en, this message translates to:
  /// **'Get More'**
  String get getMore;

  /// Visit the shop label
  ///
  /// In en, this message translates to:
  /// **'Visit the Shop'**
  String get visitTheShop;

  /// Error loading collection
  ///
  /// In en, this message translates to:
  /// **'Error loading collection'**
  String get errorLoadingCollection;

  /// Error loading items
  ///
  /// In en, this message translates to:
  /// **'Error loading items'**
  String get errorLoadingItems;

  /// Selected and saved message
  ///
  /// In en, this message translates to:
  /// **'{name} selected and saved'**
  String selectedAndSaved(String name);

  /// Failed to select error
  ///
  /// In en, this message translates to:
  /// **'Failed to select {item}: {error}'**
  String failedToSelect(String item, String error);

  /// Currently selected label
  ///
  /// In en, this message translates to:
  /// **'Currently Selected'**
  String get currentlySelected;

  /// Select this effect button
  ///
  /// In en, this message translates to:
  /// **'Select This Effect'**
  String get selectThisEffect;

  /// Select this theme button
  ///
  /// In en, this message translates to:
  /// **'Select This Theme'**
  String get selectThisTheme;

  /// Light square label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark square label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Levels and titles screen title
  ///
  /// In en, this message translates to:
  /// **'Levels & Titles'**
  String get levelsAndTitles;

  /// Failed to load levels error
  ///
  /// In en, this message translates to:
  /// **'Failed to load levels'**
  String get failedToLoadLevels;

  /// All levels section title
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevels;

  /// Current level badge
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// XP to unlock label
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to unlock'**
  String xpToUnlock(int xp);

  /// Global lobby channel
  ///
  /// In en, this message translates to:
  /// **'Global Lobby'**
  String get globalLobby;

  /// Clan channel
  ///
  /// In en, this message translates to:
  /// **'Clan'**
  String get clan;

  /// Mentions channel
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get mentions;

  /// Today date divider
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Welcome to global strategy channel message
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Global Strategy Channel'**
  String get welcomeToGlobalStrategy;

  /// You label
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Replying to you label
  ///
  /// In en, this message translates to:
  /// **'Replying to you'**
  String get replyingToYou;

  /// Type a message hint
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// Leaderboard screen title
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No leaderboard data message
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data available'**
  String get noLeaderboardData;

  /// Error loading leaderboard message
  ///
  /// In en, this message translates to:
  /// **'Error loading leaderboard'**
  String get errorLoadingLeaderboard;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
