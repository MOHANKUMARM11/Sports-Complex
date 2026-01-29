import 'package:flutter/material.dart';
import 'camera_screen.dart';


class TestSelectionScreen extends StatelessWidget {
  const TestSelectionScreen({super.key});

  final List<Map<String, dynamic>> tests = const [
    {
      'title': 'Squat Analysis',
      'icon': Icons.accessibility_new_rounded,
      'duration': '30 sec',
      'desc': 'Analyze your squat form and depth.',
    },
    {
      'title': 'Height Measurement',
      'icon': Icons.height_rounded,
      'duration': 'Instant',
      'desc': 'Measure your height using camera.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: tests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final test = tests[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(testName: test['title']),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        test['icon'],
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test['title'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            test['desc'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white60,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
