enum Categories { securityMgt, safety, enviromentProtec, fireMgt, crisisMgt }

extension CategoriesX on Categories {
  String getCategoryTopicName() {
    switch (this) {
      case Categories.securityMgt:
        return 'SecurityMgt';
      case Categories.safety:
        return 'safety';
      case Categories.enviromentProtec:
        return 'EnvironmentProtec';
      case Categories.fireMgt:
        return 'FireMgt';
      case Categories.crisisMgt:
        return 'CrisisMgt';
    }
  }
}
