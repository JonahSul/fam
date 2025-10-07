import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Render quality levels for glass effects
enum RenderQuality {
  low('Low', 'Minimal effects for maximum performance'),
  balanced('Balanced', 'Good balance of quality and performance'),
  high('High', 'Maximum visual quality with full effects');

  const RenderQuality(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Service to manage render quality settings for glass effects
class RenderQualityService extends ChangeNotifier {
  static const String _qualityKey = 'render_quality';

  RenderQuality _currentQuality = RenderQuality.balanced;
  bool _isInitialized = false;

  RenderQuality get currentQuality => _currentQuality;

  bool get isInitialized => _isInitialized;

  /// Initialize the service and load saved settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedQuality = prefs.getString(_qualityKey);

      if (savedQuality != null) {
        _currentQuality = RenderQuality.values.firstWhere(
          (quality) => quality.name == savedQuality,
          orElse: () => RenderQuality.balanced,
        );
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading render quality settings: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set the render quality and save to persistent storage
  Future<void> setQuality(RenderQuality quality) async {
    if (_currentQuality == quality) return;

    _currentQuality = quality;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_qualityKey, quality.name);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving render quality settings: $e');
    }
  }

  /// Get glass effect parameters based on current quality setting
  GlassEffectParams getGlassEffectParams() {
    switch (_currentQuality) {
      case RenderQuality.low:
        return GlassEffectParams.lowQuality();
      case RenderQuality.balanced:
        return GlassEffectParams.balanced();
      case RenderQuality.high:
        return GlassEffectParams.highQuality();
    }
  }

  /// Get animation parameters based on current quality setting
  AnimationParams getAnimationParams() {
    switch (_currentQuality) {
      case RenderQuality.low:
        return AnimationParams.disabled();
      case RenderQuality.balanced:
        return AnimationParams.balanced();
      case RenderQuality.high:
        return AnimationParams.highQuality();
    }
  }
}

/// Parameters for glass effect rendering based on quality level
class GlassEffectParams {
  final double refraction;
  final double chromaticDispersion;
  final double distortionStrength;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final double shadowOffset;
  final double opacity;

  const GlassEffectParams({
    required this.refraction,
    required this.chromaticDispersion,
    required this.distortionStrength,
    required this.shadowBlurRadius,
    required this.shadowSpreadRadius,
    required this.shadowOffset,
    required this.opacity,
  });

  /// Low quality - minimal effects for maximum performance
  factory GlassEffectParams.lowQuality() {
    return const GlassEffectParams(
      refraction: 0.95, // Minimal distortion
      chromaticDispersion: 0.001, // Almost no color separation
      distortionStrength: 0.1, // Very subtle distortion
      shadowBlurRadius: 1.0, // Minimal shadow
      shadowSpreadRadius: 0.2, // Minimal spread
      shadowOffset: 0.5, // Minimal offset
      opacity: 0.05, // Very subtle effect
    );
  }

  /// Balanced quality - good balance of quality and performance
  factory GlassEffectParams.balanced() {
    return const GlassEffectParams(
      refraction: 0.98, // Subtle distortion
      chromaticDispersion: 0.005, // Light color separation
      distortionStrength: 0.3, // Moderate distortion
      shadowBlurRadius: 2.0, // Light shadow
      shadowSpreadRadius: 0.5, // Light spread
      shadowOffset: 1.0, // Light offset
      opacity: 0.1, // Moderate effect
    );
  }

  /// High quality - maximum visual quality with full effects
  factory GlassEffectParams.highQuality() {
    return const GlassEffectParams(
      refraction: 0.99, // Strong distortion
      chromaticDispersion: 0.01, // Noticeable color separation
      distortionStrength: 0.5, // Strong distortion
      shadowBlurRadius: 4.0, // Prominent shadow
      shadowSpreadRadius: 1.0, // Noticeable spread
      shadowOffset: 2.0, // Noticeable offset
      opacity: 0.15, // Strong effect
    );
  }
}

/// Animation parameters for glass effects based on quality level
class AnimationParams {
  final bool enabled;
  final Duration duration;
  final double intensity;

  const AnimationParams({
    required this.enabled,
    required this.duration,
    required this.intensity,
  });

  /// Disabled animations for maximum performance
  factory AnimationParams.disabled() {
    return const AnimationParams(
      enabled: false,
      duration: Duration(seconds: 1), // Not used but required
      intensity: 0.0,
    );
  }

  /// Balanced animations for good performance/quality balance
  factory AnimationParams.balanced() {
    return const AnimationParams(
      enabled: true,
      duration: Duration(seconds: 3),
      intensity: 0.3,
    );
  }

  /// High quality animations for maximum visual impact
  factory AnimationParams.highQuality() {
    return const AnimationParams(
      enabled: true,
      duration: Duration(seconds: 2),
      intensity: 0.5,
    );
  }
}
