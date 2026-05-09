import '../../models/contact_model.dart';

abstract class HaloLocalDataSource {
  Future<List<ContactModel>> getContacts();
  Future<ContactModel> getContactByName(String name);
  Future<List<String>> getSuggestions();
}

class HaloLocalDataSourceImpl implements HaloLocalDataSource {
  static const _contacts = [
    ContactModel(
      name: 'Sarah Logan',
      palette: 'sage',
      group: 'Needs follow-up',
      snippet: 'Brother-in-law named CTO at Cascadia…',
      due: '2 wk',
    ),
    ContactModel(
      name: 'Marcus Reyes',
      palette: 'forest',
      group: 'Needs follow-up',
      snippet: 'Asked about a fundraising intro',
      due: '3 d',
    ),
    ContactModel(
      name: 'Priya Nathan',
      palette: 'moss',
      group: 'Needs follow-up',
      snippet: 'Promised to send the Q3 brief',
      due: '5 d',
    ),
    ContactModel(
      name: 'Jonas Weil',
      palette: 'fern',
      group: 'This week',
      snippet: "Lunch on Thursday at Saint Mark's",
    ),
    ContactModel(
      name: 'Aisha Patel',
      palette: 'pine',
      group: 'This week',
      snippet: 'Birthday on Friday',
    ),
    ContactModel(
      name: 'Tom Logan',
      palette: 'sage',
      group: 'Recently added',
      snippet: 'New — CTO, Cascadia Health Network',
    ),
    ContactModel(
      name: 'Devi Krishnan',
      palette: 'forest',
      group: 'Recently added',
      snippet: 'Met at the Aspen retreat',
    ),
  ];

  static const _details = ContactModel(
    name: 'Sarah Logan',
    starred: true,
    palette: 'sage',
    timelineItems: [
      TimelineItemModel(
        icon: 'spark',
        when: 'Yesterday · 7:42pm',
        text: "You noted her brother-in-law Tom was named CTO of Cascadia Health Network. "
            "Potential healthcare entry — follow up in 2 weeks.",
      ),
      TimelineItemModel(
        icon: 'msg',
        when: 'Mar 14',
        text: "Caught up over coffee at Alma. She's leading a new product pod and wants "
            "intros to Series-B founders.",
      ),
      TimelineItemModel(
        icon: 'gift',
        when: 'Feb 03',
        text: 'Sent flowers for her promotion. She replied with a photo and a thank-you.',
      ),
      TimelineItemModel(
        icon: 'thread',
        when: 'Jan 18',
        text: 'Email thread — introduced her to Priya. The two ended up co-hosting a workshop in March.',
      ),
    ],
    reminderItems: [
      ReminderModel(text: 'Follow up on Tom — Cascadia Health intro', due: 'In 2 weeks'),
      ReminderModel(text: 'Send the Q3 healthcare brief', due: 'May 24'),
      ReminderModel(text: 'Birthday — think of a gift', due: 'Jul 09'),
    ],
    detailItems: [
      ContactDetailModel(icon: 'briefcase', label: 'Role', value: 'VP Product, Lattice Group'),
      ContactDetailModel(icon: 'tag', label: 'Context', value: 'College roommate · mentor'),
      ContactDetailModel(icon: 'calendar', label: 'Birthday', value: 'July 9'),
      ContactDetailModel(
        icon: 'people',
        label: 'Connections',
        value: 'Tom Logan (CTO, Cascadia) · Priya N.',
      ),
    ],
  );

  static const _suggestions = [
    'Who should I follow up with?',
    'Find new contacts',
    'Brief me before my 3pm',
    "What's Sarah up to?",
    'Draft a thank-you note',
  ];

  @override
  Future<List<ContactModel>> getContacts() async => _contacts;

  @override
  Future<ContactModel> getContactByName(String name) async {
    if (name == _details.name) return _details;
    final match = _contacts.where((c) => c.name == name).firstOrNull;
    if (match == null) throw Exception('Contact not found: $name');
    return match;
  }

  @override
  Future<List<String>> getSuggestions() async => _suggestions;
}
