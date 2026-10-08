# 🚀 دليـل النشر على متجر Google Play (Google Play Store Release Guide)

هذا الدليل يلخص جميع الخطوات والمتطلبات التقنية لنشر تطبيق **تُحْفَةُ الوِلْدَانِ** بنجاح وتفادي أي رفض من مراجعة Google Play.

---

## 1. معلومات التطبيق الأساسية (App Metadata)
* **اسم التطبيق (App Name):** تُحْفَةُ الوِلْدَانِ
* **معرف الحزمة (Application ID):** `com.sharifibrahimdev.tuhfah`
* **الإصدار الحالي (Current Version):** `1.0.0+1` (Version Name: 1.0.0, Version Code: 1)
* **الفئة (Category):** الكتب والمراجع (Books & Reference) أو التعليم (Education).
* **التصنيف العمري (Content Rating):** مناسب للجميع (Everyone / 3+).

---

## 2. توافق الصلاحيات وسياسات Google Play (Permissions Compliance)
تمت مراجعة وتنظيف ملف `AndroidManifest.xml` ليتوافق بدقة مع أحدث سياسات Google Play (Android 14+):
* ✅ تم الإبقاء على:
  - `POST_NOTIFICATIONS`: لإرسال تنبيهات الحديث اليومي (Android 13+).
  - `SCHEDULE_EXACT_ALARM`: لجدولة التنبيه اليومي في وقته المحدد.
  - `RECEIVE_BOOT_COMPLETED`: لإعادة جدولة التنبيهات تلقائياً عند إعادة تشغيل الجهاز.
  - `WAKE_LOCK` & `VIBRATE`: لتنبيه المستخدم وتشغيل الاهتزاز.
  - `INTERNET`: لتحميل خطوط Google Fonts والخدمات عبر الإنترنت.
* 🛡️ تم إزالة:
  - `USE_EXACT_ALARM`: (لأن جوجل تحظر استخدامها لغير تطبيقات المنبه وساعات الإيقاف).
  - `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: (لأن جوجل ترفض التطبيقات التي تطلب هذا الإذن ما لم تكن تطبيقات محادثة صوتية أو طبية).

---

## 3. خطوة إنشاء مفتاح التوقيع (Release Keystore)
يتطلب متجر Google Play حزمة موقعة بمفتاح إنتاج (`upload-keystore.jks`) وليس بمفتاح التجربة (Debug Key).

### الطريقة السريعة:
1. قم بتشغيل الملف المساعد:
   ```cmd
   android\create_keystore.bat
   ```
   أو عبر PowerShell:
   ```powershell
   .\android\create_keystore.ps1
   ```
2. سيُطلب منك إدخال كلمة سر للمفتاح ومعلومات الاسم والمنظمة.
3. قم بإنشاء ملف `android\key.properties` (موجود بالفعل مثال له في `android\key.properties.example`):
   ```properties
   storePassword=كلمة_السر_التي_اخترتها
   keyPassword=كلمة_السر_التي_اخترتها
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```
> ⚠️ **ملاحظة أمان هامة:** ملفات `key.properties` و `*.jks` موجودة بالفعل في `.gitignore` لحمايتها من الرفع بالخطأ إلى مستودع Git. احتفظ بنسخة احتياطية آمنة من مفتاح التوقيع لديك!

---

## 4. بناء حزمة التطبيق لمتجر جوجل (Build Android App Bundle - .aab)
تطلب جوجل حزم بصيغة `.aab` بدلاً من `.apk`.

قم بتشغيل الأمر التالي في سطر الأوامر (Terminal):
```bash
flutter build appbundle --release
```

أو مع تشويش الكود وتقليص الحجم لزيادة الأمان:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

📌 ستجد ملف الحزمة الجاهز للرفع في المسار:
`build/app/outputs/bundle/release/app-release.aab`

---

## 5. نصوص بطاقة المتجر المقترحة (Store Listing Copy)

### 📌 العنوان (App Title - max 30 chars):
```
تُحْفَةُ الوِلْدَانِ
```

### 📌 الوصف المختصر (Short Description - max 80 chars):
```
ثمانون حديثاً شريفاً عن القرآن الكريم مع التلاوة والتفسير والبطاقات الدعوية.
```

### 📌 الوصف الكامل (Full Description):
```
بسم الله الرحمن الرحيم

