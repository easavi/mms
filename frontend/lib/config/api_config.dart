enum Environment {
  dev,
  prod,
}

class ApiConfig {
  static Environment _environment = Environment.dev;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://localhost:8080/api';
      case Environment.prod:
        return 'https://your-production-domain.com/api'; // Replace with your production API domain
    }
  }
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  
  // Media endpoints
  static const String media = '/media';
  static const String mediaUpload = '/media';
  static const String mediaById = '/media/'; // Append ID when using

  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
