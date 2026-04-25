import 'package:clubship/search/providers/search_query_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../send_tickets/app_search_bar.dart';

class SearchParametersRow extends ConsumerStatefulWidget {
  const SearchParametersRow({super.key});

  @override
  ConsumerState<SearchParametersRow> createState() =>
      _SearchParametersRowState();
}

class _SearchParametersRowState extends ConsumerState<SearchParametersRow> {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    final currentQuery = ref.read(searchQueryProvider);
    if (currentQuery.isNotEmpty) {
      searchController.text = currentQuery;
    }
    searchController.addListener(_onSearchChanged);
    searchFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    searchFocusNode.removeListener(_handleFocusChange);
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).update(searchController.text);
    setState(() {});
  }

  void _handleFocusChange() {
    if (!searchFocusNode.hasFocus && searchController.text.isEmpty) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      searchQueryProvider,
          (previous, next) {
        if (next != searchController.text && !searchFocusNode.hasFocus) {
          searchController.text = next;
        }
      },
    );
    final searchQuery = ref.watch(searchQueryProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (searchController.text.isEmpty) {
                  searchFocusNode.requestFocus();
                }
              },
              child: NomuSearchBar(
                controller: searchController,
                focusNode: searchFocusNode,
                placeholderText: 'Type something',
                onTap: () {
                  searchFocusNode.requestFocus();
                },
                autofocus: false,
              ),
            ),
          ),
        // AnimatedSwitcher(
        //   duration: const Duration(milliseconds: 200),
        //   transitionBuilder: (Widget child, Animation<double> animation) =>
        //       ScaleTransition(
        //         scale: animation,
        //         child: child,
        //       ),
        //   child: searchQuery.isNotEmpty
        //       ? GestureDetector(
        //     child: ref.watch(selectedFiltersProvider).isEmpty
        //         ? AppIcons.filterOptionsDefault()
        //         : AppIcons.filterOptionsApplied(),
        //     onTap: () {
        //       showModalBottomSheet(
        //         context: context,
        //         isScrollControlled: true,
        //         builder: (builder) => const FilterOptionsBottomSheet(),
        //       );
        //     },
        //   )
        //       : const SizedBox.shrink(),
        // ),
        ],
      ),
    );
  }
}
