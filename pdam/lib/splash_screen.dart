import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pdam/views/login_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _masterController;
  late AnimationController _waveCycleController;

  late Animation<Offset> _logoSlideDown;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;
  late Animation<double> _waveHeight;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  bool _isLogoMovedToTop = false;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _logoSlideDown = Tween<Offset>(
      begin: const Offset(0.0, -3.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
    ));

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    _masterController.addListener(() {
      if (_masterController.value >= 0.40 && !_isLogoMovedToTop) {
        setState(() => _isLogoMovedToTop = true);
      } else if (_masterController.value < 0.40 && _isLogoMovedToTop) {
        setState(() => _isLogoMovedToTop = false);
      }
    });

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.50, 0.63, curve: Curves.easeIn),
      ),
    );
    _textScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.50, 0.70, curve: Curves.easeOutBack),
      ),
    );

    _waveHeight = Tween<double>(begin: 0.0, end: 0.38).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.60, 0.85, curve: Curves.fastOutSlowIn),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.80, 0.93, curve: Curves.easeIn),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).chain(
      CurveTween(curve: const Interval(0.80, 1.0, curve: Curves.easeOutCubic)),
    ).animate(_masterController);

    _waveCycleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _masterController.forward();
  }

  @override
  void dispose() {
    _masterController.dispose();
    _waveCycleController.dispose();
    super.dispose();
  }

  // ── Navigasi ke LoginView ─────────────────────────────────────
  void _goToRoleView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double logoSize  = 140.0;
    const double textH     = 45.0;
    const double layoutGap = 25.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_masterController, _waveCycleController]),
        builder: (context, child) {
          final currentWaveHeight = _waveHeight.value * size.height;

          return Stack(
            children: [

              // ── Gelombang Air ─────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(_waveCycleController.value),
                  child: Container(
                    height: currentWaveHeight + 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF4EC5EE), Color(0xFF1878C2)],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Gelembung ─────────────────────────────────────
              if (_masterController.value > 0.60)
                ...List.generate(
                  8,
                  (i) => _buildLiveBubble(size, i, currentWaveHeight),
                ),

              // ── Logo ──────────────────────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 750),
                curve: Curves.fastOutSlowIn,
                top: _isLogoMovedToTop
                    ? (size.height * 0.28) - ((logoSize + layoutGap + textH) / 2)
                    : (size.height * 0.5) - ((logoSize + layoutGap + textH) / 2),
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      SlideTransition(
                        position: _logoSlideDown,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Image.asset(
                            'assets/images/Alirin logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.scale(
                          scale: _textScale.value,
                          child: Padding(
                            padding: EdgeInsets.only(top: layoutGap),
                            child: Image.asset(
                              'assets/images/Alirin.png',
                              width: logoSize * 1.2,
                              height: textH,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tombol "Mari Mulai" ───────────────────────────
              Positioned(
                bottom: 45,
                left: 35,
                right: 35,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: Opacity(
                    opacity: _buttonOpacity.value,
                    child: ElevatedButton(

                      // ← Sebelumnya: onPressed: () {}
                      // ← Sekarang:   navigasi ke RoleView
                      onPressed: _goToRoleView,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.black26,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Mari Mulai',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1878C2),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLiveBubble(Size size, int index, double waveHeight) {
    final random     = Random(index * 37 + 13);
    final xPos       = random.nextDouble() * size.width;
    final baseYPos   = size.height - waveHeight + random.nextDouble() * (waveHeight * 0.8);
    final radius     = 4.0 + random.nextDouble() * 10.0;
    final speed      = 0.5 + random.nextDouble() * 0.6;
    final delayOffset = random.nextDouble();

    final currentProgress = (_waveCycleController.value + delayOffset) % 1.0;
    final yAnimationDelta = currentProgress * 100 * speed;

    return Positioned(
      left: xPos - radius,
      top:  baseYPos - yAnimationDelta - radius,
      child: Container(
        width:  radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.0,
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animValue;
  WaveClipper(this.animValue);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveOffset = animValue * 2 * pi;

    path.moveTo(0, 40);
    for (double x = 0; x <= size.width; x++) {
      final y = 35 +
          sin((x / size.width * 2 * pi) + waveOffset) * 14 +
          sin((x / size.width * 4 * pi) + waveOffset * 1.2) * 5;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper old) => old.animValue != animValue;
}