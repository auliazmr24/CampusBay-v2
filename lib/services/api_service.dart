import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      // Untuk Chrome/Web Browser
      return "http://localhost:3000/api";
    } else {
      return "http://192.168.100.20:3000/api";
    }
  }

  // Base URL untuk gambar
  static String get baseUrlImage {
    if (kIsWeb) {
      return "http://localhost:3000";
    } else {
      return "http://192.168.100.20:3000";
    }
  }

  // Client dengan cookie support untuk session
  static final http.Client _client = http.Client();
  static String? _sessionCookie;

  // Helper: Tambahkan cookie ke header
  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
    }
    return headers;
  }

  // Helper: Simpan session cookie dari response
  static void _saveCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      _sessionCookie = rawCookie.split(';')[0];
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
        _saveCookie(response);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
        };
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
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _saveCookie(response);
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
        _sessionCookie = null;
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
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal ambil user',
        };
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
      if (category != null && category != 'Semua') {
        queryParams['category'] = category;
      }
      if (campus != null) queryParams['campus'] = campus;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await _client.get(uri, headers: _getHeaders());

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
        return {
          'success': false,
          'message': data['message'] ?? 'Produk tidak ditemukan',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  /// Add new product (require login) - DENGAN UPLOAD GAMBAR
  static Future<Map<String, dynamic>> addProduct({
    required String title,
    required int price,
    required String category,
    required String campus,
    String? description,
    String? condition,
    File? imageFile,
  }) async {
    try {
      // Gunakan MultipartRequest untuk upload file
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products'),
      );

      // Tambahkan Cookie Session ke Headers
      if (_sessionCookie != null) {
        request.headers['Cookie'] = _sessionCookie!;
      }

      // Tambahkan Text Fields
      request.fields['title'] = title;
      request.fields['price'] = price.toString();
      request.fields['category'] = category;
      request.fields['campus'] = campus;
      if (description != null) request.fields['description'] = description;
      if (condition != null) request.fields['condition'] = condition;

      // Tambahkan File Gambar (Jika ada)
      if (imageFile != null) {
        // Cek ekstensi file manual atau pakai package mime
        String mimeType = 'image/jpeg'; // Default fallback
        if (imageFile.path.endsWith('.png')) mimeType = 'image/png';

        var pic = await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(pic);
      }

      // Kirim Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal tambah produk',
        };
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

  /// Update product (require login + ownership) - DENGAN UPLOAD GAMBAR
  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String title,
    required int price,
    required String category,
    String? description,
    String? condition,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/products/$id'),
      );

      // Tambahkan Cookie Session
      if (_sessionCookie != null) {
        request.headers['Cookie'] = _sessionCookie!;
      }

      // Tambahkan Text Fields
      request.fields['title'] = title;
      request.fields['price'] = price.toString();
      request.fields['category'] = category;
      if (description != null) request.fields['description'] = description;
      if (condition != null) request.fields['condition'] = condition;

      // Tambahkan File Gambar Baru (Jika ada)
      if (imageFile != null) {
        var pic = await http.MultipartFile.fromPath('image', imageFile.path);
        request.files.add(pic);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal update produk',
        };
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
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal hapus produk',
        };
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
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal update status',
        };
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

  /// Helper untuk mendapatkan full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return empty jika tidak ada gambar
    }

    // Jika sudah full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Jika path relatif, gabungkan dengan baseUrl
    return '$baseUrlImage$imagePath';
  }

  // --- CART FEATURES ---
  
  // Ambil data keranjang (Hardcode user_id = 1 untuk demo)
  static Future<List<dynamic>> getCart() async {
    try {
      // FIX: Menghapus /api yang berlebih
      final response = await http.get(Uri.parse('$baseUrl/cart/1'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    }
    return [];
  }

  // Tambah ke keranjang
  static Future<bool> addToCart(int productId) async {
    try {
      // FIX: Menghapus /api yang berlebih
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': 1, 'product_id': productId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Hapus dari keranjang
  static Future<bool> removeFromCart(int cartId) async {
    try {
      // FIX: Menghapus /api yang berlebih
      final response = await http.delete(Uri.parse('$baseUrl/cart/$cartId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}