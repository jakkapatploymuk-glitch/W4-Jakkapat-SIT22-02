import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _songNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _songTypeCtrl = TextEditingController();

  void addSong() async {
    String _songName = _songNameCtrl.text;
    String _name = _nameCtrl.text;
    String _songType = _songTypeCtrl.text;

    print("ค่าที่เก็บ $_songName | $_name | $_songType");

    try {
      await FirebaseFirestore.instance.collection("songs").add({
        "songName": _songName,
        "artist": _name,
        "songType": _songType,
      });

      _songNameCtrl.clear();
      _nameCtrl.clear();
      _songTypeCtrl.clear();
    } catch (e) {
      print("เกิดข้อผิดพลาด : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "ชื่อเพลง"),
              controller: _songNameCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "ชื่อศิลปิน"),
              controller: _nameCtrl,
            ),
            TextField(
              decoration: InputDecoration(labelText: "แนวเพลง"),
              controller: _songTypeCtrl,
            ),
            ElevatedButton(onPressed: addSong, child: Text("บันทึก")
            ),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("songs")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(
                      12,
                    ), // เพิ่มขอบรอบ Grid ไม่ให้ชิดจอเกินไป
                    itemCount: docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12, // เพิ่มระยะห่างแนวนอน
                      mainAxisSpacing: 12, // เพิ่มระยะห่างแนวตั้ง
                      childAspectRatio:
                          0.8, // ปรับสัดส่วนให้เป็นการ์ดแนวตั้ง (สูงกว่ากว้าง)
                    ),
                    itemBuilder: (context, index) {
                      final songs = docs[index];
                      final s = songs.data();

                      return Card(
                        elevation: 4, // เพิ่มเงาให้ดูจม
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            16,
                          ), // ขอบมนสวยงาม
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            16,
                          ), // ให้ Effect เวลากดโค้งตาม Card
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SongDetail(song: s),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ส่วนแสดงรูปภาพ หรือ ไอคอน (Top Part)
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors
                                        .deepPurpleAccent, // หรือใช้ s['color'] ถ้ามี
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    gradient: LinearGradient(
                                      // เพิ่มลูกเล่นไล่สี
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.purpleAccent,
                                        Colors.deepPurple,
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.music_note_rounded, // ไอคอนแทนรูปปก
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),

                              // ส่วนแสดงชื่อเพลง (Bottom Part)
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        s["songName"] ??
                                            'Unknown', // กันค่า null
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines:
                                            2, // ให้แสดงได้สูงสุด 2 บรรทัด
                                        overflow: TextOverflow
                                            .ellipsis, // ถ้ายาวกว่านั้นให้ ...
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongDetail extends StatelessWidget {
  final song;

  const SongDetail({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังสีขาวสะอาด
      appBar: AppBar(
        title: const Text(
          "Song Detail",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // ทำให้ AppBar โปร่งใส
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87), // ไอคอนสีดำ
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // 1. ส่วนจำลองปกอัลบั้ม (Album Art Placeholder)
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.purpleAccent.shade100, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 2. ชื่อเพลง (Song Name)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                song["songName"] ?? "Unknown Song",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // 3. ชื่อศิลปิน (Artist)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  song["artist"] ?? "Unknown Artist",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // เส้นคั่นบางๆ
            const Divider(indent: 40, endIndent: 40),
            const SizedBox(height: 20),

            // 4. แนวเพลง (Song Type) แสดงแบบ Chip
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.library_music, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text(
                      song["songType"] ?? "General",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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