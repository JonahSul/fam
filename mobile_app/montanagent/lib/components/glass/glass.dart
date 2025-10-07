/// Glass components using liquidglass_container
/// 
/// This library provides beautiful Apple-style glass distortion effects
/// using the liquidglass_container package.
/// 
/// Key components:
/// - GlassBackground: Wraps your screen to enable glass effects
/// - GlassCard: Card with liquid glass effect
/// - GlassButton: Button with glass effect
/// - GlassTextField: Input field with glass effect
/// - GlassContainer: Generic container with glass effect
/// - GlassDialog: Dialog with glass effect
/// - GlassBottomSheet: Bottom sheet with glass effect
/// - GlassAppBar: AppBar with glass effect
/// 
/// Usage example:
/// ```dart
/// final GlobalKey _backgroundKey = GlobalKey();
/// 
/// Scaffold(
///   body: GlassBackground(
///     backgroundKey: _backgroundKey,
///     child: Column(
///       children: [
///         GlassCard(
///           backgroundKey: _backgroundKey,
///           child: Text('Hello Glass!'),
///         ),
///       ],
///     ),
///   ),
/// )
/// ```
library;

export 'glass_base_components.dart';
