# Quick Reference: GetX Architecture Usage Patterns

## 1. Using MyProductsController in Widgets

### Observing Products
```dart
// Get the controller
final ctrl = Get.find<MyProductsController>();

// Set username from auth
ctrl.username = auth.user?.username ?? '';
ctrl.userId = auth.user?.userId ?? 0;

// Load products
await ctrl.loadProducts();

// Observe changes (in build method)
Obx(() {
  if (ctrl.isLoading.value) {
    return CircularProgressIndicator();
  }
  return ListView.builder(
    itemCount: ctrl.products.length,
    itemBuilder: (_, i) => ProductCard(ctrl.products[i]),
  );
})
```

### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () => ctrl.loadProducts(forceRefresh: true),
  child: ListView(...),
)
```

---

## 2. Using CartController

### Load Cart
```dart
final cartCtrl = Get.find<CartController>();
await cartCtrl.loadCart(username: 'username');

// Listen to changes
Obx(() {
  print('${cartCtrl.items.length} items in cart_tab');
})
```

### Increment Item (Optimistic Update)
```dart
await cartCtrl.incrementItem(
  item: cartItem,
  username: 'current_user',
);
// UI updates immediately, reverts on error
```

### Decrement Item
```dart
if (cartItem.itemQty > 1) {
  await cartCtrl.decrementItem(
    item: cartItem,
    username: 'current_user',
  );
}
```

### Remove Item
```dart
await cartCtrl.removeItem(
  item: cartItem,
  username: 'current_user',
);
```

### Per-Item Loading State
```dart
Obx(() {
  final isLoading = cartCtrl.itemLoading[item.itemDetId] ?? false;
  return isLoading
    ? CircularProgressIndicator()
    : IncrementButton();
})
```

---

## 3. Using ProductController

### Load All Products
```dart
final prodCtrl = Get.find<ProductController>();
await prodCtrl.loadAllProducts();

Obx(() {
  return GridView.builder(
    itemCount: prodCtrl.allProducts.length,
    itemBuilder: (_, i) => ProductTile(prodCtrl.allProducts[i]),
  );
})
```

---

## 4. Using OrderController

### Load User Orders
```dart
final orderCtrl = Get.find<OrderController>();
await orderCtrl.loadOrders(username: 'current_user');

Obx(() {
  return ListView.builder(
    itemCount: orderCtrl.orders.length,
    itemBuilder: (_, i) {
      final order = orderCtrl.orders[i];
      return OrderCard(
        orderNo: order.orderNo,
        status: order.statusRaw, // Use raw status
        amount: order.netAmount,
      );
    },
  );
})
```

---

## 5. Direct Repository Usage (if not using controllers)

### ProductRepository
```dart
final repo = Get.find<ProductRepository>();

// Get all products
final products = await repo.getProducts();

// Get my products
final myProducts = await repo.getMyProducts(
  username: 'seller_username',
  userId: 123,
);

// Get product details
final details = await repo.getItemDetails(itemId: 42);

// Add product
await repo.insertProduct(CreateProductRequest(...));

// Toggle favorite
await repo.toggleFavorite(itemId: 42, username: 'user');
```

### CartRepository
```dart
final cartRepo = Get.find<CartRepository>();

// Get cart_tab
final items = await cartRepo.getCart(username: 'user');

// Add to cart_tab
await cartRepo.addToCart(AddItemToCartRequest(
  itemId: 123,
  itemDetId: 456,
  username: 'user',
  itemQty: 1,
));

// Remove from cart_tab
await cartRepo.deleteFromCart(
  detailId: 456,
  modifiedBy: 'user',
);
```

### OrderRepository
```dart
final orderRepo = Get.find<OrderRepository>();

final orders = await orderRepo.getOrders(username: 'user');
```

### UserRepository
```dart
final userRepo = Get.find<UserRepository>();

// Send OTP
await userRepo.sendOtp(
  username: 'user',
  email: 'user@example.com',
);

// Verify OTP
await userRepo.verifyOtp(
  username: 'user',
  email: 'user@example.com',
  otp: '123456',
);

