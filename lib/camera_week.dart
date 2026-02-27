import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'db_helper.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  int switchCamera = 0;

  final DBHelper dbHelper = DBHelper();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      setupCamera(switchCamera);
    }
  }

  @override
  void initState() {
    setupCamera(switchCamera);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [buidUI()]));
  }

  Widget buidUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 750,
              width: 380,
              child: CameraPreview(cameraController!),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.blue, size: 40),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GalleryScreen(),
                      ),
                    );
                  },
                ),

                IconButton(
                  iconSize: 90,
                  onPressed: () async {
                    XFile picture = await cameraController!.takePicture();
                    await Gal.putImage(picture.path);

                    await dbHelper.insertPhoto(picture.path);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Photo saved successfully")),
                    );
                  },
                  icon: const Icon(Icons.camera, color: Colors.red),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.cameraswitch,
                    size: 35,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (cameras.length > 1) {
                      int newCameraIdx = switchCamera == 0 ? 1 : 0;
                      setState(() {
                        switchCamera = newCameraIdx;
                      });
                      setupCamera(newCameraIdx);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setupCamera([int cameraIndex = 0]) async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController?.dispose();
        cameraController = CameraController(
          _cameras[cameraIndex],
          ResolutionPreset.high,
        );
      });
      cameraController
          ?.initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {});
          })
          .catchError((Object e) {
            print(e);
          });
    }
  }
}
