import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/expense_item.dart';

/// Service to export reports as PDF.
class ReportExportService {
  /// Generates and shares a PDF report of tasks and expenses for the last 7 days.
  static Future<void> exportReport({
    required List<Task> tasks,
    required List<ExpenseItem> expenses,
  }) async {
    final pdf = pw.Document();
    final today = DateTime.now();
    // Prepare task data
    final List<List<String>> taskTable = [
      ['Day', 'Completed Tasks'],
    ];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final count = tasks.where((t) {
        if (!t.completed) return false;
        if (t.isRepetitive) return true;
        return t.date.year == day.year && t.date.month == day.month && t.date.day == day.day;
      }).length;
      taskTable.add([DateFormat('EEE').format(day), count.toString()]);
    }
    // Prepare expense data
    final List<List<String>> expenseTable = [
      ['Day', 'Expense'],
    ];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final sum = expenses
          .where((e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day)
          .fold<double>(0, (prev, e) => prev + e.amount);
      expenseTable.add([DateFormat('EEE').format(day), sum.toStringAsFixed(2)]);
    }
    // Build PDF
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Weekly Productivity Report')),
          pw.Table.fromTextArray(data: taskTable),
          pw.SizedBox(height: 20),
          pw.Header(level: 0, child: pw.Text('Expense Trend')),
          pw.Table.fromTextArray(data: expenseTable),
        ],
      ),
    );
    // Share PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'report.pdf');
  }
}