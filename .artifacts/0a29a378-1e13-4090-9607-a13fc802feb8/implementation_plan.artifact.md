# تعزيز أمن الشبكة (Network Security Configuration)

الهدف هو إغلاق ثغرة الـ Cleartext Traffic العالمية في التطبيق واستبدالها بتهيئة مخصصة تسمح بالاتصال غير المشفر فقط للنطاقات (Domains) المطلوبة للتطوير المحلي، التزاماً بتوصيات الأمان في أندرويد.

## User Review Required

> [!IMPORTANT]
> تم افتراض أنك تحتاج الـ Cleartext فقط للـ Emulator (`10.0.2.2`) أو الـ `localhost`. إذا كان هناك IP معين تستخدمه في التطوير (مثلاً Backend شغال على جهازك بـ IP خاص)، يرجى إبلاغي لإضافته.

## Proposed Changes

### [Android Configuration]

#### [MODIFY] [AndroidManifest.xml](file:///E:/flutter%20progects/super_fitness/android/app/src/main/AndroidManifest.xml)
- حذف `android:usesCleartextTraffic="true"`.
- إضافة `android:networkSecurityConfig="@xml/network_security_config"`.

#### [NEW] [network_security_config.xml](file:///E:/flutter%20progects/super_fitness/android/app/src/main/res/xml/network_security_config.xml)
- إنشاء ملف التهيئة للسماح بـ HTTP فقط للـ `localhost` و `10.0.2.2`.

---

## Verification Plan

### Manual Verification
- التأكد من أن التطبيق لا يزال قادراً على الاتصال بـ الـ API الأساسي (`https://fitness.elevateegy.com`).
- إذا كان هناك Backend محلي، التأكد من أن الاتصال به لا يزال يعمل.
- التأكد من عدم وجود Warnings في الـ Logcat متعلقة بـ Cleartext traffic للنطاقات المحمية.
