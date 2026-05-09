import 'timeline_item.dart';
import 'reminder.dart';
import 'contact_detail.dart';

class Contact {
  final String name;
  final bool starred;
  final String palette;
  final String? group;
  final String? snippet;
  final String? due;
  final List<TimelineItem> timeline;
  final List<Reminder> reminders;
  final List<ContactDetail> details;

  const Contact({
    required this.name,
    this.starred = false,
    required this.palette,
    this.group,
    this.snippet,
    this.due,
    this.timeline = const [],
    this.reminders = const [],
    this.details = const [],
  });
}
