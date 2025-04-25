import 'package:flutter/material.dart';
import 'package:smart_lock_pro/theme/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key});

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  final List<RegisteredFace> _registeredFaces = [
    RegisteredFace(name: 'John Doe', isActive: true, imageUrl: null),
    RegisteredFace(name: 'Jane Smith', isActive: true, imageUrl: null),
  ];

  bool _isAddingFace = false;

  // Camera controller
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFrontCameraSelected = true;

  // Face scanning
  bool _isScanning = false;
  int _capturedImages = 0;
  final int _requiredImages = 15;
  List<String> _capturedImagePaths = [];
  String _newUserName = '';

  // Timer for automatic capture
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _captureTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Find front camera
        final frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );

        await _initializeCameraController(frontCamera);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show add face UI if adding a face
    if (_isAddingFace) {
      return _buildAddFaceUI();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Face Recognition', style: AppTheme.headingStyle),
            const SizedBox(height: 8),
            Text(
              'Manage faces that can unlock your door',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 24),

            // Add face button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingFace = true;
                    _isScanning = false;
                    _capturedImages = 0;
                    _capturedImagePaths = [];
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Face'),
              ),
            ),

            const SizedBox(height: 24),

            // Registered faces
            Expanded(
              child:
                  _registeredFaces.isEmpty
                      ? _buildEmptyState()
                      : _buildFacesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.face_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No faces registered yet', style: AppTheme.subheadingStyle),
          const SizedBox(height: 8),
          Text(
            'Add a face to unlock your door with facial recognition',
            style: AppTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFacesList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _registeredFaces.length,
      itemBuilder: (context, index) {
        final face = _registeredFaces[index];
        return _buildFaceCard(face);
      },
    );
  }

  Widget _buildAddFaceUI() {
    // This is a camera view with face detection
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Face'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _stopScanning();
            setState(() {
              _isAddingFace = false;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isScanning ? _buildFaceScanningUI() : _buildCameraSetupUI(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSetupUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Face Registration', style: AppTheme.subheadingStyle),
          const SizedBox(height: 16),
          Text(
            'Please enter your name and prepare to scan your face. We\'ll take 15 images to ensure accurate recognition.',
            style: AppTheme.bodyStyle,
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _newUserName = value;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _newUserName.trim().isNotEmpty
                      ? () {
                        setState(() {
                          _isScanning = true;
                          _capturedImages = 0;
                          _capturedImagePaths = [];
                        });
                        _startFaceScanning();
                      }
                      : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Face Scan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceScanningUI() {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraController!),
        ),

        // Face outline
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(125),
            ),
          ),
        ),

        // Progress indicator
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Keep your face in the circle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: LinearProgressIndicator(
                  value: _capturedImages / _requiredImages,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capturing: $_capturedImages/$_requiredImages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Cancel button
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                _stopScanning();
                setState(() {
                  _isScanning = false;
                });
              },
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startFaceScanning() {
    // Create a directory to store face images
    _createFaceImagesDirectory().then((directory) {
      // Start a timer to capture images every 500ms
      _captureTimer = Timer.periodic(const Duration(milliseconds: 500), (
        timer,
      ) {
        if (_capturedImages < _requiredImages) {
          _captureImage(directory);
        } else {
          _stopScanning();
          _saveFaceData();
        }
      });
    });
  }

  void _stopScanning() {
    _captureTimer?.cancel();
    _captureTimer = null;
  }

  Future<Directory> _createFaceImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final faceDir = Directory(
      '${appDir.path}/faces/${_newUserName}_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (!await faceDir.exists()) {
      await faceDir.create(recursive: true);
    }

    return faceDir;
  }

  Future<void> _captureImage(Directory directory) async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      final image = await _cameraController!.takePicture();
      final imagePath = '${directory.path}/face_${_capturedImages + 1}.jpg';

      // Copy the image to our directory
      final File imageFile = File(image.path);
      await imageFile.copy(imagePath);

      setState(() {
        _capturedImages++;
        _capturedImagePaths.add(imagePath);
      });
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
  }

  void _saveFaceData() {
    // In a real app, you would process these images for face recognition
    // For now, we'll just save the first image as a reference
    final String? firstImagePath =
        _capturedImagePaths.isNotEmpty ? _capturedImagePaths.first : null;

    setState(() {
      _registeredFaces.add(
        RegisteredFace(
          name: _newUserName,
          isActive: true,
          imageUrl: firstImagePath,
        ),
      );
      _isAddingFace = false;
      _isScanning = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Face registered successfully for $_newUserName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Update the RegisteredFace class to handle file paths
  Widget _buildFaceCard(RegisteredFace face) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Face image or placeholder
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child:
                face.imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child:
                          face.imageUrl!.startsWith('http')
                              ? Image.network(
                                face.imageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                              : Image.file(
                                File(face.imageUrl!),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                    )
                    : Icon(
                      Icons.person_outline,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
          ),

          // Rest of the face card remains the same
          const SizedBox(height: 16),
          Text(
            face.name,
            style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Active/Inactive status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  face.isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              face.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: face.isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  // Edit face
                },
                color: Colors.blue,
              ),
              IconButton(
                icon: Icon(face.isActive ? Icons.toggle_on : Icons.toggle_off),
                onPressed: () {
                  setState(() {
                    face.isActive = !face.isActive;
                  });
                },
                color: face.isActive ? Colors.green : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  // Show delete confirmation
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Face'),
                          content: Text(
                            'Are you sure you want to delete ${face.name}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _registeredFaces.remove(face);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Delete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  );
                },
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisteredFace {
  final String name;
  bool isActive;
  final String? imageUrl;

  RegisteredFace({required this.name, required this.isActive, this.imageUrl});
}
