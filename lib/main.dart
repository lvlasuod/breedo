import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite/tflite.dart';
import '../constants.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final ImagePicker _picker = ImagePicker();
  File? _image;
  List? _result;

  @override
  void initState() {

    super.initState();
    loadModelData().then((output) {
//after loading models, rebuild the UI.
      setState(() {});
    });
  }
  loadModelData() async {
   //tensorflow lite plugin loads models and labels.
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _image != null ? testImage(size, _image) : titleContent(size),
            SizedBox(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  galleryOrCamera(Icons.camera, ImageSource.camera),
                  galleryOrCamera(Icons.photo_album, ImageSource.gallery),
                ]
            ),

            SizedBox(height: 50),
            _result != null
                ? Text(
             // '$_result',
              'It\'s a ${_result![0]['label']}.',
              style: GoogleFonts.openSansCondensed(
              fontWeight: FontWeight.bold,
               fontSize: 30,
              ),
            )
                : Text(
              '1. Select or Capture the image. \n\n2. Tap the submit button.',
              style: GoogleFonts.openSans(fontSize: 16),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  elevation: 4,
                  primary: Colors.grey[300],
                ),
                onPressed:detectDogOrCat,
                //             onPressed: detectDogOrCat,
                child: Text(
                  'Breedo',
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontWeight: bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 45),
            Text(
              'copyright mpdev.com',
              style: TextStyle(
                fontWeight: bold,
              ),
            ),

          ],
        ),
      ),
    );
  }

  Container titleContent(Size size) {
    return Container(
//contains 55% of the screen height.
      height: size.height * 0.55,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/pet.png"),
          fit: BoxFit.cover,
          scale: 0.2,
//black overlay filter
         // colorFilter: filter,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 250,
            ),
            Container(
              color: Colors.black.withOpacity(0.6),
              padding: EdgeInsets.all(5),
              child: Text(
                'BREEDO',
                style: GoogleFonts.roboto(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: bold,
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.6),
              padding: EdgeInsets.all(5),
              child: Text(
                'Flutter Machine Learning App',
                style: GoogleFonts.openSansCondensed(
                  fontWeight: bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

  MaterialButton galleryOrCamera(IconData icon, ImageSource imageSource) {
    return MaterialButton(
      padding: EdgeInsets.all(14.0),
      elevation: 5,
      color: Colors.grey[300],
      onPressed: () {
        _getImage(imageSource);
      },
      child: Icon(
        icon,
        size: 20,
        color: Colors.grey[800],
      ),
      shape: CircleBorder(),
    );
  }

  _getImage(ImageSource imageSource) async {
//accessing image from Gallery or Camera.
    final XFile? image = await _picker.pickImage(source: imageSource);
//image is null, then return
    if (image == null) return;
    setState(() {
      _image = File(image.path);
      _result = null;
    });

  }

  Widget testImage(size, image) {
    return Container(
      height: size.height * 0.55,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(
            image!,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void detectDogOrCat() async {
    if (_image != null) {
      try {
        _result = await Tflite.runModelOnImage(
          path: _image!.path,
          numResults: 2,
          threshold: 0.6,
          imageMean: 127.5,
          imageStd: 127.5,
        );
      } catch (e) {}

      setState(() {});
    }
  }

}