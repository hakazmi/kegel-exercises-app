import '../../app/l10n/app_localizations.dart';
import 'engine/engine_models.dart';

/// Maps engine [SessionPhaseKey] values to localized player copy.
abstract final class SessionPhaseCopy {
  static String label(AppLocalizations l10n, String key) {
    switch (key) {
      case SessionPhaseKey.getReady:
        return l10n.s2GetReady;
      case SessionPhaseKey.squeeze:
        return l10n.t1PhaseSqueeze;
      case SessionPhaseKey.hold:
        return l10n.s3PhaseHold;
      case SessionPhaseKey.relax:
        return l10n.t1PhaseRelax;
      case SessionPhaseKey.rest:
        return l10n.s3PhaseRest;
      case SessionPhaseKey.breatheIn:
        return l10n.s3PhaseBreatheIn;
      case SessionPhaseKey.breatheOut:
        return l10n.s3PhaseBreatheOut;
      case SessionPhaseKey.done:
        return l10n.s3PhaseDone;
      case SessionPhaseKey.lift:
        return l10n.s3PhaseLift;
      default:
        return key;
    }
  }
}
