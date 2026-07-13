import 'package:get/get.dart';

/// Chaînes visibles du parcours mesures/caméra.
abstract final class MesureStrings {
  static String t(String key, {required String fallback}) {
    final value = key.tr;
    return value == key ? fallback : value;
  }

  static String guidance(String messageKey) {
    const fallbacks = {
      'mesures_camera_guidance_move_closer': 'Avancez légèrement',
      'mesures_camera_guidance_move_back': 'Reculez légèrement',
      'mesures_camera_guidance_raise_phone': 'Relevez le téléphone',
      'mesures_camera_guidance_lower_phone': 'Abaissez le téléphone',
      'mesures_camera_guidance_center_body': 'Centrez-vous dans le cadre',
      'mesures_camera_guidance_body_incomplete':
          'Corps incomplet : reculez ou incluez tête et pieds',
      'mesures_camera_guidance_pose_not_detected': 'Aucune silhouette détectée',
      'mesures_camera_guidance_stay_still': 'Restez immobile…',
      'mesures_camera_guidance_ready': 'Parfait, restez dans le cadre',
      'mesures_camera_guidance_none': '',
    };
    return t(messageKey, fallback: fallbacks[messageKey] ?? messageKey);
  }
}
