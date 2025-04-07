import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:public_app/pages/data_page.dart';

class GenderSelectionPage extends StatefulWidget {
  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _topCurveController;
  late AnimationController _bottomCurveController;
  late Animation<Offset> _topOffsetAnimation;
  late Animation<Offset> _bottomOffsetAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _topCurveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bottomCurveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _topOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _topCurveController, curve: Curves.easeOut),
    );

    _bottomOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _bottomCurveController, curve: Curves.easeOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _topCurveController.forward();
    _bottomCurveController.forward();

    // Delay fade-in until the curve animations are done
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _topCurveController.dispose();
    _bottomCurveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToDataPage(BuildContext context, String gender) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataPage(gender: gender)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      body: Stack(
        children: [
          // Top Curve Animation
          Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _topOffsetAnimation,
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(80),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Curve Animation
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _bottomOffsetAnimation,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.pink.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                ),
              ),
            ),
          ),

          // Center content with fade-in
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 91, 115, 156),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGenderButton(
                        icon: FontAwesomeIcons.mars,
                        label: 'Pria',
                        onTap: () => _navigateToDataPage(context, 'pria'),
                        color: Colors.blueAccent,
                      ),
                      _buildGenderButton(
                        icon: FontAwesomeIcons.venus,
                        label: 'Wanita',
                        onTap: () => _navigateToDataPage(context, 'wanita'),
                        color: Colors.pinkAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(125, 0, 0, 0),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: FaIcon(icon, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
