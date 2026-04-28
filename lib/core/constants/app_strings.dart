import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Language State ─────────────────────────────────────────────
enum AppLanguage { en, ru }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.en);

  void toggle() {
    state = state == AppLanguage.en ? AppLanguage.ru : AppLanguage.en;
  }

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);

// ── All Strings ────────────────────────────────────────────────
class S {
  final AppLanguage lang;
  const S(this.lang);

  bool get isRu => lang == AppLanguage.ru;

  // Navbar
  String get runs => isRu ? 'ЗАБЕГИ' : 'RUNS';
  String get leaderboard => isRu ? 'РЕЙТИНГ' : 'LEADERBOARD';
  String get announcements => isRu ? 'НОВОСТИ' : 'ANNOUNCEMENTS';
  String get admin => isRu ? 'АДМИН' : 'ADMIN';
  String get myProfile => isRu ? 'МОЙ ПРОФИЛЬ' : 'MY PROFILE';
  String get login => isRu ? 'ВОЙТИ' : 'LOGIN';

  // Hero
  String get heroLine1 => isRu ? 'МЫ НЕ БЕЖИМ.' : "WE DON'T RUN.";
  String get heroLine2 => isRu ? 'МЫ РЕЙВИМ.' : 'WE RAVE.';
  String get heroSub => isRu
      ? 'САМЫЙ КОНКУРЕНТНЫЙ БЕГОВОЙ КЛУБ ТАШКЕНТА'
      : "TASHKENT'S MOST COMPETITIVE RUNNING CREW";
  String get claimSpot => isRu ? 'ЗАНЯТЬ МЕСТО' : 'CLAIM YOUR SPOT';
  String get requestInvite => isRu ? 'ПРИСОЕДИНИТЬСЯ' : 'REQUEST AN INVITE';

  // Stats strip
  String get activeRunners => isRu ? 'АКТИВНЫХ БЕГУНОВ' : 'ACTIVE RUNNERS';
  String get totalClubKm => isRu ? 'ВСЕГО КМ В КЛУБЕ' : 'TOTAL CLUB KM';
  String get leaderThisWeek => isRu ? 'ЛИДЕР' : 'LEADER';

  // Next run
  String get nextRun => isRu ? 'СЛЕДУЮЩИЙ ЗАБЕГ' : 'NEXT RUN';
  String get noUpcomingRuns =>
      isRu ? 'Пока нет запланированных забегов.' : 'No upcoming runs announced yet.';
  String get slotsTaken => isRu ? 'МЕСТ ЗАНЯТО' : 'SLOTS TAKEN';
  String get spotsLeft => isRu ? 'МЕСТ ОСТАЛОСЬ' : 'SPOTS LEFT';
  String get soldOut => isRu ? 'МЕСТ НЕТ' : 'SOLD OUT';
  String get grabSlot => isRu ? 'ЗАНЯТЬ МЕСТО' : 'GRAB A SLOT';
  String get joinWaitlist => isRu ? 'В ЛИСТ ОЖИДАНИЯ' : 'JOIN WAITLIST';

  // Announcements
  String get announcementsTitle => isRu ? 'НОВОСТИ' : 'ANNOUNCEMENTS';
  String get viewAll => isRu ? 'ВСЕ →' : 'VIEW ALL →';
  String get noAnnouncements =>
      isRu ? 'Пока нет новостей.' : 'No announcements yet.';
  String get pinned => isRu ? '✦ ЗАКРЕПЛЕНО' : '✦ PINNED';

  // Leaderboard
  String get leaderboardTitle => isRu ? 'РЕЙТИНГ' : 'LEADERBOARD';
  String get whoRunsTashkent =>
      isRu ? 'КТО ПРАВИТ ТАШКЕНТОМ' : 'WHO RUNS TASHKENT';
  String get rankedByKm =>
      isRu ? 'Рейтинг по заработанным км.' : 'Ranked by total KM earned through attendance.';
  String get fullBoard => isRu ? 'ПОЛНЫЙ РЕЙТИНГ →' : 'FULL BOARD →';
  String get runsAttended => isRu ? 'ЗАБЕГОВ' : 'RUNS';
  String get totalKm => isRu ? 'ВСЕГО КМ' : 'TOTAL KM';
  String get runner => isRu ? 'БЕГУН' : 'RUNNER';
  String get rank => isRu ? 'МЕСТО' : 'RANK';
  String get noRunners => isRu ? 'Пока нет бегунов.' : 'No runners yet.';

  // Photos
  String get momentsTitle => isRu ? 'МОМЕНТЫ' : 'MOMENTS';
  String get momentsSub =>
      isRu ? 'По улицам Ташкента' : 'From the streets of Tashkent';

