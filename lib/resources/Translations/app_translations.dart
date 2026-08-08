import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    // ==========================================
    // --- ENGLISH DICTIONARY ---
    // ==========================================
    'en_US': {
      // General UI
      'hello': 'Hello',
      'save': 'Save',
      'cancel': 'Cancel',
      'save_expense': 'Save Expense',
      'guest_user': 'Guest User',
      'toggle_theme': 'Toggle Theme',
      'change_language': 'Change Language',

      // Auth UI
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'continue_guest': 'Continue as Guest',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': 'Don\'t have an account? Register',
      'already_have_account': 'Already have an account? Login',

      // Auth Success Messages
      'success_welcome': 'Welcome back!',
      'success_account_created': 'Account created successfully!',
      'success_guest': 'Logged in as Guest',

      // Auth Error Messages
      'err_empty_fields': 'Please fill in all fields.',
      'err_password_length': 'Password must be at least 6 characters.',
      'err_invalid_credentials': 'Invalid email or password. Please try again.',
      'err_invalid_email': 'Please enter a valid email address.',
      'err_email_in_use': 'An account with this email already exists.',
      'err_disabled': 'This account has been disabled. Contact support.',
      'err_network': 'Network error. Please check your internet connection.',
      'err_too_many_requests': 'Too many failed attempts. Please try again later.',
      'err_default': 'Authentication failed. Please try again.',

      'app_name': 'Sawari',
      'app_tagline': 'HAR SAFAR KA HISAAB',
      'no_account': 'Don\'t have an account?',
      'register_now': 'Register Now',
      'have_account': 'Already have an account?',
      'login_now': 'Login Now',

      'nav_home': 'Home',
      'nav_history': 'History',
      'nav_alerts': 'Alerts',
      'nav_bikes': 'Bikes',
      'nav_more': 'More',

      'settings_title': 'Settings',
      'tap_to_backup': 'Local only — tap to back up',
      'sec_appearance': 'Appearance',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'auto': 'Auto',
      'language': 'Language',
      'en': 'English',
      'ur': 'اردو',
      'sec_units': 'Units & Currency',
      'currency': 'Currency',
      'petrol_price': 'Petrol price',
      'petrol_desc': 'Used to estimate litres from currency',
      'sec_reminders': 'Reminders',
      'notifications': 'Notifications',
      'notif_desc': 'Helpful, never spammy',
      'warn_days': 'Warn me before — days',
      'days_suffix': 'days',
      'warn_dist': 'Warn me before — distance',
      'km_suffix': 'km',
      'logout': 'Logout',

      'err_notif_permission': 'Notification permission is required. Please enable it in Settings.',

      'my_garage': 'My Garage',
      'add_another_bike': 'Add another bike',
      'add_your_bike': 'Add your bike',
      'add_photo_opt': 'Add a photo (optional)',
      'brand': 'Brand',
      'model': 'Model',
      'nickname': 'Nickname',
      'eg_kaali': 'e.g. Kaali',
      'year': 'Year',
      'registration': 'Registration ٪',
      'current_odometer': 'Current Odometer (km)',
      'odo_disclaimer': 'Mileage & service tracking starts from this reading.',
      'save_bike_chalo': 'Save bike - Chalo!',
      'err_image_pick': 'Failed to pick image.',
      'err_invalid_odo': 'Please enter a valid positive number for Odometer.',
      'err_save_bike': 'Could not save bike. Please check your connection.',
      'success_bike_added': 'Bike added successfully to your garage!',

      'err_image_upload_failed': 'Failed to process image. Please try another.',
      'err_image_upload_network': 'Image upload failed. Check your internet connection.',
      'err_permission_denied': 'You do not have permission to perform this action.',
      'err_timeout': 'Request timed out. Please try again.',

      'err_invalid_year': 'Please enter a valid year.',

      'active': 'Active',
      'switch_bike': 'Switch',
      'entries': 'entries',
      'bike_profile': 'Bike Profile',
      'spent_in_year': 'spent this year',
      'kml_average': 'km/l average',
      'services': 'services',
      'view_mileage_analytics': 'View mileage analytics',
      'maintenance_schedule': 'Maintenance schedule',

      'err_stream_network': 'Lost connection to garage. Please check your internet.',

      'err_history_stream': 'Could not load history. Please check your connection.',
      'err_schedule_stream': 'Could not load schedules. Please check your connection.',



    },

    // ==========================================
    // --- URDU DICTIONARY ---
    // ==========================================
    'ur_PK': {
      // General UI
      'hello': 'ہیلو',
      'save': 'محفوظ کریں',
      'cancel': 'منسوخ کریں',
      'save_expense': 'خرچہ محفوظ کریں',
      'guest_user': 'مہمان صارف',
      'toggle_theme': 'تھیم تبدیل کریں',
      'change_language': 'زبان تبدیل کریں',

      // Auth UI
      'login': 'لاگ ان',
      'register': 'رجسٹر کریں',
      'email': 'ای میل',
      'password': 'پاس ورڈ',
      'full_name': 'پورا نام',
      'continue_guest': 'بطور مہمان جاری رکھیں',
      'forgot_password': 'پاس ورڈ بھول گئے؟',
      'dont_have_account': 'اکاؤنٹ نہیں ہے؟ رجسٹر کریں',
      'already_have_account': 'پہلے سے اکاؤنٹ ہے؟ لاگ ان کریں',

      // Auth Success Messages
      'success_welcome': 'خوش آمدید!',
      'success_account_created': 'اکاؤنٹ کامیابی سے بن گیا!',
      'success_guest': 'بطور مہمان لاگ ان ہو گئے',

      // Auth Error Messages
      'err_empty_fields': 'براہ کرم تمام خانے پُر کریں۔',
      'err_password_length': 'پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے۔',
      'err_invalid_credentials': 'ای میل یا پاس ورڈ غلط ہے۔ دوبارہ کوشش کریں۔',
      'err_invalid_email': 'براہ کرم درست ای میل درج کریں۔',
      'err_email_in_use': 'اس ای میل کے ساتھ ایک اکاؤنٹ پہلے سے موجود ہے۔',
      'err_disabled': 'یہ اکاؤنٹ غیر فعال کر دیا گیا ہے۔',
      'err_network': 'نیٹ ورک کی خرابی۔ براہ کرم انٹرنیٹ چیک کریں۔',
      'err_too_many_requests': 'بہت سی ناکام کوششیں۔ براہ کرم بعد میں کوشش کریں۔',
      'err_default': 'تصدیق ناکام ہو گئی۔ براہ کرم دوبارہ کوشش کریں۔',


      'app_name': 'سواری',
      'app_tagline': 'ہر سفر کا حساب',
      'no_account': 'اکاؤنٹ نہیں ہے؟',
      'register_now': 'ابھی رجسٹر کریں',
      'have_account': 'پہلے سے اکاؤنٹ ہے؟',
      'login_now': 'ابھی لاگ ان کریں',

      'nav_home': 'ہوم',
      'nav_history': 'ہسٹری',
      'nav_alerts': 'الرٹس',
      'nav_bikes': 'بائیکس',
      'nav_more': 'مزید',

      'settings_title': 'ترتیبات',
      'tap_to_backup': 'صرف مقامی — بیک اپ کے لیے ٹیپ کریں',
      'sec_appearance': 'ظاہری شکل',
      'theme': 'تھیم',
      'light': 'روشن',
      'dark': 'تاریک',
      'auto': 'خودکار',
      'language': 'زبان',
      'en': 'English',
      'ur': 'اردو',
      'sec_units': 'اکائیاں اور کرنسی',
      'currency': 'کرنسی',
      'petrol_price': 'پٹرول کی قیمت',
      'petrol_desc': 'کرنسی سے لیٹر کا اندازہ لگانے کے لیے',
      'sec_reminders': 'یاد دہانیاں',
      'notifications': 'نوٹیفیکیشنز',
      'notif_desc': 'مددگار، کبھی سپیم نہیں',
      'warn_days': 'مجھے آگاہ کریں — دن پہلے',
      'days_suffix': 'دن',
      'warn_dist': 'مجھے آگاہ کریں — فاصلہ پہلے',
      'km_suffix': 'کلومیٹر',
      'logout': 'لاگ آؤٹ',
      'err_notif_permission': 'نوٹیفیکیشن کی اجازت درکار ہے۔ براہ کرم اسے ترتیبات میں فعال کریں۔',

      'my_garage': 'میرا گیراج',
      'add_another_bike': 'ایک اور بائیک شامل کریں',
      'add_your_bike': 'اپنی بائیک شامل کریں',
      'add_photo_opt': 'تصویر شامل کریں (اختیاری)',
      'brand': 'برانڈ',
      'model': 'ماڈل',
      'nickname': 'عرفی نام',
      'eg_kaali': 'مثلاً کالی',
      'year': 'سال',
      'registration': 'رجسٹریشن ٪',
      'current_odometer': 'موجودہ اوڈومیٹر (کلومیٹر)',
      'odo_disclaimer': 'مائلیج اور سروس ٹریکنگ اس ریڈنگ سے شروع ہوتی ہے۔',
      'save_bike_chalo': 'بائیک محفوظ کریں - چلو!',
      'err_image_pick': 'تصویر منتخب کرنے میں ناکام۔',
      'err_invalid_odo': 'براہ کرم اوڈومیٹر کے لیے درست مثبت نمبر درج کریں۔',
      'err_save_bike': 'بائیک محفوظ نہیں ہو سکی۔ براہ کرم اپنا کنکشن چیک کریں۔',
      'success_bike_added': 'بائیک کامیابی کے ساتھ آپ کے گیراج میں شامل ہو گئی!',

      'err_image_upload_failed': 'تصویر پروسیس کرنے میں ناکام۔ براہ کرم کوئی اور کوشش کریں۔',
      'err_image_upload_network': 'تصویر اپ لوڈ ناکام۔ اپنا انٹرنیٹ کنکشن چیک کریں۔',
      'err_permission_denied': 'آپ کو یہ کارروائی کرنے کی اجازت نہیں ہے۔',
      'err_timeout': 'درخواست کا وقت ختم ہو گیا۔ براہ کرم دوبارہ کوشش کریں۔',
      'err_invalid_year': 'براہ کرم ایک درست سال درج کریں۔',

      'active': 'فعال',
      'switch_bike': 'تبدیل کریں',
      'entries': 'اندراجات',
      'bike_profile': 'بائیک پروفائل',
      'spent_in_year': 'اس سال خرچ ہوا',
      'kml_average': 'کلومیٹر/لیٹر اوسط',
      'services': 'سروسز',
      'view_mileage_analytics': 'مائلیج تجزیات دیکھیں',
      'maintenance_schedule': 'دیکھ بھال کا شیڈول',

      'err_stream_network': 'گیراج سے رابطہ منقطع ہو گیا۔ براہ کرم اپنا انٹرنیٹ چیک کریں۔',

      'err_history_stream': 'تاریخچہ لوڈ نہیں ہو سکا۔ براہ کرم اپنا کنکشن چیک کریں۔',

      'err_schedule_stream': 'شیڈول لوڈ نہیں ہو سکا۔ براہ کرم اپنا کنکشن چیک کریں۔',


    },
  };
}