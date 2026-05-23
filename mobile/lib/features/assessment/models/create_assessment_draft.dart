class CreateAssessmentDraft {
  const CreateAssessmentDraft({
    required this.title,
    required this.assessmentType,
    required this.subject,
    required this.gradeLevel,
    required this.unit,
    required this.questionCount,
    required this.timeLimitMinutes,
    required this.classroomIds,
    this.availableFrom,
    this.availableUntil,
  });

  final String title;
  final String assessmentType;
  final String? subject;
  final String? gradeLevel;
  final String unit;
  final int questionCount;
  final int timeLimitMinutes;
  final List<String> classroomIds;
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  Map<String, dynamic> toPayload() => {
        'title': title.trim(),
        'assessmentType': assessmentType,
        'subject': subject,
        'gradeLevel': gradeLevel,
        'units': [unit.trim()],
        'questionCount': questionCount,
        'timeLimitMinutes': timeLimitMinutes,
        'classroomIds': classroomIds,
        if (availableFrom != null)
          'availableFrom': availableFrom!.toIso8601String(),
        if (availableUntil != null)
          'availableUntil': availableUntil!.toIso8601String(),
      };

  String? validateForPublish() {
    if (classroomIds.isEmpty) {
      return 'اختر فصلًا واحدًا على الأقل قبل نشر الاختبار.';
    }
    return validateAvailabilityWindow();
  }

  String? validateAvailabilityWindow() {
    if (availableFrom == null || availableUntil == null) return null;
    if (!availableUntil!.isAfter(availableFrom!)) {
      return 'تاريخ نهاية الاختبار يجب أن يكون بعد تاريخ البداية.';
    }
    return null;
  }
}

String? extractCreatedAssessmentId(Map<String, dynamic> assessment) {
  final id = assessment['_id'] ?? assessment['id'];
  final text = id?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
