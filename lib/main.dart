import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ऑफलाइन एआई ऐप',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AiHomeScreen(),
    );
  }
}

class AiHomeScreen extends StatefulWidget {
  const AiHomeScreen({Key? key}) : super(key: key);

  @override
  State<AiHomeScreen> createState() => _AiHomeScreenState();
}

class _AiHomeScreenState extends State<AiHomeScreen> {
  List<dynamic> _masterDatabase = [];
  final TextEditingController _controller = TextEditingController();
  String _response = "सिस्टम तैयार है। अपना सवाल नीचे टाइप करें...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllJsonFiles();
  }

  Future<void> _loadAllJsonFiles() async {
    try {
      final String indexString = await rootBundle.loadString('assets/json_files/index.json');
      final Map<String, dynamic> indexData = json.decode(indexString);
      final List<dynamic> filePaths = indexData['files'];

      List<dynamic> tempDatabase = [];

      for (String path in filePaths) {
        final String fileString = await rootBundle.loadString(path);
        final List<dynamic> fileData = json.decode(fileString);
        tempDatabase.addAll(fileData);
      }

      setState(() {
        _masterDatabase = tempDatabase;
        _isLoading = false;
        _response = "डेटा सफलतापूर्वक लोड हो गया! कुल रिकॉर्ड्स: ${_masterDatabase.length}\n\nअब आप कुछ भी पूछ सकते हैं।";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _response = "डेटा लोड करने में त्रुटि: $e";
      });
    }
  }

  void _searchInDatabase(String query) {
    if (query.trim().isEmpty || _masterDatabase.isEmpty) return;

    String userQuery = query.toLowerCase();
    String foundAnswer = "माफ़ कीजिए, इस शब्द का जवाब ऑफलाइन डेटाबेस में नहीं मिला।";

    for (var item in _masterDatabase) {
      if (item['keyword'].toString().toLowerCase().contains(userQuery)) {
        foundAnswer = item['answer'];
        break;
      }
    }

    setState(() {
      _response = foundAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('मेरा ऑफलाइन एआई ऐप'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _response,
                    style: const TextStyle(fontSize: 18, height: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'यहाँ अपना सवाल लिखें...',
                    ),
                    onSubmitted: (value) {
                      _searchInDatabase(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onPressed: () {
                    _searchInDatabase(_controller.text);
                    _controller.clear();
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
