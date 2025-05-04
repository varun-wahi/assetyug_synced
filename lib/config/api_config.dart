// core/config/api_config.dart
class ApiConfig {
  // static const String _baseUrl = 'http://assetyug-lb-632006544.us-east-1.elb.amazonaws.com:8080/';
  static const String _baseUrl = 'http://assetyug-lb-551711242.us-east-1.elb.amazonaws.com:8080/';

  static String get baseUrl => _baseUrl;
}
// http://assetyug-lb-551711242.us-east-1.elb.amazonaws.com:8080/assets/advanceFilter/0/10?category=&search=&asc=true
// http://assetyug-lb-551711242.us-east-1.elb.amazonaws.com:8080/assets/advanceFilter/0/10?category=&search=null&asc=true