// Reset password
await userRepo.resetPassword(
  username: 'user',
  newPassword: 'newpass123',
);
```

---

## 6. Error Handling

### In Widgets (with Snackbar)
```dart
try {
  await ctrl.loadProducts();
} on NetworkException catch (e) {
  Get.snackbar('No Internet', e.message);
} on TimeoutException catch (e) {
  Get.snackbar('Timeout', 'Request took too long');
} on ServerException catch (e) {
  Get.snackbar('Server Error', e.message, duration: Duration(seconds: 5));
} on AppException catch (e) {
  Get.snackbar('Error', e.message);
}
```

### In Controllers (automatic)
```dart
// CartController example - automatically shows snackbar on error
await cartCtrl.removeItem(item: item, username: 'user');
// If error → Get.snackbar shown automatically
```

---

## 7. Cache Invalidation

**ProductRepository automatically invalidates cache on:**
- `insertProduct()`
- `updateProduct()`
- `insertProductDetails()`
- `deleteVariantDetail()`
- `toggleFavorite()`
- `addItemComment()`

**To force refresh:**
```dart
await ctrl.loadProducts(forceRefresh: true);
```

---

## 8. Reactive Lists

### Update entire list
```dart
products.assignAll(newProductList);  // Triggers Obx rebuild
```

### Add item
```dart
products.add(newProduct);
```

### Remove item
```dart
products.removeWhere((p) => p.id == productId);
```

### Update single item
```dart
final index = products.indexWhere((p) => p.id == id);
if (index != -1) {
  products[index] = updatedProduct;
  products.refresh();  // Notify listeners if no index assignment
}
```

---

## 9. MyProducts Page Pattern (with Bug Fixes)

```dart
class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MyProductsController>();
    final auth = context.read<AuthState>();

    // ✅ Set username ONCE (BUG FIX)
    ctrl.username = auth.user?.username.trim() ?? '';
    ctrl.userId = auth.user?.userId ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl.products.isEmpty && !ctrl.isLoading.value) {
        ctrl.loadProducts();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.products.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ctrl.loadProducts(forceRefresh: true),
            child: EmptyState(),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ctrl.loadProducts(forceRefresh: true),
          child: GridView.builder(
            itemCount: ctrl.products.length,
            itemBuilder: (_, i) {
              final product = ctrl.products[i];
              return ProductCard(
                product: product,
                isInactive: product.isActive != 1,  // Visual indicator
              );
            },
          ),
        );
      }),
    );
  }
}
```

---

## 10. ApiService Error Handling (Internal)

**The ApiService handles Oracle quirks:**

```dart
// Write operation (POST)
final response = await _apiService.post(
  endpoint,
  body: requestData,
  isReadOperation: false,  // ← Tell it this is a write
);
// HTTP 200 with ORA- in body → treated as SUCCESS ✅

// Read operation (GET)
final response = await _apiService.get(
  endpoint,
  isReadOperation: true,  // ← Tell it this is a read
);
// HTTP 200 with ORA- in body → thrown as ServerException ❌
```

---

## Common Patterns Checklist

- [ ] Always use `Obx()` to wrap widgets that observe controller properties
- [ ] Always set username/userId ONCE before loading products
- [ ] Always check `!ctrl.isLoading.value` before calling load again
- [ ] Use `forceRefresh: true` only for pull-to-refresh
- [ ] Use `Get.find<Controller>()` instead of `Get.put()` (already injected)
- [ ] Wrap errors in try-catch or let controller handle with snackbar
- [ ] Use per-item loading for cart operations (`itemLoading` map)
- [ ] Never call HTTP directly - always use repositories
- [ ] Never re-read auth state inside async methods - read once upfront
- [ ] Always dispose subscriptions in `onClose()` for custom listeners

---

## Troubleshooting

**"Get.find error: Could not find X"**
- Check that `AppBindings` is registered in `main.dart`
- Verify `initialBinding: AppBindings()` is set

**"Products list not updating"**
- Make sure you're inside `Obx()` widget
- Use `products.assignAll()` not `products = list`

**"Optimistic update reverted but snackbar not showing"**
- Controller automatically shows snackbar
- If building custom UI, wrap in try-catch and show yourself

**"Username is null"**
- Always check `auth.user != null` before accessing `username`
- Use `auth.user?.username ?? ''` pattern consistently

---