تطبيق "تُحْفَةُ الوِلْدَانِ فِي فَضْلِ حِفْظِ وَتِلاوَةِ القُرْآنِ"
كتاب قيّم يجمع ثمانين حديثاً نبوياً شريفاً في فضائل تلاوة القرآن الكريم وحفظه والعمل به، مروية بأصح الطرق ومخرجة بدقة علمية.

🌟 أبرز مميزات التطبيق:
• بطاقات الأحاديث: عرض أنيق لكل حديث مع شرح المعاني والغريب والأحكام المستفادة.
• التلاوة الصوتية الذكية: إمكانية الاستماع لنص الحديث النبوي الشريف والتكرار لتسهيل الحفظ.
• التنبيه اليومي بحديث الصباح: تذكير يومي مبارك بحديث من أحاديث القرآن في وقت تختاره.
• مشاركة البطاقات: مشاركة الأحاديث بتصميم فاخر كنصوص أو صور دعوية عبر منصات التواصل.
• المفضلة والبحث: محرك بحث ذكي وسريع للبحث في نصوص الأحاديث والكتب.
• نسخة الكتاب الأصلية (PDF): قراءة صفحات الكتاب الأصلية مباشرة من داخل التطبيق.
• تصميم إسلامي فاخر: واجهة عصرية هادئة، تدعم الوضع الليلي والنهاري والخطوط العربية الأصيلة.
• يعمل بدون إنترنت: جميع الأحاديث والنصوص والتفاسير مدمجة ولا تتطلب اتصالاً بالشبكة.

نسأل الله العظيم أن ينفع به حفاظ كتابه وقراءه وناشريه.
```

---

## 6. متطلبات التصاميم والوسائط (Store Graphics)
1. **أيقونة التطبيق عالية الدقة (High-res Icon):**
   - الأبعاد: 512 × 512 بكسل
   - الصيغة: PNG (32 بت، بخلفية غير شفافة)
   - الحد الأقصى للحجم: 1 ميغابايت
2. **صورة الميزة المميزة (Feature Graphic):**
   - الأبعاد: 1024 × 500 بكسل
   - الصيغة: JPG أو PNG (24 بت)
   - الحد الأقصى للحجم: 15 ميغابايت
3. **لقطات الشاشة (Phone Screenshots):**
   - التقط من 4 إلى 8 لقطات شاشة واضحة (شاشة الأحاديث، شاشة بطاقة الحديث، قارئ PDF، شاشة الإعدادات والوضع الليلي).
   - النسبة الموصى بها: 9:16 أو أبعاد 1080 × 1920 / 1080 × 2400.

---

## 7. سياسة الخصوصية (Privacy Policy)
تتطلب لوحة تحكم Google Play رابط سياسة خصوصية.
نظراً لأن التطبيق:
* لا يجمع أي بيانات شخصية أو حسابات أو مدفوعات.
* يطلب فقط إذن التنبيهات المحلية للتذكير بحديث اليوم.
يمكنك استخدام صفحة سياسة خصوصية مجانية (عبر GitHub Pages أو Notion أو Firebase Hosting) تنص على:
*"تطبيق تحفة الولدان لا يجمع ولا يشارك أي بيانات شخصية للمستخدمين، وتُحفظ جميع التفضيلات محلياً على جهاز المستخدم."*

---
---

# 🚀 English Release Guide: Google Play Store

This section summarizes all technical steps and requirements to successfully build and publish **Tuhfah** (`com.sharifibrahimdev.tuhfah`) to the Google Play Store without rejections.

---

## 1. App Metadata
* **App Name:** Tuhfah (تُحْفَةُ الوِلْدَانِ)
* **Application ID / Package Name:** `com.sharifibrahimdev.tuhfah`
* **Version:** `1.0.0+1` (`versionName`: 1.0.0, `versionCode`: 1)
* **Category:** Books & Reference / Education
* **Content Rating:** Everyone (3+)

---

## 2. Permissions & Policy Compliance
The `AndroidManifest.xml` file has been audited and cleaned for strict compliance with Android 14+ Google Play policies:
* ✅ **Retained (Standard Permissions):**
  - `POST_NOTIFICATIONS`: For daily hadith reminders (Android 13+).
  - `SCHEDULE_EXACT_ALARM`: For scheduling the daily reminder at the user-specified time.
  - `RECEIVE_BOOT_COMPLETED`: To reschedule reminders upon device reboot.
  - `WAKE_LOCK` & `VIBRATE`: For alert notifications.
  - `INTERNET`: For downloading Google Fonts and remote resources.
* 🛡️ **Removed (High-risk restricted permissions):**
  - `USE_EXACT_ALARM`: Removed to avoid Google Play rejection (restricted strictly to alarm clocks and stopwatches).
  - `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: Removed to avoid policy violations.

