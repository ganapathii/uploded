import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:media/datalist.dart';
import 'package:media/login.dart';

class CreateProductPage extends StatefulWidget {
  final String token;

  CreateProductPage({required this.token});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final TextEditingController productCodeController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController purchaseRateController = TextEditingController();
  final TextEditingController salesRateController = TextEditingController();
  File? mediaFile;

  Future<void> pickMedia() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        mediaFile = File(pickedFile.path);
      });
    }
  }

  Future<void> addProduct() async {
    if (productCodeController.text.isEmpty ||
        productNameController.text.isEmpty ||
        mrpController.text.isEmpty ||
        purchaseRateController.text.isEmpty ||
        salesRateController.text.isEmpty ||
        mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields and select an image/video.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = "https://spotit.cloud/interview/api/products/create";
    final Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.token}",
    };

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll(headers);

    request.fields['ProductCode'] = productCodeController.text;
    request.fields['ProductName'] = productNameController.text;
    request.fields['MRP'] = mrpController.text;
    request.fields['PurchaseRate'] = purchaseRateController.text;
    request.fields['SalesRate'] = salesRateController.text;

    if (mediaFile != null) {
      var file =
          await http.MultipartFile.fromPath('ProductImage', mediaFile!.path);
      request.files.add(file);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image/video.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListPage(token: widget.token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to add the product. Status code: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        title: Text(
          'Post Product',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your details",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 6),
            Container(
              height: 1,
              color: Color.fromARGB(255, 44, 44, 44),
            ),
            SizedBox(height: 16),
            Text(
              "Product Code",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: productCodeController,
              decoration: InputDecoration(
                labelText: "PRDTSLNO1256987",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Product Name",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            SizedBox(
              height: 4,
            ),
            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: "Enter your product Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Text(
              "MRP",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            SizedBox(
              height: 4,
            ),
            TextField(
              controller: mrpController,
              decoration: InputDecoration(
                labelText: "Enter mrp",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Text(
              "Purchase Rate",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            SizedBox(
              height: 4,
            ),
            TextField(
              controller: purchaseRateController,
              decoration: InputDecoration(
                labelText: "Enter purchase rate",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Text(
              "Sales Rate",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
            SizedBox(
              height: 4,
            ),
            TextField(
              controller: salesRateController,
              decoration: InputDecoration(
                labelText: "Enter sales rate",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              width: 400,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                color: Colors.red,
                strokeWidth: 2,
                child: ElevatedButton(
                  onPressed: pickMedia,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.all(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Upload product image/video",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (mediaFile != null) Image.file(mediaFile!),
            SizedBox(height: 16),
            Container(
              height: 50,
              width: 400,
              child: ElevatedButton(
                onPressed: addProduct,
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Post',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.send_sharp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
