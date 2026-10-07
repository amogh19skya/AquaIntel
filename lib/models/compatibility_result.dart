/// Holds the result of a compatibility check between two fish species.
///
/// This model is the single output object from [CompatibilityService] and
/// the single input consumed by the Compatibility Checker UI.
/// The UI should only *display* values from this model — all calculations
/// are performed inside the service.
class CompatibilityResult {
  // ─── Overall score & status ────────────────────────────────────────────────

  /// Overall compatibility score on a 0–100 scale.
  final int score;

  /// Short human-readable summary of the overall result.
  ///
  /// Examples: "Highly Compatible", "Moderate Compatibility", "Not Compatible".
  final String status;

  // ─── Temperature ──────────────────────────────────────────────────────────

  /// "Compatible", "Caution", or "Incompatible".
  final String temperatureStatus;

  /// User-facing explanation of the temperature comparison.
  final String temperatureMessage;

  // ─── pH ───────────────────────────────────────────────────────────────────

  /// "Compatible", "Caution", or "Incompatible".
  final String phStatus;

  /// User-facing explanation of the pH comparison.
  final String phMessage;

  // ─── Temperament ──────────────────────────────────────────────────────────

  /// "Compatible", "Caution", or "Incompatible".
  final String temperamentStatus;

  /// User-facing explanation of the temperament comparison.
  final String temperamentMessage;

  // ─── Tank size ────────────────────────────────────────────────────────────

  /// "Compatible", "Caution", or "Incompatible".
  final String tankSizeStatus;

  /// User-facing explanation of tank size requirements.
  final String tankSizeMessage;

  // ─── Recommendation ───────────────────────────────────────────────────────

  /// Overall keeper recommendation shown in the Recommendation card.
  final String recommendation;

  const CompatibilityResult({
    required this.score,
    required this.status,
    required this.temperatureStatus,
    required this.temperatureMessage,
    required this.phStatus,
    required this.phMessage,
    required this.temperamentStatus,
    required this.temperamentMessage,
    required this.tankSizeStatus,
    required this.tankSizeMessage,
    required this.recommendation,
  });

  // ─── Convenience helpers ──────────────────────────────────────────────────

  /// Returns true when the overall score is 75 or higher.
  bool get isHighlyCompatible => score >= 75;

  /// Returns true when the overall score is below 40.
  bool get isIncompatible => score < 40;

  @override
  String toString() =>
      'CompatibilityResult(score: $score, status: $status)';
}
