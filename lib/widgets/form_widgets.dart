import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../utils/format.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 11, color: kGrey, letterSpacing: 0.6)),
      );
}

InputDecoration fieldDecoration(
    {String? hint, Widget? suffix, bool focused = false}) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c));
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: kGrey),
    suffixIcon: suffix,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    enabledBorder: b(focused ? kTeal : kBorder),
    focusedBorder: b(kTeal),
    errorBorder: b(kRed),
    focusedErrorBorder: b(kRed),
    border: b(kBorder),
    errorStyle: const TextStyle(fontSize: 11),
  );
}

class DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final String? hint;
  const DropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
      decoration: fieldDecoration(hint: hint),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      validator: validator,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class DateField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? Function(String?)? validator;
  const DateField(
      {super.key, required this.value, required this.onChanged, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(value),
      initialValue: value == null ? '' : fmtDate(value!),
      readOnly: true,
      style: const TextStyle(fontSize: 13),
      validator: validator,
      decoration: fieldDecoration(
          hint: 'Select date',
          suffix: const Icon(Icons.calendar_month, size: 18, color: kGrey)),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (d != null) onChanged(d);
      },
    );
  }
}
