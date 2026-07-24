import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/advertisements/ad_management_screen.dart';
import 'package:sehatak/core/models/ad_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _totalUsers = 0;
  int _totalProviders = 0;
  int _totalBookings = 0;
  int _totalRevenue = 0;
  int _pendingAds = 0;

  final List<String> _tabs = ['الرئيسية', 'المستخدمين', 'المقدمين', 'الإعلانات'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // عدد المستخدمين
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();
      _totalUsers = usersSnap.docs.length;

      // عدد المقدمين (أطباء، صيدليات، مختبرات، مستشفيات)
      final providers = await Future.wait([
        FirebaseFirestore.instance.collection('doctors').get(),
        FirebaseFirestore.instance.collection('pharmacies').get(),
        FirebaseFirestore.instance.collection('labs').get(),
        FirebaseFirestore.instance.collection('hospitals').get(),
      ]);
      _totalProviders = providers.fold(0, (sum, snap) => sum + snap.docs.length);

      // عدد الحجوزات
      final bookingsSnap = await FirebaseFirestore.instance.collection('bookings').get();
      _totalBookings = bookingsSnap.docs.length;
      _totalRevenue = bookingsSnap.docs.fold(0, (sum, doc) {
        return sum + (doc.data()['amount'] as int? ?? 0);
      });

      // الإعلانات قيد المراجعة
      final adsSnap = await FirebaseFirestore.instance
          .collection('advertisements')
          .where('status', isEqualTo: 'pending')
          .get();
      _pendingAds = adsSnap.docs.length;

      setState(() {});
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('لوحة تحكم المشرف'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ إحصائيات سريعة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                _buildStatCard('المستخدمين', '$_totalUsers', Icons.people, Colors.blue),
                _buildStatCard('المقدمين', '$_totalProviders', Icons.business, Colors.amber),
                _buildStatCard('الحجوزات', '$_totalBookings', Icons.event, Colors.green),
                _buildStatCard('الإيرادات', '$_totalRevenue ريال', Icons.attach_money, Colors.purple),
              ],
            ),
          ),
          // ✅ تنبيه الإعلانات
          if (_pendingAds > 0)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔔 $_pendingAds إعلان في انتظار المراجعة',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdManagementScreen(
                          providerId: user?.uid,
                          providerName: 'المشرف',
                          providerType: AdType.service,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: const Text('مراجعة', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          // ✅ تبويبات
          Container(
            color: isDark ? const Color(0xFF0B1121) : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              tabs: const [
                Tab(text: 'الرئيسية'),
                Tab(text: 'المستخدمين'),
                Tab(text: 'المقدمين'),
                Tab(text: 'الإعلانات'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                _buildUsersTab(),
                _buildProvidersTab(),
                _buildAdsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مرحباً بك في لوحة تحكم المشرف', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('إدارة المنصة بالكامل من مكان واحد', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildAdminCard('المستخدمين', '$_totalUsers', Icons.people, Colors.blue),
              _buildAdminCard('المقدمين', '$_totalProviders', Icons.business, Colors.amber),
              _buildAdminCard('الحجوزات', '$_totalBookings', Icons.event, Colors.green),
              _buildAdminCard('الإيرادات', '$_totalRevenue ريال', Icons.attach_money, Colors.purple),
              _buildAdminCard('الإعلانات', '$_pendingAds قيد المراجعة', Icons.advertising, Colors.orange),
              _buildAdminCard('المنصة', 'نشطة ✅', Icons.check_circle, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(user['name']?.substring(0, 1) ?? 'U'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name'] ?? 'مستخدم', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(user['email'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(user['role'] ?? 'مريض', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['isActive'] != false ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user['isActive'] != false ? 'نشط' : 'محظور',
                      style: TextStyle(fontSize: 10, color: user['isActive'] != false ? Colors.green : Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProvidersTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'أطباء'),
              Tab(text: 'صيدليات'),
              Tab(text: 'مختبرات'),
              Tab(text: 'مستشفيات'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildProviderList('doctors'),
                _buildProviderList('pharmacies'),
                _buildProviderList('labs'),
                _buildProviderList('hospitals'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data?.docs ?? [];

        if (items.isEmpty) {
          return const Center(child: Text('لا يوجد مقدمين'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  collection == 'doctors' ? Icons.local_hospital :
                  collection == 'pharmacies' ? Icons.local_pharmacy :
                  collection == 'labs' ? Icons.science :
                  Icons.medical_services,
                  color: AppColors.primary,
                ),
              ),
              title: Text(item['name'] ?? 'غير معروف'),
              subtitle: Text(item['address'] ?? ''),
              trailing: Switch(
                value: item['isAvailable'] ?? true,
                onChanged: (value) {},
                activeColor: AppColors.primary,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.advertising, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('إدارة الإعلانات'),
          SizedBox(height: 8),
          Text('انقر على زر الإعلانات في الأعلى', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
