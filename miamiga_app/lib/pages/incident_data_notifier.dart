import 'package:flutter/material.dart';
import 'package:miamiga_app/model/datos_incidente.dart';

class IncidentDataNotifier extends ChangeNotifier {
  IncidentData _incidentData;

  IncidentDataNotifier(this._incidentData);

  IncidentData get incidentData => _incidentData;

  set incidentData(IncidentData value) {
    _incidentData = value;
    notifyListeners();
  }
}