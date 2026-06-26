class MedicationData {
  static List<Map<String, dynamic>> get medications => [
    // ========== مسكنات ==========
    {'id': 'm001', 'name': 'باراسيتامول 500mg', 'price': 500, 'category': 'مسكنات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'desc': 'مسكن للآلام وخافض للحرارة', 'brand': 'بانادول'},
    {'id': 'm002', 'name': 'إيبوبروفين 400mg', 'price': 800, 'category': 'مسكنات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'desc': 'مضاد للالتهاب ومسكن', 'brand': 'بروفين'},
    {'id': 'm003', 'name': 'ديكلوفيناك 50mg', 'price': 600, 'category': 'مسكنات', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1632833239869-a37e7a58066e?w=200', 'desc': 'مضاد التهاب قوي', 'brand': 'فولتارين'},
    {'id': 'm004', 'name': 'نابروكسين 250mg', 'price': 700, 'category': 'مسكنات', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'مسكن للآلام المزمنة', 'brand': 'نابروكسين'},
    {'id': 'm005', 'name': 'أسبرين 100mg', 'price': 400, 'category': 'مسكنات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'desc': 'مسكن وخافض حرارة', 'brand': 'أسبرين'},
    
    // ========== مضادات حيوية ==========
    {'id': 'm006', 'name': 'أموكسيسيلين 500mg', 'price': 1500, 'category': 'مضادات حيوية', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'desc': 'مضاد حيوي واسع الطيف', 'brand': 'أموكسيسيلين'},
    {'id': 'm007', 'name': 'أزيثرومايسين 500mg', 'price': 3500, 'category': 'مضادات حيوية', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=200', 'desc': 'مضاد حيوي للعدوى التنفسية', 'brand': 'زيثروماكس'},
    {'id': 'm008', 'name': 'سيفالكسين 500mg', 'price': 2000, 'category': 'مضادات حيوية', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'desc': 'مضاد حيوي للعدوى الجلدية', 'brand': 'سيفالكسين'},
    {'id': 'm009', 'name': 'دوكسيسايكلين 100mg', 'price': 1800, 'category': 'مضادات حيوية', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'desc': 'مضاد حيوي واسع الطيف', 'brand': 'دوكسيسايكلين'},
    {'id': 'm010', 'name': 'سيبروفلوكساسين 500mg', 'price': 2200, 'category': 'مضادات حيوية', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'desc': 'مضاد حيوي للعدوى البولية', 'brand': 'سيبرو'},
    
    // ========== فيتامينات ==========
    {'id': 'm011', 'name': 'فيتامين د3 1000IU', 'price': 1200, 'category': 'فيتامينات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'مكمل غذائي لصحة العظام', 'brand': 'فيتامين د'},
    {'id': 'm012', 'name': 'فيتامين سي 1000mg', 'price': 800, 'category': 'فيتامينات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1563213126-4276a5b3e1d7?w=200', 'desc': 'مقوي للمناعة', 'brand': 'فيتامين سي'},
    {'id': 'm013', 'name': 'فيتامين ب12 1000mcg', 'price': 1500, 'category': 'فيتامينات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'desc': 'للطاقة والأعصاب', 'brand': 'ب12'},
    {'id': 'm014', 'name': 'كالسيوم + مغنيسيوم', 'price': 1800, 'category': 'فيتامينات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'مكمل للعظام والعضلات', 'brand': 'كالسيوم'},
    {'id': 'm015', 'name': 'زنك 50mg', 'price': 600, 'category': 'فيتامينات', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1632833239869-a37e7a58066e?w=200', 'desc': 'مقوي للمناعة والبشرة', 'brand': 'زنك'},
    
    // ========== أدوية القلب والضغط ==========
    {'id': 'm016', 'name': 'أملوديبين 5mg', 'price': 2000, 'category': 'قلب وضغط', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'desc': 'لعلاج ضغط الدم المرتفع', 'brand': 'أملوديبين'},
    {'id': 'm017', 'name': 'ليسينوبريل 10mg', 'price': 1800, 'category': 'قلب وضغط', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'desc': 'لعلاج ارتفاع ضغط الدم', 'brand': 'ليسينوبريل'},
    {'id': 'm018', 'name': 'أتورفاستاتين 20mg', 'price': 2500, 'category': 'قلب وضغط', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'desc': 'لخفض الكوليسترول', 'brand': 'أتورفاستاتين'},
    {'id': 'm019', 'name': 'بيزوبرولول 2.5mg', 'price': 2200, 'category': 'قلب وضغط', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'لعلاج ارتفاع ضغط الدم', 'brand': 'بيزوبرولول'},
    {'id': 'm020', 'name': 'لوسارتان 50mg', 'price': 1900, 'category': 'قلب وضغط', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'desc': 'لعلاج ارتفاع ضغط الدم', 'brand': 'لوسارتان'},
    
    // ========== أدوية السكري ==========
    {'id': 'm021', 'name': 'ميتفورمين 500mg', 'price': 1000, 'category': 'سكري', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'desc': 'لعلاج السكري من النوع الثاني', 'brand': 'ميتفورمين'},
    {'id': 'm022', 'name': 'جلوكوفاج 1000mg', 'price': 1200, 'category': 'سكري', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'desc': 'لعلاج السكري من النوع الثاني', 'brand': 'جلوكوفاج'},
    {'id': 'm023', 'name': 'غليميبيريد 2mg', 'price': 800, 'category': 'سكري', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=200', 'desc': 'لخفض نسبة السكر في الدم', 'brand': 'غليميبيريد'},
    {'id': 'm024', 'name': 'سيتاغلبتين 100mg', 'price': 3000, 'category': 'سكري', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'desc': 'لعلاج السكري من النوع الثاني', 'brand': 'جانويا'},
    {'id': 'm025', 'name': 'إنسولين 100IU', 'price': 4500, 'category': 'سكري', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'desc': 'لعلاج السكري من النوع الأول', 'brand': 'إنسولين'},
    
    // ========== أدوية الجهاز التنفسي ==========
    {'id': 'm026', 'name': 'مونتيلوكاست 10mg', 'price': 2500, 'category': 'جهاز تنفسي', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'desc': 'لعلاج الربو والحساسية', 'brand': 'سينجلير'},
    {'id': 'm027', 'name': 'سالبوتامول 100mcg', 'price': 1500, 'category': 'جهاز تنفسي', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'desc': 'موسع للشعب الهوائية', 'brand': 'فنتولين'},
    {'id': 'm028', 'name': 'فلويتيكازون 250mcg', 'price': 2800, 'category': 'جهاز تنفسي', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'desc': 'لعلاج الربو والتهاب الأنف', 'brand': 'فليكسوتايد'},
    {'id': 'm029', 'name': 'بوديزونيد 200mcg', 'price': 2200, 'category': 'جهاز تنفسي', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=200', 'desc': 'لعلاج الربو', 'brand': 'بوديزونيد'},
    {'id': 'm030', 'name': 'تيربوتالين 2.5mg', 'price': 1800, 'category': 'جهاز تنفسي', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'موسع للشعب الهوائية', 'brand': 'تيربوتالين'},
    
    // ========== أدوية الجهاز الهضمي ==========
    {'id': 'm031', 'name': 'أوميبرازول 20mg', 'price': 1200, 'category': 'جهاز هضمي', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'desc': 'لعلاج حرقة المعدة', 'brand': 'أوميبرازول'},
    {'id': 'm032', 'name': 'رانتيدين 150mg', 'price': 800, 'category': 'جهاز هضمي', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1632833239869-a37e7a58066e?w=200', 'desc': 'لعلاج قرحة المعدة', 'brand': 'زانتاك'},
    {'id': 'm033', 'name': 'ميتوكلوبراميد 10mg', 'price': 600, 'category': 'جهاز هضمي', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'desc': 'لعلاج الغثيان والقيء', 'brand': 'بريمابيران'},
    {'id': 'm034', 'name': 'لوبيراميد 2mg', 'price': 500, 'category': 'جهاز هضمي', 'type': 'دواء', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1563213126-4276a5b3e1d7?w=200', 'desc': 'لعلاج الإسهال', 'brand': 'لوبيراميد'},
    {'id': 'm035', 'name': 'بسكوبان 10mg', 'price': 900, 'category': 'جهاز هضمي', 'type': 'دواء', 'prescription': true, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'desc': 'لعلاج المغص المعوي', 'brand': 'بسكوبان'},
    
    // ========== مستحضرات تجميل ==========
    {'id': 'c001', 'name': 'كريم مرطب للوجه', 'price': 2500, 'category': 'مستحضرات تجميل', 'type': 'تجميل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=200', 'desc': 'ترطيب عميق للبشرة', 'brand': 'سيتافيل'},
    {'id': 'c002', 'name': 'واقي شمس SPF 50', 'price': 3000, 'category': 'مستحضرات تجميل', 'type': 'تجميل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=200', 'desc': 'حماية من أشعة الشمس', 'brand': 'لاروش بوزاي'},
    {'id': 'c003', 'name': 'سيروم فيتامين سي', 'price': 4500, 'category': 'مستحضرات تجميل', 'type': 'تجميل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1571875257727-256c39da5afe?w=200', 'desc': 'مضاد للأكسدة وتفتيح', 'brand': 'سيروم سي'},
    {'id': 'c004', 'name': 'كريم للعينين', 'price': 3500, 'category': 'مستحضرات تجميل', 'type': 'تجميل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=200', 'desc': 'مكافحة التجاعيد', 'brand': 'لاروش بوزاي'},
    {'id': 'c005', 'name': 'ماسك للوجه', 'price': 1500, 'category': 'مستحضرات تجميل', 'type': 'تجميل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1571875257727-256c39da5afe?w=200', 'desc': 'تنقية وتفتيح البشرة', 'brand': 'ماسك'},
    
    // ========== مستلزمات صحية ==========
    {'id': 'h001', 'name': 'جهاز قياس ضغط الدم', 'price': 8500, 'category': 'مستلزمات صحية', 'type': 'جهاز', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=200', 'desc': 'قياس دقيق للضغط', 'brand': 'أومرون'},
    {'id': 'h002', 'name': 'جهاز قياس السكر', 'price': 6500, 'category': 'مستلزمات صحية', 'type': 'جهاز', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=200', 'desc': 'قياس دقيق للسكر', 'brand': 'أكسيدنت'},
    {'id': 'h003', 'name': 'أوكسيمتر نبض', 'price': 3500, 'category': 'مستلزمات صحية', 'type': 'جهاز', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=200', 'desc': 'قياس نسبة الأكسجين', 'brand': 'أوكسيمتر'},
    {'id': 'h004', 'name': 'ميزان حرارة رقمي', 'price': 1200, 'category': 'مستلزمات صحية', 'type': 'جهاز', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=200', 'desc': 'قياس دقيق للحرارة', 'brand': 'ميزان حرارة'},
    {'id': 'h005', 'name': 'بخاخة أنف', 'price': 800, 'category': 'مستلزمات صحية', 'type': 'جهاز', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=200', 'desc': 'لعلاج احتقان الأنف', 'brand': 'بخاخة'},
    
    // ========== مكملات غذائية ==========
    {'id': 's001', 'name': 'بروتين واي 2kg', 'price': 12000, 'category': 'مكملات غذائية', 'type': 'مكمل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'بروتين لبناء العضلات', 'brand': 'أوبتيموم'},
    {'id': 's002', 'name': 'أوميغا 3 1000mg', 'price': 2500, 'category': 'مكملات غذائية', 'type': 'مكمل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'لصحة القلب والدماغ', 'brand': 'أوميغا 3'},
    {'id': 's003', 'name': 'ميلاتونين 5mg', 'price': 1500, 'category': 'مكملات غذائية', 'type': 'مكمل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'لتحسين النوم', 'brand': 'ميلاتونين'},
    {'id': 's004', 'name': 'كولاجين 1000mg', 'price': 3000, 'category': 'مكملات غذائية', 'type': 'مكمل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'لصحة البشرة والمفاصل', 'brand': 'كولاجين'},
    {'id': 's005', 'name': 'بروبيوتيك 10B', 'price': 2800, 'category': 'مكملات غذائية', 'type': 'مكمل', 'prescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'لصحة الجهاز الهضمي', 'brand': 'بروبيوتيك'},
  ];
}
