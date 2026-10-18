import 'package:flutter/material.dart';
import '../widgets/animated_header.dart';

class ReflectionScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool english;
  final ValueChanged<Map<String, dynamic>> onDataChanged;

  const ReflectionScreen({
    super.key,
    required this.data,
    required this.english,
    required this.onDataChanged,
  });

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  late TextEditingController _controller;
  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    final reflections =
        Map<String, dynamic>.from(widget.data['reflections'] ?? {});
    _controller = TextEditingController(
      text: '${reflections[_today] ?? ''}',
    );
  }

  @override
  void didUpdateWidget(covariant ReflectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      final reflections =
          Map<String, dynamic>.from(widget.data['reflections'] ?? {});
      final savedText = '${reflections[_today] ?? ''}';
      if (_controller.text != savedText) {
        _controller.value = TextEditingValue(
          text: savedText,
          selection: TextSelection.collapsed(offset: savedText.length),
        );
      }
    }
  }

  void _save() {
    final updated = Map<String, dynamic>.from(widget.data);
    final reflections =
        Map<String, dynamic>.from(updated['reflections'] ?? {});
    reflections[_today] = _controller.text;
    updated['reflections'] = reflections;
    widget.onDataChanged(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.english ? 'Reflection saved' : 'লেখা সংরক্ষণ করা হয়েছে',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AnimatedHeader(
          title: widget.english ? 'Daily Reflection' : 'দৈনিক আত্মসমালোচনা',
          subtitle: widget.english
              ? 'Reflect, learn, and begin again.'
              : 'নিজেকে পর্যালোচনা করুন, শিখুন, আবার শুরু করুন।',
          icon: Icons.menu_book_rounded,
          colors: const [Color(0xFF1376A8), Color(0xFF43B8C8)],
        ),
        const SizedBox(height: 18),
        Text(
          _today,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          minLines: 10,
          maxLines: 18,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: widget.english
                ? 'What went well today? What can you improve tomorrow?'
                : 'আজ কী ভালো করেছেন? আগামীকাল কোন বিষয়ে উন্নতি করতে চান?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            contentPadding: const EdgeInsets.all(18),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: Text(widget.english ? 'Save reflection' : 'লেখা সংরক্ষণ'),
        ),
      ],
    );
  }
}
