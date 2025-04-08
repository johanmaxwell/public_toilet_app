import 'package:flutter/material.dart';

class PageDecoration extends StatefulWidget {
  const PageDecoration({super.key});

  @override
  State<PageDecoration> createState() => _PageDecorationState();
}

class _PageDecorationState extends State<PageDecoration>
    with TickerProviderStateMixin {
  late final AnimationController _topCurveController;
  late final AnimationController _bottomCurveController;
  late final Animation<Offset> _topOffsetAnimation;
  late final Animation<Offset> _bottomOffsetAnimation;

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

    _topCurveController.forward();
    _bottomCurveController.forward();
  }

  @override
  void dispose() {
    _topCurveController.dispose();
    _bottomCurveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(80),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
