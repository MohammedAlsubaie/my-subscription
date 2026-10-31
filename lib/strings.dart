import 'package:flutter/widgets.dart';

import 'settings_controller.dart';

const Map<String, String> _en = {
  'appTitle': 'My Subscriptions',
  'totalExpenses': 'Total Expenses',
  'perMonth': '/ month',
  'perYear': '/ year',
  'monthly': 'Monthly',
  'quarterly': 'Quarterly',
  'yearly': 'Yearly',
  'renews': 'Renews',
  'renewsToday': 'Renews today',
  'renewsTomorrow': 'Renews tomorrow',
  'cancelled': 'Cancelled',
  'emptyTitle': 'No subscriptions yet',
  'emptyBody':
  'Add Netflix, OSN, Spotify and more to track renewal dates and see how much you spend.',
  'addTitle': 'Add Subscription',
  'editTitle': 'Edit Subscription',
  'name': 'Name (e.g. Netflix)',
  'price': 'Price',
  'cycle': 'Billing cycle',
  'category': 'Category',
  'group': 'Group',
  'grpAdd': 'New group',
  'grpName': 'Group name',
  'grpDeleteTitle': 'Delete group?',
  'grpDeleteBody': 'Its subscriptions will move to Personal.',
  'grpHint': 'Long-press a group to delete it',
  'grp.all': 'All',
  'grp.Personal': 'Personal',
  'grp.Work': 'Work',
  'grp.Home': 'Home',
  'grp.Family': 'Family',
  'startDate': 'Start date',
  'renewalDate': 'Renewal date',
  'active': 'Active',
  'activeHint': 'Turn off if you cancelled it. Cancelled items are not counted.',
  'saveChanges': 'Save changes',
  'addSub': 'Add subscription',
  'nameReq': 'Please enter a name',
  'priceInvalid': 'Enter a valid price',
  'pricePositive': 'Price must be greater than 0',
  'deleteTitle': 'Delete subscription?',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'undo': 'Undo',
  'settings': 'Settings',
  'theme': 'Theme',
  'currency': 'Currency',
  'cur.SAR': 'Saudi Riyal (SAR)',
  'cur.USD': 'US Dollar (USD)',
  'cur.GBP': 'British Pound (GBP)',
  'light': 'Light',
  'dark': 'Dark',
  'system': 'System',
  'language': 'Language',
  'welcomeBack': 'Welcome back',
  'createAccount': 'Create account',
  'loginSubtitle': 'Log in to see your subscriptions',
  'registerSubtitle': 'Create an account to start tracking your subscriptions',
  'login': 'Log in',
  'fullName': 'Full name',
  'email': 'Email',
  'password': 'Password',
  'noAccount': "Don't have an account?",
  'haveAccount': 'Already have an account?',
  'fullNameReq': 'Please enter your name',
  'emailReq': 'Please enter your email',
  'emailInvalid': 'Enter a valid email',
  'passwordReq': 'Please enter your password',
  'passwordShort': 'At least 6 characters',
  'wrongCreds': 'Wrong email or password',
  'emailTaken': 'This email is already registered',
  'logout': 'Log out',
  'logoutConfirm': 'Do you want to log out?',
  'hello': 'Hello',
  'color': 'Color',
  'icon': 'Icon',
  'cat.Entertainment': 'Entertainment',
  'cat.Music': 'Music',
  'cat.Gaming': 'Gaming',
  'cat.Shopping': 'Shopping',
  'cat.Education': 'Education',
  'cat.Cloud & Software': 'Cloud & Software',
  'cat.Other': 'Other',
};

