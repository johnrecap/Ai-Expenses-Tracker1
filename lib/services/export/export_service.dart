import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_repository/expense_repository.dart';

class ExportService {
  Future<void> exportCsv(List<Expense> expenses) async {
    final rows = <List<String>>[
      ['Date', 'Category', 'Amount', 'Payment Method', 'Description'],
      ...expenses.map((e) => [e.date.toIso8601String(), e.categoryName, e.amount.toString(), e.paymentMethod.label, e.description]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    await _shareFile(csv, 'expenses_export.csv');
  }

  Future<void> exportExcel(List<Expense> expenses) async {
    final excel = Excel.createExcel();
    final sheet = excel['Expenses'];
    final headers = ['Date', 'Category', 'Amount', 'Payment Method', 'Description'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
    }
    for (var r = 0; r < expenses.length; r++) {
      final e = expenses[r];
      final row = r + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = e.date.toIso8601String();
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = e.categoryName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = e.amount;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = e.paymentMethod.label;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = e.description;
    }
    final bytes = excel.encode();
    if (bytes != null) await _shareBytes(bytes, 'expenses_export.xlsx');
  }

  Future<void> exportPdf(List<Expense> expenses) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      build: (ctx) => [
        pw.Header(text: 'Expenses Report', textStyle: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        pw.Table.fromTextArray(
          headers: ['Date', 'Category', 'Amount', 'Payment'],
          data: expenses.map((e) => [e.date.toIso8601String().substring(0, 10), e.categoryName, e.amount.toStringAsFixed(2), e.paymentMethod.label]).toList(),
        ),
      ],
    ));
    await _shareBytes(await pdf.save(), 'expenses_export.pdf');
  }

  Future<void> _shareFile(String content, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _shareBytes(List<int> bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }
}
