import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class Assigmentweek5 extends StatefulWidget {
  const Assigmentweek5({super.key});

  @override
  State<Assigmentweek5> createState() => _Assigmentweek5State();
}

class _Assigmentweek5State extends State<Assigmentweek5> {
  final String baseUrl = 'http://localhost:8001';
  List<Product> products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => _isLoading = true);
    try {
      var response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          products = jsonList.map((e) => Product.fromJson(e)).toList();
        });
      } else {
        _showSnackBar('Failed to load products', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode == 201) {
        _showSnackBar('Product created!');
        fetchData();
      } else {
        _showSnackBar('Failed to create product', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      var response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode == 200) {
        _showSnackBar('Product updated!');
        fetchData();
      } else {
        _showSnackBar('Failed to update product', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      var response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        _showSnackBar('Product deleted!');
        fetchData();
      } else {
        _showSnackBar('Failed to delete product', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Do you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteProduct(product.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showProductFormDialog({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newProduct = Product(
                id: product?.id ?? '',
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
              );
              if (product == null) {
                createProduct(newProduct);
              } else {
                updateProduct(newProduct);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: const Color.fromARGB(255, 0, 195, 255),
        actions: [
          IconButton(onPressed: fetchData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.grey),
              itemBuilder: (_, index) {
                final product = products[index];
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(product.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(1)} ฿',
                        style: const TextStyle(color: Colors.green),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(product),
                      ),
                    ],
                  ),
                  onTap: () => _showProductFormDialog(product: product),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'price': price};
  }
}
