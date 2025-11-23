import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  
  List<Map<String, dynamic>> posts = [
    {
      "author": "Alessia Troia",
      "handle": "@latroiona",
      "time": "5h",
      "text": "spotto tipo troppo figo vestito come un barbone con caschetto da muratore",
      "images": ["assets/icons/x/jack.png"],
      "likes": 420,
      "comments": 37
    },
    {
      "author": "Giacomo Borille",
      "handle": "@jacksborra",
      "time": "20h",
      "text": "Boia raga scusate per il cesso nel bagno dei maschi ma non ce la facevo più",
      "images": ["assets/icons/x/cesso.png"],
      "likes": 13,
      "comments": 3
    },
    {
      "author": "Davide Silvano",
      "handle": "@dade",
      "time": "1d",
      "text": "Se votate la lista comunista giuro tiro giu tutti i porchi",
      "images": [],
      "likes": 112,
      "comments": 4
    }
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
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage("assets/icons/profile.png"),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "· ${post["time"]}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.more_horiz, color: Colors.grey[700], size: 20),
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
            margin: const EdgeInsets.only(left: 17),
            padding: const EdgeInsets.only(left: 27),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.5,
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
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage("assets/icons/profile.png"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Flexible(
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
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.more_horiz, color: Colors.grey[700], size: 20)
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
                  "si chiama giacoma borilla",
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
          color: Colors.grey[700],
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xfff4f4f6),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(

      backgroundColor: Colors.transparent,
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
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: Color(0xfff4f4f6),
        foregroundColor: Colors.black,
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
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage("assets/icons/profile.png"),
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
