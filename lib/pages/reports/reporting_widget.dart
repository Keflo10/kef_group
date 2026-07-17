import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sales_app/core/widgets/transaction_tile.dart';

class ReportingWidget extends StatefulWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String currency;

  const ReportingWidget({
    super.key,
    required this.transactions,
    required this.isLoading,
    this.currency = 'UGX',
  });

  @override
  State<ReportingWidget> createState() => _ReportingWidgetState();
}

enum ReportingTimeRange { thisMonth, lastMonth, thisYear }

class _ReportingWidgetState extends State<ReportingWidget> {
  TransactionType _selectedType = TransactionType.expense;
  ReportingTimeRange _selectedRange = ReportingTimeRange.thisMonth;

  DateTimeRange? get _activeDateRange {
    final now = DateTime.now();

    DateTime start;
    DateTime end;

    switch (_selectedRange) {
      case ReportingTimeRange.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;
      case ReportingTimeRange.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        start = DateTime(lastMonth.year, lastMonth.month, 1);
        end = DateTime(now.year, now.month, 1);
        break;
      case ReportingTimeRange.thisYear:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year + 1, 1, 1);
        break;
    }

    // We'll treat the range as: start <= date < end
    return DateTimeRange(start: start, end: end);
  }

  List<TransactionModel> get _filteredTransactions {
    final range = _activeDateRange;
    return widget.transactions.where((t) {
      if (t.type != _selectedType) return false;
      if (range == null) return true;
      return !t.date.isBefore(range.start) && t.date.isBefore(range.end);
    }).toList();
  }

  double get _totalAmount {
    return _filteredTransactions.fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get _categoryData {
    final Map<String, double> data = {};
    for (var t in _filteredTransactions) {
      data[t.category] = (data[t.category] ?? 0) + t.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeToggle(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildFilterDropdown()),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Center(child: _buildChartSection()),
                        const SizedBox(height: 40),
                        const Text("Summary",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildSummaryCard(),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "${_selectedType == TransactionType.expense ? 'Expense' : 'Sale'} History",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            TextButton(
                                onPressed: () {}, child: const Text("See all")),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_filteredTransactions.isEmpty)
                          const Center(
                              child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No transactions in this category"),
                          ))
                        else
                          ..._filteredTransactions
                              .take(5)
                              .map((t) => TransactionTile(
                                    transaction: t,
                                    currency: widget.currency,
                                  )),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Amount",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 5),
              Text(
                "${widget.currency} ${_totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
          Icon(
            _selectedType == TransactionType.income
                ? Icons.trending_up
                : Icons.trending_down,
            color: _selectedType == TransactionType.income
                ? AppColors.income
                : AppColors.expense,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _toggleButton("Expenditures", TransactionType.expense),
          _toggleButton("Sales", TransactionType.income),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, TransactionType type) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    String selectedLabel;
    switch (_selectedRange) {
      case ReportingTimeRange.thisMonth:
        selectedLabel = 'This Month';
        break;
      case ReportingTimeRange.lastMonth:
        selectedLabel = 'Last Month';
        break;
      case ReportingTimeRange.thisYear:
        selectedLabel = 'This Year';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLabel,
          isExpanded: true,
          items: ['This Month', 'Last Month', 'This Year']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              switch (val) {
                case 'This Month':
                  _selectedRange = ReportingTimeRange.thisMonth;
                  break;
                case 'Last Month':
                  _selectedRange = ReportingTimeRange.lastMonth;
                  break;
                case 'This Year':
                  _selectedRange = ReportingTimeRange.thisYear;
                  break;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final data = _categoryData;
    if (data.isEmpty)
      return const SizedBox(
          height: 150, child: Center(child: Text("No data for chart")));

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 45,
              sections: data.entries.map((e) {
                return PieChartSectionData(
                  color: _getCategoryColor(e.key),
                  value: e.value,
                  title:
                      '${(e.value / _totalAmount * 100).toStringAsFixed(0)}%',
                  radius: 30,
                  titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          children: data.keys
              .map((cat) => _buildLegendItem(cat, _getCategoryColor(cat)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Colors.blue;
      case 'transport':
        return Colors.lightGreen;
      case 'entertainment':
        return Colors.orange;
      case 'shopping':
        return Colors.red;
      case 'salary':
        return Colors.green;
      case 'netflix':
        return Colors.redAccent;
      case 'sale':
        return AppColors.income;
      default:
        return AppColors.primary;
    }
  }
}
