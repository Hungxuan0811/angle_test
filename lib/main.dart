import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' as math;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Warrior2ThreeScreen(),
    );
  }
}

class Warrior2ThreeScreen extends StatefulWidget {
  @override
  _Warrior2ThreeScreenState createState() => _Warrior2ThreeScreenState();
}

class _Warrior2ThreeScreenState extends State<Warrior2ThreeScreen> {
  late File _image;
  bool _imageSelected = false;
  String detectionTime = '';
  String angleAndPoseTime = '';
  String imagePickerTime = '';
  String fileLoadTime = '';
  String inputImageTime = '';
  String totalTime = '';
  String cpuUsage = 'CPU Usage: N/A';
  late PoseDetector _poseDetector;
  Map<String, int> angles = {};
  String poseResult = '';

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
  }

  Future<void> _pickAndProcessImage() async {
    final totalStopwatch = Stopwatch()..start();
    final imagePickerStopwatch = Stopwatch()..start();

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    imagePickerStopwatch.stop();

    if (pickedFile != null) {
      final fileLoadStopwatch = Stopwatch()..start();
      setState(() {
        _image = File(pickedFile.path);
        _imageSelected = true;
      });
      fileLoadStopwatch.stop();

      final inputImageStopwatch = Stopwatch()..start();
      final inputImage = InputImage.fromFilePath(_image.path);
      inputImageStopwatch.stop();

      try {
        final detectionStopwatch = Stopwatch()..start();
        final List<Pose> detectedPoses =
            await _poseDetector.processImage(inputImage);
        detectionStopwatch.stop();

        final angleAndPoseStopwatch = Stopwatch()..start();
        if (detectedPoses.isNotEmpty) {
          calculateAngles(detectedPoses.first);
          checkWarrior2ThreePose();
        }
        angleAndPoseStopwatch.stop();

        totalStopwatch.stop();

        setState(() {
          imagePickerTime =
              'Image picker time: ${imagePickerStopwatch.elapsedMilliseconds} ms';
          fileLoadTime =
              'File load time: ${fileLoadStopwatch.elapsedMilliseconds} ms';
          inputImageTime =
              'Input image creation time: ${inputImageStopwatch.elapsedMilliseconds} ms';
          detectionTime =
              'Detection time: ${detectionStopwatch.elapsedMilliseconds} ms';
          angleAndPoseTime =
              'Angle and pose time: ${angleAndPoseStopwatch.elapsedMicroseconds / 1000.0} ms';
          totalTime = 'Total time: ${totalStopwatch.elapsedMilliseconds} ms';
        });
      } catch (e) {
        print("Error detecting pose: $e");
      }
    }
  }

  void calculateAngles(Pose pose) {
    angles.clear();

    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final rightIndex = pose.landmarks[PoseLandmarkType.rightIndex];
    final rightFootIndex = pose.landmarks[PoseLandmarkType.rightFootIndex];

    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final leftIndex = pose.landmarks[PoseLandmarkType.leftIndex];
    final leftFootIndex = pose.landmarks[PoseLandmarkType.leftFootIndex];

    /*右手腕 */
    if (rightIndex != null && rightWrist != null && rightElbow != null) {
      final int r_wrist = getAngle(rightIndex, rightWrist, rightElbow).round();
      angles['r_wrist'] = r_wrist;
    }
    /*右手肘 */
    if (rightWrist != null && rightElbow != null && rightShoulder != null) {
      final int r_elbow =
          getAngle(rightWrist, rightElbow, rightShoulder).round();
      angles['r_elbow'] = r_elbow;
    }
    /*右肩膀 */
    if (rightElbow != null && rightShoulder != null && rightHip != null) {
      final int r_shoulder =
          getAngle(rightElbow, rightShoulder, rightHip).round();
      angles['r_shoulder'] = r_shoulder;
    }
    /*右髖部 */
    if (rightShoulder != null && rightHip != null && rightKnee != null) {
      final int r_hip = getAngle(rightShoulder, rightHip, rightKnee).round();
      angles['r_hip'] = r_hip;
    }
    /*右膝蓋 */
    if (rightHip != null && rightKnee != null && rightAnkle != null) {
      final int r_knee = getAngle(rightHip, rightKnee, rightAnkle).round();
      angles['r_knee'] = r_knee;
    }
    /*右腳趾 */
    if (rightKnee != null && rightAnkle != null && rightFootIndex != null) {
      final int r_footindex =
          getAngle(rightKnee, rightAnkle, rightFootIndex).round();
      angles['r_footindex'] = r_footindex;
    }
    /*左手腕 */
    if (leftIndex != null && leftWrist != null && leftElbow != null) {
      final int l_wrist = getAngle(leftIndex, leftWrist, leftElbow).round();
      angles['l_wrist'] = l_wrist;
    }
    /*左手肘 */
    if (leftWrist != null && leftElbow != null && leftShoulder != null) {
      final int l_elbow = getAngle(leftWrist, leftElbow, leftShoulder).round();
      angles['l_elbow'] = l_elbow;
    }
    /*左肩膀 */
    if (leftElbow != null && leftShoulder != null && leftHip != null) {
      final int l_shoulder = getAngle(leftElbow, leftShoulder, leftHip).round();
      angles['l_shoulder'] = l_shoulder;
    }
    /*左髖部 */
    if (leftShoulder != null && leftHip != null && leftKnee != null) {
      final int l_hip = getAngle(leftShoulder, leftHip, leftKnee).round();
      angles['l_hip'] = l_hip;
    }
    /*左膝蓋 */
    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      final int l_knee = getAngle(leftHip, leftKnee, leftAnkle).round();
      angles['l_knee'] = l_knee;
    }
    /*左腳趾 */
    if (leftKnee != null && leftAnkle != null && leftFootIndex != null) {
      final int l_footindex =
          getAngle(leftKnee, leftAnkle, leftFootIndex).round();
      angles['l_footindex'] = l_footindex;
    }
  }

  double getAngle(PoseLandmark first, PoseLandmark middle, PoseLandmark last) {
    final double result = math.atan2(last.y - middle.y, last.x - middle.x) -
        math.atan2(first.y - middle.y, first.x - middle.x);
    double angle = result * (180 / math.pi);
    angle = angle.abs();
    if (angle > 180) {
      angle = 360 - angle;
    }
    return angle;
  }

  void checkWarrior2ThreePose() {
    const int r_shoulder_perfect_min = 90;
    const int r_shoulder_good_min = r_shoulder_perfect_min - 10;
    const int r_shoulder_perfect_max = 100;
    const int r_shoulder_good_max = r_shoulder_perfect_max + 10;
    const int r_knee_perfect_min = 125;
    const int r_knee_good_min = r_knee_perfect_min - 5;
    const int r_knee_perfect_max = 140;
    const int r_knee_good_max = r_knee_perfect_max + 5;

    if (angles.containsKey('r_knee') && angles.containsKey('r_shoulder')) {
      int r_knee = angles['r_knee']!;
      int r_shoulder = angles['r_shoulder']!;

      if (r_knee >= r_knee_perfect_min &&
          r_knee <= r_knee_perfect_max &&
          r_shoulder >= r_shoulder_perfect_min &&
          r_shoulder <= r_shoulder_perfect_max) {
        poseResult = 'Perfect Warrior2 Three Pose';
      } else if (r_knee >= r_knee_good_min &&
          r_knee <= r_knee_good_max &&
          r_shoulder >= r_shoulder_good_min &&
          r_shoulder <= r_shoulder_good_max) {
        poseResult = 'Good Warrior2 Three Pose';
      } else {
        poseResult = 'Incorrect Warrior2 Three Pose';
      }
    } else {
      poseResult = 'Unable to determine pose correctness';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Warrior2 Three Pose Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageSelected
                ? Image.file(_image, width: 300, height: 300)
                : Text('No image selected.'),
            ElevatedButton(
              onPressed: _pickAndProcessImage,
              child: Text('Select Image and Analyze Pose'),
            ),
            Text('Angles: ${angles.toString()}'),
            Text(poseResult),
            Text(imagePickerTime),
            Text(fileLoadTime),
            Text(inputImageTime),
            Text(detectionTime),
            Text(angleAndPoseTime),
            Text(totalTime),
            Text(cpuUsage),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _poseDetector.close();
    super.dispose();
  }
}
