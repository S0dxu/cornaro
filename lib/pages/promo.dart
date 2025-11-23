import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cornaro/theme.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  final List<Map<String, String>> sponsors = const [
    {
      "name": "Enri's Pizza",
      "code": "PROMO10",
      "discount": "10% OFF",
      "image": "assets/icons/enris.jpeg"
    },
    {
      "name": "McDonald's",
      "code": "SAVE20",
      "discount": "20% OFF",
      "image": "assets/icons/mc.png"
    },
    {
      "name": "KFC",
      "code": "DISCOUNT5",
      "discount": "5% OFF",
      "image": "assets/icons/kfc.png"
    },
  ];

  void _showPromoCode(BuildContext context, String name, String code, String discount, String image) {
    showModalBottomSheet(
      context: context,
      barrierColor: AppColors.text.withOpacity(0.05),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.contrast,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
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
                ClipRRect(
                  child: Image.asset(
                    image,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  discount,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  "nel tuo prossimo ordine",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double totalWidth = constraints.maxWidth;
                        double dashWidth = 10;
                        double dashSpace = 3;
                        int dashCount = (totalWidth / (dashWidth + dashSpace)).floor();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(dashCount, (_) {
                            return Container(
                              width: dashWidth,
                              height: 2,
                              color: AppColors.text.withOpacity(0.15),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff0a45ac),
                  ),
                ),
                               Text(
                  "COUPON CODE",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.bgGrey,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sponsors.length,
                      itemBuilder: (context, index) {
                        final sponsor = sponsors[index];
                        return GestureDetector(
                          onTap: () => _showPromoCode(
                            context,
                            sponsor["name"]!,
                            sponsor["code"]!,
                            sponsor["discount"]!,
                            sponsor["image"]!,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(10),
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
                                  children: [
                                    const SizedBox(width: 50, height: 50),
                                    Container(
                                      width: 60,
                                      child: ClipRRect(
                                        child: Image.asset(
                                          sponsor["image"]!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    SizedBox(
                                      height: 85,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          double totalHeight = constraints.maxHeight;
                                          double dashHeight = 10;
                                          double dashSpace = 3;
                                          int dashCount = (totalHeight / (dashHeight + dashSpace)).floor();
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: List.generate(dashCount, (_) {
                                              return Container(
                                                width: 2,
                                                height: dashHeight,
                                                color: AppColors.borderGrey,
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            sponsor["discount"]!,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.text,
                                            ),
                                          ),
                                          Text(
                                            sponsor["name"]!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.text,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: -20,
                                top: 40,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgGrey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -20,
                                top: 40,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgGrey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
