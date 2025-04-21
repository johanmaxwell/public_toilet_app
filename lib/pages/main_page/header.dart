import 'package:flutter/material.dart';
import 'package:public_app/utils/string_util.dart';

class DataPageHeader extends StatelessWidget {
  final String gender;

  const DataPageHeader(this.gender, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              gender == 'pria'
                  ? [Colors.cyan, Colors.blueAccent]
                  : [Colors.pinkAccent, Colors.pink.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white38,
            ),
            child: Icon(
              gender == 'pria' ? Icons.male : Icons.female,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Toilet ${StringUtil.capitalize(gender)}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
