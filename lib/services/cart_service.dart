import 'package:flutter/material.dart';

// ✅ Global Cart Service
class CartService {
  // List keranjang global
  static final List<Map<String, dynamic>> cartItems = [];

  // Hitung total item
  static int get cartCount => cartItems.length;

  // Tambah item
  static void addToCart(Map<String, dynamic> item) {
    cartItems.add(item);
  }

  // Hapus semua item (setelah checkout)
  static void clearCart() {
    cartItems.clear();
  }

  // Hitung total harga
  static int get totalPrice {
    int total = 0;
    for (var item in cartItems) {
      total += (item['price'] as int) * (item['qty'] as int);
    }
    return total;
  }

  // Ubah Qty
  static void incrementQty(int index) {
    cartItems[index]['qty'] = (cartItems[index]['qty'] as int) + 1;
  }

  static void decrementQty(int index) {
    if (cartItems[index]['qty'] == 1) {
      cartItems.removeAt(index);
    } else {
      cartItems[index]['qty'] = (cartItems[index]['qty'] as int) - 1;
    }
  }
}