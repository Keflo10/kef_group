import 'package:flutter/material.dart';

class TransactionSearchWidget extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onStartSearching;
  final VoidCallback onClearSearch;
  final VoidCallback? onBackPressedWhenSearching;

  const TransactionSearchWidget({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onQueryChanged,
    required this.onStartSearching,
    required this.onClearSearch,
    this.onBackPressedWhenSearching,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (isSearching) {
            onBackPressedWhenSearching?.call();
            return;
          }
          Navigator.of(context).maybePop();
        },
      ),
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: onQueryChanged,
            )
          : const Text(
              'Transactions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
      actions: [
        if (isSearching)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: onClearSearch,
          )
        else
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: onStartSearching,
          ),
      ],
    );
  }
}
