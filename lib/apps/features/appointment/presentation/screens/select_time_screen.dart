import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:my_app/apps/features/admin/data/models/doctor.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class SelectTimeScreen extends StatefulWidget {
  final String doctorId;

  const SelectTimeScreen({super.key, required this.doctorId});

  @override
  State<SelectTimeScreen> createState() => _SelectTimeScreenState();
}

class _SelectTimeScreenState extends State<SelectTimeScreen> {
  late Future<Doctor?> _doctorFuture;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String? _selectedTime;
  List<String> _availableTimes = [];
  bool _loadingTimes = false;

  static const List<String> _dayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  void initState() {
    super.initState();
    _doctorFuture = _loadDoctor();

    _doctorFuture.then((doctor) {
      if (doctor != null && mounted) {
        _loadAvailableTimes(doctor);
      }
    });
  }

 Future<Doctor?> _loadDoctor() async {
  final doc = await FirebaseFirestore.instance
      .collection('doctors')
      .doc(widget.doctorId)
      .get();

  if (!doc.exists || doc.data() == null) return null;

  return Doctor.fromMap(doc.id, doc.data()!);
}

  int _timeToMinutes(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());

    if (match == null) {
      throw FormatException('Invalid time format: $value');
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (hour < 1 || hour > 12 || minute > 59) {
      throw FormatException('Invalid time: $value');
    }

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return hour * 60 + minute;
  }

  String _formatMinutes(int totalMinutes) {
    final hour24 = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 < 12 ? 'AM' : 'PM';

    return '${hour12.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $period';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _loadAvailableTimes(Doctor doctor) async {
    if (!mounted) return;

    setState(() {
      _loadingTimes = true;
      _availableTimes = [];
      _selectedTime = null;
    });

    try {
      final dayKey = _dayKeys[_selectedDay.weekday - 1];

      if (!doctor.isActive || doctor.workingDays[dayKey] != true) {
        if (mounted) {
          setState(() => _loadingTimes = false);
        }
        return;
      }

      final start = _timeToMinutes(doctor.startTime);
      final end = _timeToMinutes(doctor.endTime);
      final duration = doctor.slotDuration;

      if (duration <= 0 || end <= start) {
        throw const FormatException('Invalid doctor availability settings.');
      }

      final date = _dateKey(_selectedDay);

      // Read availability records, not other patients' appointments.
      final snapshot = await FirebaseFirestore.instance
          .collection('appointment_slots')
          .where('doctorId', isEqualTo: doctor.id)
          .where('date', isEqualTo: date)
          .get();

      final bookedMinutes = <int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        if (data['status'] != 'booked') continue;

        final storedTime = data['time'];
        if (storedTime is! String) continue;

       try {
  bookedMinutes.add(_timeToMinutes(storedTime));
} on FormatException {
  // Ignore malformed stored times.
}
      }

      final now = DateTime.now();
      final isToday = isSameDay(_selectedDay, now);
      final currentMinutes = now.hour * 60 + now.minute;
      final times = <String>[];

      for (
        var minutes = start;
        minutes + duration <= end;
        minutes += duration
      ) {
        if (isToday && minutes <= currentMinutes) continue;
        if (bookedMinutes.contains(minutes)) continue;

        times.add(_formatMinutes(minutes));
      }

      if (!mounted) return;

      setState(() {
        _availableTimes = times;
        _loadingTimes = false;
      });
    } catch (_) {
  if (!mounted) return;

  setState(() {
    _availableTimes = [];
    _loadingTimes = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Could not load available times. Check Firestore permissions.',
      ),
    ),
  );
}

   
  }

  void _onConfirmPressed(Doctor doctor) {
    if (!doctor.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This doctor is currently unavailable.')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time', style: context.regular12White),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.push(
      '/review-appointment'
      '?doctorId=${Uri.encodeComponent(doctor.id)}'
      '&doctorName=${Uri.encodeComponent(doctor.name)}'
      '&specialty=${Uri.encodeComponent(doctor.specialty)}'
      '&date=${Uri.encodeComponent(_dateKey(_selectedDay))}'
      '&time=${Uri.encodeComponent(_selectedTime!)}'
      '&fee=${Uri.encodeComponent(doctor.fee.toStringAsFixed(0))}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: Text('Select Time', style: context.bold16TextMain),
        centerTitle: true,
      ),
      body: FutureBuilder<Doctor?>(
        future: _doctorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong.\nPlease try again.'),
            );
          }

          final doctor = snapshot.data;

          if (doctor == null) {
            return const Center(child: Text('Doctor not found.'));
          }

          return _buildContent(context, doctor);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Doctor doctor) {
    final dayKey = _dayKeys[_selectedDay.weekday - 1];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.grey100,
            ),
            child: Row(
              children: [
                _buildDoctorImage(doctor.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: context.semiBold14TextMain,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(doctor.specialty, style: context.regular11TextSub),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (_) => const Icon(
                            Icons.star,
                            size: 12,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('Select Date', style: context.bold16TextMain),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grey100),
            ),
            child: TableCalendar(
              firstDay: _today(),
              lastDay: _today().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              enabledDayPredicate: (day) {
                final key = _dayKeys[day.weekday - 1];

                return doctor.isActive &&
                    doctor.workingDays[key] == true &&
                    !day.isBefore(_today());
              },
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedTime = null;
                });

                await _loadAvailableTimes(doctor);
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: context.semiBold14TextMain,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: context.regular14TextMain,
                weekendTextStyle: context.regular14TextMain,
                outsideTextStyle: context.regular12TextSub,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Available Time', style: context.bold16TextMain),
          const SizedBox(height: 12),

          if (!doctor.isActive)
            const Text('This doctor is currently unavailable.')
          else if (doctor.workingDays[dayKey] != true)
            const Text('The doctor does not work on this day.')
          else if (_loadingTimes)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_availableTimes.isEmpty)
            const Text('No available times for this day.')
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableTimes.map((time) {
                final selected = _selectedTime == time;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTime = time);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.grey100,
                      ),
                    ),
                    child: Text(
                      time,
                      style: selected
                          ? context.semiBold12White
                          : context.regular12TextMain,
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 32),

          CustomButton(
            text: 'Confirm',
            onPressed: () => _onConfirmPressed(doctor),
          ),

          const SizedBox(height: 24),

          if (_selectedTime != null)
            Center(
              child: Text(
                '${_selectedDay.day}/${_selectedDay.month}/'
                '${_selectedDay.year} • $_selectedTime',
                style: context.regular12TextSub,
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDoctorImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.white,
        child: Icon(Icons.person, color: AppColors.textSub),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.white,
            child: Icon(Icons.person, color: AppColors.textSub),
          );
        },
      ),
    );
  }
}
