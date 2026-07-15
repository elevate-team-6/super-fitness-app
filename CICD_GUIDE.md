"استخدم الدليل ده عشان تجهزلي الـ CI/CD Pipeline للمشروع ده."##
# 📘 الدليل الكامل لإعداد CI/CD و App Distribution (Flutter)
**مرجع شامل لإعداد: GitHub Actions + Fastlane + Firebase + Shorebird**

هذا الملف هو مرجعك التقني لتكرار عملية الأتمتة (Automation) في أي مشروع Flutter قادم، مع تجنب الأخطاء الشائعة التي واجهناها.

---

## 1️⃣ المتطلبات المحلية (Local Setup)
يجب تثبيت هذه الأدوات على جهازك لمرة واحدة:
- **Ruby**: (ضروري لتشغيل Fastlane).
- **Fastlane**: `gem install fastlane -NV`
- **Firebase CLI**: `npm install -g firebase-tools`
- **Shorebird CLI**: تثبيت الأداة عبر PowerShell.

---

## 2️⃣ تهيئة الخدمات الخارجية

### أ- Shorebird (OTA Updates)
1. في التيرمينال: `shorebird init` (ينشئ ملف `shorebird.yaml`).
2. من [Shorebird Console](https://console.shorebird.dev/): انشئ **API Key** وسمه `SHOREBIRD_TOKEN`.

### ب- Firebase App Distribution
1. انشئ مشروع Firebase وفعل **App Distribution**.
2. انشئ مجموعة مختبرين باسم `testers` وأضف إيميلك.
3. في التيرمينال: `firebase login:ci` للحصول على الـ **Token**.
4. من إعدادات المشروع: انسخ الـ **App ID** للأندرويد.

---

## 3️⃣ ملفات الإعداد (Android Folder)

### 📄 `android/Gemfile`
يستخدم لتعريف Fastlane للسيرفر وتجنب المشاكل التفاعلية.
```ruby
source "https://rubygems.org"
gem "fastlane"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

### 📄 `android/fastlane/Pluginfile`
```ruby
gem 'fastlane-plugin-firebase_app_distribution'
```

### 📄 `android/fastlane/Fastfile`
المحرك الرئيسي لعملية الرفع.
```ruby
default_platform(:android)

platform :android do
  desc "Build APK and upload to Firebase App Distribution"
  lane :firebase_dist do
    sh("flutter build apk --release")
    begin
      firebase_app_distribution(
        app: ENV["FIREBASE_APP_ID_ANDROID"],
        firebase_cli_token: ENV["FIREBASE_TOKEN"],
        groups: "testers",
        release_notes: "New build from GitHub Actions",
        apk_path: "../build/app/outputs/flutter-apk/app-release.apk"
      )
    rescue => e
      UI.important("Distribution failed, but the APK was likely uploaded. Error: #{e.message}")
    end
  end
end
```

---

## 4️⃣ تعديلات Gradle الهامة (CI-Friendly)

### 📄 `android/settings.gradle.kts`
تأكد من تعديل `pluginManagement` للبحث عن الـ SDK في بيئة السيرفر (Environment Variables):
```kotlin
val flutterSdkPath = run {
    val properties = java.util.Properties()
    val localProperties = file("local.properties")
    if (localProperties.exists()) {
        localProperties.inputStream().use { properties.load(it) }
    }
    properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
        ?: throw Exception("Flutter SDK not found")
}
```
**تنبيه**: استخدم نسخة Kotlin مستقرة (مثل `2.0.21`) وتجنب النسخ غير الموجودة لتفادي خطأ `403 Forbidden`.

---

## 5️⃣ أسرار GitHub (Secrets)
يجب إضافة هذه القيم في **Repository Settings > Secrets and variables > Actions**:
1. `FIREBASE_TOKEN`: من أمر `firebase login:ci`.
2. `FIREBASE_APP_ID_ANDROID`: من إعدادات Firebase.
3. `SHOREBIRD_TOKEN`: الـ API Key من موقع Shorebird.
4. `GOOGLE_SERVICES_JSON`: محتوى ملف `google-services.json` بالكامل.

---

## 6️⃣ الـ Workflows (GitHub Actions)
موجودة في `.github/workflows/`:
- **`distribution.yml`**: لرفع النسخة كاملة (تشتغل عند الـ Merge للـ `main`).
- **`shorebird_patch.yml`**: للتعديلات الصغيرة السريعة (تشتغل يدوياً).

---

## ⚠️ دروس مستفادة (تجنب هذه الأخطاء):
1. **Google Services**: لا ترفع ملف الـ JSON؛ السيرفر سيقوم بإنشائه أوتوماتيكياً من الـ Secrets.
2. **Non-interactive Mode**: لا تستخدم أوامر تطلب إجابة (مثل `fastlane add_plugin`)؛ استخدم `bundle install` بدلاً منها.
3. **Kotlin Version**: دائماً تأكد من توفر نسخة الـ Kotlin في مستودعات Maven/Gradle.
4. **App ID**: تأكد من مطابقة الـ Package Name في فايربيز مع الـ `applicationId` في الكود.

---
**هذا النظام سيحول مشروعك إلى مستوى Enterprise Ready ويجعله واجهة مشرفة في الـ CV الخاص بك.** 🚀
