import 'package:flutter/material.dart';
import '../data/daftar_database.dart';
import '../models/daftar_record.dart';
import 'records_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _refresh = 0;

  Future<void> _open(String module, String title, IconData icon) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordsScreen(module: module, title: title, icon: icon),
      ),
    );
    if (mounted) setState(() => _refresh++);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilding after returning from a section refreshes the summary.
    final refreshKey = _refresh;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DAFTAR | دفتر', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('إدارة المحل والفواتير', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: () => setState(() => _refresh++),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Object>>(
        key: ValueKey(refreshKey),
        future: _loadSummary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final sales = data[0] as double;
          final invoices = data[1] as int;
          final clients = data[2] as int;
          final products = data[3] as int;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('مرحباً بك 👋', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('هذا ملخص نشاط محلك', style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.55,
                children: [
                  _StatCard(label: 'إجمالي المبيعات', value: _money(sales), icon: Icons.payments_outlined),
                  _StatCard(label: 'عدد الفواتير', value: '$invoices', icon: Icons.receipt_long_outlined),
                  _StatCard(label: 'العملاء', value: '$clients', icon: Icons.people_outline),
                  _StatCard(label: 'المنتجات', value: '$products', icon: Icons.inventory_2_outlined),
                ],
              ),
              const SizedBox(height: 22),
              const Text('أقسام التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _SectionTile(title: 'الفواتير والمبيعات', subtitle: 'إنشاء سجل فاتورة وطباعة PDF', icon: Icons.receipt_long, onTap: () => _open('invoices', 'الفواتير والمبيعات', Icons.receipt_long)),
              _SectionTile(title: 'العملاء', subtitle: 'حفظ أسماء العملاء وبياناتهم', icon: Icons.people, onTap: () => _open('clients', 'العملاء', Icons.people)),
              _SectionTile(title: 'المنتجات', subtitle: 'إدارة السلع والأسعار', icon: Icons.inventory_2, onTap: () => _open('products', 'المنتجات', Icons.inventory_2)),
              _SectionTile(title: 'المصاريف', subtitle: 'تسجيل مصاريف المحل', icon: Icons.trending_down, onTap: () => _open('expenses', 'المصاريف', Icons.trending_down)),
              _SectionTile(title: 'المداخيل', subtitle: 'تسجيل المداخيل الأخرى', icon: Icons.trending_up, onTap: () => _open('income', 'المداخيل', Icons.trending_up)),
              _SectionTile(title: 'الديون', subtitle: 'متابعة المبالغ المستحقة', icon: Icons.account_balance_wallet, onTap: () => _open('debts', 'الديون', Icons.account_balance_wallet)),
              _SectionTile(title: 'التقارير', subtitle: 'عرض ملخص السجلات', icon: Icons.bar_chart, onTap: () => _open('reports', 'التقارير', Icons.bar_chart)),
              _SectionTile(title: 'الإعدادات', subtitle: 'إعدادات المحل والتطبيق', icon: Icons.settings, onTap: () => _open('settings', 'الإعدادات', Icons.settings)),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'تنبيه: هذه نسخة تأسيسية تحفظ البيانات على الهاتف فقط. لم يتم ربط النسخ السحابي أو تسجيل الدخول بعد.',
                    style: TextStyle(color: Colors.blueGrey.shade800, height: 1.5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Object>> _loadSummary() async {
    final db = DaftarDatabase.instance;
    return [
      await db.totalFor('invoices'),
      await db.countFor('invoices'),
      await db.countFor('clients'),
      await db.countFor('products'),
    ];
  }

  String _money(double value) => '${value.toStringAsFixed(0)} دج';
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF2463A6)),
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

class _SectionTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _SectionTile({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEAF1F9),
        child: Icon(icon, color: const Color(0xFF2463A6)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    ),
  );
}
