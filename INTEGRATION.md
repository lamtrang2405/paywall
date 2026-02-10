# Integration Guide: Cinematic Paywall

Follow these steps to integrate the refined paywall into your existing project.

## 1. Prerequisites
Ensure you have the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^5.1.0
  url_launcher: ^6.2.1
```

## 2. Asset Setup
The paywall uses high-resolution cinematic art. Ensure the following files exist in your project:

- `assets/images/art_1.jpg`
- `assets/images/art_2.jpg`
- `assets/images/art_3.jpg`
- `assets/images/art_4.jpg`
- `assets/images/art_5.jpg`

Update your `pubspec.yaml` to include them:

```yaml
flutter:
  assets:
    - assets/images/
```

## 3. Implementation
1. Copy `paywall_screen.dart` into your `lib/` directory.
2. Navigate to the paywall with dynamic data (e.g., from RevenueCat or Store):

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const PaywallScreen(
      yearlyPrice: '$49.99',
      yearlyPerWeek: '$0.96/week',
      weeklyPrice: '$6.99',
      yearlySavings: 'Save 86%',
    ),
  ),
);
```

### Dynamic Pricing Usage
You should replace these strings with values from your store provider. For example, if using `in_app_purchase`:

```dart
// inside your store logic
final product = products.firstWhere((p) => p.id == 'premium_yearly');
final savings = calculateSavings(product, weeklyProduct); // your logic

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => PaywallScreen(
      yearlyPrice: product.price,
      yearlyPerWeek: '${product.currencySymbol}${(product.rawPrice / 52).toStringAsFixed(2)}/week',
      weeklyPrice: weeklyProduct.price,
      yearlySavings: 'Save $savings%',
    ),
  ),
);
```

## 4. Key Features Included
- **Web-Safe Shaders**: All shimmering and split-color effects use standard Flutter animations, ensuring consistency on Flutter Web.
- **Cinematic VFX**: Procedural grain, periodic chromatic aberration pulses, and drifting light leaks.
- **Attention Hook**: The "Start Now" button features a periodic "hard" shake animation.
- **Legal Requirements**: Pre-built footer with Terms, Restore, and Privacy links.

## 5. Maintenance
- **Colors**: Edit the `_Palette` class at the top of `paywall_screen.dart` to match your brand.
- **Shake Frequency**: Adjust the `Duration` in `_startShakeCycle()` to change how often the CTA vibrates.