const Map<String, String> _ar = {
  'appTitle': 'اشتراكاتي',
  'totalExpenses': 'إجمالي المصروفات',
  'perMonth': '/ شهر',
  'perYear': '/ سنة',
  'monthly': 'شهري',
  'quarterly': 'ربع سنوي',
  'yearly': 'سنوي',
  'renews': 'يتجدد',
  'renewsToday': 'يتجدد اليوم',
  'renewsTomorrow': 'يتجدد غدًا',
  'cancelled': 'ملغي',
  'emptyTitle': 'ما فيه اشتراكات بعد',
  'emptyBody':
  'أضف نتفليكس أو OSN أو سبوتيفاي وغيرها لتتبع تواريخ التجديد ومعرفة كم تصرف.',
  'addTitle': 'إضافة اشتراك',
  'editTitle': 'تعديل الاشتراك',
  'name': 'الاسم (مثال: نتفليكس)',
  'price': 'السعر',
  'cycle': 'دورة الفوترة',
  'category': 'التصنيف',
  'group': 'المجموعة',
  'grpAdd': 'مجموعة جديدة',
  'grpName': 'اسم المجموعة',
  'grpDeleteTitle': 'حذف المجموعة؟',
  'grpDeleteBody': 'ستنتقل اشتراكاتها إلى «شخصي».',
  'grpHint': 'اضغط مطولًا على المجموعة لحذفها',
  'grp.all': 'الكل',
  'grp.Personal': 'شخصي',
  'grp.Work': 'العمل',
  'grp.Home': 'البيت',
  'grp.Family': 'العائلة',
  'startDate': 'تاريخ البداية',
  'renewalDate': 'تاريخ التجديد',
  'active': 'نشط',
  'activeHint': 'أطفئه إذا ألغيت الاشتراك. الاشتراكات الملغاة لا تُحسب.',
  'saveChanges': 'حفظ التعديلات',
  'addSub': 'إضافة الاشتراك',
  'nameReq': 'الرجاء إدخال الاسم',
  'priceInvalid': 'أدخل سعرًا صحيحًا',
  'pricePositive': 'يجب أن يكون السعر أكبر من 0',
  'deleteTitle': 'حذف الاشتراك؟',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'undo': 'تراجع',
  'settings': 'الإعدادات',
  'theme': 'المظهر',
  'currency': 'العملة',
  'cur.SAR': 'ريال سعودي',
  'cur.USD': 'دولار أمريكي',
  'cur.GBP': 'جنيه إسترليني',
  'light': 'فاتح',
  'dark': 'داكن',
  'system': 'النظام',
  'language': 'اللغة',
  'welcomeBack': 'أهلاً بعودتك',
  'createAccount': 'إنشاء حساب',
  'loginSubtitle': 'سجّل دخولك لعرض اشتراكاتك',
  'registerSubtitle': 'أنشئ حساباً لتبدأ بتتبع اشتراكاتك',
  'login': 'تسجيل الدخول',
  'fullName': 'الاسم الكامل',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'noAccount': 'ما عندك حساب؟',
  'haveAccount': 'عندك حساب؟',
  'fullNameReq': 'الرجاء إدخال اسمك',
  'emailReq': 'الرجاء إدخال البريد الإلكتروني',
  'emailInvalid': 'أدخل بريداً صحيحاً',
  'passwordReq': 'الرجاء إدخال كلمة المرور',
  'passwordShort': '6 أحرف على الأقل',
  'wrongCreds': 'البريد أو كلمة المرور غير صحيحة',
  'emailTaken': 'هذا البريد مسجّل مسبقاً',
  'logout': 'تسجيل الخروج',
  'logoutConfirm': 'هل تريد تسجيل الخروج؟',
  'hello': 'مرحباً',
  'color': 'اللون',
  'icon': 'الأيقونة',
  'cat.Entertainment': 'ترفيه',
  'cat.Music': 'موسيقى',
  'cat.Gaming': 'ألعاب',
  'cat.Shopping': 'تسوق',
  'cat.Education': 'تعليم',
  'cat.Cloud & Software': 'سحابة وبرامج',
  'cat.Other': 'أخرى',
};

extension TranslateX on BuildContext {
  bool get isAr => Localizations.localeOf(this).languageCode == 'ar';

  String tr(String key) => (isAr ? _ar : _en)[key] ?? key;

  String get currencyLabel {
    switch (SettingsController.currency) {
      case 'USD':
        return isAr ? 'دولار' : 'USD';
      case 'GBP':
        return isAr ? 'جنيه إسترليني' : 'GBP';
      default:
        return isAr ? 'ر.س' : 'SAR';
    }
  }

  String category(String c) => tr('cat.$c');

  /// "in 3 days" style text.
  String daysText(int n) {
    if (!isAr) return 'in $n days';
    if (n == 2) return 'بعد يومين';
    if (n >= 3 && n <= 10) return 'بعد $n أيام';
    return 'بعد $n يومًا';
  }

  String renewsIn(int n) => isAr ? 'يتجدد ${daysText(n)}' : 'Renews ${daysText(n)}';

  String deleteBody(String name) => isAr
      ? 'سيتم حذف "$name" من القائمة.'
      : '"$name" will be removed from your list.';

  String deletedMsg(String name) => isAr ? 'تم حذف $name' : '$name deleted';
}