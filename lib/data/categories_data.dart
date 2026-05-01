import '../models/category_model.dart';

class CategoriesData {
  static final List<CategoryModel> allCategories = [
    CategoryModel(
      id: 1,
      name: 'Electronics',
      children: [
        CategoryModel(id: 101, name: 'Computers', parentId: 1),
        CategoryModel(id: 102, name: 'Laptops', parentId: 1),
        CategoryModel(id: 103, name: 'Tablets', parentId: 1),
        CategoryModel(id: 104, name: 'Cameras & Photography', parentId: 1),
        CategoryModel(id: 105, name: 'Audio & Headphones', parentId: 1),
      ],
    ),
    CategoryModel(
      id: 2,
      name: 'Computers & Accessories',
      children: [
        CategoryModel(id: 201, name: 'Desktops', parentId: 2),
        CategoryModel(id: 202, name: 'Keyboards & Mice', parentId: 2),
        CategoryModel(id: 203, name: 'Monitors', parentId: 2),
        CategoryModel(id: 204, name: 'Printers & Scanners', parentId: 2),
      ],
    ),
    CategoryModel(
      id: 3,
      name: 'Mobile Phones',
      children: [
        CategoryModel(id: 301, name: 'Smartphones', parentId: 3),
        CategoryModel(id: 302, name: 'Feature Phones', parentId: 3),
        CategoryModel(id: 303, name: 'Phone Accessories', parentId: 3),
      ],
    ),
    CategoryModel(
      id: 4,
      name: 'Home & Kitchen',
      children: [
        CategoryModel(id: 401, name: 'Furniture', parentId: 4),
        CategoryModel(id: 402, name: 'Kitchen Appliances', parentId: 4),
        CategoryModel(id: 403, name: 'Home Decor', parentId: 4),
        CategoryModel(id: 404, name: 'Bedding & Bath', parentId: 4),
      ],
    ),
    CategoryModel(
      id: 5,
      name: 'Fashion & Clothing',
      children: [
        CategoryModel(id: 501, name: 'Men Clothing', parentId: 5),
        CategoryModel(id: 502, name: 'Women Clothing', parentId: 5),
        CategoryModel(id: 503, name: 'Kids Clothing', parentId: 5),
      ],
    ),
    CategoryModel(
      id: 6,
      name: 'Shoes & Footwear',
      children: [
        CategoryModel(id: 601, name: 'Men Shoes', parentId: 6),
        CategoryModel(id: 602, name: 'Women Shoes', parentId: 6),
        CategoryModel(id: 603, name: 'Sports Shoes', parentId: 6),
      ],
    ),
    CategoryModel(
      id: 7,
      name: 'Sports & Outdoors',
      children: [
        CategoryModel(id: 701, name: 'Fitness Equipment', parentId: 7),
        CategoryModel(id: 702, name: 'Outdoor Gear', parentId: 7),
        CategoryModel(id: 703, name: 'Cycling', parentId: 7),
      ],
    ),
    CategoryModel(
      id: 8,
      name: 'Beauty & Personal Care',
      children: [
        CategoryModel(id: 801, name: 'Skincare', parentId: 8),
        CategoryModel(id: 802, name: 'Haircare', parentId: 8),
        CategoryModel(id: 803, name: 'Makeup', parentId: 8),
      ],
    ),
    CategoryModel(
      id: 9,
      name: 'Toys & Games',
      children: [
        CategoryModel(id: 901, name: 'Action Figures', parentId: 9),
        CategoryModel(id: 902, name: 'Board Games', parentId: 9),
        CategoryModel(id: 903, name: 'Puzzles', parentId: 9),
      ],
    ),
    CategoryModel(
      id: 10,
      name: 'Books & Stationery',
      children: [
        CategoryModel(id: 1001, name: 'Fiction', parentId: 10),
        CategoryModel(id: 1002, name: 'Non-Fiction', parentId: 10),
        CategoryModel(id: 1003, name: 'Stationery Supplies', parentId: 10),
      ],
    ),
    CategoryModel(
      id: 11,
      name: 'Automotive',
      children: [
        CategoryModel(id: 1101, name: 'Car Accessories', parentId: 11),
        CategoryModel(id: 1102, name: 'Motorcycle Accessories', parentId: 11),
        CategoryModel(id: 1103, name: 'Car Care & Cleaning', parentId: 11),
      ],
    ),
    CategoryModel(
      id: 12,
      name: 'Health & Fitness',
      children: [
        CategoryModel(id: 1201, name: 'Supplements', parentId: 12),
        CategoryModel(id: 1202, name: 'Fitness Gear', parentId: 12),
        CategoryModel(id: 1203, name: 'Medical Devices', parentId: 12),
      ],
    ),
    CategoryModel(
      id: 13,
      name: 'Jewelry & Accessories',
      children: [
        CategoryModel(id: 1301, name: 'Rings', parentId: 13),
        CategoryModel(id: 1302, name: 'Necklaces', parentId: 13),
        CategoryModel(id: 1303, name: 'Watches', parentId: 13),
      ],
    ),
    CategoryModel(
      id: 14,
      name: 'Pet Supplies',
      children: [
        CategoryModel(id: 1401, name: 'Dog Supplies', parentId: 14),
        CategoryModel(id: 1402, name: 'Cat Supplies', parentId: 14),
        CategoryModel(id: 1403, name: 'Fish & Aquatic Pets', parentId: 14),
      ],
    ),
    CategoryModel(
      id: 15,
      name: 'Music & Movies',
      children: [
        CategoryModel(id: 1501, name: 'Musical Instruments', parentId: 15),
        CategoryModel(id: 1502, name: 'CDs & Vinyl', parentId: 15),
        CategoryModel(id: 1503, name: 'Movies & DVDs', parentId: 15),
      ],
    ),
  ];

  static List<CategoryModel> getMainCategories() {
    return allCategories;
  }

  static List<CategoryModel> getSubcategories(int mainCategoryId) {
    final mainCategory = allCategories.firstWhere(
      (cat) => cat.id == mainCategoryId,
      orElse: () => const CategoryModel(id: 0, name: ''),
    );
    return mainCategory.children;
  }

  static CategoryModel? getCategoryById(int categoryId) {
    for (final mainCat in allCategories) {
      if (mainCat.id == categoryId) return mainCat;
      for (final subCat in mainCat.children) {
        if (subCat.id == categoryId) return subCat;
      }
    }
    return null;
  }

  static List<CategoryModel> getAllCategoriesFlat() {
    final List<CategoryModel> flatList = [];
    for (final mainCat in allCategories) {
      flatList.add(mainCat);
      flatList.addAll(mainCat.children);
    }
    return flatList;
  }

  static void upsertCategoryFromApi({
    required int level,
    required CategoryModel category,
  }) {
    if (category.id <= 0 || category.name.trim().isEmpty) return;

    if (level == 1) {
      final mainIndex = allCategories.indexWhere(
        (cat) => cat.id == category.id,
      );
      if (mainIndex >= 0) {
        allCategories[mainIndex] = CategoryModel(
          id: category.id,
          name: category.name,
          children: allCategories[mainIndex].children,
        );
        return;
      }
      allCategories.add(
        CategoryModel(id: category.id, name: category.name, children: const []),
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
    final normalizedChild = CategoryModel(
      id: category.id,
      name: category.name,
      parentId: parentId,
    );
    if (childIndex >= 0) {
      children[childIndex] = normalizedChild;
    } else {
      children.add(normalizedChild);
    }
    allCategories[parentIndex] = CategoryModel(
      id: parent.id,
      name: parent.name,
      children: children,
    );
  }
}
