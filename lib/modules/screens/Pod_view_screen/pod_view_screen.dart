import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PodViewScreen extends StatelessWidget {
  final String? podImage;
  final String? fileName;
  const PodViewScreen({super.key, this.podImage, this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "POD View",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE30613),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [

          GestureDetector(
              onTap: (){
                downloadImage(podImage!, "${fileName}");
              },
              child: Icon(Icons.download)),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(
          podImage ?? "",
          width: Get.width,
          fit: BoxFit.fitWidth, // better than fill (avoids stretching)
          // shows loader while fetching image
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child; // finished loading
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          // shows fallback if image fails
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }


  Future<void> downloadImage(String imageUrl, String fileName) async {
    Directory? directory = await getExternalStorageDirectory();

    String newPath = "";
    List<String> paths = directory!.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }
    newPath = "$newPath/CTS";
    directory = Directory(newPath);

    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    if (!directory.existsSync()) {
      try {
        directory.createSync(recursive: true);
      } catch (e) {
        print("Directory error: $e");
      }
    }

    if (await directory.exists()) {
      try {
        // 🔹 Network se image fetch
        http.Response response = await http.get(Uri.parse(imageUrl));
        Uint8List bytes = response.bodyBytes;

        // 🔹 File banake save karna
        File file = File("${directory.path}/$fileName.jpg");
        await file.writeAsBytes(bytes);

        Get.snackbar(
          "Image Downloaded Successfully",
          "",
          icon: const Icon(Icons.image, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        print("Image download error: $e");
      }
    }
  }

}