  // Drive section
  String get allMemories =>
      isRu ? 'ВСЕ НАШИ ЗАБЕГИ. ВСЕ НАШИ ВОСПОМИНАНИЯ.' : 'ALL OUR RUNS. ALL OUR MEMORIES.';
  String get driveDesc => isRu
      ? 'Каждый забег. Каждое лицо. Каждый финиш.\nПосмотреть все фото в Google Drive.'
      : 'Every run. Every face. Every finish line.\nBrowse the full photo archive on Google Drive.';
  String get viewAllPhotos => isRu ? '✦  ВСЕ ФОТО' : '✦  VIEW ALL PHOTOS';
  String get opensInDrive =>
      isRu ? 'ОТКРОЕТСЯ В GOOGLE DRIVE' : 'OPENS IN GOOGLE DRIVE';

  // Social section
  String get findUs =>
      isRu ? 'НАЙДИ НАС. СЛЕДИ. ПОДДЕРЖИ.' : 'FIND US. FOLLOW US. FUEL US.';
  String get stayInLoop =>
      isRu ? 'Будь в курсе и поддержи команду.' : 'Stay in the loop and support the crew.';
  String get followUs => isRu ? 'ПОДПИСАТЬСЯ' : 'FOLLOW US';
  String get joinChannel => isRu ? 'ВСТУПИТЬ' : 'JOIN CHANNEL';
  String get donate => isRu ? 'ПОДДЕРЖАТЬ ✦' : 'DONATE ✦';
  String get instaSublabel => isRu ? '@rizznight' : '@rizznight';
  String get telegramSublabel =>
      isRu ? 'Вступить в канал' : 'Join the channel';
  String get donateSublabel =>
      isRu ? 'Поддержи нас' : 'Keep us running';

  // Auth
  String get welcomeBack => isRu ? 'С ВОЗВРАЩЕНИЕМ' : 'WELCOME BACK';
  String get signInAccount =>
      isRu ? 'Войдите в свой аккаунт' : 'Sign in to your account';
  String get email => isRu ? 'ЭЛЕКТРОННАЯ ПОЧТА' : 'EMAIL';
  String get password => isRu ? 'ПАРОЛЬ' : 'PASSWORD';
  String get loginBtn => isRu ? 'ВОЙТИ' : 'LOGIN';
  String get noAccount =>
      isRu ? 'Нет аккаунта? Создать →' : "Don't have an account? Sign up →";
  String get invalidEmail =>
      isRu ? 'Введите корректный email' : 'Enter a valid email';
  String get minChars => isRu ? 'Минимум 6 символов' : 'Min 6 characters';
  String get wrongCredentials =>
      isRu ? 'Неверный email или пароль.' : 'Invalid email or password.';

  String get joinTheCrew => isRu ? 'ВСТУПИТЬ В КОМАНДУ' : 'JOIN THE CREW';
  String get createAccount =>
      isRu ? 'Создайте аккаунт и вступайте.' : 'Create your account and join the crew.';
  String get fullName => isRu ? 'ПОЛНОЕ ИМЯ' : 'FULL NAME';
  String get createAccountBtn =>
      isRu ? 'СОЗДАТЬ АККАУНТ' : 'CREATE ACCOUNT';
  String get alreadyAccount =>
      isRu ? 'Уже есть аккаунт? Войти →' : 'Already have an account? Login →';
  String get enterName => isRu ? 'Введите ваше имя' : 'Enter your name';

  // Profile
  String get memberSince => isRu ? 'Участник с' : 'Member since';
  String get signOut => isRu ? 'ВЫЙТИ' : 'SIGN OUT';
  String get totalEarned => isRu ? 'ВСЕГО ЗАРАБОТАНО' : 'TOTAL EARNED';
  String get runsAttendedLabel => isRu ? 'ЗАБЕГОВ ПОСЕЩЕНО' : 'RUNS ATTENDED';
  String get avgPerRun => isRu ? 'КМ/ЗАБЕГ' : 'KM/RUN';
  String get kmNote =>
      isRu ? 'Каждый посещённый забег = +3 КМ к вашему счёту.' : 'Each run attended = +3 KM added to your total.';
  String get userNotFound =>
      isRu ? 'Пользователь не найден.' : 'User not found.';

  // Runs page
  String get allRunsTitle => isRu ? 'ВСЕ ЗАБЕГИ' : 'ALL RUNS';
  String get upcomingPast =>
      isRu ? 'ПРЕДСТОЯЩИЕ И ПРОШЕДШИЕ' : 'UPCOMING & PAST EVENTS';
  String get noRuns =>
      isRu ? 'Забегов пока нет. Загляните позже.' : 'No runs yet. Check back soon.';
  String get slots => isRu ? 'МЕСТ' : 'SLOTS';
  String get completed => isRu ? 'ЗАВЕРШЁН' : 'COMPLETED';
  String get closed => isRu ? 'ЗАКРЫТ' : 'CLOSED';
  String get open => isRu ? 'ОТКРЫТ' : 'OPEN';
  String get upcoming => isRu ? 'СКОРО' : 'UPCOMING';

