import 'dart:io';
import 'package:flutter/material.dart';
import 'db_helper.dart';



class GalleryScreen extends StatefulWidget {
  const  GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> photos = [];

  @override
  void initState() {
    super.initState(); 
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    final data = await dbHelper.getPhotos();
    setState(() {
      photos = data;
    });
  }

  void deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text("Delete Photo"),
      
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              //  Delete from database
              await dbHelper.deletePhoto(photos[index]['id']);

              //  Delete file from storage
              File(photos[index]['path']).deleteSync();

              Navigator.pop(context);
              loadPhotos(); // refresh UI
            },
            child:  Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Saved Photos"),
        centerTitle: true,
      ),
      body: photos.isEmpty
          ?  Center(
              child: Text(
                "No photos saved yet",
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding:  EdgeInsets.all(10),
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () => deletePhoto(index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photos[index]['path']),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
