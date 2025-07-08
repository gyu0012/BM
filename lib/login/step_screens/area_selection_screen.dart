// =================================================================
// =================================================================

// login/step_screens/area_selection_screen.dart (NEW FILE)
// 경로: lib/login/step_screens/area_selection_screen.dart
import 'package:flutter/material.dart';
import '../../models/address_data_model.dart';

class AreaSelectionScreen extends StatefulWidget {
  final String title;

  const AreaSelectionScreen({Key? key, required this.title}) : super(key: key);

  @override
  _AreaSelectionScreenState createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  String? _selectedPrimaryRegion;
  String _searchQuery = '';
  List<String> _filteredSecondaryRegions = [];

  final _primaryRegions = AddressData.koreanAddresses.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 권역 선택 (시/도)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('1. 권역 선택', style: Theme.of(context).textTheme.titleLarge),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: _primaryRegions.map((region) {
              return ChoiceChip(
                label: Text(region),
                selected: _selectedPrimaryRegion == region,
                onSelected: (selected) {
                  setState(() {
                    _selectedPrimaryRegion = region;
                    // '세종'은 상세구역이 없으므로 바로 선택 완료
                    if (region == '세종') {
                      Navigator.of(context).pop('세종');
                    } else {
                      _updateSecondaryRegions();
                    }
                  });
                },
                selectedColor: Colors.pink.shade100,
              );
            }).toList(),
          ),
          Divider(height: 32, thickness: 1),

          // 2. 상세구역 선택 (시/군/구) - 권역 선택 시 나타남
          if (_selectedPrimaryRegion != null && _selectedPrimaryRegion != '세종')
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('2. 상세구역 선택', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  // 상세구역 검색 필드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '상세구역 검색 (예: 강남구)',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                          _updateSecondaryRegions();
                        });
                      },
                    ),
                  ),
                  // 상세구역 목록
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredSecondaryRegions.length,
                      itemBuilder: (context, index) {
                        final secondaryRegion = _filteredSecondaryRegions[index];
                        return ListTile(
                          title: Text(secondaryRegion),
                          onTap: () {
                            final fullAddress = '$_selectedPrimaryRegion $secondaryRegion';
                            Navigator.of(context).pop(fullAddress);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _updateSecondaryRegions() {
    if (_selectedPrimaryRegion != null) {
      final allSecondary = AddressData.koreanAddresses[_selectedPrimaryRegion] ?? [];
      if (_searchQuery.isEmpty) {
        _filteredSecondaryRegions = allSecondary;
      } else {
        _filteredSecondaryRegions = allSecondary
            .where((region) => region.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    }
  }
}