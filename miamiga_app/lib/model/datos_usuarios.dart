class UserData {
  String descripcionIncidente;
  DateTime fechaIncidente;
  double latitude;
  double longitude;
  List<String> imageUrls;
  String audioUrl;

  UserData({
    required this.descripcionIncidente,
    required this.fechaIncidente,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.audioUrl,
  });
}