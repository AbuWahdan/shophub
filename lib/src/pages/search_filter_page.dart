import 'package:flutter/material.dart';
import '../model/data.dart';
import '../model/product.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';

class SearchFilterPage extends StatefulWidget {
  const SearchFilterPage({super.key});

  @override
  State<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  String searchQuery = '';
  String selectedCategory = 'All';
  double minPrice = 0;
  double maxPrice = 10000;
  double selectedMinPrice = 0;
  double selectedMaxPrice = 10000;
  int selectedRating = 0;
  String sortBy = 'Best Selling';

  List<Product> get filteredProducts {
    return AppData.productList.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      final matchesPrice =
          product.finalPrice >= selectedMinPrice &&
          product.finalPrice <= selectedMaxPrice;
      final matchesRating =
          selectedRating == 0 || product.rating >= selectedRating;
      return matchesSearch && matchesCategory && matchesPrice && matchesRating;
    }).toList()..sort((a, b) {
      switch (sortBy) {
        case 'Price Low to High':
          return a.finalPrice.compareTo(b.finalPrice);
        case 'Price High to Low':
          return b.finalPrice.compareTo(a.finalPrice);
        case 'Best Rating':
          return b.rating.compareTo(a.rating);
        case 'Newest':
          return b.id.compareTo(a.id);
        default:
          return b.soldCount.compareTo(a.soldCount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search & Filter')),
      body: Column(
        children: [
          Padding(
            padding: AppTheme.padding,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  'Category',
                  Icons.category,
                  () => _showCategoryBottomSheet(),
                ),
                SizedBox(width: 12),
                _buildFilterChip(
                  'Price',
                  Icons.attach_money,
                  () => _showPriceBottomSheet(),
                ),
                SizedBox(width: 12),
                _buildFilterChip(
                  'Rating',
                  Icons.star,
                  () => _showRatingBottomSheet(),
                ),
                SizedBox(width: 12),
                _buildFilterChip(
                  'Sort',
                  Icons.sort,
                  () => _showSortBottomSheet(),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No products found'),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: filteredProducts[index],
                        onSelected: (product) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SizedBox()),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        avatar: Icon(icon, size: 18),
        backgroundColor: Colors.grey[100],
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...AppData.categoryList.map((category) {
                return ListTile(
                  title: Text(category.name ?? ''),
                  trailing: selectedCategory == category.name
                      ? Icon(Icons.check, color: LightColor.skyBlue)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedCategory = category.name ?? 'All';
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPriceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Price Range',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '\$${selectedMinPrice.toStringAsFixed(0)} - \$${selectedMaxPrice.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  RangeSlider(
                    values: RangeValues(selectedMinPrice, selectedMaxPrice),
                    min: minPrice,
                    max: maxPrice,
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        selectedMinPrice = values.start;
                        selectedMaxPrice = values.end;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text('Apply'),
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

  void _showRatingBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Minimum Rating',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...List.generate(5, (index) {
                final rating = 5 - index;
                return ListTile(
                  title: Row(
                    children: List.generate(
                      rating,
                      (i) => Icon(
                        Icons.star,
                        size: 18,
                        color: LightColor.yellowColor,
                      ),
                    ),
                  ),
                  trailing: selectedRating == rating ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      selectedRating = rating;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              ListTile(
                title: Text('Any Rating'),
                trailing: selectedRating == 0 ? Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    selectedRating = 0;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...[
                'Best Selling',
                'Price Low to High',
                'Price High to Low',
                'Best Rating',
                'Newest',
              ].map((sort) {
                return ListTile(
                  title: Text(sort),
                  trailing: sortBy == sort ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      sortBy = sort;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
