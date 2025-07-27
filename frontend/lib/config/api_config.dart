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
  static const String mediaById = '/media/'; // Append ID when using
  static const String mediaFilter = '/media/filter';
  static const String mediaFilterPaged = '/media/filter/paged';
  static const String mediaGrouped = '/media/grouped';
  static const String mediaGroupedPaged = '/media/grouped/paged';
  static const String mediaByTags = '/media/by-tags';
  static const String mediaByTagsPaged = '/media/by-tags/paged';
  static const String mediaSearch = '/media/search';
  static const String mediaSearchPaged = '/media/search/paged';
  static const String mediaStats = '/media/stats';
  static const String mediaUpload = '/media/upload';

  // Storage endpoints
  static const String storage = '/storage';
  static const String storageById = '/storage/'; // Append ID when using
  static const String storageTest = '/storage/test/'; // Append ID when using

  // Tag endpoints
  static const String tags = '/tags';
  static const String tagById = '/tags/'; // Append ID when using
  static const String tagByName = '/tags/name/'; // Append name when using

  // User endpoints
  static const String users = '/users';
  static const String userById = '/users/'; // Append ID when using
  static const String userByEmail = '/users/email/'; // Append email when using

  // System endpoints
  static const String validation = '/validation';
  static const String validationHealth = '/validation/health';
  static const String validationFeatures = '/validation/features';
  static const String demo = '/demo';
  static const String demoCreate = '/demo/create';
  static const String demoClear = '/demo/clear';
  static const String apiInfo = '/info';

  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
