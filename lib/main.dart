import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SafakSayarApp());

class SafakSayarApp extends StatelessWidget {
  const SafakSayarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Şafak Sayar',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int kalanSafak = 55; 

  final List<String> rastgeleSozler = [
    "Özgürlük, bazen gidilmesi zor yerlere gidebilmek bazen de eve dönebilmektir.",
    "Şafak atar, güneşi doğar, bitmeyen askerlik yoktur.",
    "Mehmetçik nöbette, yüreğimiz sende.",
    "Gönül isterdi ki hep tatil olsun, ama vatan borcu namustur.",
  ];

  final Map<int, String> plakaSozleri = {
    1: "Ne boya ne badana, Şafak sadece 01 Adana 🥳",
    12: "Olmasa da Bitlis'te lüks bir yaşam, Bizdeki keyif kimsede yok Paşam 😌",
    34: "İstanbul İstanbul olalı, böyle şafak görmedi!",
    55: "Samsun'a selam, bu iş burada tamam!",
    61: "Bize her yer Trabzon, şafak olmuş dar sokak!",
  };

  String getGuncelMesaj() {
    if (kalanSafak == 1) {
      return "Atarsa Doğan Güneş ☀️";
    } else if (kalanSafak <= 81 && plakaSozleri.containsKey(kalanSafak)) {
      return plakaSozleri[kalanSafak]!;
    } else {
      final random = Random();
      return rastgeleSozler[random.nextInt(rastgeleSozler.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Şafak -> Plaka: $kalanSafak"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kalanSafak == 1 ? "DOĞAN GÜNEŞ" : "$kalanSafak Gün",
              style: const TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold, 
                color: Colors.deepOrange
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  getGuncelMesaj(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (kalanSafak > 1) kalanSafak--;
                });
              },
              child: const Text("Bir Gün Eksilt (Şafak Düşür)"),
            )
          ],
        ),
      ),
    );
  }
}
