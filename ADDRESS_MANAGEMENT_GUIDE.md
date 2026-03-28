# 📦 USER ADDRESS MANAGEMENT - COMPLETE IMPLEMENTATION GUIDE

## 🏗️ ARCHITECTURE OVERVIEW

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  ┌───────────────────────────────────────────────────┐  │
│  │ AddressesListScreen / AddEditAddressScreen       │  │
│  │ (UI Components + User Interactions)               │  │
│  └─────────────────────┬─────────────────────────────┘  │
│                        │ "Give me addresses"              │
├─────────────────────────────────────────────────────────┤
│          PRESENTATION LAYER - STATE MANAGEMENT           │
│  ┌───────────────────────────────────────────────────┐  │
│  │ AddressController (GetX)                          │  │
│  │ - Manages state (observable properties)           │  │
│  │ - Handles UI events (add, update, delete)         │  │
│  │ - Delegates to repository                         │  │
│  └─────────────────────┬─────────────────────────────┘  │
│                        │ "Add/Update/Delete/Get"         │
├─────────────────────────────────────────────────────────┤
│                   DOMAIN LAYER                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │ AddressRepository (Abstract)                      │  │
│  │ - Defines contract for address operations         │  │
│  │ - AddressEntity: Domain model (business logic)    │  │
│  └─────────────────────┬─────────────────────────────┘  │
│                        │ "Implement business logic"      │
├─────────────────────────────────────────────────────────┤
│                   DATA LAYER                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │ AddressRepositoryImpl (Concrete)                   │  │
│  │ - Implements abstract repository                  │  │
│  │ - Maps Entity ↔ Model                             │  │
│  │ - Manages caching (5 min TTL)                     │  │
│  └─────────────────────┬─────────────────────────────┘  │
│                        │ "Fetch/Save data"               │
├─────────────────────────────────────────────────────────┤
│          DATA LAYER - EXTERNAL DATA SOURCES             │
│  ┌───────────────────────────────────────────────────┐  │
│  │ AddressRemoteDataSource                           │  │
│  │ - HTTP calls to API                               │  │
│  │ - AddressModel: JSON-serializable (API schema)    │  │
│  │ - Error handling & response parsing               │  │
│  └─────────────────────┬─────────────────────────────┘  │
│                        │ "Call REST API"                 │
├─────────────────────────────────────────────────────────┤
│                   EXTERNAL SERVICES                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Backend API Server (Oracle/REST)                  │  │
│  │ Endpoints:                                         │  │
│  │ - POST /AddUserAddress                            │  │
│  │ - POST /UpdateUserAddress                         │  │
│  │ - POST /DeleteUserAddress                         │  │
│  │ - GET /GetUserAddress?USERNAME={username}         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 📂 FILE STRUCTURE

```
lib/
├── controllers/
│   └── address_controller.dart          # GetX Controller for state management
│
├── domain/
│   ├── entities/
│   │   └── address_entity.dart          # DOMAIN MODEL (business logic)
│   └── repositories/
│       └── address_repository.dart      # ABSTRACT INTERFACE
│
├── data/
│   ├── datasources/
│   │   └── address_remote_datasource.dart  # API CALLS
│   └── repositories/
│       └── address_repository_impl.dart    # CONCRETE IMPLEMENTATION
│
├── src/
│   ├── model/
│   │   └── address_model.dart           # API MODEL (JSON-serializable)
│   └── pages/
│       ├── addresses_list_screen.dart   # List & Management UI
│       └── add_edit_address_screen.dart # Add/Edit Form
│
├── app_bindings.dart                    # Dependency Injection setup
└── main.dart
```

---

## 🔄 DATA FLOW

### Adding a New Address

```
User clicks "Add" button
    ↓
AddEditAddressScreen opens (form)
    ↓
User enters data and taps "Add Address"
    ↓
AddEditAddressScreen.submit() → returns AddressEntity
    ↓
AddressesListScreen._openAddAddress() receives AddressEntity
    ↓
addressController.addAddress(entity)
    ↓
AddressRepository.addAddress(entity)
    ↓
EntityToModel conversion: AddressEntity → AddressModel
    ↓
AddressRemoteDataSource.addAddress(model)
    ↓
HTTP POST → /AddUserAddress
    ↓
API creates record in database
    ↓
API returns created address back
    ↓
RemoteDataSource parses response → AddressModel
    ↓
RepositoryImpl converts Model → Entity
    ↓
Controller adds entity to observable list
    ↓
Obx() in UI rebuilds automatically
    ↓
New address appears in list ✅
```

