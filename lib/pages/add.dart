import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cornaro/theme.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  
  List<Map<String, dynamic>> posts = [
    {
      "author": "Davide Silvano",
      "handle": "@daduzz",
      "time": "5h",
      "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
      "images": ["assets/icons/x/example.jpg"],
      "likes": 420,
      "comments": 37
    },
    {
      "author": "Giacomo Borille",
      "handle": "@giacomo.borille",
      "time": "20h",
      "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
      "images": ["assets/icons/x/example.jpg"],
      "likes": 13,
      "comments": 3
    },
  ];



  String shortenHandle(String h) {
    if (h.length <= 12) return h;
    return "${h.substring(0, 10)}...";
  }

  void openPost(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailPage(post: post),
      ),
    );
  }

  Widget buildPost(Map<String, dynamic> post, int index) {
  /* String handle = shortenHandle(post["handle"]); */

  return GestureDetector(
    onTap: () => openPost(post),
    child: Container(
      margin: EdgeInsets.only(top: index == 0 ? 16 : 0),
      padding: const EdgeInsets.only(top: 14, bottom: 14, left: 14, right: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                post["author"],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "· ${post["time"]}",
                                style: TextStyle(color: AppColors.text.withOpacity(0.75), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.more_horiz, color: AppColors.text.withOpacity(0.75), size: 20),
                      ],
                    ),
                    Text(
                      post["handle"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 21),
            padding: const EdgeInsets.only(left: 27),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.borderGrey,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  post["text"],
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                if (post["images"] != null && post["images"].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: post["images"].length == 1
                      ? Image.asset(post["images"][0])
                      : Row(
                          children: [
                            Expanded(
                                child: Image.asset(post["images"][0],
                                    height: 160, fit: BoxFit.cover)),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Image.asset(post["images"][1],
                                    height: 160, fit: BoxFit.cover)),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildAction('assets/icons/comments.svg', post["comments"].toString(), 18),
                    const SizedBox(width: 10),
                    buildAction('assets/icons/heart.svg', post["likes"].toString(), 22),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                "Luca Barbata",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                " · 14min",
                                style: TextStyle(color: AppColors.text.withOpacity(0.75), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.more_horiz, color: AppColors.text.withOpacity(0.75), size: 20)
                      ],
                    ),
                    Text(
                      "@lucabarbone",
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 17),
            padding: const EdgeInsets.only(left: 27),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "top commento",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildAction('assets/icons/comments.svg', post["comments"].toString(), 18),
                    const SizedBox(width: 10),
                    buildAction('assets/icons/heart.svg', post["likes"].toString(), 22),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget buildAction(String svgAsset, String count, double width) {
    return Row(
      children: [
        SvgPicture.asset(
          svgAsset,
          width: width,
          color: AppColors.text.withOpacity(0.75),
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(color: AppColors.text.withOpacity(0.75), fontSize: 13),
        ),
      ],
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
        toolbarHeight: 0,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (_, i) => buildPost(posts[i], i),
      ),
    );
  }
}

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> comments = widget.post["commentsList"] ?? [];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
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
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.post["author"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(widget.post["handle"],
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(widget.post["text"],
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      if (widget.post["images"] != null &&
                          widget.post["images"].isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(widget.post["images"][0]),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                if (comments.isNotEmpty)
                  ...comments.map(
                    (c) => Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.grey[300]!))),
                      child: Text(c),
                    ),
                  )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Scrivi un commento...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    setState(() {
                      comments.add(controller.text.trim());
                      controller.clear();
                    });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
