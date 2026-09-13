from pathlib import Path
import subprocess

HOME = Path('lib/presentation/screens/home/tabs/home_tab.dart')
PATIENT = Path('lib/presentation/screens/patient/patient_dashboard.dart')

# Restore HomeTab if a previous CI repair accidentally replaced its contents,
# then repair both known list-closing syntax errors without deleting features.
try:
    current = HOME.read_text(encoding='utf-8')
except FileNotFoundError:
    current = ''
if current.strip() == 'REPLACE_ME' or len(current) < 1000:
    restored = subprocess.check_output(
        ['git', 'show', 'd3542870b585d95186c520edffec26f612353947:lib/presentation/screens/home/tabs/home_tab.dart'],
        text=True,
    )
    HOME.write_text(restored, encoding='utf-8')

text = HOME.read_text(encoding='utf-8')
text = text.replace(
    'color: dark ? Colors.white70 : _muted))]),',
    'color: dark ? Colors.white70 : _muted))]),',
    1,
)
# Doctor rating Row: Text closes with ), then the children list ], then Row ).
text = text.replace(
    "Text('${doctor['rating'] ?? 0}', style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted))]]),",
    "Text('${doctor['rating'] ?? 0}', style: TextStyle(fontSize: 10, color: dark ? Colors.white70 : _muted))]),",
    1,
)
HOME.write_text(text, encoding='utf-8')

# PatientDashboard: restore State.build without deleting existing fields or helpers.
text = PATIENT.read_text(encoding='utf-8')
if 'Widget build(BuildContext context)' not in text:
    marker = '  Widget _buildQRCode() {'
    if marker not in text:
        raise SystemExit('PatientDashboard insertion marker not found')
    build = '''  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF17212B) : Colors.white;
    final background = dark ? const Color(0xFF0F1720) : const Color(0xFFF5F7F8);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('ملفي الصحي'), centerTitle: true, backgroundColor: background, elevation: 0, actions: [
        IconButton(onPressed: _isSharing ? null : _shareProfile, icon: const Icon(Icons.share_outlined)),
        IconButton(onPressed: _showQRCode, icon: const Icon(Icons.qr_code_2_outlined)),
      ]),
      body: RefreshIndicator(
        onRefresh: _loadUserDataInBackground,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)), child: Row(children: [
              GestureDetector(onTap: _pickImage, child: CircleAvatar(radius: 34, backgroundColor: AppColors.primary.withOpacity(.12), backgroundImage: _userAvatar.isNotEmpty ? NetworkImage(_userAvatar) : null, child: _userAvatar.isEmpty ? const Icon(Icons.person_outline, size: 34, color: AppColors.primary) : null)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_isLoading && !_dataLoaded ? 'جاري تحميل بياناتك...' : _userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(_userEmail.isEmpty ? _userRole : _userEmail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.white70 : Colors.black54, fontSize: 12)),
                const SizedBox(height: 8),
                Text('رقم المريض: $_patientNumber • فصيلة الدم: $_bloodType', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ])),
            ])),
            const SizedBox(height: 20),
            Text('المؤشرات الصحية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black87)),
            const SizedBox(height: 10),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _vitals.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.45), itemBuilder: (context, index) {
              final item = _vitals[index];
              return InkWell(borderRadius: BorderRadius.circular(16), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget)), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(item['label'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text(item['value'].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ])));
            }),
            const SizedBox(height: 20),
            Text('الخدمات الصحية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black87)),
            const SizedBox(height: 10),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _services.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: .95), itemBuilder: (context, index) {
              final item = _services[index];
              return InkWell(borderRadius: BorderRadius.circular(15), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget)), child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(15)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.medical_services_outlined, color: item['color'] as Color, size: 27), const SizedBox(height: 7), Text(item['label'].toString(), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))])));
            }),
          ]),
        ),
      ),
    );
  }

'''
    text = text.replace(marker, build + marker, 1)
    PATIENT.write_text(text, encoding='utf-8')
    print('Restored PatientDashboard.build')
else:
    print('PatientDashboard.build already exists')
