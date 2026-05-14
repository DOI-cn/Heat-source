import 'package:flutter/material.dart';

class PortionOption {
  final String label;
  final double grams;

  const PortionOption(this.label, this.grams);
}

const defaultPortions = [
  PortionOption('半碗', 75),
  PortionOption('一碗', 150),
  PortionOption('一拳', 120),
  PortionOption('半份', 90),
  PortionOption('一份', 180),
];

class PortionSelector extends StatefulWidget {
  final double initialGrams;
  final ValueChanged<double> onChanged;

  const PortionSelector({
    super.key,
    required this.initialGrams,
    required this.onChanged,
  });

  @override
  State<PortionSelector> createState() => _PortionSelectorState();
}

class _PortionSelectorState extends State<PortionSelector> {
  late double _grams;
  late final TextEditingController _controller;
  bool _isCustom = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _grams = widget.initialGrams;
    _controller = TextEditingController(text: _grams.toStringAsFixed(0));
    _isCustom = !defaultPortions.any((o) => (o.grams - _grams).abs() < 0.5);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPortion(PortionOption option) {
    FocusScope.of(context).unfocus();
    setState(() {
      _grams = option.grams;
      _controller.text = _grams.toStringAsFixed(0);
      _isCustom = false;
      _errorText = null;
    });
    widget.onChanged(_grams);
  }

  void _onTextChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      if (value.isEmpty) return;
      setState(() => _errorText = '请输入有效克重');
      return;
    }
    setState(() {
      _grams = parsed;
      _isCustom = !defaultPortions.any((o) => (o.grams - parsed).abs() < 0.5);
      _errorText = null;
    });
    widget.onChanged(_grams);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ...defaultPortions.map((option) {
              final selected = (_grams - option.grams).abs() < 0.5;
              return ChoiceChip(
                label: Text('${option.label} (${option.grams.toStringAsFixed(0)}g)'),
                selected: selected,
                onSelected: (_) => _selectPortion(option),
              );
            }),
            InputChip(
              label: const Text('自定义'),
              selected: _isCustom,
              onSelected: (_) {
                FocusScope.of(context).requestFocus();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('精确克重：'),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: 'g',
                  isDense: true,
                  errorText: _errorText,
                ),
                onChanged: _onTextChanged,
                onSubmitted: _onTextChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
