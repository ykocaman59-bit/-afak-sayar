import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool kayitliMi = prefs.getBool('kayitliMi') ?? false;

  runApp(SafakSayarApp(kayitliMi: kayitliMi));
}

class SafakSayarApp extends StatelessWidget {
  final bool kayitliMi;
  const SafakSayarApp({super.key, required this.kayitliMi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Şafak Sayar',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: kayitliMi ? const AnaSafakEkrani() : const ProfilKayitEkrani(),
    );
  }
}

// 1. Profil ve Kayıt Ekranı
class ProfilKayitEkrani extends StatefulWidget {
  const ProfilKayitEkrani({super.key});

  @override
  State<ProfilKayitEkrani> createState() => _ProfilKayitEkraniState();
}

class _ProfilKayitEkraniState extends State<ProfilKayitEkrani> {
  final TextEditingController isimController = TextEditingController(text: "");
  String askerlikSuresi = "6 Ay";
  DateTime sevkTarihi = DateTime.now();

  Future<void> bilgileriKaydet() async {
    if (isimController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen isminizi giriniz!")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('isim', isimController.text.trim());
    await prefs.setString('askerlikSuresi', askerlikSuresi);
    await prefs.setString('sevkTarihi', sevkTarihi.toIso8601String());
    await prefs.setBool('kayitliMi', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AnaSafakEkrani()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Askerlik Bilgileri"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: isimController,
              decoration: const InputDecoration(labelText: "İsim / Künye", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: askerlikSuresi,
              decoration: const InputDecoration(labelText: "Askerlik Süresi", border: OutlineInputBorder()),
              items: ["6 Ay", "12 Ay"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  askerlikSuresi = val!;
                });
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade400)),
              title: const Text("Sevk Tarihi (Askerlik Başlangıcı)"),
              subtitle: Text("${sevkTarihi.day}.${sevkTarihi.month}.${sevkTarihi.year}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? secilen = await showDatePicker(
                  context: context,
                  initialDate: sevkTarihi,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (secilen != null) {
                  setState(() {
                    sevkTarihi = secilen;
                  });
                }
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: bilgileriKaydet,
                child: const Text("Kaydet ve Şafağı Hesapla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Ana Şafak Ekranı
class AnaSafakEkrani extends StatefulWidget {
  const AnaSafakEkrani({super.key});

  @override
  State<AnaSafakEkrani> createState() => _AnaSafakEkraniState();
}

class _AnaSafakEkraniState extends State<AnaSafakEkrani> {
  String isim = "Mehmetçik";
  int toplamGun = 180;
  DateTime sevkTarihi = DateTime.now();
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  Future<void> verileriYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isim = prefs.getString('isim') ?? "Mehmetçik";
      String sure = prefs.getString('askerlikSuresi') ?? "6 Ay";
      toplamGun = (sure == "6 Ay") ? 180 : 360;
      
      String? tarihStr = prefs.getString('sevkTarihi');
      if (tarihStr != null) {
        sevkTarihi = DateTime.parse(tarihStr);
      }
      yukleniyor = false;
    });
  }

  Future<void> verileriSifirla() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfilKayitEkrani()),
    );
  }

  int hesaplaKalanSafak() {
    DateTime terhisTarihi = sevkTarihi.add(Duration(days: toplamGun));
    DateTime simdi = DateTime.now();
    int fark = terhisTarihi.difference(simdi).inDays;
    return fark > 0 ? fark : 0;
  }

  String getRastgeleSoz() {
    final List<String> sozler = [
      "Şafak atar, güneşi doğar; bitmeyen askerlik yoktur $isim!",
      "Mehmetçik nöbette, yüreğimiz sende, az kaldı sık dişini!",
      "Geç günler, katsın sevinçler; şafak saymak bitiyor!",
      "Vatan borcu namustur, biter elbet ama bu hatıralar ömür boyudur.",
      "Geceler karanlık olsa da şafak çok yakın!",
      "Her yeni gün, sevdiklerine bir adım daha yaklaşmaktır.",
      "Sakın üzülme mert asker, çorba pişecek evde!",
      "Şafak karanlık ama kalbimiz aydınlık, az kaldı paşam!",
      "Zaman geçiyor, teskere ayak sesleri duyuluyor.",
      "Dağlar ardında memleket, şafak sayar elbet metanet!",
      "Şafak sıkıştırdıkça bitişe yaklaşıyoruz, sabır!",
      "Bitmez denilen o şafaklar, gün gelecek tarihe karışacak.",
      "Yılmak yok $isim, bu vatan bizim!",
      "Nöbet tutarken hayal kurmak serbesttir, aslan asker!",
      "Bugün de bitti ya, geriye kalan her gün kârdır.",
      "Takvimin yaprakları düşerken, terhis sevinci yaklaşıyor.",
      "Güneş batar doğar, şafak elbet bir gün sıfırlanır.",
      "Şafak olmuş otoyol, haydi $isim musmutlu ol!",
      "Çarşı izinleri hayaliyle geçen günlerin sonu geliyor.",
      "Askerin dostu şafak sayacıdır, unutma!",
      "Sağ salim gidip geleceğiz, az kaldı.",
      "Yıldızlar şahidimiz olsun, bu şafak bitecek!",
      "Sıkı dur $isim, az kaldı kavuşmaya.",
      "Gecenin en karanlık anı, şafağa en yakın andır.",
      "Şafak saymak bir sanatsa, biz bu sanatın ustasıyız.",
      "Dağ başından memlekete selam olsun!",
      "Az kaldı bitiyor bu hasret, sabır yoldaşımız.",
      "Göz açıp kapayıncaya kadar geçer bu günler.",
      "Pes etmek yok, biz bu yola baş koyduk!",
      "Askerin en güzel rüyası terhis belgesidir.",
      "Bir gün daha devirdik, aradan bir gün daha eksildi.",
      "Dostlar el sallıyor memleketten, şafak düşüyor ardına bile bakmadan.",
      "Rüzgar gibi geçer zaman, yeter ki moral bozulmasın.",
      "Umut hep var, şafak her geçen gün azalıyor.",
      "Tepeler dumanlı ama şafak umut dolu.",
      "Komutanım seslendiğinde değil, şafak attığında yüzümüz güler!",
      "Her şafak yeni bir umut, yeni bir gündür.",
      "Bitmez denilen teskere, gün gelip kapıyı çalacak.",
      "Sık dişini $isim, az kaldı özlenen günlere.",
      "Memleket kokulu rüyalar görmeye çok az kaldı.",
      "Dağların ardında güneş var, şafak bitiyor inatla.",
      "Askerlik biter, dostluklar baki kalır.",
      "Her şafak bir adımdır özgürlüğe.",
      "Gönlümüz ferah, şafak düşüyor yavaş yavaş.",
      "Bugün de şafağa bir çentik attık.",
      "Geçecek bu günler, elbet bir gün bitti diyeceğiz.",
    ];
    final random = Random();
    return sozler[random.nextInt(sozler.length)];
  }

  String getPlakaSozu(int kalan) {
    final Map<int, String> plakaSozleri = {
      1: "Ne boya ne badana, Şafak sadece 01 Adana 🥳",
      2: "Şafak 02 Adıyaman, çiğ köfteyi yiyelim hemen!",
      3: "Afyon'un kaymağı, şafak bitti bitti yla!",
      4: "Ağrı dağı var hey, şafak olmuş tay!",
      5: "Amasya elması tatlı, şafak artık çok az katlı!",
      6: "Ankara'nın soğuna kurban, az kaldı paşam!",
      7: "Antalya sahilleri bekler, şafak bitti!",
      8: "Artvin'in dağları yeşil, şafak ne güzel ne neşeli!",
      9: "Aydın diyarı nazilli, şafak artık telli!",
      10: "Balıkesir'e selam, bu şafak burada tamam!",
      11: "Bilecik'te tarih yatar, şafak artık hızlı atar!",
      12: "Olmasa da Bitlis'te lüks bir yaşam, Bizdeki keyif kimsede yok Paşam 😌",
      13: "Bolu beyi dinlemez bu şafak!",
      14: "Bolu'nun patatesi közde, şafak gözbebeğimizde!",
      15: "Burdur gölü serinletir, şafak bitiyor!",
      16: "Bursa yeşil, şafak ne güzel delikanlı!",
      17: "Çanakkale geçilmez, bu şafaktan vazgeçilmez!",
      18: "Çankırı tuzu lezzetli, şafak kıymetli!",
      19: "Çorum leblebisi çıtır, şafak bitti bitir!",
      20: "Denizli horozu ötüyor, şafak bitiyor!",
      21: "Diyarbakır surları taş, şafak az kaldı gardaş!",
      22: "Edirne köftesi mis, şafak bitiyor temiz!",
      23: "Elazığ çaycesi yaman, şafak bitti az kalan!",
      24: "Erzincan tulumu bal, şafak bitti gel de al!",
      25: "Erzurum dadaş diyarı, bitiyor şafak zarı!",
      26: "Eskişehir lületaşı, şafak bitti gardaş!",
      27: "Gaziantep baklavası tatlı, şafak artık son katlı!",
      28: "Giresun fındığı fındık, şafak artık bıktık!",
      29: "Gümüşhane pestili tatlı, şafak az katlı!",
      30: "Hakkari dağları karlı, şafak pek şanlı!",
      31: "Hatay künefesi sıcak, az kaldı kavuşacak!",
      32: "Isparta gülü mis gibi, şafak bitti işte bi!",
      33: "Mersin tantunisi şahane, şafak bitti bitti",
      34: "İstanbul İstanbul olalı, böyle şafak görmedi!",
      35: "İzmir'in dağlarında çiçekler açar, şafak kaçar!",
      36: "Kars'ın karsu, şafak buldu mu!",
      37: "Kastamonu evleri ahşap, şafak pek neşeli yakamoz!",
      38: "Kayseri mantısı sıcak, az kaldı bitiyor",
      39: "Kırklareli meşe, şafak geldi neşe!",
      40: "Kırşehir neşet ertaş, şafak bitti gardaş!",
      41: "Kocaeli sanayi ovası, şafak bitti rüyası!",
      42: "Konya etli ekmek mis, şafak temiz!",
      43: "Kütahya çinisi süslü, şafak mutlu!",
      44: "Malatya kayısı tatlı, şafak son katlı!",
      45: "Manisa mesir macunu, şafak buldu sonunu!",
      46: "Kahramanmaraş dondurması erir, şafak biterdir!",
      47: "Mardin taştan evler, şafak bitti sevmeler!",
      48: "Muğla Bodrum tatili yakın, şafak bitti bakın!",
      49: "Muş çayı yaman, şafak bitti tamam!",
      50: "Nevşehir peri bacaları, şafak bitti acıları!",
      51: "Niğde patatesi, şafak bitti neticesi!",
      52: "Ordu fındığı bol, şafak artık son yol!",
      53: "Rize çayı demli, şafak kıdemli!",
      54: "Sakarya köprüsü uzun, şafak bitiyor oğlum!",
      55: "Samsun'a selam, bu iş burada tamam!",
      56: "Siirt terveni, şafak biteni!",
      57: "Sinop kalecik, şafak bitti,çik!",
      58: "Sivas kangalı aslan, şafak bitti yaslan!",
      59: "Tekirdağ köftesi şahane, şafak bitti bahane!",
      60: "Tokat kebabı mis, şafak temiz!",
      61: "Bize her yer Trabzon, şafak olmuş dar sokak!",
      62: "Tunceli Munzur suyu, şafak bitti huyu!",
      63: "Şanlıurfa sıcağı, şafak ocağı!",
      64: "Uşak halısı dokunur, şafak okunur!",
      65: "Van kedisi gözleri van, şafak bitti ulan!",
      66: "Yozgat sürmelisi, şafak bitmesi!",
      67: "Zonguldak madeni kömür, şafak bitti ömür!",
      68: "Aksaray somuncu baba, şafak bitti merhaba!",
      69: "Bayburt baksı müzesi, şafak bitti dizeyi!",
      70: "Karaman koyunu, şafak bitirdi oyunu!",
      71: "Kırıkkale silah fabrikası, şafak bitti arkası!",
      72: "Batman petrolü, şafak bitti dolusu!",
      73: "Şırnak gabar dağı, şafak bitti ocağı!",
      74: "Bartın amasra, şafak bitti hatıra!",
      75: "Ardahan kars kış, şafak bitmiş!",
      76: "Iğdır kayısısı, şafak bitti sayısı!",
      77: "Yalova termal, şafak bitti, durma al!",
      78: "Karabük safranbolu evleri, şafak bitiyor sevmeleri!",
      79: "Kilis katmeri, şafak bitti bitti geri!",
      80: "Osmaniye fıstığı çıtır, şafak bitti bitir!",
      81: "Düzce akçakoca, şafak bitti az koca!"
    };

    if (kalan == 1) {
      return "Atarsa Doğan Güneş ☀️";
    } else if (kalan <= 81 && plakaSozleri.containsKey(kalan)) {
      return plakaSozleri[kalan]!;
    } else {
      return getRastgeleSoz();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (yukleniyor) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    int kalanSafak = hesaplaKalanSafak();

    return Scaffold(
      appBar: AppBar(
        title: Text("$isim - Şafak Durumu"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Bilgileri Sıfırla",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Bilgileri Sıfırla"),
                  content: const Text("Askerlik bilgilerinizi sıfırlamak istediğinize emin misiniz?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("İptal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        verileriSifirla();
                      },
                      child: const Text("Sıfırla", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kalanSafak == 1 ? "DOĞAN GÜNEŞ" : "$kalanSafak Gün",
              style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            const SizedBox(height: 10),
            Text("Sevk Tarihi: ${sevkTarihi.day}.${sevkTarihi.month}.${sevkTarihi.year}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 30),
            
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  getPlakaSozu(kalanSafak),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
