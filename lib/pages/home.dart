import 'package:cornaro/pages/inbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cornaro/pages/add.dart';
import 'package:cornaro/pages/shop.dart';
import 'package:cornaro/pages/promo.dart';
import 'package:cornaro/pages/login.dart';
import 'package:flutter/services.dart';
import 'package:cornaro/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

ValueNotifier<String> themeNotifier = ValueNotifier(currentTheme);
final storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _homeCardIndex = 0;

  String userName = "";
  String name = "";
  String profileImage = "assets/icons/profile.png";

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomeWidget(
        userName: userName,
        name: name,
        profileImage: profileImage,
        initialCardIndex: _homeCardIndex,
      ),
      const AddPage(),
      InboxPage(),
      const ShopPage(),
      const PromoPage(),
    ];

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final n = await storage.read(key: 'user_name') ?? "";
    final u = await storage.read(key: 'user_username') ?? "";
    final p =
        await storage.read(key: 'user_profile_image') ??
        "assets/icons/profile.png";

    setState(() {
      name = n;
      userName = u;
      profileImage = p;

      _pages[0] = HomeWidget(
        userName: userName,
        name: name,
        profileImage: profileImage,
        initialCardIndex: _homeCardIndex,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0 && _selectedIndex != 0) {
        _homeCardIndex = (_homeCardIndex + 1) % 3;
        _pages[0] = HomeWidget(
          userName: userName,
          name: name,
          profileImage: profileImage,
          initialCardIndex: _homeCardIndex,
        );
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ValueListenableBuilder<String>(
        valueListenable: themeNotifier,
        builder: (context, theme, child) {
          final borderColor = AppColors.borderGrey;

          return Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: _BottomBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, theme, child) {
        final primaryColor =
            theme == "light" ? AppColors.primary : AppColors.primary;
        final textColor = theme == "light" ? AppColors.text : AppColors.text;

        return SafeArea(
          bottom: false,
          child: SizedBox(
            height: 55,
            /* child: Row(
              children: [
                _item(
                  index: 0,
                  iconPath: "assets/icons/home.svg",
                  label: "Home",
                  primaryColor: primaryColor,
                  textColor: textColor,
                ),
                _item(
                  index: 1,
                  iconPath:
                      "assets/icons/question-mark-inside-a-bald-male-side-head-outline-svgrepo-com.svg",
                  label: "Spot",
                  primaryColor: primaryColor,
                  textColor: textColor,
                ),
                _item(
                  index: 2,
                  iconPath: "assets/icons/add-plus-circle-svgrepo-com.svg",
                  label: "",
                  isAdd: true,
                  primaryColor: primaryColor,
                  textColor: textColor,
                ),
                _item(
                  index: 3,
                  iconPath: "assets/icons/book-svgrepo-com (1).svg",
                  label: "Shop",
                  primaryColor: primaryColor,
                  textColor: textColor,
                ),
                _item(
                  index: 4,
                  iconPath: "assets/icons/present.svg",
                  label: "Promo",
                  primaryColor: primaryColor,
                  textColor: textColor,
                ),
              ],
            ), */
            child: Column(
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    _item(
                      index: 0,
                      iconPath: "assets/icons/home.svg",
                      label: "Home",
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                    _item(
                      index: 1,
                      iconPath:
                          "assets/icons/clothes-hanger-svgrepo-com.svg",
                      label: "Merch",
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                    _item(
                      index: 2,
                      iconPath: "assets/icons/mail-svgrepo-com (2).svg",
                      label: "Inbox",
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                    _item(
                      index: 3,
                      iconPath: "assets/icons/book-svgrepo-com (1).svg",
                      label: "Shop",
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                    _item(
                      index: 4,
                      iconPath: "assets/icons/present.svg",
                      label: "Promo",
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _item({
    required int index,
    required String iconPath,
    required String label,
    bool isAdd = false,
    required Color primaryColor,
    required Color textColor,
  }) {
    final selected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              height: isAdd ? 38 : 24,
              width: isAdd ? 38 : 24,
              color: selected ? primaryColor : textColor.withOpacity(0.75),
            ),
            if (!isAdd)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        selected ? primaryColor : textColor.withOpacity(0.75),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  final String userName;
  final String name;
  final String profileImage;
  final int initialCardIndex;

  const HomeWidget({
    super.key,
    required this.userName,
    required this.name,
    required this.profileImage,
    this.initialCardIndex = 0,
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Map<String, String>> allMessages = [];
  List<Map<String, String>> filteredMessages = [];
  final TextEditingController searchController = TextEditingController();
  late final PageController _contactsPageController;

  String filterType = "all";
  bool sortDescending = true;
  double maxMessages = 15;
  int _adminTapCount = 0;
  Timer? _resetTapTimer;
  bool isLoading = true;

  final List<String> contactImages = [
    "assets/icons/istockphoto-1279827640-612x612.jpg",
    "assets/icons/un-episodio-di-contro-bullismo-la-vittima-diventa-carnefice-main__748x0_q85_crop_subsampling-2.jpg",
    "assets/icons/istockphoto-1436392629-612x612.jpg",
  ];

  final List<String> contactTexts = [
    "Scopri i contatti utili della scuola per il supporto psicologico.",
    "Consulta i numeri di emergenza per la prevenzione del bullismo.",
    "Trova gli insegnanti di riferimento e i contatti amministrativi.",
  ];

  void _handleAdminTap() async {
    _adminTapCount++;
    _resetTapTimer?.cancel();
    _resetTapTimer = Timer(const Duration(seconds: 1), () {
      _adminTapCount = 0;
    });
    if (_adminTapCount >= 2) {
      _adminTapCount = 0;
      _resetTapTimer?.cancel();
      final isAdmin = await _checkIsAdmin();
      if (isAdmin) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage()));
      }
    }
  }

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
    } catch (_) {}
    return false;
  }

  bool isNetworkImage(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  Future<void> _loadMessages() async {
    final savedMessages = await storage.read(key: 'messages');

    if (savedMessages != null) {
      final List<dynamic> storedList = jsonDecode(savedMessages);
      allMessages =
          storedList
              .map<Map<String, String>>(
                (item) => Map<String, String>.from(item),
              )
              .toList();
      filteredMessages = List.from(allMessages);
      _filterMessages();
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
        final List<Map<String, String>> messages =
            messagesData.map<Map<String, String>>((item) {
              return {
                "title": item["title"] ?? "",
                "text": item["message"] ?? "",
                "type": item["type"] ?? "info",
                "date":
                    item["createdAt"] != null
                        ? _formatBackendDate(item["createdAt"])
                        : "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              };
            }).toList();
        bool isDifferent = jsonEncode(messages) != jsonEncode(allMessages);
        if (isDifferent) {
          await storage.write(key: 'messages', value: jsonEncode(messages));
          allMessages = messages;
          filteredMessages = List.from(allMessages);
          _filterMessages();
        }
      }
    } catch (_) {}

    setState(() {
      isLoading = false;
    });
  }

  String truncateWords(String text, int maxChars) {
    if (text.length <= maxChars) return text;

    List<String> words = text.split(' ');
    String result = '';

    for (var word in words) {
      if ((result + (result.isEmpty ? '' : ' ') + word).length > maxChars) {
        break;
      }
      result += (result.isEmpty ? '' : ' ') + word;
    }

    return result;
  }

  String _formatBackendDate(String isoDate) {
    final dt = DateTime.parse(isoDate).toLocal();
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  void initState() {
    super.initState();
    _contactsPageController = PageController(
      viewportFraction: 0.85,
      initialPage: widget.initialCardIndex,
    );
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
      maxMessages = double.tryParse(saved) ?? 15;
    }
    _filterMessages();
  }

  /* Future<void> _saveMaxMessages() async {
    await storage.write(
      key: 'max_messages',
      value: maxMessages.toInt().toString(),
    );
  } */

  void _filterMessages() {
    final query = searchController.text.toLowerCase();
    List<Map<String, String>> temp =
        allMessages.where((msg) {
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

    filteredMessages = temp;
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  String formatDate(String dateString) {
    final parts = dateString.split('/');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == now.year && date.month == now.month && date.day == now.day)
      return "OGGI";
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day)
      return "IERI";
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day)
      return "DOMANI";
    const months = [
      "",
      "GEN",
      "FEB",
      "MAR",
      "APR",
      "MAG",
      "GIU",
      "LUG",
      "AGO",
      "SET",
      "OTT",
      "NOV",
      "DIC",
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  String formatFullDate(String dateString) {
    final parts = dateString.split('/');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    const months = [
      "",
      "GENNAIO",
      "FEBBRAIO",
      "MARZO",
      "APRILE",
      "MAGGIO",
      "GIUGNO",
      "LUGLIO",
      "AGOSTO",
      "SETTEMBRE",
      "OTTOBRE",
      "NOVEMBRE",
      "DICEMBRE",
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  Widget shimmerItem() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderGrey,
      highlightColor: AppColors.text.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 18,
              bottom: 10,
              top: 16,
              right: 18,
            ),
            child: Container(
              height: 14,
              width: 60,
              color: AppColors.text.withOpacity(0.15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.text.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.text.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        color: AppColors.text.withOpacity(0.15),
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                      Container(
                        height: 14,
                        color: AppColors.text.withOpacity(0.15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 18,
                  width: 18,
                  color: AppColors.text.withOpacity(0.15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
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
            padding: const EdgeInsets.only(top: 60),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  /* Padding(
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
                              backgroundColor: AppColors.bgGrey,
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
                                            const Center(child: Text("Filtra per", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
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
                  ), */
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: PageView.builder(
                          controller: _contactsPageController,
                          itemCount: contactImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.contrast,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.text.withOpacity(0.05),
                                      blurRadius: 0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Image.asset(
                                          contactImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 2,
                                          right: 10,
                                        ),
                                        child: Text(
                                          contactTexts[index],
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(height: 1.25),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SmoothPageIndicator(
                          controller: _contactsPageController,
                          count: contactImages.length,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: AppColors.primary,
                            dotColor: AppColors.text.withOpacity(0.15),
                            spacing: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (isLoading)
                    Column(children: List.generate(6, (_) => shimmerItem()))
                  else
                    ...grouped.entries.toList().asMap().entries.map((
                      groupEntry,
                    ) {
                      final index = groupEntry.key;
                      final entry = groupEntry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 18,
                              bottom: 5,
                              top: 12,
                              right: 18,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(entry.key),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: AppColors.text.withOpacity(0.85),
                                  ),
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
                                  ),
                              ],
                            ),
                          ),
                          ...entry.value.map((item) {
                            final isAlert = item["type"] == "alert";
                            final iconPath =
                                isAlert
                                    ? "assets/icons/alert.svg"
                                    : "assets/icons/info.svg";
                            final iconColor =
                                isAlert ? AppColors.red : AppColors.primary;
                            final iconBgColor =
                                isAlert
                                    ? AppColors.red.withOpacity(0.05)
                                    : AppColors.primary.withOpacity(0.05);

                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return DraggableScrollableSheet(
                                      initialChildSize: 0.6,
                                      minChildSize: 0.4,
                                      maxChildSize: 0.9,
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.bgGrey,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                          ),
                                          child: SingleChildScrollView(
                                            controller: scrollController,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 16,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Container(
                                                      width: 40,
                                                      height: 5,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 16,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.text
                                                            .withOpacity(0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      item["title"]!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    item["text"]!,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        item["type"] == "alert"
                                                            ? "assets/icons/alert.svg"
                                                            : "assets/icons/info.svg",
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                              item["type"] ==
                                                                      "alert"
                                                                  ? AppColors
                                                                      .red
                                                                  : AppColors
                                                                      .primary,
                                                              BlendMode.srcIn,
                                                            ),
                                                        width: 22,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        formatFullDate(
                                                          item["date"]!,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors.text,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.borderGrey,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: iconBgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          iconPath,
                                          height: 24,
                                          width: 24,
                                          colorFilter: ColorFilter.mode(
                                            iconColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        item["text"]!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SvgPicture.asset(
                                      "assets/icons/arrow-right.svg",
                                      height: 18,
                                      width: 18,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.text.withOpacity(0.5),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
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
          Material(
            color: AppColors.primary,
            shape: ContinuousRectangleBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(70),
                bottomRight: Radius.circular(70),
              ),
            ),
            child: SizedBox(
              height: 95,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: 95,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(31),
                          bottomRight: Radius.circular(31),
                        ),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.1),
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            "assets/icons/bground.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _handleAdminTap,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showGeneralDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierLabel: "Close",
                                        barrierColor: AppColors.text
                                            .withOpacity(0.05),
                                        transitionDuration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        pageBuilder: (_, __, ___) {
                                          final double size =
                                              MediaQuery.of(
                                                context,
                                              ).size.width -
                                              80;
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
                                                        child:
                                                            widget
                                                                    .profileImage
                                                                    .isNotEmpty
                                                                ? Image.network(
                                                                  widget
                                                                      .profileImage,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                )
                                                                : Image.asset(
                                                                  "assets/icons/profile.png",
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
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
                                      backgroundColor: AppColors.borderGrey,
                                      backgroundImage: isNetworkImage(widget.profileImage)
                                          ? NetworkImage(widget.profileImage)
                                          : null,
                                      child: !isNetworkImage(widget.profileImage)
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.borderGrey, 
                                                borderRadius: BorderRadius.circular(100)
                                              ),
                                              child: Text(
                                                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "",
                                                style: TextStyle(
                                                  color: AppColors.text,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w500
                                                )
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        truncateWords(widget.name, 18),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        widget.userName.length > 24 
                                          ? '${widget.userName.substring(0, 24)}...' 
                                          : widget.userName,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => SettingsPage(
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
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
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
                          String savedTheme =
                              await storage.read(key: "theme") ?? "light";
                          String selectedTheme = savedTheme;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Scaffold(
                                  backgroundColor: AppColors.bgGrey,
                                  appBar: AppBar(
                                    title: Text(
                                      "Tema",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    backgroundColor: AppColors.bgGrey,
                                    elevation: 0,
                                    centerTitle: true,
                                    iconTheme: IconThemeData(
                                      color: AppColors.text,
                                    ),
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
                                Widget profileTile(
                                  String title,
                                  VoidCallback onTap,
                                ) {
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

                                void openBottomSheet(
                                  BuildContext context,
                                  String fieldName,
                                ) {
                                  TextEditingController controller =
                                      TextEditingController();

                                  String labelText;
                                  switch (fieldName) {
                                    case "nome utente":
                                      labelText =
                                          "Inserisci il nuovo nome utente";
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
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    barrierColor: AppColors.text.withOpacity(
                                      0.05,
                                    ),
                                    builder: (context) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom,
                                        ),
                                        child: SizedBox(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.35,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20),
                                              Center(
                                                child: Container(
                                                  width: 40,
                                                  height: 5,
                                                  margin: const EdgeInsets.only(
                                                    bottom: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.text
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: TextField(
                                                  controller: controller,
                                                  decoration: InputDecoration(
                                                    labelText: labelText,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: SizedBox(
                                                    height: 52,
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        String newValue =
                                                            controller.text
                                                                .trim();
                                                        if (newValue.isEmpty)
                                                          return;
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "$fieldName aggiornato/a: $newValue",
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors.primary,
                                                        foregroundColor:
                                                            const Color(
                                                              0xfff4f4f6,
                                                            ),
                                                        elevation: 0,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Prosegui",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
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
                                    iconTheme: IconThemeData(
                                      color: AppColors.text,
                                    ),
                                  ),
                                  body: Column(
                                    children: [
                                      profileTile(
                                        "Cambia nome utente",
                                        () => openBottomSheet(
                                          context,
                                          "nome utente",
                                        ),
                                      ),
                                      profileTile(
                                        "Cambia tag instagram",
                                        () => openBottomSheet(
                                          context,
                                          "tag instagram",
                                        ),
                                      ),
                                      profileTile(
                                        "Cambia email",
                                        () => openBottomSheet(context, "email"),
                                      ),
                                      profileTile(
                                        "Cambia immagine profilo",
                                        () => openBottomSheet(
                                          context,
                                          "immagine profilo",
                                        ),
                                      ),
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
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
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
    searchController.addListener(_filterMessages);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        fetchMessages(page: currentPage + 1);
      }
    });
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
    scrollController.dispose();
    super.dispose();
  }

  String formatBackendDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> fetchMessages({int page = 1}) async {
    if (isLoading || page > totalPages) return;

    setState(() => isLoading = true);

    final url = Uri.parse(
      'https://cornaro-backend.onrender.com/get-info?page=$page',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> infos = data['infos'];
        totalPages = data['totalPages'];

        final newMessages =
            infos.map<Map<String, String>>((info) {
              return {
                "title": info['title'] ?? '',
                "text": info['message'] ?? '',
                "type": info['type'] ?? 'info',
                "date": formatBackendDate(info['createdAt']),
              };
            }).toList();

        setState(() {
          if (page == 1) {
            allMessages = newMessages;
          } else {
            allMessages.addAll(newMessages);
          }
          filteredMessages = List.from(allMessages);
          _filterMessages();
          currentPage = page;
        });
      }
    } catch (e) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterMessages() {
    final query = searchController.text.toLowerCase();
    List<Map<String, String>> temp =
        allMessages.where((msg) {
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
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  String formatDate(String dateString) {
    final parts = dateString.split('/');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    if (date.year == now.year && date.month == now.month && date.day == now.day)
      return "OGGI";
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day)
      return "IERI";
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day)
      return "DOMANI";
    const months = [
      "",
      "GEN",
      "FEB",
      "MAR",
      "APR",
      "MAG",
      "GIU",
      "LUG",
      "AGO",
      "SET",
      "OTT",
      "NOV",
      "DIC",
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  String formatFullDate(String dateString) {
    final parts = dateString.split('/');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    const months = [
      "",
      "GENNAIO",
      "FEBBRAIO",
      "MARZO",
      "APRILE",
      "MAGGIO",
      "GIUGNO",
      "LUGLIO",
      "AGOSTO",
      "SETTEMBRE",
      "OTTOBRE",
      "NOVEMBRE",
      "DICEMBRE",
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  Widget shimmerItem() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderGrey,
      highlightColor: AppColors.text.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 18,
              bottom: 10,
              top: 16,
              right: 18,
            ),
            child: Container(
              height: 14,
              width: 60,
              color: AppColors.text.withOpacity(0.15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.text.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.text.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        color: AppColors.text.withOpacity(0.15),
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                      Container(
                        height: 14,
                        color: AppColors.text.withOpacity(0.15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 18,
                  width: 18,
                  color: AppColors.text.withOpacity(0.15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> grouped = {};
    for (var msg in filteredMessages) {
      grouped.putIfAbsent(msg["date"]!, () => []).add(msg);
    }

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
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
                              hintStyle: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  "assets/icons/search.svg",
                                  height: 20,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.text.withOpacity(0.65),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 9,
                              ),
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
                            backgroundColor: AppColors.bgGrey,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              List<String> importanza = [
                                'Tutte',
                                'Info',
                                'Alert',
                              ];
                              List<String> ordinamento = ['Recenti', 'Vecchi'];
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.45,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Center(
                                            child: Container(
                                              width: 40,
                                              height: 5,
                                              margin: const EdgeInsets.only(
                                                bottom: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.text
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),

                                          const Center(
                                            child: Text(
                                              "Filtra per",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 25),

                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Text(
                                              "Importanza",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Row(
                                              children:
                                                  importanza.map((item) {
                                                    final bool isSelected =
                                                        filterType ==
                                                            item
                                                                .toLowerCase() ||
                                                        (item == "Tutte" &&
                                                            filterType ==
                                                                "all");
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setModalState(() {
                                                          filterType =
                                                              item == "Tutte"
                                                                  ? "all"
                                                                  : item
                                                                      .toLowerCase();
                                                        });
                                                        _filterMessages();
                                                      },
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              right: 6,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                100,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : AppColors
                                                                        .text
                                                                        .withOpacity(
                                                                          0.25,
                                                                        ),
                                                            width: 2,
                                                          ),
                                                          color:
                                                              isSelected
                                                                  ? AppColors
                                                                      .primary
                                                                      .withOpacity(
                                                                        0.1,
                                                                      )
                                                                  : Colors
                                                                      .transparent,
                                                        ),
                                                        child: Text(
                                                          item,
                                                          style: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : AppColors
                                                                        .text,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ),

                                          const SizedBox(height: 25),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Text(
                                              "Data",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Row(
                                              children:
                                                  ordinamento.map((item) {
                                                    final bool isSelected =
                                                        (item == "Recenti" &&
                                                            sortDescending ==
                                                                true) ||
                                                        (item == "Vecchi" &&
                                                            sortDescending ==
                                                                false);
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setModalState(() {
                                                          sortDescending =
                                                              item == "Recenti";
                                                        });
                                                        _filterMessages();
                                                      },
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              right: 6,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                100,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : AppColors
                                                                        .text
                                                                        .withOpacity(
                                                                          0.25,
                                                                        ),
                                                            width: 2,
                                                          ),
                                                          color:
                                                              isSelected
                                                                  ? AppColors
                                                                      .primary
                                                                      .withOpacity(
                                                                        0.1,
                                                                      )
                                                                  : Colors
                                                                      .transparent,
                                                        ),
                                                        child: Text(
                                                          item,
                                                          style: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : AppColors
                                                                        .text,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
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
                          decoration: BoxDecoration(
                            color: AppColors.bgGrey,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.borderGrey,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              'assets/icons/filter.svg',
                              color: AppColors.text.withOpacity(0.65),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (isLoading && currentPage == 1)
                  Column(children: List.generate(6, (_) => shimmerItem()))
                else
                  ...grouped.entries.toList().asMap().entries.map((groupEntry) {
                    final entry = groupEntry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 18,
                            bottom: 5,
                            top: 12,
                            right: 18,
                          ),
                          child: Text(
                            formatDate(entry.key),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: AppColors.text.withOpacity(0.85),
                            ),
                          ),
                        ),
                        ...entry.value.map((item) {
                          final isAlert = item["type"] == "alert";
                          final iconPath =
                              isAlert
                                  ? "assets/icons/alert.svg"
                                  : "assets/icons/info.svg";
                          final iconColor =
                              isAlert ? AppColors.red : AppColors.primary;
                          final iconBgColor = AppColors.primary.withOpacity(
                            0.05,
                          );

                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return DraggableScrollableSheet(
                                    initialChildSize: 0.6,
                                    minChildSize: 0.4,
                                    maxChildSize: 0.9,
                                    expand: false,
                                    builder: (context, scrollController) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.bgGrey,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                        ),
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width: 40,
                                                    height: 5,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.text
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                ),

                                                Center(
                                                  child: Text(
                                                    item["title"]!,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 16),

                                                Text(
                                                  item["text"]!,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),

                                                const SizedBox(height: 24),

                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      isAlert
                                                          ? "assets/icons/alert.svg"
                                                          : "assets/icons/info.svg",
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                            isAlert
                                                                ? AppColors.red
                                                                : AppColors
                                                                    .primary,
                                                            BlendMode.srcIn,
                                                          ),
                                                      width: 22,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      formatFullDate(
                                                        item["date"]!,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors.text,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.borderGrey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: iconBgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        iconPath,
                                        height: 24,
                                        width: 24,
                                        colorFilter: ColorFilter.mode(
                                          iconColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item["text"]!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SvgPicture.asset(
                                    "assets/icons/arrow-right.svg",
                                    height: 18,
                                    width: 18,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.text.withOpacity(0.5),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),

                if (isLoading && currentPage > 1)
                  Column(children: List.generate(3, (_) => shimmerItem())),
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

  Widget _tile({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: 20,
              width: 20,
              colorFilter: ColorFilter.mode(
                AppColors.text.withOpacity(0.65),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        child: Column(
          children: [
            _tile(
              icon: "assets/icons/info.svg",
              label: "Aggiungi Info",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddInfoPage()),
                );
              },
            ),
            _tile(
              icon: "assets/icons/edit.svg",
              label: "Gestisci / Elimina Info",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageInfoPage()),
                );
              },
            ),
          ],
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Errore: $error")));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Errore: $e")));
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
                    fontFamily: "Poppins",
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.contrast,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontFamily: "Poppins",
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

class ManageInfoPage extends StatefulWidget {
  const ManageInfoPage({super.key});

  @override
  State<ManageInfoPage> createState() => _ManageInfoPageState();
}

class _ManageInfoPageState extends State<ManageInfoPage> {
  final storage = FlutterSecureStorage();
  List infos = [];
  bool loading = true;
  int page = 1;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadInfos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !loading &&
          hasMore) {
        loadInfos(nextPage: true);
      }
    });
  }

  Future<void> loadInfos({bool nextPage = false}) async {
    if (nextPage) {
      page++;
    } else {
      page = 1;
      infos.clear();
      hasMore = true;
    }

    setState(() => loading = true);

    final response = await http.get(
      Uri.parse("https://cornaro-backend.onrender.com/get-info?page=$page"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newInfos = data["infos"];
      setState(() {
        infos.addAll(newInfos);
        loading = false;
        if (newInfos.length < 15) {
          hasMore = false;
        }
      });
    } else {
      setState(() => loading = false);
    }
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    const months = [
      "",
      "GENNAIO",
      "FEBBRAIO",
      "MARZO",
      "APRILE",
      "MAGGIO",
      "GIUGNO",
      "LUGLIO",
      "AGOSTO",
      "SETTEMBRE",
      "OTTOBRE",
      "NOVEMBRE",
      "DICEMBRE",
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  Future<void> deleteInfo(String id) async {
    final token = await storage.read(key: 'session_token');
    if (token == null) return;
    final response = await http.post(
      Uri.parse("https://cornaro-backend.onrender.com/delete-info"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"id": id}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Post eliminato")));
      loadInfos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore: ${jsonDecode(response.body)['message']}"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          "Gestisci Info",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body:
          infos.isEmpty && loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: infos.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= infos.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = infos[index];
                  final isAlert = item["type"] == "alert";
                  final date = formatDate(item["createdAt"]);
                  return Card(
                    color: AppColors.contrast,
                    elevation: 2,
                    shadowColor: AppColors.text.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["title"],
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColors.text,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isAlert
                                                    ? AppColors.red.withOpacity(
                                                      0.2,
                                                    )
                                                    : AppColors.primary
                                                        .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            isAlert ? "ALERT" : "INFO",
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isAlert
                                                      ? AppColors.red
                                                      : AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["message"],
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 14,
                                        color: AppColors.text.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ModifyInfoPage(
                                                  id: item["_id"],
                                                  initialTitle: item["title"],
                                                  initialMessage:
                                                      item["message"],
                                                  initialType: item["type"],
                                                ),
                                          ),
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        "assets/icons/edit.svg",
                                        height: 22,
                                        width: 22,
                                        colorFilter: ColorFilter.mode(
                                          AppColors.primary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: AppColors.text
                                              .withOpacity(0.05),
                                          builder:
                                              (_) => AlertDialog(
                                                backgroundColor:
                                                    AppColors.contrast,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                content: const Text(
                                                  "Sei sicuro di voler eliminare questo post? Questa è un'azione irreversibile",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: Text(
                                                      "Annulla",
                                                      style: TextStyle(
                                                        color: AppColors.text,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      deleteInfo(item["_id"]);
                                                    },
                                                    child: Text(
                                                      "Elimina",
                                                      style: TextStyle(
                                                        color: AppColors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        "assets/icons/delete.svg",
                                        height: 22,
                                        width: 22,
                                        colorFilter: ColorFilter.mode(
                                          AppColors.red,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 12,
                                    color: AppColors.text.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String title;
  final String message;
  final String type;
  final String date;

  const DetailPage({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool pinned = false;

  @override
  Widget build(BuildContext context) {
    final isAlert = widget.type == "alert";
    final iconPath =
        isAlert ? "assets/icons/alert.svg" : "assets/icons/info.svg";
    final iconColor = isAlert ? AppColors.red : AppColors.primary;

    String formatDate(String dateString) {
      final parts = dateString.split('/');
      final date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      const months = [
        "",
        "GENNAIO",
        "FEBBRAIO",
        "MARZO",
        "APRILE",
        "MAGGIO",
        "GIUGNO",
        "LUGLIO",
        "AGOSTO",
        "SETTEMBRE",
        "OTTOBRE",
        "NOVEMBRE",
        "DICEMBRE",
      ];

      return "${date.day} ${months[date.month]} ${date.year}";
    }

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        title: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              setState(() {
                pinned = !pinned;
              });
            },
            child: SvgPicture.asset(
              pinned ? "assets/icons/pin_on.svg" : "assets/icons/pin_off.svg",
              colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
              width: 23,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    width: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDate(widget.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            /* Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    width: 22,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  type,
                  style: TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.w500),
                ),
              ],
            ), */
            const SizedBox(height: 16),
            Text(widget.message, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class ModifyInfoPage extends StatefulWidget {
  final String id;
  final String initialTitle;
  final String initialMessage;
  final String initialType;

  const ModifyInfoPage({
    super.key,
    required this.id,
    required this.initialTitle,
    required this.initialMessage,
    required this.initialType,
  });

  @override
  State<ModifyInfoPage> createState() => _ModifyInfoPageState();
}

class _ModifyInfoPageState extends State<ModifyInfoPage> {
  final storage = FlutterSecureStorage();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedType;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _messageController.text = widget.initialMessage;
    _selectedType = widget.initialType;
  }

  Future<void> _submitModification() async {
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
        Uri.parse("https://cornaro-backend.onrender.com/update-info"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "id": widget.id,
          "title": title,
          "message": message,
          "type": _selectedType,
        }),
      );

      setState(() => loading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avviso modificato con successo!")),
        );
        Navigator.of(context).pop();
      } else {
        final error = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Errore: $error")));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Errore: $e")));
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
          "Modifica Info",
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
              style: TextStyle(color: AppColors.text, fontFamily: "Poppins"),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: TextField(
                controller: _messageController,
                decoration: modernInput("Messaggio"),
                style: TextStyle(color: AppColors.text, fontFamily: "Poppins"),
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: null,
              ),
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
                    fontFamily: "Poppins",
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.contrast,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontFamily: "Poppins",
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
                  setState(() => _selectedType = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            modernButton("Modifica", loading, _submitModification),
          ],
        ),
      ),
    );
  }
}
