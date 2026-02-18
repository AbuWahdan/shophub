import '../models/category.dart';

class CategoriesData {
  static final List<Category> allCategories = [
    Category(
      id: 1,
      name: 'Electronics',
      children: [
        Category(id: 101, name: 'Computers', parentId: 1),
        Category(id: 102, name: 'Laptops', parentId: 1),
        Category(id: 103, name: 'Tablets', parentId: 1),
        Category(id: 104, name: 'Cameras & Photography', parentId: 1),
        Category(id: 105, name: 'Audio & Headphones', parentId: 1),
      ],
    ),
    Category(
      id: 2,
      name: 'Computers & Accessories',
      children: [
        Category(id: 201, name: 'Desktops', parentId: 2),
        Category(id: 202, name: 'Keyboards & Mice', parentId: 2),
        Category(id: 203, name: 'Monitors', parentId: 2),
        Category(id: 204, name: 'Printers & Scanners', parentId: 2),
      ],
    ),
    Category(
      id: 3,
      name: 'Mobile Phones',
      children: [
        Category(id: 301, name: 'Smartphones', parentId: 3),
        Category(id: 302, name: 'Feature Phones', parentId: 3),
        Category(id: 303, name: 'Phone Accessories', parentId: 3),
      ],
    ),
    Category(
      id: 4,
      name: 'Home & Kitchen',
      children: [
        Category(id: 401, name: 'Furniture', parentId: 4),
        Category(id: 402, name: 'Kitchen Appliances', parentId: 4),
        Category(id: 403, name: 'Home Decor', parentId: 4),
        Category(id: 404, name: 'Bedding & Bath', parentId: 4),
      ],
    ),
    Category(
      id: 5,
      name: 'Fashion & Clothing',
      children: [
        Category(id: 501, name: 'Men Clothing', parentId: 5),
        Category(id: 502, name: 'Women Clothing', parentId: 5),
        Category(id: 503, name: 'Kids Clothing', parentId: 5),
      ],
    ),
    Category(
      id: 6,
      name: 'Shoes & Footwear',
      children: [
        Category(id: 601, name: 'Men Shoes', parentId: 6),
        Category(id: 602, name: 'Women Shoes', parentId: 6),
        Category(id: 603, name: 'Sports Shoes', parentId: 6),
      ],
    ),
    Category(
      id: 7,
      name: 'Sports & Outdoors',
      children: [
        Category(id: 701, name: 'Fitness Equipment', parentId: 7),
        Category(id: 702, name: 'Outdoor Gear', parentId: 7),
        Category(id: 703, name: 'Cycling', parentId: 7),
      ],
    ),
    Category(
      id: 8,
      name: 'Beauty & Personal Care',
      children: [
        Category(id: 801, name: 'Skincare', parentId: 8),
        Category(id: 802, name: 'Haircare', parentId: 8),
        Category(id: 803, name: 'Makeup', parentId: 8),
      ],
    ),
    Category(
      id: 9,
      name: 'Toys & Games',
      children: [
        Category(id: 901, name: 'Action Figures', parentId: 9),
        Category(id: 902, name: 'Board Games', parentId: 9),
        Category(id: 903, name: 'Puzzles', parentId: 9),
      ],
    ),
    Category(
      id: 10,
      name: 'Books & Stationery',
      children: [
        Category(id: 1001, name: 'Fiction', parentId: 10),
        Category(id: 1002, name: 'Non-Fiction', parentId: 10),
        Category(id: 1003, name: 'Stationery Supplies', parentId: 10),
      ],
    ),
    Category(
      id: 11,
      name: 'Automotive',
      children: [
        Category(id: 1101, name: 'Car Accessories', parentId: 11),
        Category(id: 1102, name: 'Motorcycle Accessories', parentId: 11),
        Category(id: 1103, name: 'Car Care & Cleaning', parentId: 11),
      ],
    ),
    Category(
      id: 12,
      name: 'Health & Fitness',
      children: [
        Category(id: 1201, name: 'Supplements', parentId: 12),
        Category(id: 1202, name: 'Fitness Gear', parentId: 12),
        Category(id: 1203, name: 'Medical Devices', parentId: 12),
      ],
    ),
    Category(
      id: 13,
      name: 'Jewelry & Accessories',
      children: [
        Category(id: 1301, name: 'Rings', parentId: 13),
        Category(id: 1302, name: 'Necklaces', parentId: 13),
        Category(id: 1303, name: 'Watches', parentId: 13),
      ],
    ),
    Category(
      id: 14,
      name: 'Pet Supplies',
      children: [
        Category(id: 1401, name: 'Dog Supplies', parentId: 14),
        Category(id: 1402, name: 'Cat Supplies', parentId: 14),
        Category(id: 1403, name: 'Fish & Aquatic Pets', parentId: 14),
      ],
    ),
    Category(
      id: 15,
      name: 'Music & Movies',
      children: [
        Category(id: 1501, name: 'Musical Instruments', parentId: 15),
        Category(id: 1502, name: 'CDs & Vinyl', parentId: 15),
        Category(id: 1503, name: 'Movies & DVDs', parentId: 15),
      ],
    ),
  ];

  static List<Category> getMainCategories() {
    return allCategories;
  }

  static List<Category> getSubcategories(int mainCategoryId) {
    final mainCategory = allCategories.firstWhere(
      (cat) => cat.id == mainCategoryId,
      orElse: () => const Category(id: 0, name: ''),
    );
    return mainCategory.children;
  }

  static Category? getCategoryById(int categoryId) {
    for (final mainCat in allCategories) {
      if (mainCat.id == categoryId) return mainCat;
      for (final subCat in mainCat.children) {
        if (subCat.id == categoryId) return subCat;
      }
    }
    return null;
  }

  static List<Category> getAllCategoriesFlat() {
    final List<Category> flatList = [];
    for (final mainCat in allCategories) {
      flatList.add(mainCat);
      flatList.addAll(mainCat.children);
    }
    return flatList;
  }

  static void upsertCategoryFromApi({
    required int level,
    required Category category,
  }) {
    if (category.id <= 0 || category.name.trim().isEmpty) return;

    if (level == 1) {
      final mainIndex = allCategories.indexWhere(
        (cat) => cat.id == category.id,
      );
      if (mainIndex >= 0) {
        allCategories[mainIndex] = Category(
          id: category.id,
          name: category.name,
          children: allCategories[mainIndex].children,
        );
        return;
      }
      allCategories.add(
        Category(id: category.id, name: category.name, children: const []),
      );
      return;
    }

    final parentId = category.parentId;
    if (parentId == null || parentId <= 0) return;
    final parentIndex = allCategories.indexWhere((cat) => cat.id == parentId);
    if (parentIndex < 0) return;
    final parent = allCategories[parentIndex];
    final children = [...parent.children];
    final childIndex = children.indexWhere((child) => child.id == category.id);
    final normalizedChild = Category(
      id: category.id,
      name: category.name,
      parentId: parentId,
    );
    if (childIndex >= 0) {
      children[childIndex] = normalizedChild;
    } else {
      children.add(normalizedChild);
    }
    allCategories[parentIndex] = Category(
      id: parent.id,
      name: parent.name,
      children: children,
    );
  }
}