---

## 3. Generating Release Keystore
Google Play requires an upload keystore (`upload-keystore.jks`) to sign production bundles.

### Quick Generation:
1. Run the helper script:
   ```cmd
   android\create_keystore.bat
   ```
   Or using PowerShell:
   ```powershell
   .\android\create_keystore.ps1
   ```
2. Enter your keystore password, your name, and organization details when prompted.
3. Create `android\key.properties` (a template is available at `android\key.properties.example`):
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```
> ⚠️ **Security Notice:** `key.properties` and `*.jks` are already included in `.gitignore` so they will never be accidentally committed to Git. Keep a secure offline backup of your keystore file.

---

## 4. Build the App Bundle (.aab)
Google Play requires `.aab` format instead of `.apk`.

Run the following command in your terminal:
```bash
flutter build appbundle --release
```

Or with code obfuscation and size shrinking:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

📌 The output bundle file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 5. Google Play Store Listing Copy (English)

### 📌 App Title (Max 30 chars):
```
Tuhfah: 80 Hadiths on Quran
```

### 📌 Short Description (Max 80 chars):
```
Eighty noble Hadiths on the virtues of the Holy Quran with audio recitations.
```

### 📌 Full Description:
```
In the Name of Allah, the Most Gracious, the Most Merciful.

"Tuhfat Al-Wildan Fi Fadli Hifzi Wa Tilawati Al-Quran" (تُحْفَةُ الوِلْدَانِ)
A distinguished Islamic application featuring eighty authenticated Prophetic Hadiths on the virtues of learning, memorizing, reciting, and practicing the Holy Quran.

🌟 Key Features:
• Elegant Hadith Cards: Clear presentation of each Hadith with meanings, vocabulary explanations, and practical takeaways.
• Smart Audio Recitation: Listen to crystal-clear recitations of each Hadith with repeat features to aid memorization.
• Daily Hadith Reminder: Receive an inspirational morning reminder with a selected Hadith at your preferred time.
• Shareable Cards: Share beautiful Hadith quotes as text or designed cards across social media.
• Search & Bookmarks: Quickly search across Hadiths, topics, and chapters, and bookmark your favorites.
• Original PDF Viewer: Read directly from the original published book pages inside the app.
• Premium Islamic Design: Thoughtfully designed interface supporting both dark and light modes with exquisite Arabic typography.
• Offline Access: All hadiths and explanations are stored locally—no continuous internet required.

May Allah benefit all memorizers, readers, and seekers of knowledge through this work.
```

---

## 6. Store Listing Graphic Assets
1. **App Icon:**
   - 512 × 512 px, 32-bit PNG, non-transparent background, max 1MB.
2. **Feature Graphic:**
   - 1024 × 500 px, JPG or 24-bit PNG, max 15MB.
3. **Phone Screenshots:**
   - Minimum 2, recommended 4-8 screenshots (9:16 aspect ratio, e.g. 1080 × 1920 or 1080 × 2400 px).

---

## 7. Privacy Policy
Google Play Console requires a Privacy Policy URL.
Since the app does not collect personal data and only uses notifications locally:
*"Tuhfah app does not collect, store, or share any personal data. All user preferences and notification schedules are stored locally on your device."*

