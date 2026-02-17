/// Animation duration & curve presets for the Faani design system.
abstract final class AppAnimations {
  // ── Durations ──────────────────────────────────────────────────────
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration slower = Duration(milliseconds: 600);

  // ── Page transitions ───────────────────────────────────────────────
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration bottomSheet = Duration(milliseconds: 350);
  static const Duration dialog = Duration(milliseconds: 250);
}
