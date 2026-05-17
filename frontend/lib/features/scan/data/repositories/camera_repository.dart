import 'package:camera/camera.dart';

class CameraRepository {
  const CameraRepository();

  Future<List<CameraDescription>> getAvailableCameras() {
    return availableCameras();
  }

  CameraDescription? getBackCamera(List<CameraDescription> cameras) {
    for (final camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        return camera;
      }
    }

    return cameras.isNotEmpty ? cameras.first : null;
  }
}