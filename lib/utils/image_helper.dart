import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  /// Menampilkan gambar dari data Firestore (Base64 atau URL)
  static Widget showImage(Map<String, dynamic> data, 
      {double? width, double? height, double borderRadius = 10, BoxFit fit = BoxFit.cover}) {
    
    // Cek apakah ada imageBase64
    if (data.containsKey('imageBase64') && data['imageBase64'] != null && data['imageBase64'].toString().isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(data['imageBase64'].toString());
        
        Widget image = Image.memory(
          bytes, 
          fit: fit,
          // ✅ Jika infinity, jangan dikasih width/height, biar pakai constraint parent
          width: (width != null && width != double.infinity) ? width : null,
          height: (height != null && height != double.infinity) ? height : null,
          errorBuilder: (_, __, ___) => _buildPlaceholder(width, height, borderRadius),
        );

        // Hanya bungkus ClipRRect jika borderRadius > 0
        if (borderRadius > 0) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: image,
          );
        }
        return image;
      } catch (e) {
        return _buildPlaceholder(width, height, borderRadius);
      }
    }
    
    // Fallback ke imageUrl lama (kalau ada)
    if (data.containsKey('imageUrl') && data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
      Widget image = Image.network(
        data['imageUrl'].toString(), 
        fit: fit,
        width: (width != null && width != double.infinity) ? width : null,
        height: (height != null && height != double.infinity) ? height : null,
        errorBuilder: (_, __, ___) => _buildPlaceholder(width, height, borderRadius),
      );

      if (borderRadius > 0) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: image,
        );
      }
      return image;
    }

    return _buildPlaceholder(width, height, borderRadius);
  }

  static Widget _buildPlaceholder(double? width, double? height, double borderRadius) {
    return Container(
      width: (width != null && width != double.infinity) ? width : null,
      height: (height != null && height != double.infinity) ? height : null,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(child: Icon(Icons.pets, color: Color(0xFFFFB5A7), size: 20)),
    );
  }
}