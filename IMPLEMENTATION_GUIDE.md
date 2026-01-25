# ShopHub - Flutter E-commerce App

A complete, production-ready Flutter e-commerce application with Material 3 design, featuring a comprehensive shopping experience including product browsing, detailed product information, shopping cart management, checkout flow, and order tracking.

## 🎯 Features

### ✨ Complete User Journey
- **Splash Screen**: Animated loading with fade and scale effects
- **Onboarding**: 4-page interactive onboarding with skip functionality
- **Authentication**: Full auth flow with Login, Register, and OTP verification
- **Shopping**: Browse products, filter by category, price, and rating
- **Product Details**: Comprehensive product pages with image carousel, size/color selection
- **Shopping Cart**: Real-time cart management with quantity control and badge notifications
- **Checkout**: 3-step checkout process with address and payment selection
- **Order Tracking**: View order history and delivery status
- **Account Management**: User profile, addresses, settings, and preferences

### 🎨 Design & UX
- **Material 3 Design**: Modern Material Design with soft shadows and rounded corners
- **Dark Mode Support**: Full dark theme implementation
- **Responsive Layout**: Works seamlessly on different screen sizes
- **Hero Animations**: Smooth transitions between product list and details
- **Real-time Updates**: Cart badge shows item count updates
- **Loading States**: Proper feedback with animations and transitions

### 📦 Core Functionality
- **50+ Products**: Organized across 7 categories (Sneakers, Jackets, Watches, Clothing, Sports, Accessories, Electronics)
- **Advanced Filtering**: Multi-criteria filtering with price slider, rating, and sorting options
- **Image Management**: Centralized image constants for consistent asset handling
- **Order Management**: Complete order lifecycle with status tracking
- **Address Management**: Add, edit, and manage delivery addresses

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── src/
│   ├── config/
│   │   ├── image_constants.dart       # Centralized image asset paths
│   │   └── route.dart                 # All app routes
│   ├── model/
│   │   ├── product.dart               # Product model with discount calculation
│   │   ├── order.dart                 # Order and OrderItem models
│   │   ├── address.dart               # Delivery address model
│   │   ├── category.dart              # Product category model
│   │   └── data.dart                  # Mock data (50 products, 3 orders, 2 addresses)
│   ├── pages/
│   │   ├── splash_screen.dart         # Animated splash screen
│   │   ├── onboarding_screen.dart     # 4-page onboarding flow
│   │   ├── auth/
│   │   │   ├── login_screen.dart      # Login with email/phone and password
│   │   │   ├── register_screen.dart   # Registration with validation
│   │   │   └── otp_screen.dart        # OTP verification with timer
│   │   ├── home_page.dart             # Product grid and categories
│   │   ├── product_details_new.dart   # Full product details page
│   │   ├── search_filter_page.dart    # Multi-criteria search and filter
│   │   ├── shopping_cart_page.dart    # Cart with quantity management
│   │   ├── checkout_page.dart         # 3-step checkout process
│   │   ├── orders_page.dart           # Order history with status timeline
│   │   ├── addresses_page.dart        # Address management
│   │   ├── profile_page.dart          # User profile menu
│   │   ├── profile_settings_page.dart # Settings and preferences
│   │   ├── account_page.dart          # Comprehensive account management
│   │   ├── order_success_screen.dart  # Order confirmation with animation
│   │   ├── categories_page.dart       # Product categories
│   │   └── main_page.dart             # Bottom navigation container
│   ├── themes/
│   │   ├── light_color.dart           # Color palette
│   │   └── theme.dart                 # Material 3 theme configuration
│   └── widgets/
│       ├── product_card.dart          # Reusable product card with Hero animation
│       ├── title_text.dart
│       ├── extentions.dart
│       └── BottomNavigationBar/
│           └── bottom_navigation_bar.dart  # Custom animated bottom nav with cart badge
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10+ with Dart 3.0+
- iOS 11.0+ or Android 5.0+
- VS Code or Android Studio

