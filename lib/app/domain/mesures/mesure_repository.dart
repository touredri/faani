import 'package:faani/app/data/models/mesure_model.dart';

abstract interface class MesureRepository {
  Future<String> create(Mesure mesure);
}
