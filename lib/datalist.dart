import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProductListPage extends StatefulWidget {
  final String token;

  ProductListPage({required this.token});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> productList = [];
  List<String> orderList = [];
  late Timer _timer;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
    fetchProductList(widget.token);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchProductList(widget.token);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchProductList(String token) async {
    final String apiUrl = "https://spotit.cloud/interview/api/products/data";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          setState(() {
            productList = List<Map<String, dynamic>>.from(responseData['data']);
          });
        } else {
          print("Failed to fetch product list. Invalid data format.");
        }
      } else {
        print(
            "Failed to fetch product list. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Network error: $e");
    }
  }

  void searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        productList = List<Map<String, dynamic>>.from(productList);
      } else {
        productList = productList.where((product) {
          final productName = product['ProductName'].toString().toLowerCase();
          return productName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Product List',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          PreferredSize(
            preferredSize: Size.fromHeight(40.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border:
                      Border.all(color: const Color.fromARGB(255, 46, 46, 46)),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (query) {
                    searchProducts(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for products',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(
                            productId: product['ProductCode'],
                            productName: product['ProductName'],
                            salesRate: product['SalesRate'].toDouble(),
                            productImage: product['ProductImage'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                product['ProductImage'],
                                width: 160,
                                height: 82,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Column(
                                    children: [
                                      Icon(Icons.error),
                                      Text("Image not available"),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product['ProductName'],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '₹${product['SalesRate']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              final productName = orderList[index];
              return ListTile(
                title: Text(productName),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  final String productName;
  final double salesRate;
  final String productImage;

  ProductDetailsPage({
    required this.productId,
    required this.productName,
    required this.salesRate,
    required this.productImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Product details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            productImage,
            width: 360,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                children: [
                  Icon(Icons.error),
                  Text("Image not available"),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$productName',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 18,
                ),
                Text(
                  '₹$salesRate',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Product details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  height: 1,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 26,
                ),
                Text(
                  'Product ID     -    $productId',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 92),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 330,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Buy Now',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: 400,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart, size: 24),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