### Getting User Addresses (on screen load)

```
AddressesListScreen.initState()
    ↓
_initializeAndLoad()
    ↓
addressController.username = auth.user.username
    ↓
addressController.loadAddresses()
    ↓
AddressRepository.getUserAddresses(username)
    ↓
CHECK CACHE (5 min TTL)
    ├─ If valid → return cached addresses
    └─ If expired → fetch from API
       ↓
       AddressRemoteDataSource.getUserAddresses(username)
       ↓
       HTTP GET → /GetUserAddress?USERNAME={username}
       ↓
       API returns list of addresses
       ↓
       RemoteDataSource parses response → List<AddressModel>
       ↓
       RepositoryImpl converts all Models → Entities
       ↓
       RepositoryImpl caches entities for 5 minutes
       ↓
       Controller receives List<AddressEntity>
       ↓
       Controller: addresses.assignAll(result)
       ↓
       Obx() rebuilds UI with new list ✅
```

---

## 🔑 KEY CLASSES & RESPONSIBILITIES

### 1. **AddressModel** (Data Layer)
*File: `lib/src/model/address_model.dart`*

- **Purpose**: JSON-serializable model for API communication
- **Responsibility**: 
  - fromJson() → parse API responses
  - toJson() → serialize for API requests
  - Handle null safety in parsing
- **Scope**: Only used in data layer

### 2. **AddressEntity** (Domain Layer)
*File: `lib/domain/entities/address_entity.dart`*

- **Purpose**: Domain model independent of data source
- **Responsibility**:
  - Represent address in business logic
  - copyWith() for immutable updates
  - Props for value equality
- **Scope**: Used in domain & presentation layers

### 3. **AddressRepository** (Abstract Interface)
*File: `lib/domain/repositories/address_repository.dart`*

- **Purpose**: Define contract for address operations
- **Methods**:
  - addAddress(AddressEntity) → Future<AddressEntity>
  - updateAddress(AddressEntity) → Future<AddressEntity>
  - deleteAddress(int) → Future<void>
  - getUserAddresses(String) → Future<List<AddressEntity>>
  - getAddressById(int) → Future<AddressEntity?>
  - setDefaultAddress(int, String) → Future<void>

### 4. **AddressRepositoryImpl** (Concrete Implementation)
*File: `lib/data/repositories/address_repository_impl.dart`*

- **Purpose**: Implement business logic and data operations
- **Key Features**:
  - Entity ↔ Model mapping
  - 5-minute caching with TTL
  - Error handling & logging
  - Cache invalidation
- **Process**:
  1. Entity → Model conversion
  2. Call RemoteDataSource (API)
  3. Parse response
  4. Model → Entity conversion
  5. Cache result
  6. Return to controller

### 5. **AddressRemoteDataSource**
*File: `lib/data/datasources/address_remote_datasource.dart`*

- **Purpose**: Handle all API interactions
- **Methods**:
  - addAddress(AddressModel)
  - updateAddress(AddressModel)
  - deleteAddress(int addressId)
  - getUserAddresses(String username)
- **Responsibilities**:
  - HTTP requests
  - Response parsing
  - Error mapping

### 6. **AddressController** (GetX State Management)
*File: `lib/controllers/address_controller.dart`*

- **Purpose**: Manage address state & handle UI events
- **Observable State**:
  - `addresses: RxList<AddressEntity>` - list of all addresses
  - `isLoading: RxBool` - loading state
  - `error: RxString` - error messages
  - `selectedAddressId: Rx<int?>` - selected address
- **Key Methods**:
  - loadAddresses() - fetch all
  - addAddress(entity) - create new
  - updateAddress(entity) - modify existing
  - deleteAddress(id) - remove
  - setDefaultAddress(id) - set as default
::
  - getDefaultAddress() - helper
  - getAddressById(id) - helper
  - clear() - reset state
- **Flow**: UI → Controller → Repository → RemoteDataSource

---

## 🎨 UI SCREENS

### AddressesListScreen
*File: `lib/src/pages/addresses_list_screen.dart`*

**Features**:
- List all user addresses with RefreshIndicator
- Each address card shows:
  - Label (Home, Office, etc.)
  - "Default" badge if applicable
  - Full address details
  - Phone number
- Action menu (Edit, Set Default, Delete)
- Pull-to-refresh to reload
- Error state with retry button
- Empty state when no addresses
- FAB to add new address

