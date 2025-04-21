import 'package:flutter/material.dart';
import 'package:public_app/utils/string_util.dart';

class CompanyDropdown extends StatelessWidget {
  final String? selectedCompany;
  final ValueChanged<String?> onChanged;
  final List<String> companyOption;

  const CompanyDropdown({
    super.key,
    required this.selectedCompany,
    required this.onChanged,
    required this.companyOption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal),
      ),

      child: DropdownButton<String>(
        value: selectedCompany,
        isExpanded: true,
        hint: Center(child: Text('Pilih Instansi')),
        icon: const Icon(Icons.arrow_drop_down),
        items:
            companyOption.map((company) {
              return DropdownMenuItem<String>(
                value: company,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 6.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color:
                              companyOption.indexOf(company) == 0
                                  ? Colors.transparent
                                  : Colors.grey,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(StringUtil.snakeToCapitalized(company)),
                    ),
                  ),
                ),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
