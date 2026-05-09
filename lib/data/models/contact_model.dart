import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_detail.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/timeline_item.dart';

class TimelineItemModel {
  final String icon;
  final String when;
  final String text;

  const TimelineItemModel({
    required this.icon,
    required this.when,
    required this.text,
  });

  TimelineItem toDomain() => TimelineItem(icon: icon, when: when, text: text);
}

class ReminderModel {
  final String text;
  final String due;

  const ReminderModel({required this.text, required this.due});

  Reminder toDomain() => Reminder(text: text, due: due);
}

class ContactDetailModel {
  final String icon;
  final String label;
  final String value;

  const ContactDetailModel({
    required this.icon,
    required this.label,
    required this.value,
  });

  ContactDetail toDomain() => ContactDetail(icon: icon, label: label, value: value);
}

class ContactModel {
  final String name;
  final bool starred;
  final String palette;
  final String? group;
  final String? snippet;
  final String? due;
  final List<TimelineItemModel> timelineItems;
  final List<ReminderModel> reminderItems;
  final List<ContactDetailModel> detailItems;

  const ContactModel({
    required this.name,
    this.starred = false,
    required this.palette,
    this.group,
    this.snippet,
    this.due,
    this.timelineItems = const [],
    this.reminderItems = const [],
    this.detailItems = const [],
  });

  Contact toDomain() => Contact(
    name: name,
    starred: starred,
    palette: palette,
    group: group,
    snippet: snippet,
    due: due,
    timeline: timelineItems.map((t) => t.toDomain()).toList(),
    reminders: reminderItems.map((r) => r.toDomain()).toList(),
    details: detailItems.map((d) => d.toDomain()).toList(),
  );
}
