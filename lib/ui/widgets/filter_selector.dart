import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

/// Filter data model
class FilterItem {
  final String id;
  final String name;
  final List<Color> colors;

  const FilterItem({
    required this.id,
    required this.name,
    required this.colors,
  });
}

/// Sample filters for demo
const List<FilterItem> sampleFilters = [
  FilterItem(
    id: 'original',
    name: 'Original',
    colors: [Color(0xFF333333), Color(0xFF555555)],
  ),
  FilterItem(
    id: 'warm',
    name: 'Warm',
    colors: [Color(0xFFFF6B35), Color(0xFFF7C59F)],
  ),
  FilterItem(
    id: 'cool',
    name: 'Cool',
    colors: [Color(0xFF2E86AB), Color(0xFFA3CEF1)],
  ),
  FilterItem(
    id: 'vintage',
    name: 'Vintage',
    colors: [Color(0xFFD4A373), Color(0xFFE9EDC9)],
  ),
  FilterItem(
    id: 'bw',
    name: 'B&W',
    colors: [Color(0xFF1A1A1A), Color(0xFF666666)],
  ),
  FilterItem(
    id: 'vivid',
    name: 'Vivid',
    colors: [Color(0xFFE63946), Color(0xFF457B9D)],
  ),
  FilterItem(
    id: 'sunset',
    name: 'Sunset',
    colors: [Color(0xFFFF7B00), Color(0xFFFFAA00)],
  ),
  FilterItem(
    id: 'neon',
    name: 'Neon',
    colors: [Color(0xFF00F5D4), Color(0xFFF15BB5)],
  ),
  FilterItem(
    id: 'moody',
    name: 'Moody',
    colors: [Color(0xFF2D3142), Color(0xFF4F5D75)],
  ),
  FilterItem(
    id: 'golden',
    name: 'Golden',
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
  ),
];

/// Instagram-style horizontal filter selector with snap-to-center
class FilterSelector extends StatefulWidget {
  final Function(FilterItem filter, int index)? onFilterChanged;
  final int initialIndex;

  const FilterSelector({
    super.key,
    this.onFilterChanged,
    this.initialIndex = 0,
  });

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  late PageController _pageController;
  late int _selectedIndex;
  static const double _viewportFraction = 0.18;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      HapticFeedback.selectionClick();
      widget.onFilterChanged?.call(sampleFilters[index], index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scrollable filter list
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemCount: sampleFilters.length,
            itemBuilder: (context, index) {
              return _FilterCircle(
                filter: sampleFilters[index],
                isSelected: index == _selectedIndex,
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual filter circle widget with scale animation
class _FilterCircle extends StatelessWidget {
  final FilterItem filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterCircle({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 0.85,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: filter.colors,
                    ),
                    border: Border.all(
                      color: AppColors.filterUnselected,
                      width: 1.5,
                    ),
                    boxShadow: null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  filter.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
