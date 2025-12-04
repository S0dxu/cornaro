import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cornaro/pages/chat.dart';
import 'package:cornaro/pages/add.dart';
import 'package:cornaro/pages/shop.dart';
import 'package:cornaro/pages/promo.dart';
import 'package:cornaro/pages/login.dart';
import 'package:flutter/services.dart';
import 'package:cornaro/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/* class AppColors {
  static Color get primary =>
      currentTheme == "dark" ? const Color.fromARGB(255, 33, 87, 179) : const Color.fromARGB(255, 33, 87, 179);

  static Color get bgGrey =>
      currentTheme == "dark" ? const Color.fromARGB(255, 3, 3, 3) : const Color(0xfff4f4f4);

  static Color get borderGrey =>
      currentTheme == "dark" ? const Color.fromARGB(204, 43, 43, 43) : const Color(0xCCdadada);

  static Color get text =>
      currentTheme == "dark" ? const Color(0xffffffff) : const Color(0xff000000);

  static Color get contrast =>
      currentTheme == "dark" ? const Color(0xff000000) : const Color(0xffffffff);

  static Color get red =>
      currentTheme == "dark" ? const Color(0xffff6f6a) : const Color(0xffe53935);
} */

ValueNotifier<String> themeNotifier = ValueNotifier(currentTheme);

final storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userName = "";
  String name = "";
  String profileImage = "assets/icons/profile.png";

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final n = await storage.read(key: 'user_name') ?? "";
    final u = await storage.read(key: 'user_username') ?? "";
    final p = await storage.read(key: 'user_profile_image') ?? "assets/icons/profile.png";

    setState(() {
      name = n;
      userName = u;
      profileImage = p;
      _pages.addAll([
        HomeWidget(userName: userName, name: name, profileImage: profileImage),
        const ChatPage(),
        const AddPage(),
        const ShopPage(),
        const PromoPage(),
      ]);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _bottomNavItem(String iconPath, String label, bool isSelected) {
    bool isAddButton = label.isEmpty;
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: isAddButton ? 10.0 : 0.0),
        child: SvgPicture.asset(
          iconPath,
          height: isAddButton ? 28 : 24,
          width: isAddButton ? 28 : 24,
          colorFilter: ColorFilter.mode(
            isSelected ? AppColors.primary : AppColors.text.withOpacity(0.85),
            BlendMode.srcIn,
          ),
        ),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, value, child) {
        return Scaffold(
          body: _pages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _pages[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.borderGrey,
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedFontSize: 12,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.text.withOpacity(0.75),
              type: BottomNavigationBarType.fixed,
              items: [
                _bottomNavItem("assets/icons/home.svg", "Home", _selectedIndex == 0),
                _bottomNavItem("assets/icons/spot.svg", "Spot", _selectedIndex == 1),
                _bottomNavItem("assets/icons/plus-circle-svgrepo-com.svg", "", _selectedIndex == 2),
                _bottomNavItem("assets/icons/book-svgrepo-com (1).svg", "Shop", _selectedIndex == 3),
                _bottomNavItem("assets/icons/present.svg", "Promo", _selectedIndex == 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeWidget extends StatefulWidget {
  final String userName;
  final String name;
  final String profileImage;

  const HomeWidget({
    super.key,
    required this.userName,
    required this.name,
    required this.profileImage,
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Map<String, String>> allMessages = [];
  List<Map<String, String>> filteredMessages = [];
  final TextEditingController searchController = TextEditingController();

  String filterType = "all";
  bool sortDescending = true;
  double maxMessages = 15;

  /* List<Map<String, String>> generateMessages() {
    final now = DateTime.now();
    final List<Map<String, String>> texts = [
      {"text": "Attenzione: l'acqua non è potabile.", "type": "alert"},
      {"text": "Nuova manutenzione programmata venerdì.", "type": "info"},
      {"text": "Aggiornamento orari apertura sportello di matematica.", "type": "info"},
      {"text": "Servizio raccolta differenziata posticipato.", "type": "info"},
      {"text": "Allerta meteo per forti piogge. Ricordarsi di portare ombrelli e/o ponchi", "type": "alert"},
      {"text": "Evento locale: festa di San Martino.", "type": "info"},
      {"text": "Nuove offerte nel negozio del paese.", "type": "info"},
      {"text": "Interruzione temporanea elettricità.", "type": "alert"},
      {"text": "Avviso: chiusura strade per lavori pubblici.", "type": "alert"},
      {"text": "Promozione acqua minerale in negozio.", "type": "info"},
      {"text": "Nuovo avviso pubblico affisso in bacheca.", "type": "alert"},
      {"text": "Aggiornamento sul servizio navetta.", "type": "info"},
      {"text": "Riapertura biblioteca comunale.", "type": "info"},
      {"text": "Mercatino domenicale spostato in piazza centrale.", "type": "info"},
      {"text": "Servizio di pulizia straordinario sabato.", "type": "info"},
      {"text": "Attenzione: lavori fognari in corso.", "type": "alert"},
      {"text": "Nuova ordinanza per la raccolta rifiuti.", "type": "alert"},
      {"text": "Evento sportivo sabato alle 18.", "type": "info"},
      {"text": "Sospensione erogazione gas per manutenzione.", "type": "alert"},
      {"text": "Comunicazione importante dal comune.", "type": "info"},
    ];
    return List.generate(20, (i) {
      final date = now.subtract(Duration(days: i ~/ 3));
      return {
        "text": texts[i]["text"]!,
        "type": texts[i]["type"]!,
        "date": "${date.day}/${date.month}/${date.year}",
      };
    });
  }
 */

  Future<bool> _checkIsAdmin() async {
    final token = await storage.read(key: 'session_token');
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse("https://cornaro-backend.onrender.com/is-admin"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isAdmin'] ?? false;
      }
    } catch (e) {
      print("Errore controllo admin: $e");
    }

    return false;
  }


  Future<void> _loadMessages() async {
  final savedMessages = await storage.read(key: 'messages');
  if (savedMessages != null) {
    final List<dynamic> storedList = jsonDecode(savedMessages);
    setState(() {
      allMessages = storedList.map<Map<String, String>>((item) => Map<String, String>.from(item)).toList();
      filteredMessages = List.from(allMessages);
      _filterMessages();
    });
  }

  try {
    final token = await storage.read(key: 'session_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse("https://cornaro-backend.onrender.com/get-info"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> messagesData = data['infos'] ?? [];

      final List<Map<String, String>> messages = messagesData.map<Map<String, String>>((item) {
        return {
          "text": item["message"] ?? "",
          "type": item["type"] ?? "info",
          "date": item["createdAt"] != null
              ? _formatBackendDate(item["createdAt"])
              : "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        };
      }).toList();

      bool isDifferent = jsonEncode(messages) != jsonEncode(allMessages);
      if (isDifferent) {
        await storage.write(key: 'messages', value: jsonEncode(messages));
        setState(() {
          allMessages = messages;
          filteredMessages = List.from(allMessages);
          _filterMessages();
        });
      }
    } else {
      print("Errore caricamento messaggi: ${response.statusCode}");
    }
  } catch (e) {
    print("Errore fetch messaggi: $e");
  }
}


  String _formatBackendDate(String isoDate) {
    final dt = DateTime.parse(isoDate).toLocal();
    return "${dt.day}/${dt.month}/${dt.year}";
  }


  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _loadMaxMessages();
    _loadMessages();
    searchController.addListener(_filterMessages);
  }


  Future<void> _loadMaxMessages() async {
    String? saved = await storage.read(key: 'max_messages');
    if (saved != null) {
      setState(() {
        maxMessages = double.tryParse(saved) ?? 15;
      });
    }
    _filterMessages();
  }


  Future<void> _saveMaxMessages() async {
    await storage.write(key: 'max_messages', value: maxMessages.toInt().toString());
  }

  void _filterMessages() {
    final query = searchController.text.toLowerCase();

    List<Map<String, String>> temp = allMessages.where((msg) {
      bool matchesSearch = msg["text"]!.toLowerCase().contains(query);
      bool matchesType = filterType == "all" || msg["type"] == filterType;
      return matchesSearch && matchesType;
    }).toList();

    temp.sort((a, b) {
      DateTime da = _parseDate(a["date"]!);
      DateTime db = _parseDate(b["date"]!);
      return sortDescending ? db.compareTo(da) : da.compareTo(db);
    });

    if (searchController.text.isEmpty && maxMessages < temp.length) {
      temp = temp.sublist(0, maxMessages.toInt());
    }

    setState(() {
      filteredMessages = temp;
    });
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  String formatDate(String dateString) {
    final parts = dateString.split('/');
    final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "OGGI";
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return "IERI";
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return "DOMANI";
    } else {
      const months = [
        "", "GEN", "FEB", "MAR", "APR", "MAG", "GIU", "LUG", "AGO", "SET", "OTT", "NOV", "DIC"
      ];
      return "${date.day} ${months[date.month]} ${date.year}";
    }
  }

 @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> grouped = {};
    for (var msg in filteredMessages) {
      grouped.putIfAbsent(msg["date"]!, () => []).add(msg);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.bgGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: searchController,
                              style: TextStyle(
                                color: AppColors.text,
                              ),
                              decoration: InputDecoration(
                                hintText: "Cerca",
                                hintStyle: TextStyle(color: AppColors.text.withOpacity(0.65)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset(
                                    "assets/icons/search.svg",
                                    height: 20,
                                    width: 20,
                                    colorFilter: ColorFilter.mode(AppColors.text.withOpacity(0.65), BlendMode.srcIn),
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.contrast,
                              barrierColor: AppColors.text.withOpacity(0.05),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                List<String> importanza = ['Tutte', 'Info', 'Alert'];
                                List<String> ordinamento = ['Recenti', 'Vecchi'];
                                return StatefulBuilder(
                                  builder: (context, setModalState) {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.55,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.text.withOpacity(0.15), borderRadius: BorderRadius.circular(10)))),
                                            const Center(child: Text("Filtra per", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
                                            const SizedBox(height: 25),
                                            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Importanza", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                            const SizedBox(height: 10),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Row(
                                                children: importanza.map((item) {
                                                  final bool isSelected = filterType == item.toLowerCase() || (item == "Tutte" && filterType == "all");
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setModalState(() { filterType = item == "Tutte" ? "all" : item.toLowerCase(); });
                                                      _filterMessages();
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(right: 6),
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(100),
                                                        border: Border.all(color: isSelected ? const Color(0xff0a45ac) : AppColors.text.withOpacity(0.25), width: 2),
                                                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                                      ),
                                                      child: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.text, fontWeight: FontWeight.w500)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                            const SizedBox(height: 10),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Row(
                                                children: ordinamento.map((item) {
                                                  final bool isSelected = (item == "Recenti" && sortDescending == true) || (item == "Vecchi" && sortDescending == false);
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setModalState(() { sortDescending = item == "Recenti"; });
                                                      _filterMessages();
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(right: 6),
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(100),
                                                        border: Border.all(color: isSelected ? const Color(0xff0a45ac) : AppColors.text.withOpacity(0.25), width: 2),
                                                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                                      ),
                                                      child: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.text, fontWeight: FontWeight.w500)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Numero di messaggi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 20),
                                              child: SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  activeTrackColor: AppColors.primary,
                                                  inactiveTrackColor: AppColors.borderGrey,
                                                  thumbColor: AppColors.primary,
                                                  overlayColor: AppColors.primary.withOpacity(0.2),
                                                  trackHeight: 4,
                                                  valueIndicatorColor: AppColors.primary,
                                                ),
                                                child: Slider(
                                                  value: maxMessages,
                                                  min: 0,
                                                  max: 15,
                                                  divisions: 15,
                                                  label: maxMessages.toInt().toString(),
                                                  onChanged: (val) {
                                                    setModalState(() {
                                                      maxMessages = val;
                                                    });
                                                    _filterMessages();
                                                    _saveMaxMessages();
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.borderGrey, width: 1)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset('assets/icons/filter.svg', color: AppColors.text.withOpacity(0.65)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  ...grouped.entries.toList().asMap().entries.map((groupEntry) {
                    final index = groupEntry.key;
                    final entry = groupEntry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                          left: 18, bottom: 5, top: 12, right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDate(entry.key),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: AppColors.text.withOpacity(0.85)),
                              ),
                              if (index == 0)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Visualizza tutti",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SvgPicture.asset(
                                      "assets/icons/arrow-right.svg",
                                      height: 14,
                                      width: 14,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        ...entry.value.map((item) {
                          final isAlert = item["type"] == "alert";
                          final iconPath =
                              isAlert ? "assets/icons/alert.svg" : "assets/icons/info.svg";
                          final iconColor = isAlert ? AppColors.red : AppColors.primary;
                          final iconBgColor =
                              isAlert ? AppColors.red.withOpacity(0.05) : AppColors.primary.withOpacity(0.05);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14
                            ),
                            decoration: BoxDecoration(
                            border: Border(
                            bottom: BorderSide(
                            color: AppColors.borderGrey, width: 1))),
                            child: Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration:
                                      BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                                  child: Center(
                                    child: SvgPicture.asset(iconPath,
                                        height: 24,
                                        width: 24,
                                        colorFilter:
                                            ColorFilter.mode(iconColor, BlendMode.srcIn)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                  item["text"]!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                                )),
                                const SizedBox(width: 10),
                                SvgPicture.asset("assets/icons/arrow-right.svg",
                                    height: 18,
                                    width: 18,
                                    colorFilter: ColorFilter.mode(AppColors.text.withOpacity(0.5), BlendMode.srcIn)
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                  /* Image.asset(
                    "assets/icons/ads1.png",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ), */
                  /* Image.asset(
                    "assets/icons/ads2.png",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ) */
                ],
              ),
            ),
          ),
          Material(
            color: AppColors.primary,
            shape: ContinuousRectangleBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(70),
                bottomRight: Radius.circular(70),
              ),
            ),
            child: Container(
              height: 110,
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: "Close",
                                barrierColor: AppColors.text.withOpacity(0.05),
                                transitionDuration: const Duration(milliseconds: 200),
                                pageBuilder: (_, __, ___) {
                                  final double size = MediaQuery.of(context).size.width - 80;
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: ClipOval(
                                            child: Container(
                                              width: size,
                                              height: size,
                                              color: AppColors.bgGrey,
                                              child: InteractiveViewer(
                                                child: widget.profileImage.isNotEmpty
                                                    ? Image.network(
                                                        widget.profileImage,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.asset(
                                                        "assets/icons/profile.png",
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.contrast.withOpacity(0.2),
                              backgroundImage: widget.profileImage.isNotEmpty
                                  ? NetworkImage(widget.profileImage)
                                  : const AssetImage("assets/icons/profile.png") as ImageProvider,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              Text(
                                widget.userName != "" ? "@${widget.userName}" : "",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          children: [
                            FutureBuilder<bool>(
                              future: _checkIsAdmin(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox();
                                }
                                if (snapshot.hasData && snapshot.data == true) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminPage(),
                                        ),
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      "assets/icons/admin.svg",
                                      height: 24,
                                      width: 24,
                                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SettingsPage(
                                      onThemeChanged: () {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/icons/settings-svgrepo-com.svg",
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
      )],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.bgGrey,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  void _toggleTheme(String theme) async {
    currentTheme = theme;
    await storage.write(key: "theme", value: theme);

    themeNotifier.value = currentTheme;
    widget.onThemeChanged();
    refreshApp();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settingsSections = [
      {
        'sectionTitle': 'Account',
        'items': [
          {'title': 'Profilo', 'icon': 'assets/icons/user.svg'},
          {'title': 'Password', 'icon': 'assets/icons/lock.svg'},
          {'title': 'Privacy', 'icon': 'assets/icons/privacy.svg'},
        ],
      },
      {
        'sectionTitle': 'Preferenze',
        'items': [
          {'title': 'Notifiche', 'icon': 'assets/icons/bell.svg'},
          {'title': 'Lingua', 'icon': 'assets/icons/language.svg'},
          {'title': 'Tema', 'icon': 'assets/icons/theme.svg'},
        ],
      },
      {
        'sectionTitle': 'Supporto',
        'items': [
          {'title': 'Aiuto', 'icon': 'assets/icons/help.svg'},
          {'title': 'Informazioni', 'icon': 'assets/icons/info.svg'},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        //systemOverlayStyle: SystemUiOverlayStyle.light,
        forceMaterialTransparency: true,
        title: Text(
          'Impostazioni',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      backgroundColor: AppColors.bgGrey,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: settingsSections.length + 1,
        itemBuilder: (context, sectionIndex) {
          if (sectionIndex == settingsSections.length) {
            return GestureDetector(
              onTap: () async {
                await storage.deleteAll();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.contrast,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text.withOpacity(0.05),
                      blurRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Esci',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.red,
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/icons/logout.svg",
                      height: 22,
                      width: 22,
                      colorFilter: ColorFilter.mode(
                        AppColors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final section = settingsSections[sectionIndex];
          final items = section['items'] as List<Map<String, String>>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  section['sectionTitle'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.text.withOpacity(0.85),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () async {
                        if (item['title'] == "Tema") {
                          String savedTheme = await storage.read(key: "theme") ?? "light";
                          String selectedTheme = savedTheme;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Scaffold(
                                  backgroundColor: AppColors.bgGrey,
                                  appBar: AppBar(
                                    title: Text("Tema", style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: AppColors.text,
                                    )),
                                    backgroundColor: AppColors.bgGrey,
                                    elevation: 0,
                                    centerTitle: true,
                                    iconTheme: IconThemeData(
                                        color: AppColors.text),
                                  ),
                                  body: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          "Light Mode",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        trailing: Icon(
                                          selectedTheme == "light"
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color: AppColors.primary,
                                        ),
                                        onTap: () {
                                          selectedTheme = "light";
                                          _toggleTheme("light");
                                        },
                                      ),
                                      ListTile(
                                        title: Text(
                                          "Dark Mode",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        trailing: Icon(
                                          selectedTheme == "dark"
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          color: AppColors.primary,
                                        ),
                                        onTap: () {
                                          selectedTheme = "dark";
                                          _toggleTheme("dark");
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (item['title'] == "Profilo") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                Widget profileTile(String title, VoidCallback onTap) {
                                  return ListTile(
                                    title: Text(
                                      title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    trailing: SvgPicture.asset(
                                      "assets/icons/arrow-right.svg",
                                      height: 18,
                                      width: 18,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.text.withOpacity(0.6),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    onTap: onTap,
                                  );
                                }

                                void openBottomSheet(BuildContext context, String fieldName) {
                                  TextEditingController controller = TextEditingController();

                                  String labelText;
                                  switch (fieldName) {
                                    case "nome utente":
                                      labelText = "Inserisci il nuovo nome utente";
                                      break;
                                    case "tag instagram":
                                      labelText = "Inserisci il nuovo tag";
                                      break;
                                    case "email":
                                      labelText = "Inserisci la nuova email";
                                      break;
                                    case "immagine profilo":
                                      labelText = "Seleziona la nuova immagine";
                                      break;
                                    default:
                                      labelText = "Inserisci il nuovo valore";
                                  }

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: AppColors.contrast,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    barrierColor: AppColors.text.withOpacity(0.05),
                                    builder: (context) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.35,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20),
                                              Center(
                                                child: Container(
                                                  width: 40,
                                                  height: 5,
                                                  margin: const EdgeInsets.only(bottom: 16),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.text.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  "Modifica $fieldName",
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 40),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: TextField(
                                                  controller: controller,
                                                  decoration: InputDecoration(
                                                    labelText: labelText,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: SizedBox(
                                                    height: 52,
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        String newValue = controller.text.trim();
                                                        if (newValue.isEmpty) return;
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("$fieldName aggiornato/a: $newValue")),
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.primary,
                                                        foregroundColor: const Color(0xfff4f4f6),
                                                        elevation: 0,
                                                        shadowColor: Colors.transparent,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Prosegui",
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ),

                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }

                                return Scaffold(
                                  appBar: AppBar(
                                    title: Text(
                                      "Profilo",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    backgroundColor: AppColors.bgGrey,
                                    elevation: 0,
                                    centerTitle: true,
                                    iconTheme: IconThemeData(color: AppColors.text),
                                  ),
                                  body: Column(
                                    children: [
                                      profileTile("Cambia nome utente", () => openBottomSheet(context, "nome utente")),
                                      profileTile("Cambia tag instagram", () => openBottomSheet(context, "tag instagram")),
                                      profileTile("Cambia email", () => openBottomSheet(context, "email")),
                                      profileTile("Cambia immagine profilo", () => openBottomSheet(context, "immagine profilo")),
                                    ],
                                  ),
                                );
                              },

                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(item['title']!)),
                          );
                        }
                      },


                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.contrast,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.text.withOpacity(0.05),
                              blurRadius: 0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  item['icon']!,
                                  height: 22,
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.text.withOpacity(0.6),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SvgPicture.asset(
                              "assets/icons/arrow-right.svg",
                              height: 18,
                              width: 18,
                              colorFilter: ColorFilter.mode(
                                AppColors.text.withOpacity(0.6),
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class ViewPage extends StatefulWidget {
  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final storage = const FlutterSecureStorage();
  List<Map<String, String>> allMessages = [];
  List<Map<String, String>> filteredMessages = [];
  final TextEditingController searchController = TextEditingController();
  String filterType = "all";
  bool sortDescending = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.bgGrey,
        statusBarIconBrightness: currentTheme == "light" ? Brightness.dark : Brightness.light,
        statusBarBrightness:  currentTheme == "light" ? Brightness.light : Brightness.dark,
      ),
    );
    allMessages = generateMessages();
    filteredMessages = List.from(allMessages);
    searchController.addListener(_filterMessages);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> generateMessages() {
    final now = DateTime.now();
    final List<Map<String, String>> texts = [
      {"text": "Attenzione: l'acqua non è potabile.", "type": "alert"},
      {"text": "Nuova manutenzione programmata venerdì.", "type": "info"},
      {"text": "Aggiornamento orari apertura sportello di matematica.", "type": "info"},
      {"text": "Servizio raccolta differenziata posticipato.", "type": "info"},
      {"text": "Allerta meteo per forti piogge. Ricordarsi di portare ombrelli e/o ponchi", "type": "alert"},
      {"text": "Evento locale: festa di San Martino.", "type": "info"},
      {"text": "Nuove offerte nel negozio del paese.", "type": "info"},
      {"text": "Interruzione temporanea elettricità.", "type": "alert"},
      {"text": "Avviso: chiusura strade per lavori pubblici.", "type": "alert"},
      {"text": "Promozione acqua minerale in negozio.", "type": "info"},
      {"text": "Nuovo avviso pubblico affisso in bacheca.", "type": "alert"},
      {"text": "Aggiornamento sul servizio navetta.", "type": "info"},
      {"text": "Riapertura biblioteca comunale.", "type": "info"},
      {"text": "Mercatino domenicale spostato in piazza centrale.", "type": "info"},
      {"text": "Servizio di pulizia straordinario sabato.", "type": "info"},
      {"text": "Attenzione: lavori fognari in corso.", "type": "alert"},
      {"text": "Nuova ordinanza per la raccolta rifiuti.", "type": "alert"},
      {"text": "Evento sportivo sabato alle 18.", "type": "info"},
      {"text": "Sospensione erogazione gas per manutenzione.", "type": "alert"},
      {"text": "Comunicazione importante dal comune.", "type": "info"},
    ];
    return List.generate(20, (i) {
      final date = now.subtract(Duration(days: i ~/ 3));
      return {
        "text": texts[i]["text"]!,
        "type": texts[i]["type"]!,
        "date": "${date.day}/${date.month}/${date.year}",
      };
    });
  }

  void _filterMessages() {
    final query = searchController.text.toLowerCase();
    List<Map<String, String>> temp = allMessages.where((msg) {
      bool matchesSearch = msg["text"]!.toLowerCase().contains(query);
      bool matchesType = filterType == "all" || msg["type"] == filterType;
      return matchesSearch && matchesType;
    }).toList();

    temp.sort((a, b) {
      DateTime da = _parseDate(a["date"]!);
      DateTime db = _parseDate(b["date"]!);
      return sortDescending ? db.compareTo(da) : da.compareTo(db);
    });

    setState(() {
      filteredMessages = temp;
    });
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  String formatDate(String dateString) {
    final parts = dateString.split('/');
    final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == now.year && date.month == now.month && date.day == now.day) return "OGGI";
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) return "IERI";
    if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) return "DOMANI";
    const months = ["", "GEN", "FEB", "MAR", "APR", "MAG", "GIU", "LUG", "AGO", "SET", "OTT", "NOV", "DIC"];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> grouped = {};
    for (var msg in filteredMessages) {
      grouped.putIfAbsent(msg["date"]!, () => []).add(msg);
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  ...grouped.entries.toList().asMap().entries.map((groupEntry) {
                    final entry = groupEntry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18, bottom: 5, top: 12, right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatDate(entry.key), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: AppColors.text.withOpacity(0.85))),
                            ],
                          ),
                        ),
                        ...entry.value.map((item) {
                          final isAlert = item["type"] == "alert";
                          final iconPath = isAlert ? "assets/icons/alert.svg" : "assets/icons/info.svg";
                          final iconColor = isAlert ? AppColors.red : AppColors.primary;
                          final iconBgColor = isAlert ? AppColors.primary.withOpacity(0.05) : AppColors.primary.withOpacity(0.05);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderGrey, width: 1))),
                            child: Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                                  child: Center(
                                    child: SvgPicture.asset(iconPath, height: 24, width: 24, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Text(item["text"]!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400))),
                                const SizedBox(width: 10),
                                SvgPicture.asset("assets/icons/arrow-right.svg", height: 18, width: 18, colorFilter: ColorFilter.mode(AppColors.text.withOpacity(0.5), BlendMode.srcIn)),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                const SizedBox(height: 26),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: AppColors.text),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.bgGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "Cerca",
                                hintStyle: TextStyle(color: AppColors.text.withOpacity(0.65)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset(
                                    "assets/icons/search.svg",
                                    height: 20,
                                    width: 20,
                                    colorFilter: ColorFilter.mode(AppColors.text.withOpacity(0.65), BlendMode.srcIn),
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.contrast,
                              barrierColor: AppColors.text.withOpacity(0.05),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                List<String> importanza = ['Tutte', 'Info', 'Alert'];
                                List<String> ordinamento = ['Recenti', 'Vecchi'];
                                return StatefulBuilder(
                                  builder: (context, setModalState) {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.45,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.text.withOpacity(0.15), borderRadius: BorderRadius.circular(10)))),
                                            const Center(child: Text("Filtra per", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
                                            const SizedBox(height: 25),
                                            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Importanza", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                            const SizedBox(height: 10),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Row(
                                                children: importanza.map((item) {
                                                  final bool isSelected = filterType == item.toLowerCase() || (item == "Tutte" && filterType == "all");
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setModalState(() { filterType = item == "Tutte" ? "all" : item.toLowerCase(); });
                                                      _filterMessages();
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(right: 6),
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(100),
                                                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.text.withOpacity(0.25), width: 2),
                                                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                                      ),
                                                      child: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.text, fontWeight: FontWeight.w500)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                            const SizedBox(height: 10),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Row(
                                                children: ordinamento.map((item) {
                                                  final bool isSelected = (item == "Recenti" && sortDescending == true) || (item == "Vecchi" && sortDescending == false);
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setModalState(() { sortDescending = item == "Recenti"; });
                                                      _filterMessages();
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(right: 6),
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(100),
                                                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.text.withOpacity(0.25), width: 2),
                                                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                                      ),
                                                      child: Text(item, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.text, fontWeight: FontWeight.w500)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(color: AppColors.bgGrey, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.borderGrey, width: 1)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset('assets/icons/filter.svg', color: AppColors.text.withOpacity(0.65)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          "Pannello Admin",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddInfoPage()),
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.contrast,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text.withOpacity(0.05),
                  blurRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/info.svg",
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(AppColors.text.withOpacity(0.65), BlendMode.srcIn),
                ),
                SizedBox(width: 8),
                Text(
                  "Aggiungi Info",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddInfoPage extends StatefulWidget {
  const AddInfoPage({super.key});

  @override
  State<AddInfoPage> createState() => _AddInfoPageState();
}

class _AddInfoPageState extends State<AddInfoPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedType;
  bool loading = false;

  Future<void> _submitInfo() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tutti i campi sono obbligatori")),
      );
      return;
    }

    setState(() => loading = true);

    final token = await storage.read(key: 'session_token');
    if (token == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sessione scaduta, effettua il login")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://cornaro-backend.onrender.com/add-info"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "title": title,
          "message": message,
          "type": _selectedType,
        }),
      );

      setState(() => loading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avviso aggiunto con successo!")),
        );
        Navigator.of(context).pop();
      } else {
        final error = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: $error")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          "Aggiungi Info",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: modernInput("Titolo"),
              style: TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: modernInput("Messaggio"),
              style: TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey, width: 1),
              ),
              child: DropdownButton<String>(
                value: _selectedType,
                hint: Text(
                  "Seleziona Tipo",
                  style: TextStyle(
                    color: AppColors.text.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins"
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.contrast,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontFamily: "Poppins"
                ),
                items: [
                  DropdownMenuItem(
                    value: "info",
                    child: Text(
                      "Info",
                      style: TextStyle(color: AppColors.text),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "alert",
                    child: Text(
                      "Alert",
                      style: TextStyle(color: AppColors.text),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            modernButton("Aggiungi", loading, _submitInfo),
          ],
        ),
      ),
    );
  }
}