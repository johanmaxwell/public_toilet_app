import 'package:flutter/material.dart';
import 'package:public_app/utils/string_util.dart';

class GedungDropdown extends StatelessWidget {
  final List<String> gedungList;
  final String? selectedGedung;
  final ValueChanged<String?> onChanged;
  final String gender;

  const GedungDropdown({
    super.key,
    required this.gedungList,
    required this.selectedGedung,
    required this.onChanged,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gender == 'pria' ? Colors.blueAccent : Colors.pinkAccent,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGedung,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items:
              gedungList.map((gedung) {
                return DropdownMenuItem<String>(
                  value: gedung,
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 6.0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                gedungList.indexOf(gedung) == 0
                                    ? Colors.transparent
                                    : Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(StringUtil.snakeToCapitalized(gedung)),
                      ),
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
