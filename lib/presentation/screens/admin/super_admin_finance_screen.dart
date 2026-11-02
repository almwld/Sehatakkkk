import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/services/toast_service.dart';

class SuperAdminFinanceScreen extends StatefulWidget {
  const SuperAdminFinanceScreen({super.key});

  @override
  State<SuperAdminFinanceScreen> createState() => _SuperAdminFinanceScreenState();
}

class _SuperAdminFinanceScreenState extends State<SuperAdminFinanceScreen> {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  String _filter = 'pending';
  final Set<String> _processing = <String>{};

  String _t(String value) => AppStrings.of(context).translate(value);

  String _money(num value) => '${value.toStringAsFixed(2)} YER';

  DateTime? _dateOf(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _dateLabel(dynamic value) {
    final date = _dateOf(value);
    if (date == null) return '—';
    final local = date.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}  ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _review(String id, bool approve) async {
    if (_processing.contains(id)) return;
    setState(() => _processing.add(id));
    try {
      await _functions.httpsCallable('reviewTransaction').call({
        'transactionId': id,
        'decision': approve ? 'approve' : 'reject',
      });
      if (mounted) {
        ToastService.showSuccess(_t(approve ? 'تم اعتماد المعاملة المالية' : 'تم رفض المعاملة المالية'));
      }
    } catch (error) {
      if (mounted) ToastService.showError(_t('تعذرت معالجة المعاملة: ') + error.toString());
    } finally {
      if (mounted) setState(() => _processing.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF172033) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF263238);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(child: Text(_t('المركز المالي'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor))),
          IconButton(tooltip: _t('تحديث'), onPressed: () => setState(() {}), icon: const Icon(Icons.refresh)),
        ]),
        Text(_t('ملخص الأرصدة والحركات المالية المسجلة في المنصة.'), style: TextStyle(color: textColor.withOpacity(.7))),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('wallets').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _errorCard(_t('تعذر تحميل أرصدة المحافظ: ') + snapshot.error.toString());
            if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
            num balance = 0, pending = 0, deposited = 0, withdrawn = 0;
            for (final doc in snapshot.data!.docs) {
              final data = doc.data();
              balance += _number(data['balance']);
              pending += _number(data['pendingBalance']);
              deposited += _number(data['totalDeposited']);
              withdrawn += _number(data['totalWithdrawn']);
            }
            return Column(children: [
              _metricGrid(surface, textColor, [
                _Metric(_t('إجمالي أرصدة المحافظ'), _money(balance), Icons.account_balance_wallet_outlined),
                _Metric(_t('أرصدة معلقة'), _money(pending), Icons.hourglass_top),
                _Metric(_t('إجمالي الإيداعات المعتمدة'), _money(deposited), Icons.south_west),
                _Metric(_t('إجمالي السحوبات المعتمدة'), _money(withdrawn), Icons.north_east),
              ]),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: Text(_t('عدد المحافظ المسجلة: ') + snapshot.data!.size.toString(), style: TextStyle(color: textColor.withOpacity(.7)))),
            ]);
          },
        ),
        const SizedBox(height: 20),
        Text(_t('الأرباح والإيرادات'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: textColor)),
        const SizedBox(height: 8),
        Card(color: surface, child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.insights_outlined, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(_t('العمولات والرسوم المسجلة'), style: const TextStyle(fontWeight: FontWeight.w800)))]),
            const SizedBox(height: 8),
            Text(_t('لا تُسجل المنظومة حالياً قيوداً مستقلة كافية لحساب صافي أرباح المنصة بصورة موثوقة.'), style: TextStyle(color: textColor.withOpacity(.75))),
            const SizedBox(height: 6),
            Text(_t('لن نعتبر مبالغ شحن المحافظ أو إجمالي المدفوعات أرباحاً؛ يلزم تسجيل عمولات المنصة والمصروفات بشكل منفصل.'), style: TextStyle(color: textColor.withOpacity(.75))),
          ]),
        )),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Text(_t('إدارة المعاملات'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: textColor))),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          _filterChip(_t('المعلقة'), 'pending'),
          _filterChip(_t('الكل'), 'all'),
        ]),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _transactionStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _errorCard(_t('تعذر تحميل المعاملات: ') + snapshot.error.toString());
            if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return Card(color: surface, child: Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(_t('لا توجد معاملات ضمن هذا العرض')))));
            return Column(children: docs.map((doc) => _transactionCard(doc, surface, textColor)).toList()),
          },
        ),
        const SizedBox(height: 12),
        Text(_t('يتم عرض أحدث 100 معاملة كحد أقصى. تتم مراجعة طلبات الإيداع والسحب والاسترداد من هذا المركز.'), style: TextStyle(fontSize: 12, color: textColor.withOpacity(.65))),
      ],
    );
  }

  num _number(dynamic value) => value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;

  Stream<QuerySnapshot<Map<String, dynamic>>> _transactionStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('transactions');
    if (_filter == 'pending') query = query.where('status', isEqualTo: 'pending');
    return query.orderBy('createdAt', descending: true).limit(100).snapshots();
  }

  Widget _filterChip(String label, String value) => ChoiceChip(
    label: Text(label), selected: _filter == value,
    onSelected: (_) => setState(() => _filter = value),
  );

  Widget _metricGrid(Color surface, Color textColor, List<_Metric> metrics) => GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.42, mainAxisSpacing: 8, crossAxisSpacing: 8,
    children: metrics.map((metric) => Card(color: surface, child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(metric.icon, color: AppColors.primary),
        const SizedBox(height: 7),
        Text(metric.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor)),
        const SizedBox(height: 3),
        Text(metric.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: textColor.withOpacity(.75))),
      ]),
    ))).toList(),
  );

  Widget _transactionCard(QueryDocumentSnapshot<Map<String, dynamic>> doc, Color surface, Color textColor) {
    final data = doc.data();
    final type = data['type']?.toString() ?? '—';
    final status = data['status']?.toString() ?? '—';
    final pending = status == 'pending';
    final busy = _processing.contains(doc.id);
    final title = data['title']?.toString() ?? _transactionType(type);
    final subtitle = [
      _t('المستخدم: ') + (data['userId']?.toString() ?? '—'),
      _t('التاريخ: ') + _dateLabel(data['createdAt']),
      _t('الحالة: ') + _transactionStatus(status),
    ].join('\n');
    return Card(
      color: surface, margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
            Text(_money(_number(data['amount'])), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
          ]),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 12, color: textColor.withOpacity(.7))),
          if ((data['walletName'] ?? '').toString().isNotEmpty) Text(_t('المحفظة: ') + data['walletName'].toString()),
          if ((data['referenceNumber'] ?? '').toString().isNotEmpty) Text(_t('المرجع: ') + data['referenceNumber'].toString()),
          if (pending && ['deposit', 'withdrawal', 'refund'].contains(type)) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: busy ? null : () => _review(doc.id, false),
                child: Text(_t('رفض')),
              )),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(
                onPressed: busy ? null : () => _review(doc.id, true),
                child: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_t('اعتماد')),
              )),
            ]),
          ],
        ]),
      ),
    );
  }

  String _transactionType(String type) {
    switch (type) {
      case 'deposit': return _t('إيداع');
      case 'withdrawal': return _t('سحب');
      case 'payment': return _t('دفع');
      case 'refund': return _t('استرداد');
      default: return type;
    }
  }

  String _transactionStatus(String status) {
    switch (status) {
      case 'pending': return _t('قيد المراجعة');
      case 'completed': return _t('مكتملة');
      case 'failed': return _t('مرفوضة');
      default: return status;
    }
  }

  Widget _errorCard(String message) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(message)));
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}
