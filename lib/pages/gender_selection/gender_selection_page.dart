import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:public_app/pages/main_page/data_page.dart';
import 'package:public_app/decoration/page_decoration.dart';
import 'package:public_app/decoration/fade_in.dart';
import 'package:public_app/pages/gender_selection/gender_button.dart';

class GenderSelectionPage extends StatelessWidget {
  const GenderSelectionPage({super.key});

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
          const PageDecoration(),
          Center(
            child: FadeIn(
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
                      GenderButton(
                        icon: FontAwesomeIcons.mars,
                        label: 'Pria',
                        onTap: () => _navigateToDataPage(context, 'pria'),
                        color: Colors.blueAccent,
                      ),
                      GenderButton(
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
}
