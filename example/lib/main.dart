import 'package:flutter/material.dart';
import 'package:toastify_x/toastify_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToastifyX Demo',
      debugShowCheckedModeBanner: false,
      // The navigatorKey is REQUIRED for ToastifyX to show toasts globally
      navigatorKey: toastNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ToastDemoScreen(),
    );
  }
}

class ToastDemoScreen extends StatefulWidget {
  const ToastDemoScreen({super.key});

  @override
  State<ToastDemoScreen> createState() => _ToastDemoScreenState();
}

class _ToastDemoScreenState extends State<ToastDemoScreen> {
  ToastStyle _selectedStyle = ToastStyle.modern;
  ToastPosition _selectedPosition = ToastPosition.top;
  AnimationType _selectedAnimation = AnimationType.slide;
  Color? _selectedColor;
  bool _enableBlur = false;
  // Advanced feature switches
  bool _showProgress = false;
  bool _useCustomIcon = false;
  bool _useBoldText = false;
  bool _useExtraPadding = false;

  /// Helper method to trigger a toast with current configurations
  void _showToast(ToastType type) {
    String message = "";
    switch (type) {
      case ToastType.success:
        message = "Operation completed successfully!";
        break;
      case ToastType.error:
        message = "Something went wrong. Please try again.";
        break;
      case ToastType.warning:
        message = "Caution: This action cannot be undone.";
        break;
      case ToastType.info:
        message = "Did you know? ToastifyX is highly customizable.";
        break;
      case ToastType.loading:
        message = "Processing your request...";
        break;
    }

    ToastifyX.show(
      context,
      message: message,
      type: type,
      style: _selectedStyle,
      position: _selectedPosition,
      animationType: _selectedAnimation,
      backgroundColor: _selectedColor,
      enableBlur: _enableBlur,
      showProgress: _showProgress,
      customIcon: _useCustomIcon ? Icons.rocket_launch : null,
      textStyle: _useBoldText 
          ? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
          : null,
      padding: _useExtraPadding ? const EdgeInsets.all(32) : null,
      actionLabel: type == ToastType.error ? "RETRY" : null,
      onAction: () {
        debugPrint("Action clicked!");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ToastifyX',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'Premium Toast Notifications for Flutter',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                // Use Expanded + SingleChildScrollView to prevent overflow on small screens
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CONFIGURATION SECTION ---
                        _buildSectionTitle('STYLE'),
                        Wrap(
                          spacing: 10,
                          children: ToastStyle.values.map((style) {
                            final isSelected = _selectedStyle == style;
                            return ChoiceChip(
                              label: Text(style.name.toUpperCase()),
                              selected: isSelected,
                              onSelected: (val) =>
                                  setState(() => _selectedStyle = style),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle('POSITION'),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildToggle(
                                  'TOP', _selectedPosition == ToastPosition.top,
                                  () {
                                setState(() =>
                                    _selectedPosition = ToastPosition.top);
                              }),
                              const SizedBox(width: 10),
                              _buildToggle('CENTER',
                                  _selectedPosition == ToastPosition.center,
                                  () {
                                setState(() =>
                                    _selectedPosition = ToastPosition.center);
                              }),
                              const SizedBox(width: 10),
                              _buildToggle('BOTTOM',
                                  _selectedPosition == ToastPosition.bottom,
                                  () {
                                setState(() =>
                                    _selectedPosition = ToastPosition.bottom);
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle('ANIMATION'),
                        Wrap(
                          spacing: 10,
                          children: AnimationType.values.map((anim) {
                            final isSelected = _selectedAnimation == anim;
                            return ChoiceChip(
                              label: Text(anim.name.toUpperCase()),
                              selected: isSelected,
                              onSelected: (val) =>
                                  setState(() => _selectedAnimation = anim),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle('CUSTOM COLOR'),
                        Row(
                          children: [
                            _buildColorOption(null, 'AUTO'),
                            const SizedBox(width: 10),
                            _buildColorOption(Colors.purple, 'PURPLE'),
                            const SizedBox(width: 10),
                            _buildColorOption(Colors.teal, 'TEAL'),
                            const SizedBox(width: 10),
                            _buildColorOption(Colors.pink, 'PINK'),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle('ADVANCED FEATURES'),
                        Row(
                          children: [
                            const Text('Show Progress Bar',
                                style: TextStyle(color: Colors.white)),
                            const Spacer(),
                            Switch(
                              value: _showProgress,
                              onChanged: (val) =>
                                  setState(() => _showProgress = val),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Custom Icon (Rocket)',
                                style: TextStyle(color: Colors.white)),
                            const Spacer(),
                            Switch(
                              value: _useCustomIcon,
                              onChanged: (val) =>
                                  setState(() => _useCustomIcon = val),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Bold Large Text',
                                style: TextStyle(color: Colors.white)),
                            const Spacer(),
                            Switch(
                              value: _useBoldText,
                              onChanged: (val) =>
                                  setState(() => _useBoldText = val),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Extra Large Padding',
                                style: TextStyle(color: Colors.white)),
                            const Spacer(),
                            Switch(
                              value: _useExtraPadding,
                              onChanged: (val) =>
                                  setState(() => _useExtraPadding = val),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Enable Backdrop Blur',
                                style: TextStyle(color: Colors.white)),
                            const Spacer(),
                            Switch(
                              value: _enableBlur,
                              onChanged: (val) =>
                                  setState(() => _enableBlur = val),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Previews Section
                        _buildSectionTitle('VISUAL PREVIEWS'),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildGifPreview('assets/gifs/styles.gif', 'STYLES'),
                              const SizedBox(width: 15),
                              _buildGifPreview('assets/gifs/positions.gif', 'POSITIONS'),
                              const SizedBox(width: 15),
                              _buildGifPreview('assets/gifs/types.gif', 'TYPES'),
                              const SizedBox(width: 15),
                              _buildGifPreview('assets/gifs/effects.gif', 'EFFECTS'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Triggers Section
                        _buildSectionTitle('TRIGGER TOASTS'),
                        const SizedBox(height: 10),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5,
                          children: [
                            _buildTriggerButton(
                                'SUCCESS', ToastType.success, Colors.green),
                            _buildTriggerButton(
                                'ERROR', ToastType.error, Colors.red),
                            _buildTriggerButton(
                                'WARNING', ToastType.warning, Colors.orange),
                            _buildTriggerButton(
                                'INFO', ToastType.info, Colors.blue),
                            _buildTriggerButton(
                                'LOADING', ToastType.loading, Colors.blueGrey),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withAlpha(128),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTriggerButton(String label, ToastType type, Color color) {
    return ElevatedButton(
      onPressed: () => _showToast(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(51),
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(128)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildColorOption(Color? color, String label) {
    final isSelected = _selectedColor == color;
    return InkWell(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color ?? Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color == null ? Colors.white : (color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGifPreview(String path, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            path,
            height: 160,
            width: 280,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 160,
                width: 280,
                color: Colors.white10,
                child: const Icon(Icons.broken_image, color: Colors.white24),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
