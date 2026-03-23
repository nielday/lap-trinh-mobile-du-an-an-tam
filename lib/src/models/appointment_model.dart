import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String parentId;
  final String title;
  final String doctorName;
  final String location;
  final DateTime date;
  final String type;
  final String status; // 'upcoming', 'confirmed', 'pending', etc.

  const AppointmentModel({
    required this.id,
    required this.parentId,
    required this.title,
    required this.doctorName,
    this.location = '',
    required this.date,
    required this.type,
    this.status = '',
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppointmentModel(
      id: doc.id,
      parentId: data['parentId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] as String? ?? '',
      status: data['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'parentId': parentId,
        'title': title,
        'doctorName': doctorName,
        'location': location,
        'date': Timestamp.fromDate(date),
        'type': type,
        'status': status,
      };
}
