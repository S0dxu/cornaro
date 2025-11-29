/* import 'package:flutter/material.dart';
import 'package:cornaro/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Row(
                  children: const [
                    Expanded(
                      child: _InstaCard(
                        username: 'luca.barbone',
                        message: 'Spotto tipa figa con il pizzetto e mullet (5cs)',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _InstaCard(
                        username: 'daduzz',
                        message: 'Spotto prof con i capelli lunghi che sembra un surfista anni 70',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'scherzavo, spotto il barbone fuori scuola che si è scopato la Marta',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'Spotto me stesso (son troppo figo)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _InstaCard(
                      username: 'luca.barbone',
                      message: 'Spotto tipa figa con il pizzetto e mullet (5cs)',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InstaCard(
                      username: 'daduzz',
                      message: 'Spotto prof con i capelli lunghi che sembra un surfista anni 70',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'scherzavo, spotto il barbone fuori scuola che si è scopato la Marta',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'Spotto me stesso (son troppo figo)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _InstaCard(
                      username: 'luca.barbone',
                      message: 'Spotto tipa figa con il pizzetto e mullet (5cs)',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InstaCard(
                      username: 'daduzz',
                      message: 'Spotto prof con i capelli lunghi che sembra un surfista anni 70',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'scherzavo, spotto il barbone fuori scuola che si è scopato la Marta',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'Spotto me stesso (son troppo figo)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _InstaCard(
                      username: 'luca.barbone',
                      message: 'Spotto tipa figa con il pizzetto e mullet (5cs)',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InstaCard(
                      username: 'daduzz',
                      message: 'Spotto prof con i capelli lunghi che sembra un surfista anni 70',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'scherzavo, spotto il barbone fuori scuola che si è scopato la Marta',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InstaCard(
                      username: 'giacomo.borille',
                      message: 'Spotto me stesso (son troppo figo)',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstaCard extends StatelessWidget {
  final String username;
  final String message;

  const _InstaCard({required this.username, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey, width: 1),
        color: AppColors.bgGrey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 28,
                          height: 28,
                          color: AppColors.bgGrey,
                          child: SvgPicture.asset(
                            "assets/icons/profile-user-svgrepo-com.svg",
                            colorFilter: ColorFilter.mode(
                              AppColors.text,
                              BlendMode.srcIn,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "@$username",
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reply',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.contrast,
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/arrow-right.svg",
                  height: 14,
                  width: 14,
                  colorFilter: ColorFilter.mode(
                    AppColors.contrast,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:cornaro/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> cards = [
    {
      "username": "luca.barbone",
      "message": "Spotto tipa figa con il pizzetto e mullet (5cs)",
      "profilo": "assets/icons/jack.png",
    },
    {
      "username": "daduzz",
      "message": "Spotto prof con i capelli lunghi che sembra un surfista anni 70",
    },
    {
      "username": "giacomo.borille",
      "message": "scherzavo, spotto il barbone fuori scuola che si è scopato la Marta",
      "profilo": "assets/icons/profile2.png",
    },
    {
      "username": "giacomo.borille",
      "message": "Spotto me stesso (son troppo figo)",
      "profilo": "assets/icons/profile.png",
    },
    {
      "username": "luca.barbone",
      "message": "Spotto tipa figa con il pizzetto e mullet (5cs)",
    },
    {
      "username": "daduzz",
      "message": "Spotto prof con i capelli lunghi che sembra un surfista anni 70",
    },
    {
      "username": "giacomo.borille",
      "message": "scherzavo, spotto il barbone fuori scuola che si è scopato la Marta",
    },
    {
      "username": "giacomo.borille",
      "message": "Spotto me stesso (son troppo figo)",
    },
    {
      "username": "luca.barbone",
      "message": "Spotto tipa figa con il pizzetto e mullet (5cs)",
    },
    {
      "username": "daduzz",
      "message": "Spotto prof con i capelli lunghi che sembra un surfista anni 70",
    },
    {
      "username": "giacomo.borille",
      "message": "scherzavo, spotto il barbone fuori scuola che si è scopato la Marta",
    },
    {
      "username": "giacomo.borille",
      "message": "Spotto me stesso (son troppo figo)",
    },
    {
      "username": "luca.barbone",
      "message": "Spotto tipa figa con il pizzetto e mullet (5cs)",
    },
    {
      "username": "daduzz",
      "message": "Spotto prof con i capelli lunghi che sembra un surfista anni 70",
    },
    {
      "username": "giacomo.borille",
      "message": "scherzavo, spotto il barbone fuori scuola che si è scopato la Marta",
    },
    {
      "username": "giacomo.borille",
      "message": "Spotto me stesso (son troppo figo)",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate((cards.length / 2).ceil(), (i) {
              final a = cards[i * 2];
              final b = i * 2 + 1 < cards.length ? cards[i * 2 + 1] : null;

              return Container(
                margin: EdgeInsets.only(top: i == 0 ? 16 : 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _InstaCard(
                        username: a["username"]!,
                        message: a["message"]!,
                        profilo: a["profilo"] ?? "",
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: b == null
                          ? SizedBox.shrink()
                          : _InstaCard(
                              username: b["username"]!,
                              message: b["message"]!,
                              profilo: b["profilo"] ?? "",
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _InstaCard extends StatelessWidget {
  final String username;
  final String message;
  final String profilo;

  const _InstaCard({
    required this.username,
    required this.message,
    required this.profilo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey, width: 1),
        color: AppColors.bgGrey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 28,
                          height: 28,
                          color: AppColors.bgGrey,
                          child: profilo.isNotEmpty
                              ? ClipPath(
                                  clipper: ShapeBorderClipper(
                                    shape: ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: Image.asset(
                                    profilo,
                                    width: 57,
                                    height: 57,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: SvgPicture.asset(
                                    "assets/icons/user-3-svgrepo-com.svg",
                                    colorFilter: ColorFilter.mode(
                                      AppColors.text,
                                      BlendMode.srcIn,
                                    ),
                                    width: 41,
                                    height: 41,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "@$username",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reply',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.contrast,
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/arrow-right.svg",
                  height: 14,
                  width: 14,
                  colorFilter: ColorFilter.mode(
                    AppColors.contrast,
                    BlendMode.srcIn,
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