### Installation
```bash
# Clone the repository
git clone <repository-url>

# Navigate to project
cd sinwar_shoping

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🎨 Design System

### Color Palette
- **Primary**: Sky Blue (#3498DB)
- **Accent**: Orange (#FF6B35)
- **Success**: Green (#27AE60)
- **Error**: Red (#E74C3C)
- **Background**: Light Gray (#F8F9FA)

### Typography
- **Font Family**: Mulish (from Google Fonts)
- **Heading**: 28px Bold
- **Subheading**: 18px Semi-bold
- **Body**: 14px Regular

### Spacing
- Default padding: 16px
- Border radius: 12-16px
- Icon sizes: 24px (default), 32px (large)

## 📱 Key Screens

### Splash & Onboarding
- 1500ms animated splash with fade and scale effects
- 4-page onboarding with page indicators and skip button
- Auto-transition to login after completion

### Authentication
- Email/phone and password login
- Full registration form with validation
- 6-digit OTP verification with 60-second countdown timer
- Password visibility toggles

### Shopping Experience
- 2-column product grid with Hero animations
- Advanced filtering: category, price range (0-10000), rating (1-5), sort options
- Real-time search with live filtering
- Product carousel with 5-dot indicators

### Checkout
- **Step 1**: Address selection with "Add New" option
- **Step 2**: Payment method selection (Card, COD, Wallet)
- **Step 3**: Order review with totals summary
- Order confirmation screen with animation

### Order Management
- Order history with status badges (pending, processing, shipped, delivered, cancelled)
- Visual status timeline in order details
- Complete order information with items breakdown
- Delivery estimates

### Account Settings
- Dark mode toggle
- Language selection (English, Arabic, Spanish, French)
- Email and push notifications toggle
- Privacy policy and terms access

## 🔄 Navigation Flow

```
Splash (3s)
    ↓
Onboarding (4 pages) → Skip
    ↓                ↓
Login ←──────────────┘
    ↓
Register (or OTP)
    ↓
OTP Verification
    ↓
Main App (Bottom Nav)
├── Home (Product Grid)
│   └── Product Details → Add to Cart
├── Categories (Category Filter)
├── Cart (Manage Items)
│   └── Checkout
│       └── Order Success
├── Profile
│   ├── Orders
│   │   └── Order Details
│   ├── Addresses
│   └── Settings
```

## 💾 Mock Data

The app comes with comprehensive mock data:

### 50 Products
- **7 Categories**: Sneakers, Jackets, Watches, Clothing, Sports, Accessories, Electronics
- **Price Range**: $19.99 - $8500
- **Ratings**: 4.0 - 4.9 stars
- **Sold Count**: 3000 - 25000+
- **Multiple Images**: Each product has 2-3 product images

### Sample Orders (3)
- Various statuses: Delivered, Shipped, Processing
- Complete order items with size and color details
- Calculated totals with shipping and discount

### Sample Addresses (2)
- Home (default)
- Office
- Complete with phone, street, city, state, zipcode

## 🎯 User Scenarios Covered

1. **New User**: Splash → Onboarding → Register → OTP → App
2. **Existing User**: Splash → Onboarding (skip) → Login → App
3. **Guest**: Can browse products but needs to register for checkout
4. **Shopping**: Browse → Filter → View Details → Add to Cart → Checkout
5. **Account Management**: Profile → Orders/Addresses/Settings

## 🔐 Features

- ✅ Persistent bottom navigation across main screens
- ✅ Real-time cart badge with item count
- ✅ Hero animations between product list and details
- ✅ Quantity management in cart (add/remove)
- ✅ Address management (add/edit/delete/set default)
- ✅ Order status timeline visualization
- ✅ Theme preferences (dark/light mode)
- ✅ Multi-criteria product filtering
- ✅ Search with real-time results
- ✅ OTP verification with timer and resend

## 🎬 Animations Implemented

- **Splash**: Fade (0→1) + Scale (0.5→1) with elasticOut curve
- **Onboarding**: Page transitions with easeInOut
- **OTP Timer**: AnimationController-driven 60-second countdown
- **Order Success**: Scale animation for checkmark + pulse effect
- **Bottom Nav**: Custom curved painter with animation
- **Cart Badge**: Badge counter updates with fade transition
- **Hero Animations**: Product images between list and details

## 📊 Performance

- Lazy loading for product grids
- Efficient image caching with Asset images
- Minimal rebuilds using StatefulWidgets strategically
- No external dependencies beyond Material Design

## 🔮 Future Enhancements

- [ ] Backend API integration
- [ ] Real payment gateway integration
- [ ] Push notifications for order updates
- [ ] Product reviews and ratings system
- [ ] Wishlist functionality
- [ ] Search history and suggestions
- [ ] Multiple language support (i18n)
- [ ] Advanced user analytics
- [ ] Social sharing
- [ ] Live chat support

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For support, email support@shophub.com or visit the app's help section.

---

**Built with ❤️ using Flutter and Material Design 3**
