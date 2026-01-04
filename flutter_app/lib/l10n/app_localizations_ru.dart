// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Шахматная Арена';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get english => 'Английский';

  @override
  String get russian => 'Русский';

  @override
  String get account => 'АККАУНТ';

  @override
  String get gameplay => 'ИГРОВОЙ ПРОЦЕСС';

  @override
  String get audioAndSync => 'АУДИО И СИНХРОНИЗАЦИЯ';

  @override
  String get privacy => 'ПРИВАТНОСТЬ';

  @override
  String get boardTheme => 'Тема доски';

  @override
  String get pieceSet => 'Набор фигур';

  @override
  String get autoQueen => 'Автоматический ферзь';

  @override
  String get autoQueenDescription => 'Автоматически повышать до ферзя';

  @override
  String get confirmMoves => 'Подтверждать ходы';

  @override
  String get masterVolume => 'Главная громкость';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get onlineStatus => 'Статус онлайн';

  @override
  String get onlineStatusDescription => 'Видно только друзьям';

  @override
  String get logout => 'Выйти';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get membership => 'Членство';

  @override
  String get general => 'ОБЩЕЕ';

  @override
  String get grandmaster => 'Гроссмейстер';

  @override
  String ratingPosition(int position) {
    return 'Позиция в рейтинге: #$position';
  }

  @override
  String get errorLoadingSettings => 'Ошибка загрузки настроек';

  @override
  String get errorLoadingLanguageSettings => 'Ошибка загрузки языковых настроек';

  @override
  String get cancel => 'Отмена';

  @override
  String get appVersion => 'Шахматная Арена v2.4.1 (Сборка 890)';

  @override
  String get home => 'Главная';

  @override
  String get events => 'События';

  @override
  String get chat => 'Чат';

  @override
  String get profile => 'Профиль';

  @override
  String get rating => 'Рейтинг';

  @override
  String get collection => 'Коллекция';

  @override
  String get friends => 'Друзья';

  @override
  String get skinsAndBoards => 'Скины и доски';

  @override
  String get online => 'Онлайн';

  @override
  String get preferences => 'Настройки';

  @override
  String get variationGames => 'Вариативные игры';

  @override
  String get variationGamesDescription => 'КНБ, Блиц, Буллет и Хаос режимы';

  @override
  String get tournamentGames => 'Турнирные игры';

  @override
  String get tournamentGamesDescription => 'Участвуйте в ежедневных событиях и выигрывайте эксклюзивные скины.';

  @override
  String get featured => 'РЕКОМЕНДУЕМОЕ';

  @override
  String get live => '• В ЭФИРЕ';

  @override
  String level(int level) {
    return 'Уровень $level';
  }

  @override
  String get novice => 'Новичок';

  @override
  String mmr(int rating) {
    return '$rating MMR';
  }

  @override
  String get chessRps => 'Шахматы КНБ';

  @override
  String get selectGameMode => 'Выберите режим игры';

  @override
  String get classicalMode => 'Классический режим';

  @override
  String get rpsMode => 'Режим КНБ';

  @override
  String get selectOpponent => 'Выберите соперника';

  @override
  String get chooseOpponentDescription => 'Выберите, с кем хотите играть';

  @override
  String get playWithAI => 'Играть с ИИ';

  @override
  String get comingSoon => 'Скоро...';

  @override
  String get playOnline => 'Играть онлайн';

  @override
  String failedToFindMatch(String error) {
    return 'Не удалось найти матч: $error';
  }

  @override
  String get youWonRps => 'Вы выиграли КНБ! Сделайте ход';

  @override
  String get opponentWonRps => 'Соперник выиграл КНБ. Ожидание...';

  @override
  String get draw => 'Ничья!';

  @override
  String get victory => 'Победа!';

  @override
  String get defeat => 'Поражение';

  @override
  String get stalemateMessage => 'Игра закончилась патом.\nНикто не выиграл.';

  @override
  String get drawMessage => 'Игра закончилась вничью.';

  @override
  String get checkmateWin => 'Поздравляем! Вы выиграли матом!';

  @override
  String get winMessage => 'Поздравляем! Вы выиграли!';

  @override
  String get checkmateLoss => 'Вам поставили мат.\nУдачи в следующий раз!';

  @override
  String get lossMessage => 'Вы проиграли игру.\nУдачи в следующий раз!';

  @override
  String get experience => 'Опыт';

  @override
  String xpGained(int xp) {
    return '+$xp ОП';
  }

  @override
  String get returnToMenu => 'Вернуться в меню';

  @override
  String get finishGame => 'Завершить игру?';

  @override
  String get warning => 'Предупреждение';

  @override
  String get finishGameWarning => 'Вы уверены, что хотите завершить эту игру?\nВаш прогресс будет потерян.';

  @override
  String get finish => 'Завершить';

  @override
  String get chooseYourSide => 'Выберите свою сторону';

  @override
  String get whiteMovesFirst => 'Белые всегда ходят первыми';

  @override
  String get white => 'Белые';

  @override
  String get black => 'Черные';

  @override
  String get randomize => 'Случайно';

  @override
  String get movesFirst => 'Ходит первым';

  @override
  String get aiMovesFirst => 'ИИ ходит первым';

  @override
  String get selectDifficulty => 'Выберите сложность';

  @override
  String get chooseAIDifficulty => 'Выберите уровень сложности ИИ';

  @override
  String get beginner => 'Новичок';

  @override
  String get beginnerDescription => 'Идеально для изучения основ';

  @override
  String get easy => 'Легко';

  @override
  String get easyDescription => 'Мягкий вызов';

  @override
  String get medium => 'Средне';

  @override
  String get mediumDescription => 'Сбалансированный соперник';

  @override
  String get hard => 'Сложно';

  @override
  String get hardDescription => 'Серьезный вызов';

  @override
  String get expert => 'Эксперт';

  @override
  String get expertDescription => 'Максимальная сложность';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get enterPhoneNumber => 'Введите номер телефона';

  @override
  String get pleaseEnterPhoneNumber => 'Пожалуйста, введите номер телефона';

  @override
  String get phoneNumberMinDigits => 'Номер телефона должен содержать не менее 10 цифр';

  @override
  String get password => 'Пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get passwordMinLength => 'Не менее 8 символов';

  @override
  String get pleaseEnterPassword => 'Пожалуйста, введите пароль';

  @override
  String get passwordMinCharacters => 'Пароль должен содержать не менее 8 символов';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get reenterPassword => 'Повторите пароль';

  @override
  String get pleaseConfirmPassword => 'Пожалуйста, подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get dontHaveAccount => 'Нет аккаунта? ';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get signUpToGetStarted => 'Зарегистрируйтесь, чтобы начать';

  @override
  String get waitingForOpponent => 'Ожидание соперника';

  @override
  String get connecting => 'Подключение...';

  @override
  String get roomCode => 'Код комнаты';

  @override
  String get connectingToRoom => 'Подключение к комнате...';

  @override
  String get pleaseWait => 'Пожалуйста, подождите';

  @override
  String get waitingForOpponentMessage => 'Ожидание соперника...';

  @override
  String get searchingForOpponent => 'Мы ищем для вас соперника...';

  @override
  String failedToConnect(String error) {
    return 'Не удалось подключиться: $error';
  }

  @override
  String get season4ShadowGambit => 'Сезон 4: Теневой Гамбит';

  @override
  String get liveNow => 'В ЭФИРЕ';

  @override
  String get grandPrix2024 => 'Гран-при 2024';

  @override
  String get grandPrixDescription => 'Главное рапид-шоу. Смотрите, как гроссмейстеры сражаются за трон.';

  @override
  String get watchStream => 'Смотреть трансляцию';

  @override
  String get details => 'Подробности';

  @override
  String get allEvents => 'Все события';

  @override
  String get challenges => 'Вызовы';

  @override
  String get community => 'Сообщество';

  @override
  String get weeklyBlitz => 'Еженедельный блиц';

  @override
  String startsIn(String time) {
    return 'Начинается через $time';
  }

  @override
  String blitzArena(String time) {
    return 'Блиц-арена $time';
  }

  @override
  String prize(String amount) {
    return 'Приз $amount';
  }

  @override
  String participants(String current, String max) {
    return '$current/$max';
  }

  @override
  String get registrationOpen => 'Регистрация открыта';

  @override
  String get dailyChallenge => 'ЕЖЕДНЕВНЫЙ ВЫЗОВ';

  @override
  String get mateIn3Puzzle => 'Мат в 3 хода';

  @override
  String get solvePuzzleDescription => 'Решите самую сложную головоломку дня, чтобы заработать очки.';

  @override
  String get clubWars => 'Войны клубов';

  @override
  String teamVsTeam(int days) {
    return 'Команда против команды • Начинается через $days дней';
  }

  @override
  String get join => 'Присоединиться';

  @override
  String get topStandings => 'Топ рейтинга';

  @override
  String get viewAll => 'Посмотреть все';

  @override
  String get noStandingsAvailable => 'Рейтинг недоступен';

  @override
  String get failedToLoadStandings => 'Не удалось загрузить рейтинг';

  @override
  String get player => 'Игрок';

  @override
  String get competeAndClimb => 'Соревнуйтесь и поднимайтесь в рейтинге';

  @override
  String get allModes => 'Все режимы';

  @override
  String get classical => 'Классический';

  @override
  String get allStatus => 'Все статусы';

  @override
  String get inProgress => 'В процессе';

  @override
  String get finished => 'Завершено';

  @override
  String get noTournamentsFound => 'Турниры не найдены';

  @override
  String get createNewTournament => 'Создайте новый турнир, чтобы начать';

  @override
  String failedToLoadTournaments(String error) {
    return 'Не удалось загрузить турниры: $error';
  }

  @override
  String get singleElim => 'Олимпийская система';

  @override
  String get doubleElim => 'Двойная олимпийская';

  @override
  String get swiss => 'Швейцарская';

  @override
  String get roundRobin => 'Круговая';

  @override
  String get registrationEnded => 'Регистрация завершена';

  @override
  String startsInDays(int days, String plural) {
    return 'Начинается через $days день$plural';
  }

  @override
  String startsInHours(int hours, String plural) {
    return 'Начинается через $hours час$plural';
  }

  @override
  String startsInMinutes(int minutes, String plural) {
    return 'Начинается через $minutes минут$plural';
  }

  @override
  String endsInDays(int days, String plural) {
    return 'Заканчивается через $days день$plural';
  }

  @override
  String endsInHours(int hours, String plural) {
    return 'Заканчивается через $hours час$plural';
  }

  @override
  String endsInMinutes(int minutes, String plural) {
    return 'Заканчивается через $minutes минут$plural';
  }

  @override
  String get soon => 'скоро';

  @override
  String get cancelled => 'Отменено';

  @override
  String get playerProfile => 'ПРОФИЛЬ ИГРОКА';

  @override
  String get errorLoadingProfile => 'Ошибка загрузки профиля';

  @override
  String get winRate => 'Процент побед';

  @override
  String get streak => 'Серия';

  @override
  String best(String value) {
    return 'Лучший: $value';
  }

  @override
  String games(int count) {
    return '$count игр';
  }

  @override
  String get performance => 'Производительность';

  @override
  String get weekly => 'Неделя';

  @override
  String get monthly => 'Месяц';

  @override
  String noPerformanceData(String period) {
    return 'Нет данных о производительности за $period период';
  }

  @override
  String get noPerformanceDataYet => 'Пока нет данных о производительности';

  @override
  String get errorLoadingPerformance => 'Ошибка загрузки данных о производительности';

  @override
  String get achievements => 'Достижения';

  @override
  String get grandmasterAchievement => 'Гроссмейстер';

  @override
  String get reach2500MMR => 'Достичь 2500 MMR';

  @override
  String get onFire => 'В огне';

  @override
  String get winStreak10 => 'Серия из 10 побед';

  @override
  String get puzzleMaster => 'Мастер головоломок';

  @override
  String get solve1000Puzzles => 'Решить 1000 головоломок';

  @override
  String get showcase => 'Витрина';

  @override
  String get voidSpiritKnight => 'Рыцарь Духа Пустоты';

  @override
  String get legendarySkin => 'Легендарный скин';

  @override
  String get nebulaQueen => 'Королева Туманности';

  @override
  String get epicSkin => 'Эпический скин';

  @override
  String get enterName => 'Введите имя';

  @override
  String get nameCannotBeEmpty => 'Имя не может быть пустым';

  @override
  String get profileNameUpdated => 'Имя профиля обновлено';

  @override
  String get failedToUpdateProfileName => 'Не удалось обновить имя профиля';

  @override
  String get addFriends => 'Добавить друзей';

  @override
  String get searchForFriends => 'Искать друзей';

  @override
  String get enterAtLeast3Characters => 'Введите не менее 3 символов для поиска пользователей';

  @override
  String get errorSearchingUsers => 'Ошибка поиска пользователей';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get alreadyFriends => 'Уже друзья';

  @override
  String get requestPending => 'Запрос ожидает';

  @override
  String get notFriends => 'Не друзья';

  @override
  String get friendRequestSent => 'Запрос на дружбу отправлен';

  @override
  String failedToSendRequest(String error) {
    return 'Не удалось отправить запрос: $error';
  }

  @override
  String get searchByPhoneOrId => 'Поиск по номеру телефона или ID пользователя (минимум 3 символа)...';

  @override
  String get searchUsers => 'Поиск пользователей';

  @override
  String get myFriends => 'Мои друзья';

  @override
  String get requests => 'ЗАПРОСЫ';

  @override
  String pending(int count) {
    return '$count Ожидает';
  }

  @override
  String sentYouARequest(String timeAgo) {
    return 'Отправил вам запрос • $timeAgo';
  }

  @override
  String get friendRequestAccepted => 'Запрос на дружбу принят';

  @override
  String failedToAcceptRequest(String error) {
    return 'Не удалось принять запрос: $error';
  }

  @override
  String get friendRequestDeclined => 'Запрос на дружбу отклонен';

  @override
  String failedToDeclineRequest(String error) {
    return 'Не удалось отклонить запрос: $error';
  }

  @override
  String get noFriendsYet => 'Пока нет друзей';

  @override
  String get addFriendsToChallenge => 'Добавьте друзей, чтобы бросить им вызов';

  @override
  String get errorLoadingFriends => 'Ошибка загрузки друзей';

  @override
  String get retry => 'Повторить';

  @override
  String get offline => 'Офлайн';

  @override
  String get inGame => 'В игре';

  @override
  String get onlineFriends => 'ОНЛАЙН';

  @override
  String get offlineFriends => 'ОФЛАЙН';

  @override
  String get noUsersFound => 'Пользователи не найдены';

  @override
  String get tryDifferentQuery => 'Попробуйте другой запрос. Убедитесь, что введено не менее 3 символов.';

  @override
  String get discoverUsers => 'ОТКРЫТЬ ПОЛЬЗОВАТЕЛЕЙ';

  @override
  String users(int count) {
    return '$count пользователей';
  }

  @override
  String get noUsersAvailable => 'Пользователи недоступны';

  @override
  String get trySearchingForUsers => 'Попробуйте поискать конкретных пользователей';

  @override
  String get errorLoadingUsers => 'Ошибка загрузки пользователей';

  @override
  String get enterPhoneNumberOrUserId => 'Введите номер телефона или ID пользователя';

  @override
  String get ratingOverview => 'Обзор рейтинга';

  @override
  String get errorLoadingRating => 'Ошибка загрузки рейтинга';

  @override
  String get goBack => 'Назад';

  @override
  String get currentLevel => 'Текущий уровень';

  @override
  String get history => 'История';

  @override
  String get modeBreakdown => 'Разбивка по режимам';

  @override
  String get standardChess => 'Стандартные шахматы';

  @override
  String get rockPaperScissors => 'Камень, ножницы, бумага';

  @override
  String get pieces => 'Фигуры';

  @override
  String get boards => 'Доски';

  @override
  String get avatars => 'Аватары';

  @override
  String get effects => 'Эффекты';

  @override
  String availablePieceSets(int count) {
    return 'Доступные наборы фигур ($count)';
  }

  @override
  String selected(String name) {
    return 'Выбрано: $name';
  }

  @override
  String get select => 'Выбрать';

  @override
  String get availableAvatars => 'Доступные аватары (20)';

  @override
  String availableBoardThemes(int count) {
    return 'Доступные темы доски ($count)';
  }

  @override
  String availableEffects(int count) {
    return 'Доступные эффекты ($count)';
  }

  @override
  String get selectedClassic => 'Выбрано: Классика';

  @override
  String myPieces(String category) {
    return 'Мои $category';
  }

  @override
  String get sortByRarity => 'Сортировать по: Редкость';

  @override
  String get equipped => 'Надета';

  @override
  String unlockAtLevel(int level) {
    return 'Разблокировать на уровне $level';
  }

  @override
  String equippedItem(String name) {
    return '$name надета!';
  }

  @override
  String failedToEquip(String error) {
    return 'Не удалось надеть: $error';
  }

  @override
  String get customize => 'Настроить';

  @override
  String get getMore => 'Получить больше';

  @override
  String get visitTheShop => 'Посетить магазин';

  @override
  String get errorLoadingCollection => 'Ошибка загрузки коллекции';

  @override
  String get errorLoadingItems => 'Ошибка загрузки предметов';

  @override
  String selectedAndSaved(String name) {
    return '$name выбрано и сохранено';
  }

  @override
  String failedToSelect(String item, String error) {
    return 'Не удалось выбрать $item: $error';
  }

  @override
  String get currentlySelected => 'В настоящее время выбрано';

  @override
  String get selectThisEffect => 'Выбрать этот эффект';

  @override
  String get selectThisTheme => 'Выбрать эту тему';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get levelsAndTitles => 'Уровни и звания';

  @override
  String get failedToLoadLevels => 'Не удалось загрузить уровни';

  @override
  String get allLevels => 'Все уровни';

  @override
  String get current => 'ТЕКУЩИЙ';

  @override
  String xpToUnlock(int xp) {
    return '$xp ОП для разблокировки';
  }

  @override
  String get globalLobby => 'Глобальный лобби';

  @override
  String get clan => 'Клан';

  @override
  String get mentions => 'Упоминания';

  @override
  String get today => 'Сегодня';

  @override
  String get welcomeToGlobalStrategy => 'Добро пожаловать в Глобальный стратегический канал';

  @override
  String get you => 'Вы';

  @override
  String get replyingToYou => 'Ответ на ваше сообщение';

  @override
  String get typeAMessage => 'Введите сообщение...';

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get noLeaderboardData => 'Нет данных таблицы лидеров';

  @override
  String get errorLoadingLeaderboard => 'Ошибка загрузки таблицы лидеров';
}
