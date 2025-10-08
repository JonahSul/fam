# Glass Components

Beautiful Apple-style glass distortion effects using [liquidglass_container](https://pub.dev/packages/liquidglass_container).

## Features

- 💧 **Realistic lens distortion** using FragmentShader
- 🌈 **Refraction and chromatic dispersion** effects
- 🧊 **Live background capture** for true glass effect
- 💡 **Highly customizable** colors, shadows, and visual parameters
- 📦 **Smooth corners** with adjustable border radius
- 🎉 **Cross-platform** support (Web, Android, iOS, etc.)

## Components

### GlassBackground
Wraps your screen to enable glass effects. **Required** for all glass components.

```dart
final GlobalKey _backgroundKey = GlobalKey();

Scaffold(
  body: GlassBackground(
    backgroundKey: _backgroundKey,
    child: YourContent(),
  ),
)
```

### GlassCard
Beautiful card with liquid glass effect.

```dart
GlassCard(
  backgroundKey: _backgroundKey,
  borderRadius: 20,
  padding: EdgeInsets.all(16),
  color: Colors.white.withOpacity(0.1),
  onTap: () => print('Tapped!'),
  child: Text('Glass Card'),
)
```

### GlassButton
Button with glass effect.

```dart
GlassButton(
  backgroundKey: _backgroundKey,
  onPressed: () => print('Pressed!'),
  child: Text('Click Me'),
)
```

### GlassTextField
Input field with glass effect.

```dart
GlassTextField(
  backgroundKey: _backgroundKey,
  hintText: 'Type something...',
  controller: myController,
)
```

### GlassContainer
Generic container with glass effect.

```dart
GlassContainer(
  backgroundKey: _backgroundKey,
  width: 200,
  height: 100,
  borderRadius: 16,
  child: Center(child: Text('Container')),
)
```

### GlassDialog
Dialog with glass effect.

```dart
showDialog(
  context: context,
  builder: (context) => GlassDialog(
    backgroundKey: _backgroundKey,
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('Glass Dialog'),
    ),
  ),
)
```

### GlassBottomSheet
Bottom sheet with glass effect.

```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (context) => GlassBottomSheet(
    backgroundKey: _backgroundKey,
    child: YourContent(),
  ),
)
```

## Important Notes

1. **Always use the same `backgroundKey`** for all glass components on a screen
2. **Wrap your screen with `GlassBackground`** to enable the effects
3. **Performance**: Glass effects are GPU-intensive. Use sparingly on lower-end devices
4. **Colors**: Use semi-transparent colors (e.g., `Colors.white.withOpacity(0.1)`) for best results

## Example Screen

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        backgroundKey: _backgroundKey,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  backgroundKey: _backgroundKey,
                  child: Text('Welcome!'),
                ),
                SizedBox(height: 16),
                GlassButton(
                  backgroundKey: _backgroundKey,
                  onPressed: () {},
                  child: Text('Click Me'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Credits

Powered by [liquidglass_container](https://pub.dev/packages/liquidglass_container) - A beautiful Apple-26 style container with glass distortion.
