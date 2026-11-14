import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/daftar_database.dart';
import '../models/daftar_record.dart';
import '../services/invoice_pdf_service.dart';

class RecordsScreen extends StatefulWidget {
  final String module;
  final String title;
  final IconData icon;
  const RecordsScreen({super.key, required this.module, required this.title, required this.icon});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  late Future<List<DaftarRecord>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = DaftarDatabase.instance.getRecords(widget.module);

  String get _titleLabel => widget.module == 'clients'
      ? 'اسم العميل'
      : widget.module == 'products'
          ? 'اسم المنتج'
          : widget.module == 'invoices'
              ? 'عنوان الفاتورة / العميل'
              : 'البيان';

  bool get _needsAmount => !{'clients', 'settings', 'reports'}.contains(widget.module);

  Future<void> _addRecord() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('إضافة: ${widget.title}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: _titleLabel),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
                ),
                if (_needsAmount) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: widget.module == 'products' ? 'السعر بالدينار' : 'المبلغ بالدينار',
                      suffixText: 'دج',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'أدخل المبلغ';
                      if (double.tryParse(v.replaceAll(',', '.')) == null) return 'أدخل رقماً صحيحاً';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 10),
                TextFormField(
                  controller: detailsController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'ملاحظات / تفاصيل (اختياري)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (saved == true) {
      final amount = _needsAmount
          ? double.parse(amountController.text.trim().replaceAll(',', '.'))
          : 0.0;
      await DaftarDatabase.instance.addRecord(DaftarRecord(
        module: widget.module,
        title: titleController.text.trim(),
        amount: amount,
        details: detailsController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      ));
      if (mounted) {
        setState(_reload);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ على الهاتف')));
      }
    }
    titleController.dispose();
    amountController.dispose();
    detailsController.dispose();
  }

  Future<void> _delete(DaftarRecord record) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السجل؟'),
        content: Text('هل تريد حذف "${record.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok == true && record.id != null) {
      await DaftarDatabase.instance.deleteRecord(record.id!);
      if (mounted) setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addRecord,
      icon: const Icon(Icons.add),
      label: const Text('إضافة'),
    ),
    body: FutureBuilder<List<DaftarRecord>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final records = snapshot.data!;
        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 54, color: Colors.blueGrey.shade200),
                  const SizedBox(height: 12),
                  const Text('لا توجد سجلات بعد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('اضغط على زر إضافة لبدء تسجيل البيانات', textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final record = records[index];
            final date = DateFormat('yyyy/MM/dd').format(DateTime.parse(record.createdAt));
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEAF1F9),
                  child: Icon(widget.icon, color: const Color(0xFF2463A6)),
                ),
                title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(record.details.isEmpty ? date : '$date\n${record.details}'),
                isThreeLine: record.details.isNotEmpty,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await _delete(record);
                    } else if (value == 'pdf' && widget.module == 'invoices') {
                      await InvoicePdfService.printInvoice(record);
                    }
                  },
                  itemBuilder: (_) => [
                    if (widget.module == 'invoices')
                      const PopupMenuItem(value: 'pdf', child: Text('طباعة / PDF')),
                    const PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
                onTap: widget.module == 'invoices'
                    ? () => InvoicePdfService.printInvoice(record)
                    : null,
              ),
            );
          },
        );
      },
    ),
  );
}
