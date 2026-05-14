import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportIssueScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const ReportIssueScreen({super.key, this.onBackToHome});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  int _currentStep = 1;
  String? _selectedCategory;
  String? _selectedPriority;
  bool _isConfirmed = false; 
  
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherTitleController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Infrastructure Issues', 'desc': 'Structural problems, building maintenance', 'icon': Icons.business_rounded},
    {'title': 'Street & Public Lighting', 'desc': 'Lights not working, dark areas', 'icon': Icons.lightbulb_outline_rounded},
    {'title': 'Water Supply & Sanitation', 'desc': 'Water shortage, leakage, sewage', 'icon': Icons.opacity_rounded},
    {'title': 'Cleanliness & Waste Management', 'desc': 'Garbage collection, littering, bins', 'icon': Icons.delete_outline_rounded},
    {'title': 'Roads & Traffic', 'desc': 'Potholes, road damage, traffic signals', 'icon': Icons.traffic_rounded},
    {'title': 'Public Facilities', 'desc': 'Toilets, bus stops, benches', 'icon': Icons.home_work_rounded},
    {'title': 'Parks & Environment', 'desc': 'Park maintenance, tree cutting', 'icon': Icons.eco_rounded},
    {'title': 'Safety & Emergency Hazards', 'desc': 'Dangerous conditions, broken equipment', 'icon': Icons.shield_outlined},
    {'title': 'Administrative & Civic Services', 'desc': 'Government office issues, documents', 'icon': Icons.account_balance_rounded},
    {'title': 'Other Civic Issues', 'desc': 'Issues not covered in other categories', 'icon': Icons.more_horiz_rounded},
  ];

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (photo != null) setState(() => _selectedImage = File(photo.path));
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

