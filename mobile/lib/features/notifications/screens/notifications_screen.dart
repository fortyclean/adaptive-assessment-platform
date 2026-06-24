import 'advanced_notification_center_screen.dart';

/// Backward-compatible alias for the canonical notification experience.
///
/// All active routes use [AdvancedNotificationCenterScreen]. Keeping this
/// alias prevents older imports from reviving a second notification flow.
@Deprecated('Use AdvancedNotificationCenterScreen instead.')
class NotificationsScreen extends AdvancedNotificationCenterScreen {
  const NotificationsScreen({super.key});
}
