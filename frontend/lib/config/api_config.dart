enum Environment {
  dev,
  devMobile,
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
        return 'http://localhost:8080';
      case Environment.devMobile:
        return 'http://10.0.2.2:8080'; // Android emulator host IP
      case Environment.prod:
        return 'https://your-production-domain.com'; // Replace with your production API domain
    }
  }
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  
  // Media endpoints
  static const String media = '/api/media';
  static const String mediaById = '/api/media/'; // Append ID when using
  static const String mediaUpload = '/api/media/upload';
  static const String mediaThumbnail = '/api/media/thumbnail/'; // Append ID when using
  static const String mediaThumbnailByBucket = '/api/media/thumbnail'; // Use with bucket and fileId params

  // Storage endpoints
  static const String storage = '/api/storage';
  static const String storageById = '/api/storage/'; // Append ID when using
  static const String storageTest = '/api/storage/test/'; // Append ID when using

  // Tag endpoints
  static const String tags = '/api/tags';
  static const String tagById = '/api/tags/'; // Append ID when using
  static const String tagByName = '/api/tags/name/'; // Append name when using

  // User endpoints
  static const String users = '/api/users';
  static const String userById = '/api/users/'; // Append ID when using
  static const String userByEmail = '/api/users/email/'; // Append email when using

  // System endpoints
  static const String validation = '/api/validation';
  static const String validationHealth = '/api/validation/health';
  static const String validationFeatures = '/api/validation/features';
  static const String demo = '/api/demo';
  static const String demoCreate = '/api/demo/create';
  static const String demoClear = '/api/demo/clear';
  static const String apiInfo = '/api/info';

  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
