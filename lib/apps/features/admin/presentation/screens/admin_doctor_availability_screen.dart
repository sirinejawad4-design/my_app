import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/models/doctor.dart';
import '../../data/repositories/doctor_repository.dart';

class AdminDoctorAvailabilityScreen extends StatefulWidget {
  final Doctor doctor;

  const AdminDoctorAvailabilityScreen({super.key, required this.doctor});

  @override
  State<AdminDoctorAvailabilityScreen> createState() =>
      _AdminDoctorAvailabilityScreenState();
}

class _AdminDoctorAvailabilityScreenState
    extends State<AdminDoctorAvailabilityScreen> {
  static const Color _background = Color(0xFFFFFCF5);
  static const Color _card = Color(0xFFFFF4E7);
  static const Color _green = Color(0xFF19B58A);
  static const Color _text = Color(0xFF263238);
  static const Color _muted = Color(0xFF8A9297);

  final DoctorRepository _repository = DoctorRepository();

  final Stream<DocumentSnapshot<Map<String, dynamic>>> _clinicStream =
      FirebaseFirestore.instance
          .collection('app_settings')
          .doc('clinic')
          .snapshots();

  final List<String> _days = const [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final Map<String, String> _labels = const {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  late Map<String, bool> _workingDays;
  late String _startTime;
  late String _endTime;
  late int _slotDuration;

  bool _saving = false;

  List<String> get _timeOptions => [
    for (int hour = 0; hour < 24; hour++)
      for (int minute in [0, 30])
        '${((hour % 12 == 0) ? 12 : hour % 12).toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')} '
            '${hour < 12 ? 'AM' : 'PM'}',
  ];

  @override
  void initState() {
    super.initState();

    _workingDays = {
      for (final day in _days) day: widget.doctor.workingDays[day] ?? false,
    };

    _startTime = _timeOptions.contains(widget.doctor.startTime)
        ? widget.doctor.startTime
        : '09:00 AM';

    _endTime = _timeOptions.contains(widget.doctor.endTime)
        ? widget.doctor.endTime
        : '05:00 PM';

    _slotDuration = [15, 30, 45, 60].contains(widget.doctor.slotDuration)
        ? widget.doctor.slotDuration
        : 30;
  }

  int _toMinutes(String value) {
    final parts = value.split(' ');
    final hm = parts[0].split(':');

    int hour = int.parse(hm[0]) % 12;
    final minute = int.parse(hm[1]);

    if (parts[1] == 'PM') {
      hour += 12;
    }

    return hour * 60 + minute;
  }

  Future<void> _saveAvailability() async {
    if (!_workingDays.values.any((active) => active)) {
      _showMessage('Select at least one working day.', error: true);
      return;
    }

    if (_toMinutes(_endTime) <= _toMinutes(_startTime)) {
      _showMessage('End time must be after start time.', error: true);
      return;
    }

    setState(() => _saving = true);

    try {
      await _repository.updateAvailability(
        doctorId: widget.doctor.id,
        workingDays: Map<String, bool>.from(_workingDays),
        startTime: _startTime,
        endTime: _endTime,
        slotDuration: _slotDuration,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Availability updated successfully.'),
          backgroundColor: _green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);

      _showMessage('Failed to update availability: $e', error: true);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : _green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _text),
        ),
        title: const Text(
          'Doctor Availability',
          style: TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorCard(doctor),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Working Days'),
                  Text(
                    '${_workingDays.values.where((v) => v).length} days selected',
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: _days.map((day) {
                    final active = _workingDays[day] ?? false;

                    return SizedBox(
                      height: 57,
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: active
                                  ? _green.withValues(alpha: 0.12)
                                  : const Color(0xFFEDEBE5),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              color: active ? _green : _muted,
                              size: 17,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              _labels[day]!,
                              style: TextStyle(
                                color: active ? _text : _muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Switch.adaptive(
                            value: active,
                            activeTrackColor: _green.withValues(alpha: 0.5),
                            activeThumbColor: _green,
                            onChanged: _saving
                                ? null
                                : (value) {
                                    setState(() {
                                      _workingDays[day] = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 25),

              _sectionTitle('Working Hours'),

              const SizedBox(height: 13),

              Row(
                children: [
                  Expanded(
                    child: _buildTimeSelector(
                      label: 'START TIME',
                      value: _startTime,
                      onChanged: (value) {
                        setState(() => _startTime = value);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildTimeSelector(
                      label: 'END TIME',
                      value: _endTime,
                      onChanged: (value) {
                        setState(() => _endTime = value);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 23),

              _sectionTitle('Slot Duration'),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFECE5DA)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _slotDuration,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: _muted),
                    items: [15, 30, 45, 60].map((minutes) {
                      return DropdownMenuItem<int>(
                        value: minutes,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: _green,
                              size: 19,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$minutes minutes',
                              style: const TextStyle(
                                color: _text,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _slotDuration = value;
                              });
                            }
                          },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveAvailability,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 19),
                  label: Text(
                    _saving ? 'Saving...' : 'Save Availability',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _clinicStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final clinicName = (data?['clinicName'] as String?)?.trim() ?? '';

        final clinicLocation =
            (data?['clinicLocation'] as String?)?.trim() ?? '';

        final clinicDetails = [
          if (doctor.specialty.trim().isNotEmpty) doctor.specialty.trim(),
          if (clinicName.isNotEmpty) clinicName,
          if (clinicLocation.isNotEmpty) clinicLocation,
        ].join(' · ');

        String subtitle;

        if (snapshot.hasError) {
          subtitle = doctor.specialty;
        } else if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          subtitle = doctor.specialty;
        } else {
          subtitle = clinicDetails.isNotEmpty
              ? clinicDetails
              : 'Clinic location not set';
        }

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: _green.withValues(alpha: 0.12),
                backgroundImage: doctor.imageUrl.isNotEmpty
                    ? NetworkImage(doctor.imageUrl)
                    : null,
                child: doctor.imageUrl.isEmpty
                    ? const Icon(Icons.person_outline, color: _green, size: 30)
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: doctor.isActive
                      ? _green.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doctor.isActive ? '• Active' : '• Inactive',
                  style: TextStyle(
                    color: doctor.isActive ? _green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFECE5DA)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: _muted,
                size: 18,
              ),
              items: _timeOptions.map((time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: _green, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          time,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _text, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _saving
                  ? null
                  : (newValue) {
                      if (newValue != null) {
                        onChanged(newValue);
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }
}
