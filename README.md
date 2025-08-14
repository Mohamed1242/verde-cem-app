# Verde-Cem Flutter App

A Flutter mobile application for Verde-Cem, an eco-friendly cement company that produces sustainable building materials using algae technology.

## Features

- **User Authentication**: Secure login with JWT token management
- **Product Catalog**: Browse and view eco-friendly cement products
- **Order Management**: Place orders and track their status
- **Real-time Tracking**: Monitor order progress from placement to delivery
- **Modern UI**: Clean, responsive design with green theme
- **API Integration**: Full integration with Verde-Cem backend API

## API Integration

The app integrates with the Verde-Cem API (`http://localhost:8000/api`) and includes:

### Authentication Endpoints
- User login (`/auth/login`)
- User registration (`/auth/signup`)
- Get current user (`/auth/me`)
- User logout (`/auth/logout`)

### Product Endpoints
- Get all products (`/products`)
- Get single product (`/products/{id}`)

### Order Endpoints
- Place order (`/orders`)
- Get user orders (`/orders`)
- Get single order (`/orders/{id}`)

### Features Implemented
- ✅ Removed heart icons from products
- ✅ Added API integration for products
- ✅ Added API integration for orders
- ✅ Added API integration for user authentication
- ✅ Added order tracking functionality
- ✅ Added user profile display in drawer
- ✅ Added secure token management
- ✅ Added loading states and error handling
- ✅ Added pull-to-refresh functionality

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure API Base URL**
   - Update the base URL in `lib/core/services/api_service.dart` if needed
   - Default: `http://localhost:8000/api`

3. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── models/           # Data models
│   │   ├── product.dart
│   │   ├── user.dart
│   │   └── order.dart
│   ├── services/         # API services
│   │   └── api_service.dart
│   ├── theme/           # App theme
│   │   └── app_theme.dart
│   └── widgets/         # Reusable widgets
│       ├── custom_elevated_button.dart
│       └── custom_text_form_field.dart
├── screens/             # App screens
│   ├── login_screen.dart
│   ├── products_screen_new.dart
│   ├── track_screen.dart
│   ├── setting_screen.dart
│   └── drawer.dart
└── main.dart           # App entry point
```

## Dependencies

- `http`: For API requests
- `dio`: Alternative HTTP client
- `flutter_secure_storage`: Secure token storage
- `shared_preferences`: Local data persistence
- `awesome_dialog`: Enhanced dialog boxes

## API Response Format

The app expects API responses in the following format:

```json
{
  "success": true,
  "data": {
    // Response data
  }
}
```

## Error Handling

The app includes comprehensive error handling for:
- Network connectivity issues
- API authentication failures
- Invalid data responses
- User input validation

## Security Features

- JWT token-based authentication
- Secure token storage using `flutter_secure_storage`
- Automatic token refresh handling
- Secure logout with token cleanup

## UI/UX Improvements

- Modern card-based design
- Consistent green color scheme
- Loading indicators and error states
- Pull-to-refresh functionality
- Responsive layout for different screen sizes
- Smooth navigation transitions

## Development Notes

- The app uses a bottom navigation bar for main navigation
- Products are displayed in a grid layout with detailed product pages
- Orders are tracked with visual progress indicators
- User information is displayed in the drawer menu
- All API calls include proper error handling and loading states
