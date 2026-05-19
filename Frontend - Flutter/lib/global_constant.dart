class GlobalConstant {
  GlobalConstant._();

  static const isRelease = true;

  static const backendUrl = isRelease
      ? 'https://api.servicesai.chainspair.com'
      : 'http://192.168.1.5:8000';
}
