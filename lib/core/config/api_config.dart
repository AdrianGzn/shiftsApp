/// Configuración centralizada de la API.
/// Aquí se define la URL base del servidor desplegado.
class ApiConfig {
  /// URL base de la API REST desplegada.
  /// Cambiar esta URL al dominio de producción cuando se despliegue.
  static const String baseUrl = 'https://adri-web.icu';

  /// Timeout en segundos para las peticiones HTTP.
  static const int timeoutSeconds = 30;
}
