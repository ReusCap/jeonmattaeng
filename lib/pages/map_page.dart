import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지도')),
      body: const Center(
        child: Text(
          '지도 기능은 아직 구현되지 않았습니다.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
