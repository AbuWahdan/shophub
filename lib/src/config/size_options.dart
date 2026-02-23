class SizeGroupOption {
  final int id;
  final String name;

  const SizeGroupOption({required this.id, required this.name});
}

class SizeOption {
  final int id;
  final int groupId;
  final String code;
  final String name;

  const SizeOption({
    required this.id,
    required this.groupId,
    required this.code,
    required this.name,
  });
}

const List<SizeGroupOption> sizeGroups = <SizeGroupOption>[
  SizeGroupOption(id: 2, name: 'Shoes - EU'),
  SizeGroupOption(id: 3, name: 'Clothing - Numeric'),
  SizeGroupOption(id: 4, name: 'Accessories'),
  SizeGroupOption(id: 5, name: 'One Size'),
  SizeGroupOption(id: 6, name: 'Shoes - US'),
  SizeGroupOption(id: 7, name: 'Kids - Clothing'),
  SizeGroupOption(id: 8, name: 'Kids - Shoes EU'),
  SizeGroupOption(id: 9, name: 'Shoes - UK'),
  SizeGroupOption(id: 10, name: 'Clothing - International'),
  SizeGroupOption(id: 11, name: 'Jeans - Waist/Length'),
];

const Map<int, List<SizeOption>> sizeOptions = <int, List<SizeOption>>{
  2: <SizeOption>[
    SizeOption(id: 11, groupId: 2, code: '35', name: 'EU 35'),
    SizeOption(id: 12, groupId: 2, code: '36', name: 'EU 36'),
    SizeOption(id: 13, groupId: 2, code: '37', name: 'EU 37'),
    SizeOption(id: 14, groupId: 2, code: '38', name: 'EU 38'),
    SizeOption(id: 15, groupId: 2, code: '39', name: 'EU 39'),
    SizeOption(id: 16, groupId: 2, code: '40', name: 'EU 40'),
    SizeOption(id: 17, groupId: 2, code: '41', name: 'EU 41'),
    SizeOption(id: 18, groupId: 2, code: '42', name: 'EU 42'),
    SizeOption(id: 19, groupId: 2, code: '43', name: 'EU 43'),
    SizeOption(id: 20, groupId: 2, code: '44', name: 'EU 44'),
    SizeOption(id: 41, groupId: 2, code: '45', name: 'EU 45'),
    SizeOption(id: 42, groupId: 2, code: '46', name: 'EU 46'),
  ],
  3: <SizeOption>[
    SizeOption(id: 10, groupId: 3, code: '36', name: 'Size 36'),
    SizeOption(id: 9, groupId: 3, code: '38', name: 'Size 38'),
    SizeOption(id: 7, groupId: 3, code: '40', name: 'Size 40'),
    SizeOption(id: 8, groupId: 3, code: '42', name: 'Size 42'),
  ],
  4: <SizeOption>[
    SizeOption(id: 138, groupId: 4, code: 'S', name: 'Small'),
    SizeOption(id: 140, groupId: 4, code: 'M', name: 'Medium'),
    SizeOption(id: 139, groupId: 4, code: 'L', name: 'Large'),
  ],
  5: <SizeOption>[
    SizeOption(id: 137, groupId: 5, code: 'OS', name: 'One Size'),
  ],
  6: <SizeOption>[
    SizeOption(id: 37, groupId: 6, code: '6', name: 'US 6'),
    SizeOption(id: 38, groupId: 6, code: '7', name: 'US 7'),
    SizeOption(id: 39, groupId: 6, code: '8', name: 'US 8'),
    SizeOption(id: 40, groupId: 6, code: '9', name: 'US 9'),
    SizeOption(id: 61, groupId: 6, code: '10', name: 'US 10'),
    SizeOption(id: 62, groupId: 6, code: '11', name: 'US 11'),
  ],
  7: <SizeOption>[
    SizeOption(id: 115, groupId: 7, code: '2Y', name: '2 Years'),
    SizeOption(id: 116, groupId: 7, code: '4Y', name: '4 Years'),
    SizeOption(id: 117, groupId: 7, code: '6Y', name: '6 Years'),
    SizeOption(id: 118, groupId: 7, code: '8Y', name: '8 Years'),
    SizeOption(id: 119, groupId: 7, code: '10Y', name: '10 Years'),
  ],
  8: <SizeOption>[
    SizeOption(id: 120, groupId: 8, code: '24', name: 'EU 24'),
    SizeOption(id: 121, groupId: 8, code: '25', name: 'EU 25'),
    SizeOption(id: 122, groupId: 8, code: '26', name: 'EU 26'),
    SizeOption(id: 123, groupId: 8, code: '27', name: 'EU 27'),
    SizeOption(id: 124, groupId: 8, code: '28', name: 'EU 28'),
    SizeOption(id: 125, groupId: 8, code: '29', name: 'EU 29'),
    SizeOption(id: 126, groupId: 8, code: '30', name: 'EU 30'),
    SizeOption(id: 127, groupId: 8, code: '31', name: 'EU 31'),
    SizeOption(id: 128, groupId: 8, code: '32', name: 'EU 32'),
    SizeOption(id: 129, groupId: 8, code: '33', name: 'EU 33'),
    SizeOption(id: 130, groupId: 8, code: '34', name: 'EU 34'),
    SizeOption(id: 131, groupId: 8, code: '35', name: 'EU 35'),
  ],
  9: <SizeOption>[
    SizeOption(id: 109, groupId: 9, code: '5', name: 'UK 5'),
    SizeOption(id: 110, groupId: 9, code: '6', name: 'UK 6'),
    SizeOption(id: 111, groupId: 9, code: '7', name: 'UK 7'),
    SizeOption(id: 112, groupId: 9, code: '8', name: 'UK 8'),
    SizeOption(id: 113, groupId: 9, code: '9', name: 'UK 9'),
    SizeOption(id: 114, groupId: 9, code: '10', name: 'UK 10'),
  ],
  10: <SizeOption>[
    SizeOption(id: 2, groupId: 10, code: 'XS', name: 'Extra Small'),
    SizeOption(id: 5, groupId: 10, code: 'S', name: 'Small'),
    SizeOption(id: 1, groupId: 10, code: 'M', name: 'Medium'),
    SizeOption(id: 3, groupId: 10, code: 'L', name: 'Large'),
    SizeOption(id: 6, groupId: 10, code: 'XL', name: 'Extra Large'),
    SizeOption(id: 4, groupId: 10, code: 'XXL', name: 'Double XL'),
  ],
  11: <SizeOption>[
    SizeOption(id: 136, groupId: 11, code: '30/30', name: 'Waist 30 Length 30'),
    SizeOption(id: 132, groupId: 11, code: '32/30', name: 'Waist 32 Length 30'),
    SizeOption(id: 133, groupId: 11, code: '32/32', name: 'Waist 32 Length 32'),
    SizeOption(id: 134, groupId: 11, code: '34/32', name: 'Waist 34 Length 32'),
    SizeOption(id: 135, groupId: 11, code: '36/32', name: 'Waist 36 Length 32'),
  ],
};

SizeOption? findSizeOptionById(int sizeId) {
  for (final entry in sizeOptions.entries) {
    for (final option in entry.value) {
      if (option.id == sizeId) return option;
    }
  }
  return null;
}

int? findSizeGroupIdBySizeId(int sizeId) {
  final option = findSizeOptionById(sizeId);
  return option?.groupId;
}