Future<void> _submitReport() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('complaints').add({
      'userId': user?.uid ?? 'guest',
      'category': _selectedCategory ?? 'No Category',
      'description': _descriptionController.text.trim(),
      'priority': _selectedPriority ?? 'Not Set',
      'location': 'MG Road, Mumbai, Maharashtra',
      'status': 'Pending',
      'imagePath': _selectedImage?.path ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Submission Successful", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text("Your report has been saved successfully.", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onBackToHome != null) {
                  widget.onBackToHome!();
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit report: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildProgressBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildCurrentStepContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    if (_currentStep == 1) return _buildStep1();
    if (_currentStep == 2) return _buildStep2();
    if (_currentStep == 3) return _buildStep3();
    if (_currentStep == 4) return _buildStep4();
    return const Center(child: Text("Process Complete"));
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)]),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A237E), size: 18),
              onPressed: () {
                if (_currentStep > 1) {
                  setState(() => _currentStep--);
                } else {
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  } else {
                    Navigator.pop(context, 'return_home');
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          const Text("New Report", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepCircle("1", isActive: _currentStep >= 1, isDone: _currentStep > 1),
          _buildStepLine(highlight: _currentStep >= 2),
          _buildStepCircle("2", isActive: _currentStep >= 2, isDone: _currentStep > 2),
          _buildStepLine(highlight: _currentStep >= 3),
          _buildStepCircle("3", isActive: _currentStep >= 3, isDone: _currentStep > 3),
          _buildStepLine(highlight: _currentStep >= 4),
          _buildStepCircle("4", isActive: _currentStep >= 4, isDone: _currentStep > 4),
        ],
      ),
    );
  }

  // --- STEP 1: PHOTO ---
  Widget _buildStep1() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text("Capture Evidence", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: Text("Photos help authorities understand the scale of the issue quickly.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        const SizedBox(height: 30),
        Center(
          child: GestureDetector(
            onTap: _pickImageFromCamera,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: const Color(0xFF2962FF).withAlpha(26), blurRadius: 20, offset: const Offset(0, 10))],
                image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                border: Border.all(color: _selectedImage == null ? const Color(0xFF2962FF).withAlpha(51) : Colors.transparent, width: 2),
              ),
              child: _selectedImage == null 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFF2962FF).withAlpha(13), shape: BoxShape.circle),
                        child: const Icon(Icons.add_a_photo_rounded, size: 50, color: Color(0xFF2962FF)),
                      ),
                      const SizedBox(height: 15),
                      const Text("Tap to Open Camera", style: TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold)),
                    ],
                  ) 
                : null,
            ),
          ),
        ),
        const Spacer(),
        _buildNavigationButtons(
          onNext: () => setState(() => _currentStep = 2), 
          enabled: _selectedImage != null,
          showBack: false,
        ),
      ],
    );
  }

  // --- STEP 2: CATEGORY ---
  Widget _buildStep2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("What is the issue?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                const SizedBox(height: 20),
                _buildSectionHeader("Current Location"),
                _buildLocationBox(),
                const SizedBox(height: 25),
                _buildSectionHeader("Select Category"),
                const SizedBox(height: 10),
                ..._categories.map((cat) => _buildCategoryTile(cat)),
              ],
            ),
          ),
        ),
        _buildNavigationButtons(onNext: () => setState(() => _currentStep = 3), enabled: _selectedCategory != null),
      ],
    );
  }

  // --- STEP 3: DESCRIPTION ---
  Widget _buildStep3() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Additional Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                const SizedBox(height: 25),
                _buildSectionHeader("Description"),
                _buildDescriptionField(),
                const SizedBox(height: 25),
                _buildSectionHeader("Voice Note"),
                _buildVoiceMessageButton(),
                const SizedBox(height: 30),
                _buildSectionHeader("Priority Level"),
                const SizedBox(height: 12),
                _buildPriorityTile("Low Priority", "Non-urgent issue", Icons.keyboard_double_arrow_down_rounded, Colors.blue),
                _buildPriorityTile("Medium Priority", "Needs attention soon", Icons.remove_circle_outline_rounded, Colors.orange),
                _buildPriorityTile("High Priority", "Requires immediate action", Icons.keyboard_double_arrow_up_rounded, Colors.red),
              ],
            ),
          ),
        ),
        _buildNavigationButtons(
          onNext: () {
            if (_descriptionController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please describe the issue")));
            } else {
              setState(() => _currentStep = 4);
            }
          }, 
          enabled: _selectedPriority != null,
        ),
      ],
    );
  }

  // --- STEP 4: REVIEW ---
  Widget _buildStep4() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Final Review", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, height: 180, width: double.infinity, fit: BoxFit.cover)
                            : Container(
                                height: 180,
                                width: double.infinity,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(height: 24),
                      _buildReviewRow("LOCATION", "MG Road, Mumbai, Maharashtra", Icons.location_on_rounded),
                      _buildReviewRow("CATEGORY", _selectedCategory ?? "", Icons.grid_view_rounded),
                      _buildReviewRow("PRIORITY", _selectedPriority ?? "", Icons.flag_rounded),
                      _buildReviewRow("DESCRIPTION", _descriptionController.text, Icons.notes_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isConfirmed,
                        activeColor: const Color(0xFF2962FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _isConfirmed = val!),
                      ),
                      const Expanded(
                        child: Text("I certify that the information provided is accurate and intended for community improvement.",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A237E))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 3),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56), 
                    side: const BorderSide(color: Color(0xFF2962FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isConfirmed ? _submitReport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    minimumSize: const Size(0, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Submit Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- UI HELPERS ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildReviewRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2962FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 10, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> cat) {
    bool isSelected = _selectedCategory == cat['title'];
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat['title']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? const Color(0xFF2962FF) : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isSelected ? const Color(0xFF2962FF) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: Icon(cat['icon'], color: isSelected ? Colors.white : Colors.grey, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cat['title'], style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1A237E) : Colors.black87)),
                Text(cat['desc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF2962FF)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityTile(String title, String subtitle, IconData icon, Color color) {
    bool isSelected = _selectedPriority == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(13) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: isSelected ? color : const Color(0xFF1A237E), fontWeight: FontWeight.w800)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            ]),
            const Spacer(),
            if (isSelected) Icon(Icons.radio_button_checked_rounded, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 5,
        onChanged: (v) => setState(() {}),
        decoration: InputDecoration(
          hintText: "E.g. Large pothole near the signal causing traffic...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildVoiceMessageButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), 
        borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2962FF).withAlpha(51))
      ),
      child: Row(children: const [
        Icon(Icons.mic_rounded, color: Color(0xFF2962FF)),
        SizedBox(width: 12),
        Text("Hold to record voice description", style: TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildLocationBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
      ),
      child: Row(children: const [
        Icon(Icons.my_location_rounded, color: Color(0xFF2962FF), size: 20),
        SizedBox(width: 12),
        Expanded(child: Text("MG Road, Mumbai, Maharashtra", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E)))),
        Icon(Icons.edit_location_alt_rounded, color: Colors.grey, size: 18),
      ]),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _otherTitleController.dispose();
    super.dispose();
  }

  Widget _buildNavigationButtons({required VoidCallback onNext, required bool enabled, bool showBack = true}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          if (showBack) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: enabled ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF), 
                minimumSize: const Size(0, 56),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(String t, {required bool isActive, bool isDone = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: isDone ? Colors.green : (isActive ? const Color(0xFF2962FF) : const Color(0xFFF1F5F9)),
        shape: BoxShape.circle,
        boxShadow: isActive ? [BoxShadow(color: const Color(0xFF2962FF).withAlpha(77), blurRadius: 8, spreadRadius: 2)] : null,
      ),
      child: Center(
        child: isDone 
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) 
          : Text(t, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStepLine({required bool highlight}) {
    return Expanded(child: AnimatedContainer(duration: const Duration(milliseconds: 300), height: 3, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: highlight ? const Color(0xFF2962FF) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(2))));
  }
}