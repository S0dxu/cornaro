import 'package:flutter/material.dart';
import 'package:cornaro/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shimmer/shimmer.dart';
import 'package:cornaro/state/message_notifier.dart';

Future<List<Map<String, dynamic>>> fetchChats(String token) async {
  final response = await http.get(
    Uri.parse('https://cornaro-backend.onrender.com/chats'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Errore nel caricamento delle chat');
  }

  final List data = jsonDecode(response.body);
  List<Map<String, dynamic>> chats = [];

  for (var chat in data) {
    final sellerEmail = chat['other'];

    final sellerResponse = await http.get(
      Uri.parse('https://cornaro-backend.onrender.com/profile/$sellerEmail'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    Map<String, dynamic> sellerData;
    if (sellerResponse.statusCode == 200) {
      sellerData = jsonDecode(sellerResponse.body);
    } else {
      sellerData = {
        'firstName': sellerEmail.split(".")[0],
        'lastName': "",
        'profileImage': "",
        'isOnline': false,
      };
    }

    final lastMessage = chat['lastMessage'];
    final lastMessageSeen =
        lastMessage != null ? lastMessage['seen'] ?? false : false;
    final isMe =
        lastMessage != null ? lastMessage['sender'] == chat['me'] : false;

    final lastMessageText =
        lastMessage != null ? lastMessage['text'] ?? '' : '';
    final lastMessageTime =
        lastMessage != null
            ? lastMessage['createdAt'] ?? chat['updatedAt'] ?? ''
            : chat['updatedAt'] ?? '';

    final bookInfo =
        chat['book'] != null
            ? {
              'title': chat['book']['title'] ?? '',
              'image': chat['book']['image'] ?? '',
              'price': chat['book']['price'] ?? 0,
            }
            : null;

    chats.add({
      'chatId': chat['_id'],
      'username': '${sellerData['firstName']} ${sellerData['lastName']}',
      'avatar': sellerData['profileImage'],
      'online': sellerData['isOnline'] ?? false,
      'lastMessage': lastMessageText,
      'time': lastMessageTime,
      'seen': lastMessageSeen,
      'isMe': isMe,
      'book': bookInfo,
    });
  }

  return chats;
}

Future<List<Map<String, String>>> fetchMessages(
  String chatId,
  String token, {
  int skip = 0,
  int limit = 20,
}) async {
  final response = await http.get(
    Uri.parse(
      'https://cornaro-backend.onrender.com/chats/$chatId/messages?skip=$skip&limit=$limit',
    ),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map<Map<String, String>>((msg) {
      return {
        'sender': msg['sender'],
        'text': msg['text'],
        'time': msg['createdAt'],
        'isMe': msg['isMe']?.toString() ?? 'false',
      };
    }).toList();
  } else {
    throw Exception('Errore nel caricamento dei messaggi');
  }
}

String formatTime(String dateString) {
  if (dateString.isEmpty) return "";

  try {
    final date = DateTime.parse(dateString).toLocal();
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $amPm";
  } catch (_) {
    return dateString;
  }
}

bool isSameDay(String a, String b) {
  try {
    final da = DateTime.parse(a).toLocal();
    final db = DateTime.parse(b).toLocal();
    return da.year == db.year && da.month == db.month && da.day == db.day;
  } catch (_) {
    return true;
  }
}

String formatDayHeader(String dateString) {
  try {
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return "OGGI";
    if (target == yesterday) return "IERI";

    final day = target.day.toString().padLeft(2, '0');
    final month = target.month.toString().padLeft(2, '0');

    return "$day/$month/${target.year}";
  } catch (_) {
    return "";
  }
}

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with WidgetsBindingObserver {
  int _selectedTab = 0;
  List<Map<String, dynamic>> chats = [];
  final storage = const FlutterSecureStorage();
  Timer? _refreshTimer;
  final imgurRegex = RegExp(r'https://i\.imgur\.com/\S+\.(?:png|jpg|jpeg|gif)');
  bool isLoading = true;

  String displayMessage(String? message) {
    if (message == null || message.trim().isEmpty) return "Foto";

    String withoutLinks = message.replaceAll(imgurRegex, "").trim();

    return withoutLinks.isEmpty ? "Foto" : withoutLinks;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadChats();
    startTimer();
  }

  void startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => loadChats(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      startTimer();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget shimmerChatItem({bool isFirst = false}) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderGrey,
      highlightColor: AppColors.text.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.text.withOpacity(0.2)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                top: isFirst ? 8 : 16,
                bottom: 4,
              ),
              child: Container(
                height: 14,
                width: 60,
                color: AppColors.text.withOpacity(0.15),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          ],
        ),
      ),
    );
  }

  Future<void> loadChats() async {
    setState(() => isLoading = true);
    final token = await storage.read(key: 'session_token');
    if (token == null) return;

    final data = await fetchChats(token);

    data.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['updatedAt'] ?? a['time'] ?? '') ??
          DateTime(1970);
      final dateB =
          DateTime.tryParse(b['updatedAt'] ?? b['time'] ?? '') ??
          DateTime(1970);
      return dateB.compareTo(dateA);
    });

    final hasUnread = data.any((chat) {
      return chat['seen'] == false && chat['isMe'] == false;
    });

    hasNewMessagesNotifier.value = hasUnread;

    setState(() {
      chats = data;
      isLoading = false;
    });

  }

  String formatDate(String dateString) {
    if (dateString.isEmpty) return "";

    DateTime date;
    try {
      date = DateTime.parse(dateString).toLocal();
    } catch (_) {
      return dateString;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return "${formatTime(dateString)}";
    if (target == yesterday) return "IERI";
    if (target == tomorrow) return "DOMANI";

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
    return "${target.day} ${months[target.month]} ${target.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.bgGrey,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Messaggi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                _selectedTab == 0
                                    ? AppColors.text
                                    : AppColors.text.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Libro correlato",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                _selectedTab == 1
                                    ? AppColors.text
                                    : AppColors.text.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    color: AppColors.borderGrey,
                  ),
                  AnimatedAlign(
                    alignment:
                        _selectedTab == 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: 1.5,
                      width: MediaQuery.of(context).size.width / 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
      body:
          isLoading && chats.isEmpty
              ? ListView.builder(
                itemCount: 4,
                itemBuilder: (_, index) => shimmerChatItem(isFirst: index == 0),
              )
              : ListView.separated(
                itemCount: chats.length,
                separatorBuilder:
                    (_, __) =>
                        Divider(color: AppColors.borderGrey, thickness: 1),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  if (_selectedTab == 1 && chat['book'] != null) {
            final book = chat['book'];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: book['image'] != ""
                    ? Image.network(
                        book['image'],
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 56,
                        width: 56,
                        color: AppColors.borderGrey,
                        child: Icon(Icons.book, color: AppColors.text),
                      ),
              ),
              title: Text(
                book['title'] ?? '',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "${book['price'].toString()} €",
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.75),
                  fontSize: 16,
                ),
              ),
              trailing: SvgPicture.asset(
                "assets/icons/arrow-right.svg",
                height: 18,
                width: 18,
                colorFilter: ColorFilter.mode(
                  AppColors.text.withOpacity(0.5),
                  BlendMode.srcIn,
                ),
              ),
              onTap: () {
                //TODO
              },
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Text(
                  formatDate(chat['time']),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: AppColors.text.withOpacity(0.85),
                  ),
                ),
              ),
              ListTile(
                leading: UserAvatar(
                  avatar: chat['avatar'] is String
                      ? chat['avatar']
                      : chat['username'][0],
                  fallbackText: chat['username'][0].toUpperCase(),
                  radius: 22,
                  showOnline: true,
                  online: chat['online'] ?? false,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat['username'],
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              height: 1,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        if (!(chat['seen'] ?? true) &&
                            !(chat['isMe'] ?? false))
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.primary,
                            ),
                            child: Center(
                              child: Text(
                                "nuovi messaggi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  height: 1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 18,
                      child: Row(
                        children: [
                          if ((chat['seen'] ?? true) &&
                              (chat['isMe'] ?? true))
                            Row(
                              children: [
                                Center(
                                  child: Transform.translate(
                                    offset: const Offset(0, 1),
                                    child: SvgPicture.asset(
                                      "assets/icons/seen-svgrepo-com.svg",
                                      height: 20,
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2),
                              ],
                            ),
                          chat['lastMessage'] != null &&
                                  imgurRegex.hasMatch(chat['lastMessage']!)
                              ? Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, 1),
                                      child: SvgPicture.asset(
                                        "assets/icons/image-svgrepo-com.svg",
                                        height: 20,
                                        width: 20,
                                        colorFilter: ColorFilter.mode(
                                          AppColors.text.withOpacity(0.75),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      displayMessage(chat['lastMessage']),
                                      style: TextStyle(
                                        color:
                                            AppColors.text.withOpacity(0.75),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              : Expanded(
                                  child: Text(
                                    chat['lastMessage']!,
                                    style: TextStyle(
                                      color: AppColors.text.withOpacity(0.75),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      height: 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: SvgPicture.asset(
                  "assets/icons/arrow-right.svg",
                  height: 18,
                  width: 18,
                  colorFilter: ColorFilter.mode(
                    AppColors.text.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chat['chatId'],
                        username: chat['username'],
                        avatar: chat['avatar'] is String
                            ? chat['avatar']
                            : chat['username'][0],
                        book: chat['book'],
                      ),
                    ),
                  );
                  await loadChats();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  String chatId;
  final String username;
  final dynamic avatar;
  final Map<String, dynamic>? book;
  final VoidCallback? onChatOpened;

  ChatPage({
    Key? key,
    required this.chatId,
    required this.username,
    this.avatar,
    this.book,
    this.onChatOpened,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final storage = const FlutterSecureStorage();

  File? _imageToPreview;
  final imgurRegex = RegExp(r'https://i\.imgur\.com/\S+\.(?:png|jpg|jpeg|gif)');
  bool _isSending = false;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 20;
  bool _isAtBottom = true;
  int _newMessagesCount = 0;
  Timer? _checkMessagesTimer;

  @override
  void initState() {
    super.initState();
    widget.onChatOpened?.call();

    _loadMessages();
    _checkMessagesTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_isLoading && mounted) {
        await _checkNewMessages();
      }
    });

    _scrollController.addListener(() {
      final currentScroll = _scrollController.position.pixels;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final minScroll = _scrollController.position.minScrollExtent;

      _isAtBottom = currentScroll <= minScroll + 50;
      if (_isAtBottom) {
        setState(() {
          _newMessagesCount = 0;
        });
      }

      if (currentScroll >= maxScroll - 100 && !_isLoading && _hasMore) {
        _loadMessages(loadOlder: true);
      }
    });
  }

  @override
  void dispose() {
    _checkMessagesTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkNewMessages() async {
    if (!mounted) return;
    _isLoading = true;
    final token = await storage.read(key: 'session_token');
    if (token == null) return;

    final fetched = await fetchMessages(
      widget.chatId,
      token,
      skip: 0,
      limit: 20,
    );
    final newFetched = fetched.reversed.toList();

    /* print(newFetched); */

    if (!mounted) return;
    setState(() {
      final onlyNew =
          newFetched.where((m) {
            final exists = _messages.any((msg) => msg['time'] == m['time']);
            /* for (final msg in _messages) {
              print(msg['local']);
            } */
            _messages.removeWhere((msg) => msg['local'] == true);
            return !exists;
          }).toList();

      /* print(onlyNew); */

      if (onlyNew.isNotEmpty) {
        _messages.insertAll(0, onlyNew);
        if (_isAtBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.minScrollExtent,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          _newMessagesCount += onlyNew.length;
        }
      }
    });

    _isLoading = false;
  }

  Future<void> _loadMessages({bool loadOlder = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    final token = await storage.read(key: 'session_token');
    if (token == null) {
      _isLoading = false;
      return;
    }

    final fetched = await fetchMessages(
      widget.chatId,
      token,
      skip: _skip,
      limit: _limit,
    );
    final newFetched = fetched.reversed.toList();

    if (!mounted) {
      _isLoading = false;
      return;
    }

    setState(() {
      if (loadOlder) {
        _messages.addAll(newFetched);
      } else {
        final existingTimes = _messages.map((m) => m['time']).toSet();
        final onlyNew =
            newFetched
                .where((m) => !existingTimes.contains(m['time']))
                .toList();
        if (onlyNew.isNotEmpty) {
          _messages.insertAll(0, onlyNew);
          if (_isAtBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          } else {
            _newMessagesCount += onlyNew.length;
          }
        }
      }

      _skip += fetched.length;
      if (fetched.length < _limit) _hasMore = false;
    });

    _isLoading = false;
  }

  Future<void> _pickImageFromGalleryOrCamera() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.text.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.text.withOpacity(0.75),
                ),
                title: Text(
                  'Galleria',
                  style: TextStyle(color: AppColors.text.withOpacity(0.75)),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    await _handlePickedImage(File(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: AppColors.text.withOpacity(0.75),
                ),
                title: Text(
                  'Fotocamera',
                  style: TextStyle(color: AppColors.text.withOpacity(0.75)),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    await _handlePickedImage(File(pickedFile.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> optimizeImage(File file) async {
    final dir = await getTemporaryDirectory();

    final targetPath = p.join(
      dir.path,
      'optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
      minWidth: 1200,
      minHeight: 1200,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (compressed == null) {
      throw Exception("Compression failed");
    }

    return File(compressed.path);
  }

  /* Future<void> _uploadAndSendImage(File file) async {
    try {
      const clientId = '3b4fd0382862345';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgur.com/3/upload'),
      );
      request.headers['Authorization'] = 'Client-ID $clientId';
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data["success"] == true) {
        final imgurLink = data["data"]["link"];
        await _sendMessage(imgurLink);
      } else {
        throw Exception("Errore upload Imgur");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore caricamento immagine: ${e.toString()}")),
      );
    }
  } */

  Future<void> _handlePickedImage(File file) async {
    final optimizedFile = await optimizeImage(file);

    setState(() {
      _imageToPreview = optimizedFile;
    });
  }

  Future<String?> _uploadImage(File file) async {
    try {
      const clientId = '3b4fd0382862345';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgur.com/3/upload'),
      );
      request.headers['Authorization'] = 'Client-ID $clientId';
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data["success"] == true) {
        /* print(data["data"]["link"]); */
        return data["data"]["link"];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore caricamento immagine: ${e.toString()}")),
      );
    }
    return null;
  }

  Future<void> _sendMessage(String text) async {
    if (_isSending) return;
    _isSending = true;

    final token = await storage.read(key: 'session_token');
    if (token == null) {
      _isSending = false;
      return;
    }

    String chatId = widget.chatId;

    if (chatId.isEmpty && widget.book != null) {
      final response = await http.post(
        Uri.parse('https://cornaro-backend.onrender.com/chats/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sellerEmail': widget.book?['sellerEmail'],
          'bookId': widget.book?['_id'],
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        chatId = data['chatId'];
        setState(() {
          widget.chatId = chatId;
        });
      } else {
        _isSending = false;
        return;
      }
    }

    String? imageUrl;
    if (_imageToPreview != null) {
      imageUrl = await _uploadImage(_imageToPreview!);
      if (text != "") {
        imageUrl = "$imageUrl $text";
      }
      print(imageUrl);
    }

    if ((text.isEmpty && imageUrl == null)) {
      _isSending = false;
      return;
    }

    final response = await http.post(
      Uri.parse('https://cornaro-backend.onrender.com/chats/$chatId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': imageUrl ?? text}),
    );

    if (response.statusCode == 201) {
      _controller.clear();
      setState(() {
        _messages.insert(0, {
          'sender': 'me',
          'text': imageUrl ?? text,
          'time': DateTime.now().toIso8601String(),
          'isMe': 'true',
          'local': true,
        });
        _imageToPreview = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    _isSending = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.bgGrey,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        titleSpacing: 0,
        title: Row(
          children: [
            /* UserAvatar(
              avatar: widget.avatar is String
                  ? widget.avatar
                  : widget.username[0].toUpperCase(),
              fallbackText: widget.username[0].toUpperCase(),
              radius: 16,
            ),
            const SizedBox(width: 8), */
            Expanded(
              child: Text(
                widget.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderGrey,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/info.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                AppColors.text,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              //TODO
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.book != null && widget.book!['title'] != "")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    child: Row(
                      children: [
                        if (widget.book!['image'] != null &&
                            widget.book!['image'] != '')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              widget.book!['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            color: AppColors.borderGrey,
                            child: Center(
                              child: Text(
                                widget.book!['title'] != null &&
                                        widget.book!['title'].isNotEmpty
                                    ? widget.book!['title'][0]
                                    : '?',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book!['title'] ?? '',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  height: 1.8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.book!['price'] ?? 0} €",
                                style: TextStyle(
                                  color: AppColors.text.withOpacity(0.75),
                                  fontSize: 14,
                                  height: 1,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${(widget.book!['price'] + (widget.book!['price'] * 0.014) + 0.75).toStringAsFixed(2).replaceAll('.', ',')} € Include la Protezione acquisti",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "assets/icons/protection-secure-security-svgrepo-com.svg",
                                    color: AppColors.primary,
                                    width: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe =
                        (message['isMe']?.toString().toLowerCase() == 'true');

                    final seen = message['seen'] ?? false;

                    final previousIsMe =
                        index > 0
                            ? (_messages[index - 1]['isMe']
                                    ?.toString()
                                    .toLowerCase() ==
                                'true')
                            : null;
                    final nextIsMe =
                        index < _messages.length - 1
                            ? (_messages[index + 1]['isMe']
                                    ?.toString()
                                    .toLowerCase() ==
                                'true')
                            : null;

                    final showAvatar = !isMe && (previousIsMe != false);

                    final currentTime = message['time'];
                    final previousTime =
                        index < _messages.length - 1
                            ? _messages[index + 1]['time']
                            : null;

                    final showDateHeader =
                        previousTime == null ||
                        !isSameDay(currentTime, previousTime);

                    /* final topMargin = previousIsMe == null
                        ? 12
                        : (previousIsMe == isMe ? 2 : 12);
                    final bottomMargin = nextIsMe == null
                        ? 12
                        : (nextIsMe == isMe ? 2 : 12); */

                    String? imageUrl;
                    String? remainingText;

                    final match = imgurRegex.firstMatch(message['text'] ?? '');
                    if (match != null) {
                      imageUrl = match.group(0);
                      remainingText =
                          message['text']!.replaceFirst(imageUrl, '').trim();
                    } else {
                      remainingText = message['text'];
                    }

                    final nextMessage =
                        index > 0 ? _messages[index - 1] : null;

                    final nextIsMeVisual = nextMessage != null
                        ? (nextMessage['isMe']?.toString().toLowerCase() == 'true')
                        : null;

                    final bool isLastMine =
                        isMe && (nextIsMe != true);

                    final bool isLastHis =
                        !isMe && (nextIsMe != false);

                    return Column(
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              formatDayHeader(currentTime),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: AppColors.text.withOpacity(0.75),
                              ),
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment:
                              isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            if (showAvatar)
                              Transform.translate(
                                offset: const Offset(0, -2),
                                child: UserAvatar(
                                  avatar: widget.avatar is String
                                      ? widget.avatar
                                      : widget.username[0].toUpperCase(),
                                  fallbackText: widget.username[0].toUpperCase(),
                                  radius: 16,
                                ),
                              )
                            else
                              const SizedBox(width: 32),
                            SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                    isMe ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                margin: EdgeInsets.only(
                                  /* top: (isLastMine == true || isLastHis == true ) ? 12 : 3, */
                                  top: 1.5,
                                  bottom: 1.5
                                ),
                                /* margin: EdgeInsets.all(3), */
                                decoration: BoxDecoration(
                                  color:
                                      isMe
                                          ? AppColors.contrast
                                          : AppColors.bgGrey,
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                          imageUrl,
                                          width: 200,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: AppColors.borderGrey,
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: AppColors.borderGrey,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: AppColors.text,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (remainingText != null &&
                                        remainingText.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          remainingText,
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        textAlign: TextAlign.left,
                                        formatTime(message['time']!),
                                        style: TextStyle(
                                          color: AppColors.text.withOpacity(
                                            0.6,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    if (isMe && seen && index == 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Visto',
                                          style: TextStyle(
                                            color: AppColors.text.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                if (_newMessagesCount > 0)
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          _scrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                        setState(() {
                          _newMessagesCount = 0;
                          _isAtBottom = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.contrast,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_newMessagesCount',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_downward, color: AppColors.text),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_imageToPreview != null)
                  Positioned(
                    bottom: 15,
                    left: 15,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageToPreview!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageToPreview = null),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderGrey)),
              color: AppColors.bgGrey,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 6,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Scrivi un messaggio qui',
                          hintStyle: TextStyle(
                            color: AppColors.text.withOpacity(0.75),
                          ),
                          filled: true,
                          fillColor: AppColors.contrast,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _pickImageFromGalleryOrCamera,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/image-plus-svgrepo-com (1).svg',
                          colorFilter: ColorFilter.mode(
                            AppColors.text.withOpacity(0.5),
                            BlendMode.srcIn,
                          ),
                          height: 26,
                          width: 26,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          _isSending
                              ? null
                              : () {
                                final text = _controller.text.trim();
                                if (text.isNotEmpty ||
                                    _imageToPreview != null) {
                                  _sendMessage(text);
                                }
                              },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        color: Colors.transparent,
                        child: Text(
                          _isSending ? 'Invio...' : 'Invia',
                          style: TextStyle(
                            color:
                                _isSending
                                    ? AppColors.text.withOpacity(0.75)
                                    : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final dynamic avatar;
  final String fallbackText;
  final double radius;
  final bool showOnline;
  final bool online;

  const UserAvatar({
    super.key,
    required this.avatar,
    required this.fallbackText,
    required this.radius,
    this.showOnline = false,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.borderGrey,
          child:
              avatar is String && avatar != ""
                  ? ClipOval(
                    child: Image.network(
                      avatar,
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Text(
                    fallbackText,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w400,
                      fontSize: radius,
                    ),
                  ),
        ),
        if (showOnline)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: online ? AppColors.bgGrey : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        online ? AppColors.green : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/* import 'package:flutter/material.dart';
import 'package:cornaro/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';


Future<List<Map<String, dynamic>>> fetchChats(String token) async {
  final response = await http.get(
    Uri.parse('https://cornaro-backend.onrender.com/chats'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Errore nel caricamento delle chat');
  }

  final List data = jsonDecode(response.body);
  List<Map<String, dynamic>> chats = [];

  for (var chat in data) {
    final sellerEmail = chat['other'];

    final sellerResponse = await http.get(
      Uri.parse('https://cornaro-backend.onrender.com/profile/$sellerEmail'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    Map<String, dynamic> sellerData;
    if (sellerResponse.statusCode == 200) {
      sellerData = jsonDecode(sellerResponse.body);
    } else {
      sellerData = {
        'firstName': sellerEmail.split(".")[0],
        'lastName': "",
        'profileImage': "",
        'isOnline': false,
      };
    }

    final lastMessage = chat['lastMessage'];
    final lastMessageSeen =
        lastMessage != null ? lastMessage['seen'] ?? false : false;
    final isMe =
        lastMessage != null ? lastMessage['sender'] == chat['me'] : false;

    final lastMessageText =
        lastMessage != null ? lastMessage['text'] ?? '' : '';
    final lastMessageTime =
        lastMessage != null
            ? lastMessage['createdAt'] ?? chat['updatedAt'] ?? ''
            : chat['updatedAt'] ?? '';

    final bookInfo =
        chat['book'] != null
            ? {
              'title': chat['book']['title'] ?? '',
              'image': chat['book']['image'] ?? '',
              'price': chat['book']['price'] ?? 0,
            }
            : null;

    chats.add({
      'chatId': chat['_id'],
      'username': '${sellerData['firstName']} ${sellerData['lastName']}',
      'avatar': sellerData['profileImage'],
      'online': sellerData['isOnline'] ?? false,
      'lastMessage': lastMessageText,
      'time': lastMessageTime,
      'seen': lastMessageSeen,
      'isMe': isMe,
      'book': bookInfo,
    });
  }

  return chats;
}

Future<List<Map<String, String>>> fetchMessages(
  String chatId,
  String token, {
  int skip = 0,
  int limit = 20,
}) async {
  final response = await http.get(
    Uri.parse(
      'https://cornaro-backend.onrender.com/chats/$chatId/messages?skip=$skip&limit=$limit',
    ),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map<Map<String, String>>((msg) {
      return {
        'sender': msg['sender'],
        'text': msg['text'],
        'time': msg['createdAt'],
        'isMe': msg['isMe']?.toString() ?? 'false',
      };
    }).toList();
  } else {
    throw Exception('Errore nel caricamento dei messaggi');
  }
}

String formatTime(String dateString) {
  if (dateString.isEmpty) return "";

  try {
    final date = DateTime.parse(dateString).toLocal();
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $amPm";
  } catch (_) {
    return dateString;
  }
}

bool isSameDay(String a, String b) {
  try {
    final da = DateTime.parse(a).toLocal();
    final db = DateTime.parse(b).toLocal();
    return da.year == db.year && da.month == db.month && da.day == db.day;
  } catch (_) {
    return true;
  }
}

String formatDayHeader(String dateString) {
  try {
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return "OGGI";
    if (target == yesterday) return "IERI";

    final day = target.day.toString().padLeft(2, '0');
    final month = target.month.toString().padLeft(2, '0');

    return "$day/$month/${target.year}";
  } catch (_) {
    return "";
  }
}

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  int _selectedTab = 0;
  List<Map<String, dynamic>> chats = [];
  final storage = const FlutterSecureStorage();
  Timer? _refreshTimer;
  final imgurRegex = RegExp(r'https://i\.imgur\.com/\S+\.(?:png|jpg|jpeg|gif)');

  String displayMessage(String? message) {
    if (message == null || message.trim().isEmpty) return "Foto";

    String withoutLinks = message.replaceAll(imgurRegex, "").trim();

    return withoutLinks.isEmpty ? "Foto" : withoutLinks;
  }

  @override
  void initState() {
    super.initState();
    loadChats();

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      loadChats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Widget shimmerChatItem({bool isFirst = false}) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderGrey,
      highlightColor: AppColors.text.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.text.withOpacity(0.2)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                top: isFirst ? 8 : 16,
                bottom: 4,
              ),
              child: Container(
                height: 14,
                width: 60,
                color: AppColors.text.withOpacity(0.15),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          ],
        ),
      ),
    );
  }

  Future<void> loadChats() async {
    final token = await storage.read(key: 'session_token');
    if (token == null) return;

    final data = await fetchChats(token);

    data.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['updatedAt'] ?? a['time'] ?? '') ??
          DateTime(1970);
      final dateB =
          DateTime.tryParse(b['updatedAt'] ?? b['time'] ?? '') ??
          DateTime(1970);
      return dateB.compareTo(dateA);
    });

    setState(() {
      chats = data;
    });
  }

  String formatDate(String dateString) {
    if (dateString.isEmpty) return "";

    DateTime date;
    try {
      date = DateTime.parse(dateString).toLocal();
    } catch (_) {
      return dateString;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return "${formatTime(dateString)}";
    if (target == yesterday) return "IERI";
    if (target == tomorrow) return "DOMANI";

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
    return "${target.day} ${months[target.month]} ${target.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.bgGrey,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Messaggi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                _selectedTab == 0
                                    ? AppColors.text
                                    : AppColors.text.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Ordini",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                _selectedTab == 1
                                    ? AppColors.text
                                    : AppColors.text.withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    color: AppColors.borderGrey,
                  ),
                  AnimatedAlign(
                    alignment:
                        _selectedTab == 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: 1.5,
                      width: MediaQuery.of(context).size.width / 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
      body:
          chats.isEmpty
              ? ListView.builder(
                itemCount: 4,
                itemBuilder: (_, index) => shimmerChatItem(isFirst: index == 0),
              )
              : ListView.separated(
                itemCount: chats.length,
                separatorBuilder:
                    (_, __) =>
                        Divider(color: AppColors.borderGrey, thickness: 1),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Text(
                          formatDate(chat['time']),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: AppColors.text.withOpacity(0.85),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: UserAvatar(
                          avatar:
                              chat['avatar'] is String
                                  ? chat['avatar']
                                  : chat['username'][0],
                          fallbackText: chat['username'][0],
                          radius: 22,
                          showOnline: true,
                          online: chat['online'] ?? false,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat['username'],
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 14,
                                      height: 1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 4),
                                if (!(chat['seen'] ?? true) &&
                                    !(chat['isMe'] ?? false))
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.primary,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "nuovi messaggi",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          height: 1,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 18,
                              child: Row(
                                children: [
                                  if ((chat['seen'] ?? true) &&
                                      (chat['isMe'] ?? true))
                                    Row(
                                      children: [
                                        Center(
                                          child: Transform.translate(
                                            offset: const Offset(0, 1),
                                            child: SvgPicture.asset(
                                              "assets/icons/seen-svgrepo-com.svg",
                                              height: 20,
                                              width: 20,
                                              colorFilter: ColorFilter.mode(
                                                AppColors.primary,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                      ],
                                    ),
                                  chat['lastMessage'] != null &&
                                          imgurRegex.hasMatch(
                                            chat['lastMessage']!,
                                          )
                                      ? Row(
                                        children: [
                                          Transform.translate(
                                            offset: const Offset(0, 1),
                                            child: SvgPicture.asset(
                                              "assets/icons/image-svgrepo-com.svg",
                                              height: 20,
                                              width: 20,
                                              colorFilter: ColorFilter.mode(
                                                AppColors.text.withOpacity(
                                                  0.75,
                                                ),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            displayMessage(chat['lastMessage']),
                                            style: TextStyle(
                                              color: AppColors.text.withOpacity(
                                                0.75,
                                              ),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Expanded(
                                        child: Text(
                                          chat['lastMessage']!,
                                          style: TextStyle(
                                            color: AppColors.text.withOpacity(
                                              0.75,
                                            ),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: SvgPicture.asset(
                          "assets/icons/arrow-right.svg",
                          height: 18,
                          width: 18,
                          colorFilter: ColorFilter.mode(
                            AppColors.text.withOpacity(0.5),
                            BlendMode.srcIn,
                          ),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChatPage(
                                    chatId: chat['chatId'],
                                    username: chat['username'],
                                    avatar:
                                        chat['avatar'] is String
                                            ? chat['avatar']
                                            : chat['username'][0],
                                    book: chat['book'],
                                  ),
                            ),
                          );

                          await loadChats();
                        },
                      ),
                    ],
                  );
                },
              ),
    );
  }
}

class ChatPage extends StatefulWidget {
  String chatId;
  final String username;
  final dynamic avatar;
  final Map<String, dynamic>? book;
  final VoidCallback? onChatOpened;

  ChatPage({
    Key? key,
    required this.chatId,
    required this.username,
    this.avatar,
    this.book,
    this.onChatOpened,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final storage = const FlutterSecureStorage();

  File? _imageToPreview;
  final imgurRegex = RegExp(r'https://i\.imgur\.com/\S+\.(?:png|jpg|jpeg|gif)');
  bool _isSending = false;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 20;
  bool _isAtBottom = true;
  int _newMessagesCount = 0;
  Timer? _checkMessagesTimer;
Uint8List? _imageToPreviewWeb; // Web

  @override
  void initState() {
    super.initState();
    widget.onChatOpened?.call();

    _loadMessages();
    _checkMessagesTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_isLoading && mounted) {
        await _checkNewMessages();
      }
    });

    _scrollController.addListener(() {
      final currentScroll = _scrollController.position.pixels;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final minScroll = _scrollController.position.minScrollExtent;

      _isAtBottom = currentScroll <= minScroll + 50;
      if (_isAtBottom) {
        setState(() {
          _newMessagesCount = 0;
        });
      }

      if (currentScroll >= maxScroll - 100 && !_isLoading && _hasMore) {
        _loadMessages(loadOlder: true);
      }
    });
  }

  Future<void> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1200, // opzionale
    maxHeight: 1200,
    imageQuality: 70, // solo Mobile
  );

  if (pickedFile != null) {
    if (kIsWeb) {
      // Su Web ottieni i bytes
      final bytes = await pickedFile.readAsBytes();
      // Puoi fare l’upload direttamente dai bytes
      uploadImageWeb(bytes, pickedFile.name);
    } else {
      // Mobile: File
      final file = File(pickedFile.path);
      // Puoi fare compressione con flutter_image_compress se vuoi
      final optimizedFile = await optimizeImage(file);
      uploadImageMobile(optimizedFile);
    }
  }
}

Future<void> uploadImageMobile(File file) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://api.imgur.com/3/upload'),
  );
  request.headers['Authorization'] = 'Client-ID 3b4fd0382862345';
  request.files.add(await http.MultipartFile.fromPath('image', file.path));

  final response = await request.send();
  // gestisci la risposta
}

Future<String?> uploadImageWeb(Uint8List bytes, String filename) async {
  try {
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {
        'Authorization': 'Client-ID 3b4fd0382862345',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image': base64Image,
        'type': 'base64',
        'name': filename,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data']['link'];
    } else {
      throw Exception("Errore upload Imgur: ${data['data']['error']}");
    }
  } catch (e) {
    print('Errore upload Imgur: $e');
    return null;
  }
}


  @override
  void dispose() {
    _checkMessagesTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkNewMessages() async {
    if (!mounted) return;
    _isLoading = true;
    final token = await storage.read(key: 'session_token');
    if (token == null) return;

    final fetched = await fetchMessages(
      widget.chatId,
      token,
      skip: 0,
      limit: 20,
    );
    final newFetched = fetched.reversed.toList();

    /* print(newFetched); */

    if (!mounted) return;
    setState(() {
      final onlyNew =
          newFetched.where((m) {
            final exists = _messages.any((msg) => msg['time'] == m['time']);
            /* for (final msg in _messages) {
              print(msg['local']);
            } */
            _messages.removeWhere((msg) => msg['local'] == true);
            return !exists;
          }).toList();

      /* print(onlyNew); */

      if (onlyNew.isNotEmpty) {
        _messages.insertAll(0, onlyNew);
        if (_isAtBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.minScrollExtent,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          _newMessagesCount += onlyNew.length;
        }
      }
    });

    _isLoading = false;
  }

  Future<void> _loadMessages({bool loadOlder = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    final token = await storage.read(key: 'session_token');
    if (token == null) {
      _isLoading = false;
      return;
    }

    final fetched = await fetchMessages(
      widget.chatId,
      token,
      skip: _skip,
      limit: _limit,
    );
    final newFetched = fetched.reversed.toList();

    if (!mounted) {
      _isLoading = false;
      return;
    }

    setState(() {
      if (loadOlder) {
        _messages.addAll(newFetched);
      } else {
        final existingTimes = _messages.map((m) => m['time']).toSet();
        final onlyNew =
            newFetched
                .where((m) => !existingTimes.contains(m['time']))
                .toList();
        if (onlyNew.isNotEmpty) {
          _messages.insertAll(0, onlyNew);
          if (_isAtBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          } else {
            _newMessagesCount += onlyNew.length;
          }
        }
      }

      _skip += fetched.length;
      if (fetched.length < _limit) _hasMore = false;
    });

    _isLoading = false;
  }

  Future<void> _pickImageFromGalleryOrCamera() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.text.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.text.withOpacity(0.75),
                ),
                title: Text(
                  'Galleria',
                  style: TextStyle(color: AppColors.text.withOpacity(0.75)),
                ),
                onTap: () async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      await handlePickedImage(pickedFile); // <- qui
    }
  },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: AppColors.text.withOpacity(0.75),
                ),
                title: Text(
                  'Fotocamera',
                  style: TextStyle(color: AppColors.text.withOpacity(0.75)),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    await handlePickedImage(pickedFile);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> optimizeImage(File file) async {
    final dir = await getTemporaryDirectory();

    final targetPath = p.join(
      dir.path,
      'optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 30,
      minWidth: 1200,
      minHeight: 1200,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (compressed == null) {
      throw Exception("Compression failed");
    }

    return File(compressed.path);
  }

  /* Future<void> _uploadAndSendImage(File file) async {
    try {
      const clientId = '3b4fd0382862345';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgur.com/3/upload'),
      );
      request.headers['Authorization'] = 'Client-ID $clientId';
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data["success"] == true) {
        final imgurLink = data["data"]["link"];
        await _sendMessage(imgurLink);
      } else {
        throw Exception("Errore upload Imgur");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore caricamento immagine: ${e.toString()}")),
      );
    }
  } */

  Future<void> handlePickedImage(XFile pickedFile) async {
  if (kIsWeb) {
    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _imageToPreviewWeb = bytes;
    });
    // Se vuoi inviare subito:
    await _uploadImageWeb(bytes, pickedFile.name);
  } else {
    final file = File(pickedFile.path);
    final optimizedFile = await optimizeImage(file);
    setState(() {
      _imageToPreview = optimizedFile;
    });
    // Non inviare qui, lascia che _sendMessage gestisca l'invio
  }
}
Future<String?> _uploadImageWeb(Uint8List bytes, String filename) async {
  try {
    const clientId = '3b4fd0382862345';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgur.com/3/upload'),
    );
    request.headers['Authorization'] = 'Client-ID $clientId';
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
    ));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr);

    if (response.statusCode == 200 && data["success"] == true) {
      return data["data"]["link"];
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Errore caricamento immagine: $e")),
    );
  }
  return null;
}



  Future<String?> _uploadImage(File file) async {
    try {
      const clientId = '3b4fd0382862345';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgur.com/3/upload'),
      );
      request.headers['Authorization'] = 'Client-ID $clientId';
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data["success"] == true) {
        /* print(data["data"]["link"]); */
        return data["data"]["link"];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore caricamento immagine: ${e.toString()}")),
      );
    }
    return null;
  }

  Future<void> _sendMessage(String text) async {
    if (_isSending) return;
    _isSending = true;

    final token = await storage.read(key: 'session_token');
    if (token == null) {
      _isSending = false;
      return;
    }

    String chatId = widget.chatId;

    if (chatId.isEmpty && widget.book != null) {
      final response = await http.post(
        Uri.parse('https://cornaro-backend.onrender.com/chats/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sellerEmail': widget.book?['sellerEmail'],
          'bookId': widget.book?['_id'],
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        chatId = data['chatId'];
        setState(() {
          widget.chatId = chatId;
        });
      } else {
        _isSending = false;
        return;
      }
    }

    String? imageUrl;
    if (_imageToPreview != null) {
      imageUrl = await _uploadImage(_imageToPreview!);
      if (text != "") {
        imageUrl = "$imageUrl $text";
      }
    }

    if ((text.isEmpty && imageUrl == null)) {
      _isSending = false;
      return;
    }

    final response = await http.post(
      Uri.parse('https://cornaro-backend.onrender.com/chats/$chatId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': imageUrl ?? text}),
    );

    if (response.statusCode == 201) {
      _controller.clear();
      setState(() {
        _messages.insert(0, {
          'sender': 'me',
          'text': imageUrl ?? text,
          'time': DateTime.now().toIso8601String(),
          'isMe': 'true',
          'local': true,
        });
        _imageToPreview = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    _isSending = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          widget.username,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),
        ),
        backgroundColor: AppColors.bgGrey,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderGrey, height: 1),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/info.svg',
              color: AppColors.text,
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.book != null && widget.book!['title'] != "")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    child: Row(
                      children: [
                        if (widget.book!['image'] != null &&
                            widget.book!['image'] != '')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              widget.book!['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 60,
                            height: 60,
                            color: AppColors.borderGrey,
                            child: Center(
                              child: Text(
                                widget.book!['title'] != null &&
                                        widget.book!['title'].isNotEmpty
                                    ? widget.book!['title'][0]
                                    : '?',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book!['title'] ?? '',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  height: 1.8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.book!['price'] ?? 0} €",
                                style: TextStyle(
                                  color: AppColors.text.withOpacity(0.75),
                                  fontSize: 14,
                                  height: 1,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${(widget.book!['price'] + (widget.book!['price'] * 0.014) + 0.75).toStringAsFixed(2).replaceAll('.', ',')} € Include la Protezione acquisti",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "assets/icons/protection-secure-security-svgrepo-com.svg",
                                    color: AppColors.primary,
                                    width: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe =
                        (message['isMe']?.toString().toLowerCase() == 'true');

                    final seen = message['seen'] ?? false;

                    /* final previousIsMe =
                        index > 0
                            ? (_messages[index - 1]['isMe']
                                    ?.toString()
                                    .toLowerCase() ==
                                'true')
                            : null;
                    final nextIsMe =
                        index < _messages.length - 1
                            ? (_messages[index + 1]['isMe']
                                    ?.toString()
                                    .toLowerCase() ==
                                'true')
                            : null; */

                    final currentTime = message['time'];
                    final previousTime =
                        index < _messages.length - 1
                            ? _messages[index + 1]['time']
                            : null;

                    final showDateHeader =
                        previousTime == null ||
                        !isSameDay(currentTime, previousTime);

                    /* final topMargin = previousIsMe == null
                        ? 12
                        : (previousIsMe == isMe ? 2 : 12);
                    final bottomMargin = nextIsMe == null
                        ? 12
                        : (nextIsMe == isMe ? 2 : 12); */

                    String? imageUrl;
                    String? remainingText;

                    final match = imgurRegex.firstMatch(message['text'] ?? '');
                    if (match != null) {
                      imageUrl = match.group(0);
                      remainingText =
                          message['text']!.replaceFirst(imageUrl, '').trim();
                    } else {
                      remainingText = message['text'];
                    }

                    return Column(
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              formatDayHeader(currentTime),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: AppColors.text.withOpacity(0.75),
                              ),
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment:
                              isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                /* margin: EdgeInsets.only(
                                  top: topMargin.toDouble(),
                                  bottom: bottomMargin.toDouble(),
                                ), */
                                margin: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color:
                                      isMe
                                          ? AppColors.contrast
                                          : AppColors.bgGrey,
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          imageUrl,
                                          width: 200,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: AppColors.borderGrey,
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: AppColors.borderGrey,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: AppColors.text,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (remainingText != null &&
                                        remainingText.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          remainingText,
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        textAlign: TextAlign.left,
                                        formatTime(message['time']!),
                                        style: TextStyle(
                                          color: AppColors.text.withOpacity(
                                            0.6,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    if (isMe && seen && index == 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Visto',
                                          style: TextStyle(
                                            color: AppColors.text.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                if (_newMessagesCount > 0)
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        _scrollController.animateTo(
                          _scrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                        setState(() {
                          _newMessagesCount = 0;
                          _isAtBottom = true;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.contrast,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_newMessagesCount',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_downward, color: AppColors.text),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_imageToPreview != null)
                  Positioned(
                    bottom: 15,
                    left: 15,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageToPreview!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageToPreview = null),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderGrey)),
              color: AppColors.bgGrey,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 6,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Scrivi un messaggio qui',
                          hintStyle: TextStyle(
                            color: AppColors.text.withOpacity(0.75),
                          ),
                          filled: true,
                          fillColor: AppColors.contrast,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _pickImageFromGalleryOrCamera,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/image-plus-svgrepo-com (1).svg',
                          colorFilter: ColorFilter.mode(
                            AppColors.text.withOpacity(0.5),
                            BlendMode.srcIn,
                          ),
                          height: 26,
                          width: 26,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          _isSending
                              ? null
                              : () {
                                final text = _controller.text.trim();
                                if (text.isNotEmpty ||
                                    _imageToPreview != null) {
                                  _sendMessage(text);
                                }
                              },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _isSending ? 'Invio...' : 'Invia',
                          style: TextStyle(
                            color: _isSending ? Colors.grey : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final dynamic avatar;
  final String fallbackText;
  final double radius;
  final bool showOnline;
  final bool online;

  const UserAvatar({
    super.key,
    required this.avatar,
    required this.fallbackText,
    required this.radius,
    this.showOnline = false,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.borderGrey,
          child:
              avatar is String && avatar != ""
                  ? ClipOval(
                    child: Image.network(
                      avatar,
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Text(
                    fallbackText,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w400,
                      fontSize: radius,
                    ),
                  ),
        ),
        if (showOnline)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: online ? AppColors.bgGrey : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color:
                        online ? const Color(0xFF43a25a) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} */