**State Management**:
```dart
Obx(() {
  if (controller.error.isNotEmpty) return ErrorWidget();
  if (controller.isLoading.value) return LoadingWidget();
  if (controller.addresses.isEmpty) return EmptyWidget();
  return AddressList();
})
```

### AddEditAddressScreen  
*File: `lib/src/pages/add_edit_address_screen.dart`*

**Form Fields**:
- Label (required) - "Home", "Office", etc.
- Street Address (required) - text area
- City (required)
- State/Province (required)
- Country (default: "Pakistan")
- Zip/Postal Code (required)
- Phone (required, min 10 digits)
- Latitude (optional, decimal validates)
- Longitude (optional, decimal validates)

**Validation**:
- Required fields must not be empty
- Phone must be at least 10 characters
- Latitude/Longitude must be valid doubles

**Return Value**: AddressEntity (to parent screen)

---

## 🔧 USAGE EXAMPLE

### Setup (Already Done in AppBindings)

```dart
// In app_bindings.dart, dependencies() method:

Get.lazyPut<AddressRemoteDataSource>(
  () => AddressRemoteDataSource(Get.find<ApiService>()),
  fenix: true,
);

Get.lazyPut<AddressRepository>(
  () => AddressRepositoryImpl(Get.find<AddressRemoteDataSource>()),
  fenix: true,
);

Get.lazyPut<AddressController>(
  () => AddressController(Get.find<AddressRepository>()),
  fenix: true,
);
```

### In a Screen

```dart
class MyAddressesPage extends StatefulWidget {
  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  late AddressController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AddressController>();
    
    // Set username from auth and load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthState>();
      if (auth.user != null) {
        controller.username = auth.user!.username;
        controller.loadAddresses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        
        if (controller.addresses.isEmpty) {
          return const EmptyWidget();
        }
        
        return ListView.builder(
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final address = controller.addresses[index];
            return AddressCard(address: address);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<AddressEntity>(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditAddressScreen(
                username: controller.username,
              ),
            ),
          );
          
          if (result != null) {
            await controller.addAddress(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🚀 API ENDPOINTS

### 1. Add Address
```http
POST /AddUserAddress
Content-Type: application/json

{
  "username": "john_doe",
  "label": "Home",
  "street_address": "123 Main St",
  "city": "Lahore",
  "state": "Punjab",
  "country": "Pakistan",
  "zip_code": "54000",
  "phone": "+923001234567",
  "latitude": 31.5204,
  "longitude": 74.3587
}

Response:
{
  "address_id": 1,
  "username": "john_doe",
  "label": "Home",
  ...
}
```

### 2. Update Address
```http
POST /UpdateUserAddress
Content-Type: application/json

{
  "address_id": 1,
  "username": "john_doe",
  "label": "Home (Updated)",
  ...
}
```

### 3. Delete Address
```http
POST /DeleteUserAddress
Content-Type: application/json

{
  "address_id": 1
}
```

### 4. Get User Addresses
```http
GET /GetUserAddress?USERNAME=john_doe

Response:
[
  {
    "address_id": 1,
    "username": "john_doe",
    "label": "Home",
    ...
  },
  {
    "address_id": 2,
    "username": "john_doe",
    "label": "Office",
    ...
  }
]
```

---

## ✅ BEST PRACTICES APPLIED

1. **Clean Architecture**: Separation of concerns (Domain, Data, Presentation)
2. **Null Safety**: Proper null handling with non-null returns (empty list not null)
3. **Error Handling**: Try-catch at each layer with meaningful error messages
4. **Caching**: 5-minute TTL with manual invalidation
5. **Logging**: Debug logs at key points for troubleshooting
6. **Validation**: Form validation on client & API response parsing
7. **Immutability**: Entities use copyWith() for updates
8. **State Management**: GetX observables for reactive UI updates
9. **Dependency Injection**: Lazy initialization with fenix: true
10. **Type Safety**: Strongly typed Dart code throughout

---

## 🧪 TESTING CHECKLIST

- [ ] Verify API endpoints are accessible
- [ ] Test adding a new address
- [ ] Test updating an address
- [ ] Test deleting an address
- [ ] Test marking address as default
- [ ] Test fetching addresses for user
- [ ] Test cache invalidation on add/update/delete
- [ ] Test error handling (network error, API error)
- [ ] Test form validation
- [ ] Test empty state
- [ ] Test loading state
- [ ] Test pull-to-refresh
