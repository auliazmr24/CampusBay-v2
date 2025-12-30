import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // PENTING: Ganti sesuai environment
  // Android Emulator → 192.168.1.8
  // iOS Simulator → localhost
  // Real Device → IP komputer (misal 192.168.1.5)
  static const String baseUrl = "http://192.168.1.8:3000";
  
  // Client dengan cookie support untuk session
  static final http.Client _client = http.Client();
  static String? _sessionCookie;

  // Helper: Tambahkan cookie ke header
  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
    }
    return headers;
  }

  // Helper: Simpan session cookie dari response
  static void _saveCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      _sessionCookie = rawCookie.split(';')[0]; // Ambil cookie utama
    }
  }

  // ============================================
  // AUTH METHODS
  // ============================================

  /// Register user baru
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String campus,
    String? major,
    String? year,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'campus': campus,
          'major': major,
          'year': year,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _saveCookie(response); // Simpan session
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registrasi gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _saveCookie(response); // Simpan session
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _sessionCookie = null; // Hapus session local
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Logout gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Get current user info
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal ambil user'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Check apakah user masih login (ada session aktif)
  static Future<bool> isLoggedIn() async {
    if (_sessionCookie == null) return false;
    
    final result = await getCurrentUser();
    return result['success'] == true;
  }

  // ============================================
  // PRODUCT METHODS
  // ============================================

  /// Get all products (public)
  static Future<List<dynamic>> getProducts({
    String? category,
    String? campus,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category != 'Semua') queryParams['category'] = category;
      if (campus != null) queryParams['campus'] = campus;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      
      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      } else {
        throw Exception('Gagal load produk');
      }
    } catch (e) {
      throw Exception('Koneksi error: $e');
    }
  }

  /// Get product detail by ID
  static Future<Map<String, dynamic>> getProductById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['product']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Produk tidak ditemukan'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Add new product (require login)
  static Future<Map<String, dynamic>> addProduct({
    required String title,
    required int price,
    required String category,
    required String campus,
    String? description,
    String? condition,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/products'),
        headers: _getHeaders(),
        body: jsonEncode({
          'title': title,
          'price': price,
          'category': category,
          'campus': campus,
          'description': description,
          'condition': condition,
          'image_url': imageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal tambah produk'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Get my products (require login)
  static Future<List<dynamic>> getMyProducts() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/products/my/listings'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      } else {
        throw Exception('Gagal load produk Anda');
      }
    } catch (e) {
      throw Exception('Koneksi error: $e');
    }
  }

  /// Update product (require login + ownership)
  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String title,
    required int price,
    required String category,
    String? description,
    String? condition,
    String? imageUrl,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: _getHeaders(),
        body: jsonEncode({
          'title': title,
          'price': price,
          'category': category,
          'description': description,
          'condition': condition,
          'image_url': imageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal update produk'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Delete product (require login + ownership)
  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal hapus produk'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Mark product as sold
  static Future<Map<String, dynamic>> markAsSold(int id) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/products/$id/sold'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal update status'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Clear session (untuk force logout)
  static void clearSession() {
    _sessionCookie = null;
  }

  /// Check if has active session
  static bool hasSession() {
    return _sessionCookie != null;
  }
}