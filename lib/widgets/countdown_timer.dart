import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
  final DateTime expireAt;

  const CountdownTimer({super.key, required this.expireAt});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expireAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.expireAt.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d.isNegative) return "Hết hạn";
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    return days > 0 ? "$days ngày $hours giờ $minutes phút" : "$hours giờ $minutes phút";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "Còn lại: ${_format(_remaining)}",
      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}