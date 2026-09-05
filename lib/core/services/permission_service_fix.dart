// إصلاح مشكلة Permission.notifications
// استبدال Permission.notifications بـ Permission.notification

// في السطر 24:
// Permission.notifications,
// بـ:
// Permission.notification,

// في السطر 65:
// final status = await Permission.notifications.status;
// بـ:
// final status = await Permission.notification.status;

// في السطر 70:
// final status = await Permission.notifications.request();
// بـ:
// final status = await Permission.notification.request();