  // Run detail
  String get allRuns => isRu ? '← ВСЕ ЗАБЕГИ' : '← ALL RUNS';
  String get registeredRunners =>
      isRu ? 'ЗАРЕГИСТРИРОВАННЫЕ БЕГУНЫ' : 'REGISTERED RUNNERS';
  String get completedAttendance => isRu
      ? 'ЗАБЕГ ЗАВЕРШЁН. ПОСЕЩАЕМОСТЬ ОТМЕЧЕНА.'
      : 'THIS RUN IS COMPLETED. ATTENDANCE HAS BEEN MARKED.';
  String get cancelSlot => isRu ? '✗  ОТМЕНИТЬ МЕСТО' : '✗  CANCEL MY SLOT';
  String get slotClaimed =>
      isRu ? '✦  МЕСТО ЗАНЯТО! До встречи на забеге.' : '✦  SLOT CLAIMED! See you at the run.';
  String get grabMySlot => isRu ? '✦  ЗАНЯТЬ МЕСТО' : '✦  GRAB MY SLOT';

  // Admin
  String get accessDenied => isRu ? 'ДОСТУП ЗАПРЕЩЁН' : 'ACCESS DENIED';
  String get createRun => isRu ? 'СОЗДАТЬ ЗАБЕГ' : 'CREATE RUN';
  String get attendance => isRu ? 'ПОСЕЩАЕМОСТЬ' : 'ATTENDANCE';
  String get invites => isRu ? 'ПРИГЛАШЕНИЯ' : 'INVITES';
  String get announcementsTab => isRu ? 'НОВОСТИ' : 'ANNOUNCEMENTS';
  String get createNewRun => isRu ? 'НОВЫЙ ЗАБЕГ' : 'CREATE NEW RUN';
  String get runTitle => isRu ? 'НАЗВАНИЕ ЗАБЕГА' : 'RUN TITLE';
  String get runTitleRu => isRu ? 'НАЗВАНИЕ (РУС)' : 'TITLE (RU)';
  String get location => isRu ? 'МЕСТО' : 'LOCATION';
  String get description => isRu ? 'ОПИСАНИЕ (НЕОБЯЗ.)' : 'DESCRIPTION (OPTIONAL)';
  String get descriptionRu => isRu ? 'ОПИСАНИЕ (РУС, НЕОБЯЗ.)' : 'DESCRIPTION (RU, OPTIONAL)';
  String get createRunBtn => isRu ? '✦  СОЗДАТЬ ЗАБЕГ' : '✦  CREATE RUN';
  String get allRunsAdmin => isRu ? 'ВСЕ ЗАБЕГИ' : 'ALL RUNS';
  String get markAttendance => isRu ? 'ОТМЕТИТЬ ПОСЕЩАЕМОСТЬ' : 'MARK ATTENDANCE';
  String get selectRun => isRu ? 'ВЫБЕРИТЕ ЗАБЕГ' : 'SELECT RUN';
  String get runnersRegistered => isRu ? 'БЕГУНОВ ЗАРЕГИСТРИРОВАНО' : 'RUNNERS REGISTERED';
  String get noOneRegistered =>
      isRu ? 'Никто не зарегистрировался.' : 'No one registered for this run.';
  String get confirmAttendance =>
      isRu ? '✦  ПОДТВЕРДИТЬ И НАЧИСЛИТЬ +3КМ' : '✦  CONFIRM & APPLY +3KM';
  String get attendanceConfirmed =>
      isRu ? '✓ ПОСЕЩАЕМОСТЬ ПОДТВЕРЖДЕНА. КМ НАЧИСЛЕНЫ.' : '✓ ATTENDANCE CONFIRMED. KM AWARDED.';
  String get postAnnouncement =>
      isRu ? 'ОПУБЛИКОВАТЬ НОВОСТЬ' : 'POST ANNOUNCEMENT';
  String get title => isRu ? 'ЗАГОЛОВОК' : 'TITLE';
  String get titleRu => isRu ? 'ЗАГОЛОВОК (РУС)' : 'TITLE (RU)';
  String get body => isRu ? 'ТЕКСТ' : 'BODY';
  String get bodyRu => isRu ? 'ТЕКСТ (РУС)' : 'BODY (RU)';
  String get pinToTop => isRu ? 'Закрепить наверху' : 'Pin to top';
  String get postBtn => isRu ? '✦  ОПУБЛИКОВАТЬ' : '✦  POST';
  String get allAnnouncements =>
      isRu ? 'ВСЕ НОВОСТИ' : 'ALL ANNOUNCEMENTS';
  String get clubNewsTitle => isRu ? 'НОВОСТИ КЛУБА' : 'CLUB NEWS & UPDATES';

  // Footer
  String get allRightsReserved =>
      isRu ? '© 2025 RIZZNIGHT' : '© 2025 RIZZNIGHT';
}
