import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ReferenceItem {
  final String title;
  final String author;
  final String deathYear;
  final String category;
  final String description;
  final String usage;

  const ReferenceItem({
    required this.title,
    required this.author,
    required this.deathYear,
    required this.category,
    required this.description,
    required this.usage,
  });
}

class ReferencesScreen extends StatefulWidget {
  const ReferencesScreen({super.key});

  @override
  State<ReferencesScreen> createState() => _ReferencesScreenState();
}

class _ReferencesScreenState extends State<ReferencesScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<ReferenceItem> _references = const [
    // 1. كتب الحديث المسندة
    ReferenceItem(
      title: 'صحيح البخاري (الجامع المسند الصحيح المختصر)',
      author: 'الإمام محمد بن إسماعيل البخاري',
      deathYear: '٢٥٦ هـ',
      category: 'أمهات كتب الحديث',
      description: 'أصح كتاب بعد كتاب الله تعالى، أجمع الأمة على تلقيه بالقبول واستنباط الأحكام منه.',
      usage: 'تخريج وضبط نصوص الأحاديث المتفق عليها وأحاديث فضل تلاوة القرآن وحفظه.',
    ),
    ReferenceItem(
      title: 'صحيح مسلم (المسند الصحيح المختصر)',
      author: 'الإمام مسلم بن الحجاج القشيري النيسابوري',
      deathYear: '٢٦١ هـ',
      category: 'أمهات كتب الحديث',
      description: 'ثاني الصحيحين، امتاز بجمع طرق الحديث في موضع واحد وعنايته بدقة الألفاظ.',
      usage: 'تخريج الأحاديث في فضل قراءة القرآن والماهر به وأجر قارئه في الصلاة والاعتكاف.',
    ),
    ReferenceItem(
      title: 'سنن أبي داود',
      author: 'الإمام سليمان بن الأشعث السجستاني',
      deathYear: '٢٧٥ هـ',
      category: 'أمهات كتب الحديث',
      description: 'من أمهات كتب السنن الأربعة، عُني بأحاديث الأحكام والآداب الشرعية والتلاوة.',
      usage: 'تخريج أحاديث آداب الجهر بالقراءة، وتلاوة القرآن في الوتر والنوافل وسورة الملك.',
    ),
    ReferenceItem(
      title: 'جامع الترمذي (السنن)',
      author: 'الإمام محمد بن عيسى بن سورة الترمذي',
      deathYear: '٢٧٩ هـ',
      category: 'أمهات كتب الحديث',
      description: 'امتاز ببيان درجات الأحاديث صحة وضعفاً، ونقل مذاهب فقهاء الصحابة والتابعين.',
      usage: 'تخريج أحاديث فضائل سور القرآن وثواب قراءة كل حرف بعشر حسنات.',
    ),
    ReferenceItem(
      title: 'سنن النسائي (المجتبى من السنن الكبرى)',
      author: 'الإمام أحمد بن شعيب النسائي',
      deathYear: '٣٠٣ هـ',
      category: 'أمهات كتب الحديث',
      description: 'من أدق كتب السنن شرطاً وأكثرها عناية بعلل الأحاديث واختلاف الروايات.',
      usage: 'تخريج أحاديث قيام الليل بالقرآن وفضل قراءة السور المنجيات والمعوذات.',
    ),
    ReferenceItem(
      title: 'سنن ابن ماجه',
      author: 'الإمام محمد بن يزيد بن ماجه القزويني',
      deathYear: '٢٧٥ هـ',
      category: 'أمهات كتب الحديث',
      description: 'أحد كتب السنن الأربعة المعتمدة، تميز بحسن التبويب وسلاسة الترتيب الفقهي.',
      usage: 'تخريج أحاديث فضل حامل القرآن وإكرام أهله في الدنيا والآخرة.',
    ),
    ReferenceItem(
      title: 'مسند الإمام أحمد بن حنبل',
      author: 'إمام أهل السنة أحمد بن محمد بن حنبل الشيباني',
      deathYear: '٢٤١ هـ',
      category: 'أمهات كتب الحديث',
      description: 'أكبر موسوعة حديثية مسندة جمعت أكثر من ثلاثين ألف حديث عن رسول الله ﷺ.',
      usage: 'توثيق شواهد الأحاديث في أجر إلباس والدي قارئ القرآن تاج الوقار يوم القيامة.',
    ),
    ReferenceItem(
      title: 'موطأ الإمام مالك',
      author: 'إمام دار الهجرة مالك بن أنس الأصبحي',
      deathYear: '١٧٩ هـ',
      category: 'أمهات كتب الحديث',
      description: 'من أقدم وأصح كتب السنة والآثار، جمع بين الحديث الصحيح وفقه أهل المدينة.',
      usage: 'تخريج الروايات في تعاهد القرآن وتحسين الصوت به والتأني في التلاوة.',
    ),
    ReferenceItem(
      title: 'سنن الدارمي',
      author: 'الإمام عبد الله بن عبد الرحمن الدارمي',
      deathYear: '٢٥٥ هـ',
      category: 'أمهات كتب الحديث',
      description: 'كتاب جليل القدر عالي الأسانيد، أفرد فيه أبواباً جامعة في فضائل القرآن وآدابه.',
      usage: 'شواهد فضائل آيات القرآن الكريم وأجور حفظته ومعلميه.',
    ),
    ReferenceItem(
      title: 'صحيح الجامع الصغير وزيادته وسلسلة الأحاديث الصحيحة',
      author: 'العلامة المحدث محمد ناصر الدين الألباني',
      deathYear: '١٤٢٠ هـ',
      category: 'أمهات كتب الحديث',
      description: 'تحقيق وتخريج علمي معاصر لأحاديث السنة النبوية مع بيان درجات صحتها وفق قواعد المحدثين.',
      usage: 'ضبط صحة الأحاديث الواردة في تحسين الصوت بالقرآن والفضائل.',
    ),

    // 2. شروح الحديث النبوي
    ReferenceItem(
      title: 'فتح الباري شرح صحيح البخاري',
      author: 'الحافظ أحمد بن علي بن حجر العسقلاني',
      deathYear: '٨٥٢ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'أعظم شرح لصحيح البخاري، عمدة المحدثين والفقهاء في تحقيق الألفاظ والمعاني.',
      usage: 'شرح معاني أحاديث «خيركم من تعلم القرآن وعلمه» و«الماهر بالقرآن» وسائر الأحاديث.',
    ),
    ReferenceItem(
      title: 'المنهاج شرح صحيح مسلم بن الحجاج',
      author: 'الإمام محيي الدين يحيى بن شرف النووي',
      deathYear: '٦٧٦ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'شرح جامع يجمع بين استنباط الأحكام الفقهية وتوضيح اللطائف الإسنادية واللغوية.',
      usage: 'بيان معاني أحاديث شفاعة القرآن، واستماع الملائكة لتلاوة الصحابة ونزول السكينة.',
    ),
    ReferenceItem(
      title: 'جامع العلوم والحكم في شرح خمسين حديثاً من جوامع الكلم',
      author: 'الحافظ زين الدين عبد الرحمن بن رجب الحنبلي',
      deathYear: '٧٩٥ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'من أروع الشروح الحديثية التربوية الإيمانية، بيّن فيه قواعد الشريعة ومقاصدها.',
      usage: 'تأصيل حديث «إنما الأعمال بالنيات» ووجوب تجريد الإخلاص في تعلم كتاب الله.',
    ),
    ReferenceItem(
      title: 'لطائف المعارف فيما لمواسم العام من الوظائف',
      author: 'الحافظ زين الدين عبد الرحمن بن رجب الحنبلي',
      deathYear: '٧٩٥ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'كتاب جامع في وظائف الأوقات والمواسم وفضل تلاوة القرآن وتدبره ومدارسته.',
      usage: 'بيان حكم ختم القرآن في أوقات الفضائل وتوجيه هدي السلف في المدارسة.',
    ),
    ReferenceItem(
      title: 'تحفة الأحوذي بشرح جامع الترمذي',
      author: 'العلامة محمد عبد الرحمن المباركفوري',
      deathYear: '١٣٥٣ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'شرح محقق نفيس لجامع الترمذي، اعتنى ببيان معاني الغريب ومذاهب أئمة السلف.',
      usage: 'شرح أحاديث فضل سورة الملك وشفاعتها لصاحبها وفضل سورة الإخلاص والمعوذتين.',
    ),
    ReferenceItem(
      title: 'عون المعبود شرح سنن أبي داود',
      author: 'العلامة محمد أشرف شمس الحق العظيم آبادي',
      deathYear: '١٣٢٩ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'شرح وافٍ لسنن أبي داود اعتنى بتوضيح المشكلات الفقهية والمسائل المسلكية.',
      usage: 'إيضاح أحاديث النهي عن رفع الصوت في القراءة بالمسجد وأدب المناجاة لله تعالى.',
    ),
    ReferenceItem(
      title: 'فيض القدير شرح الجامع الصغير',
      author: 'الحافظ زين الدين محمد عبد الرؤوف المناوي',
      deathYear: '١٠٣١ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'موسوعة علمية حوت شروحاً لدقائق الأحاديث النبوية ودلالاتها التربوية والسلوكية.',
      usage: 'بيان أسرار مضاعفة أجور قارئ القرآن وحكم المداومة على أوراد التلاوة.',
    ),
    ReferenceItem(
      title: 'شرح رياض الصالحين',
      author: 'فضيلة الشيخ محمد بن صالح العثيمين',
      deathYear: '١٤٢١ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'شرح معاصر ميسر رصين يربط بين نصوص الأحاديث والواقع العملي التربوي للمسلم.',
      usage: 'استنباط الفوائد العقدية والتربوية لأحاديث آداب حملة القرآن وتلاوته.',
    ),
    ReferenceItem(
      title: 'دليل الفالحين لطرق رياض الصالحين',
      author: 'الشيخ محمد بن علان الصديقي الشافعي',
      deathYear: '١٠٥٧ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'شرح معتمد لرياض الصالحين عُني باللغة وإعراب الألفاظ وتخريج الآثار.',
      usage: 'تحرير شروط مرافقة القرآن وشفاعته لأصحابه يوم القيامة.',
    ),
    ReferenceItem(
      title: 'التمهيد لما في الموطأ من المعاني والأسانيد',
      author: 'الإمام الحافظ أبو عمر يوسف بن عبد البر القرطبي',
      deathYear: '٤٦٣ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'أعظم موسوعة فقهية وحديثية في شرح موطأ الإمام مالك وتحقيق معانيه ورواياته.',
      usage: 'شرح أحاديث صلاة الوتر وفضل قيام الليل لأهل القرآن وسنة الاستذكار.',
    ),
    ReferenceItem(
      title: 'المجموع شرح المهذب',
      author: 'الإمام محيي الدين يحيى بن شرف النووي',
      deathYear: '٦٧٦ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'موسوعة الفقه المقارن الكبرى للإمام النووي مع تحقيق نصوص الأحاديث وأحكام الصلاة.',
      usage: 'أحكام الجهر بالقراءة في الصلاة وسجود التلاوة وآداب الاستماع.',
    ),
    ReferenceItem(
      title: 'الشرح الممتع على زاد المستقنع',
      author: 'فضيلة الشيخ محمد بن صالح العثيمين',
      deathYear: '١٤٢١ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'شرح فقهي تأصيلي ميسر يقرر مسائل العبادات والآداب بدليلها من الكتاب والسنة.',
      usage: 'بيان أحكام سجود التلاوة وعدده وضوابط رفع الصوت بالقراءة في المساجد.',
    ),
    ReferenceItem(
      title: 'شرح صحيح البخاري',
      author: 'الإمام أبو الحسن علي بن خلف بن بطال القرطبي',
      deathYear: '٤٤٩ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'من أقدم وأجل شروح صحيح البخاري، عُني باستنباط المقاصد التربوية والفقهية.',
      usage: 'بيان لطائف بكاء النبي ﷺ عند سماع آيات القرآن وهيبة الاستماع.',
    ),
    ReferenceItem(
      title: 'نيل الأوطار من أسرار منتقى الأخبار',
      author: 'الإمام محمد بن علي بن محمد الشوكاني',
      deathYear: '١٢٥٠ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'مرجع فقهي وحديثي رصين في شرح أحاديث الأحكام وتخريجها وتحرير مذاهب العلماء.',
      usage: 'تحرير مسألة الإنصات لقراءة الإمام في الصلوات الجهرية.',
    ),
    ReferenceItem(
      title: 'حاشية السندي على سنن ابن ماجه (كفاية الحاجة)',
      author: 'العلامة محمد بن عبد الهادي التتوي السندي',
      deathYear: '١١٣٨ هـ',
      category: 'شروح الحديث المعتمدة',
      description: 'حاشية نفيسة محررة على سنن ابن ماجه توضح غريب الألفاظ وتستنبط الفوائد.',
      usage: 'شرح حديث ترديد النبي ﷺ للآية الواحدة في قيام الليل بالرجاء والشفقة.',
    ),

    // 3. كتب التفسير وعلوم القرآن
    ReferenceItem(
      title: 'التبيان في آداب حملة القرآن',
      author: 'الإمام محيي الدين يحيى بن شرف النووي',
      deathYear: '٦٧٦ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'أشهر وأجمع مصنف في آداب تلاوة القرآن وحفظه وتعليمه وإكرام أهله وإخلاص النية فيه.',
      usage: 'المرجع الأساسي في توجيه آداب الطلاب والمعلمين وحواشي الكتاب التطبيقية.',
    ),
    ReferenceItem(
      title: 'فضائل القرآن وتفسير القرآن العظيم',
      author: 'الحافظ عماد الدين إسماعيل بن عمر بن كثير',
      deathYear: '٧٧٤ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'عمدة كتب التفسير بالمأثور، جمع فيه مؤلفه فضائل السور والآيات بالأسانيد الصحيحة.',
      usage: 'بيان فضائل سورة البقرة وآل عمران، وآية الكرسي، وخواتيم سورة البقرة.',
    ),
    ReferenceItem(
      title: 'تيسير الكريم الرحمن في تفسير كلام المنان',
      author: 'العلامة عبد الرحمن بن ناصر السعدي',
      deathYear: '١٣٧٦ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'تفسير سلفي ميسر يعتني ببيان المعنى الإجمالي والمقاصد القرآنية بعبارة عذبة.',
      usage: 'تفسير الآيات الواردة في نصوص الأحاديث وشواهد التدبر والعمل.',
    ),
    ReferenceItem(
      title: 'الجامع لأحكام القرآن (تفسير القرطبي)',
      author: 'الإمام أبو عبد الله محمد بن أحمد الأنصاري القرطبي',
      deathYear: '٦٧١ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'موسوعة كبرى في التفسير واستنباط الأحكام الشرعية وآداب التلاوة وحرمة نسيان القرآن.',
      usage: 'تفسير حديث نزول القرآن على سبعة أحرف وتأكيد حرمة إهمال تعاهد القرآن.',
    ),
    ReferenceItem(
      title: 'الإبانة عن معاني القراءات',
      author: 'الإمام مكي بن أبي طالب القيسي',
      deathYear: '٤٣٧ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'من أوائل وأدق كتب علوم القراءات، بيّن فيه علل القراءات ووجوهها وتواترها.',
      usage: 'توجيه حديث قراءة النبي ﷺ على أبيّ بن كعب وضبط الأداء والتلقي بالسند المتصل.',
    ),
    ReferenceItem(
      title: 'الوافي في شرح الشاطبية في القراءات السبع',
      author: 'فضيلة الشيخ عبد الفتاح بن عبد الغني القاضي',
      deathYear: '١٤٠٣ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'أشهر وأشمل شرح معاصر لمنظومة الشاطبية، حرر فيه قواعد القراءات السبع وأصولها وفرشها.',
      usage: 'تحرير وضبط وجوه القراءات المتواترة المروية عن النبي ﷺ في تلاوة الآيات.',
    ),
    ReferenceItem(
      title: 'الفرائد الجليلة في شرح الدرر اللوامع في أصل مقرأ الإمام نافع',
      author: 'العلامة المحدث عبد الله بن فودي النيجيري',
      deathYear: '١٢٤٥ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'شرح فريد رصين لمنظومة الدرر اللوامع لابن بري في قراءة الإمام نافع بروايتي قالون وورش.',
      usage: 'تأصيل علوم الإقراء ورواية ورش وقالون المعتمدة في غرب إفريقيا وحلقات التحفيظ.',
    ),
    ReferenceItem(
      title: 'الإتقان في علوم القرآن',
      author: 'الحافظ جلال الدين عبد الرحمن السيوطي',
      deathYear: '٩١١ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'موسوعة شاملة في سائر أنواع علوم القرآن كالمكي والمدني وأسباب النزول والقراءات.',
      usage: 'تأصيل مباحث كيفية نزول القرآن والوحي ورخصة نزوله على سبعة أحرف.',
    ),
    ReferenceItem(
      title: 'النشر في القراءات العشر ومنجد المقرئين',
      author: 'الإمام شمس الدين أبو الخير محمد بن محمد بن الجزري',
      deathYear: '٨٣٣ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'أعظم كتاب في علم القراءات العشر المتواترة وضوابط التلقي والإسناد وأصول الأداء.',
      usage: 'تحرير ركنية التلقي المشافهة عن الشيوخ المسندين المتقنين.',
    ),
    ReferenceItem(
      title: 'التحديد في الإتقان والتجويد',
      author: 'الإمام أبو عمرو عثمان بن سعيد الداني',
      deathYear: '٤٤٤ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'كتاب أصيل في مخارج الحروف وصفاتها وسنة المد والترتيل المأثورة عن النبي ﷺ.',
      usage: 'تحرير صفة قراءة النبي ﷺ بالمد والترتيل الحسن.',
    ),
    ReferenceItem(
      title: 'حرز الأماني ووجه التهاني (الشاطبية)',
      author: 'الإمام القاسم بن فيرُّه بن خلف الشاطبي',
      deathYear: '٥٩٠ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'المنظومة اللامية الشهيرة في القراءات السبع المتواترة، عمدة القراء عبر القرون.',
      usage: 'الاستشهاد بأبياتها في فضل نقل القرآن وأجر أهل الأداء المتقنين.',
    ),
    ReferenceItem(
      title: 'شرح القواعد الحسان في تفسير القرآن',
      author: 'فضيلة الشيخ محمد بن صالح العثيمين',
      deathYear: '١٤٢١ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'شرح أصولي رصين لقواعد العلامة السعدي في استنباط المعاني وفهم القرآن وتدبره.',
      usage: 'بيان الضوابط المنهجية في فهم نصوص الوحي وتفسير الآيات الواردة في الأحاديث.',
    ),
    ReferenceItem(
      title: 'بهجة قلوب الأبرار وقرة عيون الأخيار',
      author: 'العلامة عبد الرحمن بن ناصر السعدي',
      deathYear: '١٣٧٦ هـ',
      category: 'علوم القرآن وآدابه',
      description: 'شرح جامع لتسعة وتسعين حديثاً من جوامع الكلم في العقيدة والآداب والقرآن.',
      usage: 'توجيه أحاديث خشوع الصوت بالقرآن والتدبر.',
    ),
    ReferenceItem(
      title: 'الواضح في علوم القرآن',
      author: 'فضيلة الشيخ د. مصطفى ديب البغا ود. محيي الدين مستو',
      deathYear: 'معاصر',
      category: 'علوم القرآن وآدابه',
      description: 'كتاب منهجي مبسط وجامع في مباحث علوم القرآن الكريم وتاريخ المصحف الشريف.',
      usage: 'تقريب مباحث جمع القرآن وتدوينه وتلاوته وتجويده لطلاب العلم والناشئة.',
    ),

    // 4. كتب العقيدة والرقائق وهدي السلف
    ReferenceItem(
      title: 'زاد المعاد في هدي خير العباد',
      author: 'الإمام شمس الدين محمد بن أبي بكر بن قيم الجوزية',
      deathYear: '٧٥١ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'كتاب فذ في سيرة النبي ﷺ وفقه هديه في عباداته ومعاملاته وتلاوته للقرآن واستشفائه به.',
      usage: 'بيان هدي النبي ﷺ في قيام الليل بالقرآن والترتيل والرقية بالفاتحة والمعوذات.',
    ),
    ReferenceItem(
      title: 'جواب أهل العلم والإيمان بأن «قل هو الله أحد» تعدل ثلث القرآن',
      author: 'شيخ الإسلام أحمد بن عبد الحليم بن تيمية',
      deathYear: '٧٢٨ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'رسالة علمية برهانية فريدة في إثبات فضل سورة الإخلاص وأقسام علوم القرآن وتوحيد الربوبية والأسماء والصفات.',
      usage: 'بيان أسرار عدل سورة الإخلاص لثلث القرآن في المعنى والثواب.',
    ),
    ReferenceItem(
      title: 'مجموع الفتاوى',
      author: 'شيخ الإسلام أحمد بن عبد الحليم بن تيمية',
      deathYear: '٧٢٨ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'الموسوعة السلفية العظمى في تقرير عقيدة أهل السنة في كلام الله والقرآن والإيمان.',
      usage: 'تقرير أن القرآن كلام الله حقيقة غير مخلوق، منه بدأ وإليه يعود.',
    ),
    ReferenceItem(
      title: 'بدائع الفوائد ومدارج السالكين',
      author: 'الإمام شمس الدين ابن قيم الجوزية',
      deathYear: '٧٥١ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'تحقيقات إيمانية وسلوكية رفيعة في أسرار الشريعة ومنازل العبودية وتدبر كلام الله.',
      usage: 'استنباط الحكم والفوائد الجليلة في الاستعاذة بالمعوذتين وسورة الإخلاص ونزول السكينة.',
    ),
    ReferenceItem(
      title: 'إغاثة اللهفان من مصائد الشيطان ومفتاح دار السعادة',
      author: 'الإمام شمس الدين ابن قيم الجوزية',
      deathYear: '٧٥١ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'مصنفان فريدان في سلامة القلوب وتدبر آيات القرآن وترديدها في قيام الليل.',
      usage: 'توجيه النهي عن القراءة بأقل من ثلاث وترديد الآية الواحدة للتدبر والخشوع.',
    ),
    ReferenceItem(
      title: 'الأذكار المنتخبة من كلام سيد الأبرار',
      author: 'الإمام محيي الدين يحيى بن شرف النووي',
      deathYear: '٦٧٦ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'أشهر كتاب في الأدعية والأذكار المأثورة عن النبي ﷺ وقراءة القرآن قبل النوم والرقية.',
      usage: 'أوراد تلاوة خواتيم سورة البقرة والمعوذات والتحصين بها كل ليلة.',
    ),
    ReferenceItem(
      title: 'الفصول في سيرة الرسول ﷺ',
      author: 'الحافظ عماد الدين أبو الفداء إسماعيل بن عمر بن كثير',
      deathYear: '٧٧٤ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'مختصر تاريخي محقق في سيرة النبي ﷺ وشمائله الشريفة ونزول الوحي عليه.',
      usage: 'توثيق وقائع نزول الوحي ومدارسة جبريل عليه السلام للقرآن مع النبي ﷺ.',
    ),
    ReferenceItem(
      title: 'رياض الصالحين من كلام سيد المرسلين',
      author: 'الإمام محيي الدين يحيى بن شرف النووي',
      deathYear: '٦٧٦ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'أشهر كتاب حديثي جامع لأحاديث الفضائل والآداب والتربية الإيمانية في العالم الإسلامي.',
      usage: 'ترتيب أبواب الفضائل ومراجعة متون أحاديث آداب حملة القرآن وتلاوته.',
    ),
    ReferenceItem(
      title: 'مجموع فتاوى ومقالات متنوعة وفتاوى نور على الدرب',
      author: 'سماحة الشيخ الإمام عبد العزيز بن عبد الله بن باز',
      deathYear: '١٤٢٠ هـ',
      category: 'العقيدة وهدي السلف',
      description: 'فتاوى محققة على هدي الكتاب والسنة في أحكام التلاوة والإنصات والأدعية.',
      usage: 'بيان أحكام الاستماع للقرآن وقراءة المعوذات دبر كل صلاة مكتوبة.',
    ),
  ];

  List<String> get _categories {
    final Set<String> cats = {'الكل'};
    for (final item in _references) {
      cats.add(item.category);
    }
    return cats.toList();
  }

  List<ReferenceItem> get _filteredReferences {
    return _references.where((item) {
      final matchesCategory =
          _selectedCategory == 'الكل' || item.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.author.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.usage.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showReferenceDetails(ReferenceItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14241C) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.right,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'توفي سنة: ${item.deathYear}',
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('•', style: TextStyle(color: theme.colorScheme.secondary)),
                  const SizedBox(width: 8),
                  Text(
                    item.author,
                    style: GoogleFonts.tajawal(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.person_outline_rounded,
                      size: 16, color: theme.colorScheme.secondary),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Text(
                'التعريف بالكتاب ومكانته:',
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                textAlign: TextAlign.right,
                style: GoogleFonts.amiri(
                  fontSize: 15.5,
                  height: 1.7,
                  color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'موضع الاستفادة منه في «تحفة الولدان»:',
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  item.usage,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    height: 1.65,
                    color: isDark ? const Color(0xFFECE6D9) : const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '«${item.title}» — ${item.author} (${item.deathYear})\n'
                          '${item.description}\nالاستفادة في تحفة الولدان: ${item.usage}',
                    ),
                  );
                  Navigator.pop(modalContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ بيانات المرجع بنجاح'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(
                  'نسخ توثيق المرجع',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final green = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;
    final bgColor = isDark ? const Color(0xFF0F1E15) : const Color(0xFFFAF7F0);
    final cardBg = isDark ? const Color(0xFF16261E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E362A) : const Color(0xFFEBE3D5);
    final filtered = _filteredReferences;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'أَهَمُّ مَصَادِرِ وَمَرَاجِعِ الكِتَابِ',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن اسم المرجع أو العالم أو الكلمة المفتاحية...',
                    hintStyle: GoogleFonts.tajawal(fontSize: 13),
                    prefixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    suffixIcon: Icon(Icons.search_rounded, color: green),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1F3328) : const Color(0xFFF3EFE6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: green,
                          backgroundColor: isDark ? const Color(0xFF1F3328) : const Color(0xFFEBE5D8),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Overview Header Note
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'جميع نصوص الأحاديث والتعليقات والحواشي في «تحفة الولدان» مستقاة من أصح مصادر وشروح أهل السنة والجماعة المعتمدة.',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.tajawal(
                        fontSize: 12.5,
                        height: 1.55,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.verified_rounded, color: gold, size: 22),
                ],
              ),
            ),
          ),

          // References List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'لم يتم العثور على مراجع مطابقة للبحث',
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showReferenceDetails(item),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.auto_stories_rounded,
                                          color: green,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              item.title,
                                              textAlign: TextAlign.right,
                                              style: GoogleFonts.amiri(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: green,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.author} (${item.deathYear})',
                                              textAlign: TextAlign.right,
                                              style: GoogleFonts.tajawal(
                                                fontSize: 12.5,
                                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.description,
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'عرض التفاصيل',
                                            style: GoogleFonts.tajawal(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: gold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.arrow_back_ios_new_rounded,
                                              size: 11, color: gold),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: gold.withValues(alpha: isDark ? 0.18 : 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: GoogleFonts.tajawal(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: gold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
