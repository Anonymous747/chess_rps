// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Chess Arena';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get account => 'ACCOUNT';

  @override
  String get gameplay => 'GAMEPLAY';

  @override
  String get audioAndSync => 'AUDIO & SYNC';

  @override
  String get privacy => 'PRIVACY';

  @override
  String get boardTheme => 'Board Theme';

  @override
  String get pieceSet => 'Piece Set';

  @override
  String get autoQueen => 'Auto-Queen';

  @override
  String get autoQueenDescription => 'Automatically promote to Queen';

  @override
  String get confirmMoves => 'Confirm Moves';

  @override
  String get masterVolume => 'Master Volume';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get onlineStatus => 'Online Status';

  @override
  String get onlineStatusDescription => 'Visible to friends only';

  @override
  String get logout => 'Log Out';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get membership => 'Membership';

  @override
  String get general => 'GENERAL';

  @override
  String get grandmaster => 'Grandmaster';

  @override
  String ratingPosition(int position) {
    return 'Rating Position: #$position';
  }

  @override
  String get errorLoadingSettings => 'Error loading settings';

  @override
  String get errorLoadingLanguageSettings => 'Error loading language settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get appVersion => 'Chess Arena v2.4.1 (Build 890)';

  @override
  String get home => 'Home';

  @override
  String get events => 'Events';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get rating => 'Rating';

  @override
  String get collection => 'Collection';

  @override
  String get friends => 'Friends';

  @override
  String get skinsAndBoards => 'Skins & Boards';

  @override
  String get online => 'Online';

  @override
  String get preferences => 'Preferences';

  @override
  String get variationGames => 'Variation Games';

  @override
  String get variationGamesDescription => 'RPS, Blitz, Bullet & Chaos Modes';

  @override
  String get tournamentGames => 'Tournament Games';

  @override
  String get tournamentGamesDescription => 'Compete in daily events and win exclusive skins.';

  @override
  String get featured => 'FEATURED';

  @override
  String get live => '• LIVE';

  @override
  String level(int level) {
    return 'Level $level';
  }

  @override
  String get novice => 'Novice';

  @override
  String mmr(int rating) {
    return '$rating MMR';
  }

  @override
  String get chessRps => 'Chess RPS';

  @override
  String get selectGameMode => 'Select Game Mode';

  @override
  String get classicalMode => 'Classical Mode';

  @override
  String get rpsMode => 'RPS Mode';

  @override
  String get selectOpponent => 'Select Opponent';

  @override
  String get chooseOpponentDescription => 'Choose who you want to play with';

  @override
  String get playWithAI => 'Play with AI';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get playOnline => 'Play Online';

  @override
  String failedToFindMatch(String error) {
    return 'Failed to find match: $error';
  }

  @override
  String get youWonRps => 'You won RPS! Make your move';

  @override
  String get opponentWonRps => 'Opponent won RPS. Waiting...';

  @override
  String get draw => 'Draw!';

  @override
  String get victory => 'Victory!';

  @override
  String get defeat => 'Defeat';

  @override
  String get stalemateMessage => 'The game ended in a stalemate.\nNeither player wins.';

  @override
  String get drawMessage => 'The game ended in a draw.';

  @override
  String get checkmateWin => 'Congratulations! You won by checkmate!';

  @override
  String get winMessage => 'Congratulations! You won!';

  @override
  String get checkmateLoss => 'You were checkmated.\nBetter luck next time!';

  @override
  String get lossMessage => 'You lost the game.\nBetter luck next time!';

  @override
  String get experience => 'Experience';

  @override
  String xpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get returnToMenu => 'Return to Menu';

  @override
  String get finishGame => 'Finish Game?';

  @override
  String get warning => 'Warning';

  @override
  String get finishGameWarning => 'Are you sure you want to finish this game?\nYour progress will be lost.';

  @override
  String get finish => 'Finish';

  @override
  String get chooseYourSide => 'Choose Your Side';

  @override
  String get whiteMovesFirst => 'White always moves first';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get randomize => 'Randomize';

  @override
  String get movesFirst => 'Moves First';

  @override
  String get aiMovesFirst => 'AI Moves First';

  @override
  String get selectDifficulty => 'Select Difficulty';

  @override
  String get chooseAIDifficulty => 'Choose the AI difficulty level';

  @override
  String get beginner => 'Beginner';

  @override
  String get beginnerDescription => 'Perfect for learning the basics';

  @override
  String get easy => 'Easy';

  @override
  String get easyDescription => 'A gentle challenge';

  @override
  String get medium => 'Medium';

  @override
  String get mediumDescription => 'A balanced opponent';

  @override
  String get hard => 'Hard';

  @override
  String get hardDescription => 'A tough challenge';

  @override
  String get expert => 'Expert';

  @override
  String get expertDescription => 'Maximum difficulty';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get phoneNumberMinDigits => 'Phone number must contain at least 10 digits';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get passwordMinLength => 'At least 8 characters';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinCharacters => 'Password must be at least 8 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get reenterPassword => 'Re-enter your password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpToGetStarted => 'Sign up to get started';

  @override
  String get waitingForOpponent => 'Waiting for Opponent';

  @override
  String get connecting => 'Connecting...';

  @override
  String get roomCode => 'Room Code';

  @override
  String get connectingToRoom => 'Connecting to room...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get waitingForOpponentMessage => 'Waiting for opponent...';

  @override
  String get searchingForOpponent => 'We are searching for an opponent for you...';

  @override
  String failedToConnect(String error) {
    return 'Failed to connect: $error';
  }

  @override
  String get season4ShadowGambit => 'Season 4: Shadow Gambit';

  @override
  String get liveNow => 'LIVE NOW';

  @override
  String get grandPrix2024 => 'Grand Prix 2024';

  @override
  String get grandPrixDescription => 'The ultimate rapid chess showdown. Watch grandmasters battle for the throne.';

  @override
  String get watchStream => 'Watch Stream';

  @override
  String get details => 'Details';

  @override
  String get allEvents => 'All Events';

  @override
  String get challenges => 'Challenges';

  @override
  String get community => 'Community';

  @override
  String get weeklyBlitz => 'Weekly Blitz';

  @override
  String startsIn(String time) {
    return 'Starts in $time';
  }

  @override
  String blitzArena(String time) {
    return '$time Blitz Arena';
  }

  @override
  String prize(String amount) {
    return '$amount Prize';
  }

  @override
  String participants(String current, String max) {
    return '$current/$max';
  }

  @override
  String get registrationOpen => 'Registration Open';

  @override
  String get dailyChallenge => 'DAILY CHALLENGE';

  @override
  String get mateIn3Puzzle => 'Mate in 3 Puzzle';

  @override
  String get solvePuzzleDescription => 'Solve today\'s hardest puzzle to earn points.';

  @override
  String get clubWars => 'Club Wars';

  @override
  String teamVsTeam(int days) {
    return 'Team vs Team • Starts in $days days';
  }

  @override
  String get join => 'Join';

  @override
  String get topStandings => 'Top Standings';

  @override
  String get viewAll => 'View All';

  @override
  String get noStandingsAvailable => 'No standings available';

  @override
  String get failedToLoadStandings => 'Failed to load standings';

  @override
  String get player => 'Player';

  @override
  String get competeAndClimb => 'Compete and climb the rankings';

  @override
  String get allModes => 'All Modes';

  @override
  String get classical => 'Classical';

  @override
  String get allStatus => 'All Status';

  @override
  String get inProgress => 'In Progress';

  @override
  String get finished => 'Finished';

  @override
  String get noTournamentsFound => 'No tournaments found';

  @override
  String get createNewTournament => 'Create a new tournament to get started';

  @override
  String failedToLoadTournaments(String error) {
    return 'Failed to load tournaments: $error';
  }

  @override
  String get singleElim => 'Single Elim';

  @override
  String get doubleElim => 'Double Elim';

  @override
  String get swiss => 'Swiss';

  @override
  String get roundRobin => 'Round Robin';

  @override
  String get registrationEnded => 'Registration ended';

  @override
  String startsInDays(int days, String plural) {
    return 'Starts in $days day$plural';
  }

  @override
  String startsInHours(int hours, String plural) {
    return 'Starts in $hours hour$plural';
  }

  @override
  String startsInMinutes(int minutes, String plural) {
    return 'Starts in $minutes minute$plural';
  }

  @override
  String endsInDays(int days, String plural) {
    return 'Ends in $days day$plural';
  }

  @override
  String endsInHours(int hours, String plural) {
    return 'Ends in $hours hour$plural';
  }

  @override
  String endsInMinutes(int minutes, String plural) {
    return 'Ends in $minutes minute$plural';
  }

  @override
  String get soon => 'soon';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get playerProfile => 'PLAYER PROFILE';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get winRate => 'Win Rate';

  @override
  String get streak => 'Streak';

  @override
  String best(String value) {
    return 'Best: $value';
  }

  @override
  String games(int count) {
    return '$count Games';
  }

  @override
  String get performance => 'Performance';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String noPerformanceData(String period) {
    return 'No performance data for $period period';
  }

  @override
  String get noPerformanceDataYet => 'No performance data yet';

  @override
  String get errorLoadingPerformance => 'Error loading performance data';

  @override
  String get achievements => 'Achievements';

  @override
  String get grandmasterAchievement => 'Grandmaster';

  @override
  String get reach2500MMR => 'Reach 2500 MMR';

  @override
  String get onFire => 'On Fire';

  @override
  String get winStreak10 => '10 Win Streak';

  @override
  String get puzzleMaster => 'Puzzle Master';

  @override
  String get solve1000Puzzles => 'Solve 1000 Puzzles';

  @override
  String get showcase => 'Showcase';

  @override
  String get voidSpiritKnight => 'Void Spirit Knight';

  @override
  String get legendarySkin => 'Legendary Skin';

  @override
  String get nebulaQueen => 'Nebula Queen';

  @override
  String get epicSkin => 'Epic Skin';

  @override
  String get enterName => 'Enter name';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get profileNameUpdated => 'Profile name updated';

  @override
  String get failedToUpdateProfileName => 'Failed to update profile name';

  @override
  String get addFriends => 'Add Friends';

  @override
  String get searchForFriends => 'Search for friends';

  @override
  String get enterAtLeast3Characters => 'Enter at least 3 characters to search for users';

  @override
  String get errorSearchingUsers => 'Error searching users';

  @override
  String get tryAgain => 'Try again';

  @override
  String get alreadyFriends => 'Already friends';

  @override
  String get requestPending => 'Request pending';

  @override
  String get notFriends => 'Not friends';

  @override
  String get friendRequestSent => 'Friend request sent';

  @override
  String failedToSendRequest(String error) {
    return 'Failed to send request: $error';
  }

  @override
  String get searchByPhoneOrId => 'Search by phone number or user ID (min 3 characters)...';

  @override
  String get searchUsers => 'Search Users';

  @override
  String get myFriends => 'My Friends';

  @override
  String get requests => 'REQUESTS';

  @override
  String pending(int count) {
    return '$count Pending';
  }

  @override
  String sentYouARequest(String timeAgo) {
    return 'Sent you a request • $timeAgo';
  }

  @override
  String get friendRequestAccepted => 'Friend request accepted';

  @override
  String failedToAcceptRequest(String error) {
    return 'Failed to accept request: $error';
  }

  @override
  String get friendRequestDeclined => 'Friend request declined';

  @override
  String failedToDeclineRequest(String error) {
    return 'Failed to decline request: $error';
  }

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get addFriendsToChallenge => 'Add friends to challenge them to games';

  @override
  String get errorLoadingFriends => 'Error loading friends';

  @override
  String get retry => 'Retry';

  @override
  String get offline => 'Offline';

  @override
  String get inGame => 'In Game';

  @override
  String get onlineFriends => 'ONLINE';

  @override
  String get offlineFriends => 'OFFLINE';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get tryDifferentQuery => 'Try searching with a different query. Make sure to enter at least 3 characters.';

  @override
  String get discoverUsers => 'DISCOVER USERS';

  @override
  String users(int count) {
    return '$count users';
  }

  @override
  String get noUsersAvailable => 'No users available';

  @override
  String get trySearchingForUsers => 'Try searching for specific users';

  @override
  String get errorLoadingUsers => 'Error loading users';

  @override
  String get enterPhoneNumberOrUserId => 'Enter phone number or user ID';

  @override
  String get ratingOverview => 'Rating Overview';

  @override
  String get errorLoadingRating => 'Error loading rating';

  @override
  String get goBack => 'Go Back';

  @override
  String get currentLevel => 'Current Level';

  @override
  String get history => 'History';

  @override
  String get modeBreakdown => 'Mode Breakdown';

  @override
  String get standardChess => 'Standard Chess';

  @override
  String get rockPaperScissors => 'Rock Paper Scissors';

  @override
  String get pieces => 'Pieces';

  @override
  String get boards => 'Boards';

  @override
  String get avatars => 'Avatars';

  @override
  String get effects => 'Effects';

  @override
  String availablePieceSets(int count) {
    return 'Available Piece Sets ($count)';
  }

  @override
  String selected(String name) {
    return 'Selected: $name';
  }

  @override
  String get select => 'Select';

  @override
  String get availableAvatars => 'Available Avatars (20)';

  @override
  String availableBoardThemes(int count) {
    return 'Available Board Themes ($count)';
  }

  @override
  String availableEffects(int count) {
    return 'Available Effects ($count)';
  }

  @override
  String get selectedClassic => 'Selected: Classic';

  @override
  String myPieces(String category) {
    return 'My $category';
  }

  @override
  String get sortByRarity => 'Sort by: Rarity';

  @override
  String get equipped => 'Equipped';

  @override
  String unlockAtLevel(int level) {
    return 'Unlock at Lvl $level';
  }

  @override
  String equippedItem(String name) {
    return '$name equipped!';
  }

  @override
  String failedToEquip(String error) {
    return 'Failed to equip: $error';
  }

  @override
  String get customize => 'Customize';

  @override
  String get getMore => 'Get More';

  @override
  String get visitTheShop => 'Visit the Shop';

  @override
  String get errorLoadingCollection => 'Error loading collection';

  @override
  String get errorLoadingItems => 'Error loading items';

  @override
  String selectedAndSaved(String name) {
    return '$name selected and saved';
  }

  @override
  String failedToSelect(String item, String error) {
    return 'Failed to select $item: $error';
  }

  @override
  String get currentlySelected => 'Currently Selected';

  @override
  String get selectThisEffect => 'Select This Effect';

  @override
  String get selectThisTheme => 'Select This Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get levelsAndTitles => 'Levels & Titles';

  @override
  String get failedToLoadLevels => 'Failed to load levels';

  @override
  String get allLevels => 'All Levels';

  @override
  String get current => 'CURRENT';

  @override
  String xpToUnlock(int xp) {
    return '$xp XP to unlock';
  }

  @override
  String get globalLobby => 'Global Lobby';

  @override
  String get clan => 'Clan';

  @override
  String get mentions => 'Mentions';

  @override
  String get today => 'Today';

  @override
  String get welcomeToGlobalStrategy => 'Welcome to the Global Strategy Channel';

  @override
  String get you => 'You';

  @override
  String get replyingToYou => 'Replying to you';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get noLeaderboardData => 'No leaderboard data available';

  @override
  String get errorLoadingLeaderboard => 'Error loading leaderboard';
}
