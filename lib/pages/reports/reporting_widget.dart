import 'package:flutter/material.dart';
import 'package:sales_app/core/constants/colors.dart';
import 'package:sales_app/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sales_app/core/widgets/transaction_tile.dart';

class ReportingWidget extends StatefulWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;

  const ReportingWidget({
    super.key,
    required this.transactions,
    required this.isLoading,
  });

  @override
  State<ReportingWidget> createState() => _ReportingWidgetState();
}

class _ReportingWidgetState extends State<ReportingWidget> {
  TransactionType _selectedType = TransactionType.expense;

  double get _totalAmount {
    return widget.transactions
        .where((t) => t.type == _selectedType)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get _categoryData {
    Map<String, double> data = {};
    for (var t in widget.transactions.where((t) => t.type == _selectedType)) {
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
                        _buildFilterDropdown(),
                        const SizedBox(height: 20),
                        _buildChartSection(),
                        const SizedBox(height: 30),
                        Text(
                            "Total ${_selectedType == TransactionType.expense ? 'Expenses' : 'Income'}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text("ugx ${_totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 30),
                        const Text("Expense Breakdown",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        if (widget.transactions
                            .where((t) => t.type == _selectedType)
                            .isEmpty)
                          const Center(
                              child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No transactions in this category"),
                          ))
                        else
                          ...widget.transactions
                              .where((t) => t.type == _selectedType)
                              .map((t) => TransactionTile(transaction: t)),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _toggleButton("Expenses", TransactionType.expense),
          _toggleButton("Income", TransactionType.income),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: "This Month",
          isExpanded: true,
          items: ["This Month", "Last Month", "This Year"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final data = _categoryData;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 150,
            child: data.isEmpty
                ? const Center(child: Text("No data"))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: data.entries.map((e) {
                        return PieChartSectionData(
                          color: _getCategoryColor(e.key),
                          value: e.value,
                          title: '',
                          radius: 20,
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.keys
                .map((cat) => _buildLegendItem(cat, _getCategoryColor(cat)))
                .toList(),
          ),
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
      default:
        return AppColors.primary;
    }
  }
}
