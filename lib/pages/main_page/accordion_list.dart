import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:public_app/models/toilet_data.dart';
import 'package:public_app/utils/string_util.dart';

class ToiletAccordionList extends StatelessWidget {
  final Map<String, List<ToiletData>> toiletFloorMap;
  final Map<String, String> visitorFloorMap;
  final String gender;

  const ToiletAccordionList({
    super.key,
    required this.toiletFloorMap,
    required this.visitorFloorMap,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children:
            toiletFloorMap.entries.map((entry) {
              final lokasi = entry.key;
              final toilets = entry.value;
              final visitors = visitorFloorMap[lokasi] ?? '0';

              toilets.sort(
                (a, b) => int.parse(
                  a.toiletNumber,
                ).compareTo(int.parse(b.toiletNumber)),
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  title: Text(
                    '${StringUtil.snakeToCapitalized(lokasi)} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  collapsedBackgroundColor:
                      gender == 'pria'
                          ? Colors.purple.shade200
                          : Colors.red.shade300,
                  collapsedTextColor: Colors.white,
                  backgroundColor: Colors.white,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 25,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 20,
                              runSpacing: 12,
                              children:
                                  toilets.map((toilet) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.toilet,
                                          color:
                                              toilet.status == 'occupied'
                                                  ? Colors.red
                                                  : Colors.yellow,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Toilet ${toilet.toiletNumber}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.people, size: 40),
                              const SizedBox(width: 7),
                              Text(
                                visitors,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
