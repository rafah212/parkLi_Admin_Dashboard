import 'package:flutter/material.dart';

class AppData {
  // الدارك مود
  static bool isDarkMode = false;

  // أول ما اغير اللغة تتغير الصفحات كلها كأنها تعلمها
  static final ValueNotifier<bool> languageNotifier = ValueNotifier<bool>(false); // false = إنجليزي, true = عربي

  // يشوف هل اللغة اللي الحين عربية او لا؟
  static bool get isArabic => languageNotifier.value;

// الوان صفحة الادمن
  static Color getPrimaryColor() {
    return const Color(0xFF195A64);
  }

  static Color getBackgroundColor() {
    return isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
  }

  // هنا كتبتهاغ لأن بعض الكلمات مكرره فا لو بهذا الملف افضل من كل ملف فيه ترجمه القاموس للأدمن (يترجم الكلمات والصفحات تلقائياً)
  static final Map<String, String> _localizedValues = {
    // قائمة السايدبار والصفحات
    'Dashboard': 'لوحة التحكم',
    'Parking Spots': 'مواقف السيارات',
    'Users': 'المستخدمين',
    'Places': 'الأماكن المضافة',
    'Pricing': 'إعدادات الأسعار',
    'Reservations': 'الحجوزات الحالية',
    'Reports': 'التقارير والإحصائيات',
    'Violations': 'المخالفات والجزاءات',
    'Complations': 'الشكاوى والبلاغات',
    'Setting': 'الإعدادات الشخصية',
    'Logout': 'تسجيل الخروج',
    'Welcome': 'مرحباً بك',

    // صفحة المواقف 
    "Real-time Parking Spots": "مراقبة مواقف السيارات الحية",
    "Select Parking Location": "اختر موقع المواقف المراد عرضه",
    "No parking spots assigned to this location.": "لا توجد مواقف مضافة لهذا الموقع بعد.",

    // التقرير
    'Total Users': 'إجمالي المستخدمين',
    'Complaints': 'إجمالي الشكاوى',
    'Total Bookings': 'إجمالي الحجوزات',
    'System Analytics': 'التقارير والإحصائيات',
    'Quick Summary': 'ملخص سريع',
    'Total Spots': 'إجمالي المواقف',
    'Active Users': 'المستخدمين النشطين',
    'Total Places': 'إجمالي المواقع',
    'Live Occupancy Rate': 'نسبة الإشغال الحية للمواقف',
    'Live Status': 'الحالة المباشرة',
    'Free Spots': 'مواقف شاغرة ومتاحة',
    'Available': 'متاح',
    'Occupied': 'ممتلئ',
    'No tracking data available': 'لا تتوفر بيانات تتبع حالياً',
    'Loading...': 'جاري التحميل...',
    'Error': 'خطأ',
    'Export PDF': 'تصدير بصيغة PDF',
    'Export CSV': 'تصدير بصيغة CSV',
    'CSV Report downloaded successfully!': 'تم تحميل تقرير CSV بنجاح!',
    
    // صفحة الإعدادات
    'Language': 'اللغة (Language)',
    'Dark Mode': 'الوضع الداكن (Dark Mode)',
    'English': 'English',
    'Arabic': 'العربية',

    // الاشعارات
    "Send To": "إرسال إلى",
    "All Users (Broadcast)": "جميع المستخدمين (بث عام)",
    "Notification Event Type": "نوع حدث الإشعار (مفتاح الجوال)",
    "Message Details": "تفاصيل نص الرسالة",
    "General System Alert": "تنبيه عام بالنظام",
    "New Violation Issued ⚠️": "إصدار مخالفة جديدة ⚠️",
    "Reservation Confirmed ✅": "تأكيد الحجز بنجاح ✅",
    "Complaint Solved ": "حل الشكوى والبلاغ ",
    "Specific User": "مستخدم محدد",
    "All Users": "عام للكل",

    //المستخدمين
    "Confirm Deletion": "تأكيد حذف المستخدم",
    "Are you sure you want to delete": "هل أنت متأكد تماماً من رغبتك في حذف",
    "All associated data will be removed.": "سيتم إزالة كافة البيانات المرتبطة بهذا الحساب بشكل نهائي.",
    "User deleted successfully": "تم حذف بيانات المستخدم بنجاح.",
    "No Email":  "لا يوجد بريد إلكتروني مسجل",
    "No Phone": "لا يوجد رقم جوال مسجل",

    //صفحة الأماكن
    "Manage Places": "إدارة المواقع والأماكن",
    "Deleting": "جاري حذف الموقع",
    "spots": "موقف",
    "in 5s...": "خلال ٥ ثوانٍ...",
    "UNDO": "تراجع",
    "Place deleted successfully": "تم حذف الموقع بنجاح.",
    "No places found.": "لا توجد مواقع مسجلة حالياً.",
    "Unnamed": "موقع بدون اسم",
    "Price": "تعرفة السعر",
    "Add New Place": "إضافة موقع مواقف جديد",
    "Place Name": "اسم الموقع الجغرافي",
    "Price (e.g. 10 SAR/h)": "السعر (مثال: ١٠ ريال/ساعة)",

    // الاسعار
    "Pricing Management": "إدارة وإعدادات سياسات الأسعار",
    "Current Rate": "التعرفة الحالية النشطة",
    "Hourly Rate": "احتساب بالساعة",
    "University (FREE)": "صرح جامعي (مجاني بالكامل)",
    "Fixed Rate (Gov/Hospital)": "سعر ثابت (جهة حكومية / مستشفى)",
    "No places available to price.": "لا توجد مواقع جغرافية مضافة لجدولة أسعارها.",
    "Update Policy & Rate": "تحديث سياسة التسعير للموقع",
    "Quick Templates:": "قوالب تسعير ذكية سريعة:",
    "Fixed (Gov)": "حكومي ثابت",
    "Hourly": "بالساعة (مول/مزرعة)",
    "University": "جامعي مجاني",
    "Price updated successfully": "تم تحديث تعرفة السعر بنجاح.",

    // الحجوزات 
    "Reservations Management": "سجل وإدارة الحجوزات الحالية",
    "Bookings History": "سجل حركة عمليات الحجز",
    "Error loading bookings": "حدث خطأ ما أثناء جلب بيانات الحجوزات",
    "No reservations found.": "لا توجد عمليات حجز مسجلة في النظام حالياً.",
    "Unknown User": "مستخدم غير معروف",
    "No Vehicle Info": "لا تتوفر تفاصيل للمركبة",
    "Spot": "الموقف",
    "User": "المستخدم",
    "Vehicle": "المركبة الحالية",
    "CANCEL": "إلغاء الحجز",
    "UPCOMING": "قادم ومؤكد",
    "COMPLETED": "مكتمل ومنتهي",
    "CANCELLED": "ملغي",
    "Booking cancelled successfully": "تم إلغاء الحجز المحدد بنجاح.",

    // المخالفات 
    "Issue Violations": "إصدار رصد المخالفات والجزاءات",
    "No vehicles found.": "لا توجد مركبات مسجلة حالياً بنظام الحسابات.",
    "Plate": "رقم اللوحة المرورية",
    "Select Violation Type:": "اختر نوع البلاغ أو المخالفة المراد رصدها:",
    "Incorrect Parking": "وقوف خاطئ (بغير موقعه المخصص)",
    "Overtime Dynamic": "وقت إضافي (حساب تصاعدي)",
    "SAR": "ريال",
    "Calculate Overtime Penalty": "حساب غرامة الوقت الإضافي المتأخر",
    "Enter extra hours stayed (5 SAR per hour):": "أدخل عدد الساعات الإضافية (٥ ريال لكل ساعة تأخير):",
    "e.g. 2": "مثال: ٢",
    "Issue": "إصدار الرصد",
    "issued and notification sent!": "تم رصده بنجاح وإرسال الإشعار الفوري للجوال!",

    // الشكاوي
    "Complaints Management": "إدارة شكاوى وبلاغات المستخدمين",
    "User Reports & Issues": "قائمة البلاغات والشكاوى الواردة",
    "No complaints found. Clean inbox!": "صندوق الوارد نظيف، لا توجد شكاوى حالياً!",
    "From": "مرسل من",
    "Message:": "نص البلاغ:",
    "No message content": "لا يوجد محتوى نصي للشكوى",
    "Set Pending": "تعيين قيد المراجعة",
    "Mark Solved": "إغلاق وحل الشكوى",
    "Solved": "تم الحل",
    "Select Resolution Response": "تحديد نوع الرد لإغلاق البلاغ",
    "Quick Responses:": "قوالب ردود توجيهية سريعة:",
    "Custom Response / Edit:": "تعديل أو كتابة رد مخصص لمستلم الرسالة:",
    "Write a custom response to the user...": "اكتب ردًا مخصصًا ليظهر في جوال المستخدم...",
    "Send & Solve": "إرسال الرد وإغلاق البلاغ",
    "Issue Fixed ✅": "تم حل المشكلة وإصلاح العطل ✅",
    "Contact Support Email ✉️": "التوجيه لمراسلة بريد الدعم الفني ✉️",
    "Request Plate Details 🚗": "طلب تفاصيل رقم اللوحة للمركبة 🚗",
    "Status updated and notification sent!": "تم تحديث حالة البلاغ وإرسال الرد لجوال المستخدم!"


  };

  // تحول النصوص و الاراقام على حسب اللغة
  static String translate(String key) {
    // إذا عربي والكلمة لها ترجمة، نرجع الترجمة العربية
    if (isArabic && _localizedValues.containsKey(key)) {
      return _localizedValues[key]!;
    }
    // غير كذا نرجع النص الإنجليزي الأصلي
    return key;
  }

  // لتحويل الأرقام الإنجليزية إلى أرقام عربية (١، ٢، ٣) 
  static String formatNumbers(String input) {
    if (!isArabic) return input; // لو إنجليزي يرجع الرقم عادي (1, 2, 3)
    
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}