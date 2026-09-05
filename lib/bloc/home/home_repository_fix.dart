// إصلاح مشاكل الأنواع

// تغيير:
// return (calories: 0, steps: 0, sleep: 0, heartRate: 0);
// إلى:
// return (calories: 0.0, steps: 0.0, sleep: 0.0, heartRate: 0.0);

// تغيير:
// return snapshot.count;
// إلى:
// return snapshot.count ?? 0;
