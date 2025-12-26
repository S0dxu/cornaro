import 'package:cornaro/pages/inbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cornaro/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cornaro/pages/login.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: ShopPage()),
  );
}

class AppuntiPage extends StatefulWidget {
  const AppuntiPage({super.key});

  @override
  State<AppuntiPage> createState() => _AppuntiPageState();
}

class _AppuntiPageState extends State<AppuntiPage> {
  String selectedMateria = 'Tutte';
  String selectedClasse = 'Tutte';
  RangeValues selectedPrezzoRange = const RangeValues(0, 20);

  final List<Map<String, dynamic>> appunti = [
    {
      'titolo': 'Il Rischio vulcanico e le conseguenze sulla Terra',
      'materia': 'Scienze',
      'prezzo': '8,00',
      'classe': '5',
      'prof': 'Sagrillo',
      'immagine': 'assets/icons/appunti/a1.png',
      'likes': 2,
      'liked': false,
    },
    {
      'titolo': 'La seconda guerra mondiale',
      'materia': 'Storia',
      'prezzo': '6,00',
      'classe': '5',
      'prof': 'Bubola',
      'immagine': 'assets/icons/appunti/a2.png',
      'likes': 5,
      'liked': false,
    },
    {
      'titolo': 'Il Manierismo in europa',
      'materia': 'Arte',
      'prezzo': '10,00',
      'classe': '3',
      'prof': 'Petrosa',
      'immagine': 'assets/icons/appunti/a3.png',
      'likes': 1,
      'liked': false,
    },
    {
      'titolo': 'Bonifaccio VIII',
      'materia': 'Storia',
      'prezzo': '9,00',
      'classe': '4',
      'prof': 'Bubola',
      'immagine': 'assets/icons/appunti/a4.png',
      'likes': 3,
      'liked': false,
    },
    {
      'titolo': 'Lavoro e energia in un condensatore',
      'materia': 'Fisica',
      'prezzo': '7,00',
      'classe': '1',
      'prof': 'Morando',
      'immagine': 'assets/icons/appunti/a5.png',
      'likes': 4,
      'liked': false,
    },
  ];

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredAppunti =
        appunti.where((appunto) {
          final titolo = appunto['titolo'].toString().toLowerCase();
          final materia = appunto['materia'].toString().toLowerCase();
          final classe = appunto['classe'].toString();
          final prezzoString =
              appunto['prezzo']
                  .toString()
                  .replaceAll('€', '')
                  .replaceAll(',', '.')
                  .trim();
          final prezzo = double.tryParse(prezzoString) ?? 0;

          bool materiaMatch =
              selectedMateria == 'Tutte' ||
              materia.contains(selectedMateria.toLowerCase());

          bool classeMatch =
              selectedClasse == 'Tutte' || classe == selectedClasse;

          bool prezzoMatch =
              prezzo >= selectedPrezzoRange.start &&
              prezzo <= selectedPrezzoRange.end;

          bool searchMatch =
              titolo.contains(searchText.toLowerCase()) ||
              materia.contains(searchText.toLowerCase());

          return materiaMatch && classeMatch && prezzoMatch && searchMatch;
        }).toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(color: AppColors.bgGrey),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  style: TextStyle(color: AppColors.text),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Cerca appunti',
                    hintStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.65),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: AppColors.text.withOpacity(0.65),
                        width: 18,
                        height: 18,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  barrierColor: AppColors.text.withOpacity(0.05),
                  isScrollControlled: true,
                  backgroundColor: AppColors.contrast,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    List<String> materie = [
                      'Tutte',
                      'Matematica',
                      'Fisica',
                      'Italiano',
                      'Informatica',
                      'Latino',
                      'Inglese',
                      'Scienze',
                      'Arte',
                      'Storia',
                      'Filosofia',
                    ];

                    List<String> classi = ['Tutte', '1', '2', '3', '4', '5'];

                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: SingleChildScrollView(
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
                                      color: const Color(0xffcccccc),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    "Filtra per",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "Materia",
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
                                        materie.map((materia) {
                                          final bool isSelected =
                                              selectedMateria == materia;
                                          return GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                selectedMateria = materia;
                                              });
                                              setState(() {});
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? AppColors.primary
                                                          : AppColors.text
                                                              .withOpacity(
                                                                0.25,
                                                              ),
                                                  width: 2,
                                                ),
                                                color:
                                                    isSelected
                                                        ? AppColors.primary
                                                            .withOpacity(0.1)
                                                        : Colors.transparent,
                                              ),
                                              child: Text(
                                                materia,
                                                style: TextStyle(
                                                  color:
                                                      isSelected
                                                          ? AppColors.primary
                                                          : AppColors.text,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "Classe",
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
                                        classi.map((classe) {
                                          final bool isSelected =
                                              selectedClasse == classe;
                                          return GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                selectedClasse = classe;
                                              });
                                              setState(() {});
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                right: 6,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? AppColors.primary
                                                          : AppColors.text
                                                              .withOpacity(
                                                                0.25,
                                                              ),
                                                  width: 2,
                                                ),
                                                color:
                                                    isSelected
                                                        ? AppColors.primary
                                                            .withOpacity(0.1)
                                                        : Colors.transparent,
                                              ),
                                              child: Text(
                                                classe == 'Tutte'
                                                    ? 'Tutte'
                                                    : '${classe}ª',
                                                style: TextStyle(
                                                  color:
                                                      isSelected
                                                          ? AppColors.primary
                                                          : AppColors.text,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "Prezzo (€)",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: RangeSlider(
                                    values: selectedPrezzoRange,
                                    min: 0,
                                    max: 20,
                                    divisions: 20,
                                    activeColor: AppColors.primary,
                                    labels: RangeLabels(
                                      "${selectedPrezzoRange.start.toStringAsFixed(2)} €",
                                      "${selectedPrezzoRange.end.toStringAsFixed(2)} €",
                                    ),
                                    onChanged: (range) {
                                      setModalState(() {
                                        selectedPrezzoRange = range;
                                      });
                                      setState(() {});
                                    },
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
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.bgGrey,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.borderGrey.withOpacity(0.8),
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
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double itemHeight = 430;
            final double itemWidth = constraints.maxWidth / 2;

            return GridView.builder(
              itemCount: filteredAppunti.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: itemWidth / itemHeight,
              ),
              itemBuilder: (context, index) {
                final appunto = filteredAppunti[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DettaglioItemPage(
                              item: appunto,
                              tipo: "Appunto",
                              /* onLike: () {
                            setState(() {
                              appunto['liked'] = !appunto['liked'];
                              appunto['likes'] += appunto['liked'] ? 1 : -1;
                            });
                          }, */
                            ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              appunto['immagine'],
                              width: double.infinity,
                              height: itemHeight * 0.69,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  appunto['liked'] = !appunto['liked'];
                                  appunto['likes'] += appunto['liked'] ? 1 : -1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.contrast,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.text.withOpacity(0.05),
                                      blurRadius: 0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      appunto['liked']
                                          ? 'assets/icons/heart_on.svg'
                                          : 'assets/icons/heart_off.svg',
                                      color:
                                          appunto['liked']
                                              ? AppColors.primary
                                              : AppColors.text.withOpacity(
                                                0.65,
                                              ),
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${appunto['likes']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color:
                                            appunto['liked']
                                                ? AppColors.primary
                                                : AppColors.text.withOpacity(
                                                  0.65,
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appunto['titolo'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              appunto['materia'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              appunto['classe'] + "ª classe",
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              appunto['prof'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${appunto['prezzo']} €",
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: SvgPicture.asset(
          'assets/icons/plus.svg',
          color: AppColors.bgGrey,
          width: 26,
          height: 26,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class RipetizioniPage extends StatefulWidget {
  const RipetizioniPage({super.key});

  @override
  State<RipetizioniPage> createState() => _RipetizioniPageState();
}

class _RipetizioniPageState extends State<RipetizioniPage> {
  final List<Map<String, dynamic>> ripetizioni = [
    {
      'titolo': 'Ripetizioni di Italiano',
      'materia': 'Italiano / Latino',
      'livello': 5,
      'descrizione':
          'Faccio lezioni di italiano, insegno come si scrivono temi efficaci e latino, lessico e grammatica.',
      'prof': 'Giacomo Borille',
      'numero': '+39 333 112 2233',
      'prezzo': '20',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/jack.png',
      'posizione': 'Padova',
      'valutazione': 4.5,
      'valutazioni': 24,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'posizione': 'Albignasego',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile2.png',
      'posizione': 'Legnaro',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Matematica',
      'materia': 'Matematica',
      'livello': 5,
      'descrizione': 'Lezioni private di algebra, geometria e analisi 1.',
      'prof': 'Elena Moretti',
      'numero': '+39 333 112 2233',
      'prezzo': '20',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Padova',
      'valutazione': 4.5,
      'valutazioni': 24,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'posizione': 'Albignasego',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Legnaro',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Matematica',
      'materia': 'Matematica',
      'livello': 5,
      'descrizione': 'Lezioni private di algebra, geometria e analisi 1.',
      'prof': 'Elena Moretti',
      'numero': '+39 333 112 2233',
      'prezzo': '20',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Padova',
      'valutazione': 4.5,
      'valutazioni': 24,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Albignasego',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Legnaro',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Matematica',
      'materia': 'Matematica',
      'livello': 5,
      'descrizione': 'Lezioni private di algebra, geometria e analisi 1.',
      'prof': 'Elena Moretti',
      'numero': '+39 333 112 2233',
      'prezzo': '20',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Padova',
      'valutazione': 4.5,
      'valutazioni': 24,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Albignasego',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Legnaro',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Matematica',
      'materia': 'Matematica',
      'livello': 5,
      'descrizione': 'Lezioni private di algebra, geometria e analisi 1.',
      'prof': 'Elena Moretti',
      'numero': '+39 333 112 2233',
      'prezzo': '20',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Padova',
      'valutazione': 4.5,
      'valutazioni': 24,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Albignasego',
      'valutazione': 4.0,
      'valutazioni': 18,
    },
    {
      'titolo': 'Ripetizioni di Inglese',
      'materia': 'Inglese',
      'livello': 4,
      'descrizione':
          'Conversazione, grammatica e preparazione esami Cambridge.',
      'prof': 'Marco Bianchi',
      'numero': '+39 339 998 1122',
      'prezzo': '18',
      'mockup': 'assets/icons/mockup/matematica.png',
      'profilo': 'assets/icons/profile.png',
      'posizione': 'Legnaro',
      'valutazione': 4.0,
      'valutazioni': 18,
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
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(color: AppColors.bgGrey),
                child: TextField(
                  onChanged: (value) {},
                  style: TextStyle(color: AppColors.text),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Cerca tutor',
                    hintStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.65),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: AppColors.text.withOpacity(0.65),
                        width: 18,
                        height: 18,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  barrierColor: AppColors.text.withOpacity(0.05),
                  isScrollControlled: true,
                  backgroundColor: AppColors.contrast,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                        );
                      },
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.bgGrey,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.borderGrey.withOpacity(0.8),
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
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        itemCount: ripetizioni.length,
        separatorBuilder: (context, index) {
          return Divider(color: AppColors.bgGrey, height: 0, thickness: 1);
        },
        itemBuilder: (context, index) {
          final rep = ripetizioni[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DettaglioRipetizionePage(rep: rep),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderGrey.withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 14),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* Material(
                            color: AppColors.bgGrey,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: rep['profilo'] != null
                              ? ClipPath(
                                  clipper: ShapeBorderClipper(
                                    shape: ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Image.asset(
                                    rep['profilo'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    "assets/icons/user-3-svgrepo-com.svg",
                                    colorFilter: ColorFilter.mode(
                                      AppColors.bgGrey,
                                      BlendMode.srcIn,
                                    ),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                          ), */
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 50,
                              height: 50,
                              color: AppColors.bgGrey,
                              child:
                                  rep['profilo'] != null
                                      ? Image.asset(
                                        rep['profilo'],
                                        fit: BoxFit.cover,
                                      )
                                      : Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: SvgPicture.asset(
                                          "assets/icons/user-3-svgrepo-com.svg",
                                          colorFilter: ColorFilter.mode(
                                            AppColors.text,
                                            BlendMode.srcIn,
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${rep['prof']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/star.svg',
                                            width: 13,
                                            height: 13,
                                            colorFilter: ColorFilter.mode(
                                              const Color(0xFFe6a823),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            rep['valutazione']?.toStringAsFixed(
                                                  1,
                                                ) ??
                                                '0.0',
                                            style: TextStyle(
                                              color: const Color(0xFFe6a823),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "(${rep['valutazioni'] ?? 0})",
                                            style: TextStyle(
                                              color: AppColors.text,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/map.svg",
                                            width: double.infinity,
                                            height: 16,
                                            colorFilter: ColorFilter.mode(
                                              AppColors.text.withOpacity(0.85),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            rep['posizione'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppColors.text.withOpacity(
                                                0.85,
                                              ),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      /* Text(
                                        "€${rep['prezzo']}/h",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: AppColors.primary,
                                        ),
                                      ), */
                                    ],
                                  ),
                                  /* Text(rep['descrizione'] ?? '',
                                      style: TextStyle(
                                        color: AppColors.text.withOpacity(0.65),
                                        fontSize: 13,
                                      ),
                                  ), */
                                  /* Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "€${rep['prezzo']}/h",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ), */
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfbc877).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFe6a823),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/university-svgrepo-com.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColors.text,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                rep['materia'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              /* SvgPicture.asset(
                                'assets/icons/calendar-user-svgrepo-com.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColors.contrast,
                                  BlendMode.srcIn,
                                ),
                              ), */
                              Text(
                                "${rep['livello'].toString()}ª classe",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(
                      color: AppColors.borderGrey.withOpacity(0.5),
                      height: 1,
                      thickness: 1,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/dollar-sign-svgrepo-com.svg',
                            width: 21,
                            height: 21,
                            colorFilter: ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "€${rep['prezzo']} / ora",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      rep['descrizione'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      /* 'Appunti',  */ 'Libri Usati',
      'Ripetizioni',
    ];

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bgGrey,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...categories.map(
              (title) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    if (title == 'Appunti') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AppuntiPage()),
                      );
                    } else if (title == 'Libri Usati') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LibriUsatiPage(),
                        ),
                      );
                    } else if (title == 'Ripetizioni') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RipetizioniPage(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final storage = FlutterSecureStorage();

class LibriUsatiPage extends StatefulWidget {
  const LibriUsatiPage({super.key});

  @override
  State<LibriUsatiPage> createState() => _LibriUsatiPageState();
}

class _LibriUsatiPageState extends State<LibriUsatiPage> {
  String selectedCondizione = 'Tutte';
  RangeValues selectedPrezzoRange = const RangeValues(0, 50);
  String selectedMateria = 'Tutte';
  String selectedClasse = 'Tutte';
  String searchText = '';
  List<Map<String, dynamic>> libri = [];
  bool isLoading = false;
  bool hasMore = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLibri();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          hasMore &&
          !isLoading &&
          !isLoadingMore) {
        _fetchLibri();
      }
    });
  }

  Future<void> _fetchLibri({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      libri = [];
      hasMore = true;
    }
    if (!hasMore) return;

    setState(() {
      if (currentPage == 1) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
    });

    final token = await storage.read(key: 'session_token');
    if (token == null) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      return;
    }

    try {
      final uri = Uri.parse(
        "https://cornaro-backend.onrender.com/get-books",
      ).replace(
        queryParameters: {
          "condition": selectedCondizione,
          "subject": selectedMateria,
          "grade": selectedClasse,
          "search": searchText,
          "minPrice": selectedPrezzoRange.start.toString(),
          "maxPrice": selectedPrezzoRange.end.toString(),
          "page": currentPage.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded["books"];

        setState(() {
          libri.addAll(
            data.map<Map<String, dynamic>>((item) {
              return {
                "titolo": item["title"] ?? "",
                "condizione": item["condition"] ?? "Usato",
                "prezzo": (item["price"] as num?)?.toDouble() ?? 0.0,
                "materia": item["subject"] ?? "",
                "classe": item["grade"] ?? "",
                "immagine": List<String>.from(item["images"] ?? []),
                "valutazione": item["rating"] ?? "0.0",
                "valutazioni": item["ratings"] ?? "0",
                "likes": item["likes"] ?? 0,
                "likedByMe": item["likedByMe"] ?? false,
                "_id": item["_id"],
                "createdBy": item["createdBy"] ?? item["userId"] ?? null,
                "createdAt": item["createdAt"] ?? "",
                "description": item["description"] ?? "",
                "isbn": item["isbn"] ?? "",
                "isReliable": item["isReliable"] ?? null,
              };
            }),
          );

          hasMore = currentPage < decoded["totalPages"];
          currentPage++;
        });
      }
    } catch (_) {}

    setState(() {
      isLoading = false;
      isLoadingMore = false;
    });
  }

  Future<void> toggleLike(String bookId, int index) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'session_token');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse("https://cornaro-backend.onrender.com/books/like"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"bookId": bookId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          libri[index]['likes'] = data['likes'];
          libri[index]['likedByMe'] = data['likedByMe'] ?? false;
        });
      }
    } catch (e) {
      print("Errore like: $e");
    }
  }

  List<Map<String, dynamic>> get filteredLibri {
    return libri.where((libro) {
      final prezzo = libro['prezzo'] as double;
      bool condizioneMatch =
          selectedCondizione == 'Tutte' ||
          libro['condizione'] == selectedCondizione;
      bool prezzoMatch =
          prezzo >= selectedPrezzoRange.start &&
          prezzo <= selectedPrezzoRange.end;
      bool materiaMatch =
          selectedMateria == 'Tutte' || libro['materia'] == selectedMateria;
      bool classeMatch =
          selectedClasse == 'Tutte' || libro['classe'] == selectedClasse;
      bool searchMatch =
          libro['titolo'].toLowerCase().contains(searchText.toLowerCase()) ||
          libro['materia'].toLowerCase().contains(searchText.toLowerCase());
      return condizioneMatch &&
          prezzoMatch &&
          materiaMatch &&
          classeMatch &&
          searchMatch;
    }).toList();
  }

  Widget shimmerCard(double itemWidth) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderGrey.withOpacity(0.85),
      highlightColor: AppColors.borderGrey.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 290,
            decoration: BoxDecoration(
              color: AppColors.borderGrey.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: itemWidth * 0.8,
            height: 14,
            color: AppColors.borderGrey.withOpacity(0.85),
          ),
          const SizedBox(height: 6),
          Container(
            width: itemWidth * 0.6,
            height: 12,
            color: AppColors.borderGrey.withOpacity(0.85),
          ),
          const SizedBox(height: 6),
          Container(
            width: itemWidth * 0.5,
            height: 12,
            color: AppColors.borderGrey.withOpacity(0.85),
          ),
          const SizedBox(height: 6),
          Container(
            width: itemWidth * 0.4,
            height: 12,
            color: AppColors.borderGrey.withOpacity(0.85),
          ),
          const SizedBox(height: 8),
          Container(
            width: itemWidth * 0.3,
            height: 16,
            color: AppColors.borderGrey.withOpacity(0.85),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final condizioni = ['Tutte', 'Nuovo', 'Ottimo', 'Buono', 'Usato'];
    final materie = [
      'Tutte',
      'Matematica',
      'Fisica',
      'Italiano',
      'Informatica',
      'Latino',
      'Inglese',
      'Scienze',
      'Arte',
      'Storia',
      'Filosofia',
    ];
    final classi = ['Tutte', '1ª', '2ª', '3ª', '4ª', '5ª'];

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(color: AppColors.bgGrey),
                child: TextField(
                  onChanged: (value) {
                    setState(() => searchText = value);
                  },
                  style: TextStyle(color: AppColors.text.withOpacity(0.8)),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Cerca libri',
                    hintStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.65),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        color: AppColors.text.withOpacity(0.65),
                        width: 18,
                        height: 18,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                  builder:
                      (context) => StatefulBuilder(
                        builder:
                            (context, setModalState) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
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
                                            color: AppColors.text.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                      const SizedBox(height: 20),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          "Condizione",
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
                                              condizioni.map((condizione) {
                                                final isSelected =
                                                    selectedCondizione ==
                                                    condizione;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setModalState(
                                                      () =>
                                                          selectedCondizione =
                                                              condizione,
                                                    );
                                                    _fetchLibri(reset: true);
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
                                                                : AppColors.text
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
                                                      condizione,
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
                                      const SizedBox(height: 15),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          "Materia",
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
                                              materie.map((materia) {
                                                final isSelected =
                                                    selectedMateria == materia;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setModalState(
                                                      () =>
                                                          selectedMateria =
                                                              materia,
                                                    );
                                                    _fetchLibri(reset: true);
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
                                                                : AppColors.text
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
                                                      materia,
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
                                      const SizedBox(height: 15),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          "Classe",
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
                                              classi.map((classe) {
                                                final isSelected =
                                                    selectedClasse == classe;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setModalState(
                                                      () =>
                                                          selectedClasse =
                                                              classe,
                                                    );
                                                    _fetchLibri(reset: true);
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
                                                                : AppColors.text
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
                                                      classe,
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
                                          "Prezzo (€)",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: RangeSlider(
                                          values: selectedPrezzoRange,
                                          min: 0,
                                          max: 50,
                                          divisions: 50,
                                          activeColor: AppColors.primary,
                                          labels: RangeLabels(
                                            "${selectedPrezzoRange.start.toStringAsFixed(0)} €",
                                            "${selectedPrezzoRange.end.toStringAsFixed(0)} €",
                                          ),
                                          onChanged: (range) {
                                            setModalState(
                                              () => selectedPrezzoRange = range,
                                            );
                                            _fetchLibri(reset: true);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.bgGrey,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.borderGrey.withOpacity(0.8),
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
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double itemHeight = 430;
            final double itemWidth = constraints.maxWidth / 2;

            if (isLoading) {
              return GridView.builder(
                itemCount: 16,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: itemWidth / itemHeight,
                ),
                itemBuilder: (context, index) => shimmerCard(itemWidth),
              );
            }

            return GridView.builder(
              controller: _scrollController,
              itemCount: filteredLibri.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: itemWidth / itemHeight,
              ),
              itemBuilder: (context, index) {
                final libro = filteredLibri[index];
                final hasImage =
                    libro['immagine'].isNotEmpty &&
                    libro['immagine'][0].isNotEmpty;

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DettaglioItemPage(item: libro, tipo: "Libro"),
                      ),
                    );

                    setState(() {
                      libri[index]['likes'] = libro['likes'];
                      libri[index]['likedByMe'] = libro['likedByMe'];
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: hasImage
                                ? Image.network(
                                    libro['immagine'][0],
                                    width: double.infinity,
                                    height: 290,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 290,
                                    color: AppColors.text.withOpacity(0.1),
                                    child: const Center(
                                      child: Text(
                                        'Immagine non\ndisponibile',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => toggleLike(libro['_id'], index),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.bgGrey,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    libro['likedByMe']
                                      ? SvgPicture.asset("assets/icons/heart_on.svg", color: Colors.red, width: 20)
                                      : SvgPicture.asset("assets/icons/heart_off.svg", color: AppColors.text.withOpacity(0.65), width: 20),
                                    if (libro['likes'] != 0)
                                      Row(
                                        children: [
                                          const SizedBox(width: 2),
                                          Text(
                                            libro['likes'].toString(),
                                            style: TextStyle(
                                              color: AppColors.text,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              libro['titolo'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              libro['materia'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              "${libro['classe']}º anno",
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              libro['condizione'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${libro['prezzo'].toStringAsFixed(2).replaceAll('.', ',')} €",
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                            if (libro['prezzo'] != null)
                              Row(
                                children: [
                                  Text(
                                    "${(libro['prezzo'] + (libro['prezzo'] * 0.014) + 0.75).toStringAsFixed(2).replaceAll('.', ',')} € incl.",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  SvgPicture.asset(
                                    "assets/icons/protection-secure-security-svgrepo-com.svg",
                                    color: AppColors.primary,
                                    width: 16,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final storage = FlutterSecureStorage();
          final token = await storage.read(key: 'session_token');
          if (token == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Devi essere loggato per aggiungere un libro'),
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBookPage(token: token)),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: SvgPicture.asset(
          'assets/icons/plus.svg',
          color: Colors.white,
          width: 26,
          height: 26,
        ),
      ),
    );
  }
}

class DettaglioItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final String tipo;

  const DettaglioItemPage({super.key, required this.item, required this.tipo});

  @override
  State<DettaglioItemPage> createState() => _DettaglioItemPageState();
}

class _DettaglioItemPageState extends State<DettaglioItemPage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.transparent;
  double _lineOpacity = 0.0;
  double _titleOpacity = 0.0;
  int _selectedTab = 0;
  Map<String, dynamic>? seller;
  bool isLoading = true;

  List<dynamic> sellerItems = [];
  bool isLoadingSellerItems = true;
  int limit = 4;
  int page = 1;
  bool hasMore = true;

  String timeAgo(dynamic value) {
    if (value == null) return 'N/A';

    final DateTime date =
        value is DateTime ? value : DateTime.parse(value);

    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) {
      return 'Ora';
    } else if (diff.inMinutes < 60) {
      return diff.inMinutes == 1
          ? '1 minuto fa'
          : '${diff.inMinutes} minuti fa';
    } else if (diff.inHours < 24) {
      return diff.inHours == 1
          ? '1 ora fa'
          : '${diff.inHours} ore fa';
    } else if (diff.inDays < 7) {
      return diff.inDays == 1
          ? '1 giorno fa'
          : '${diff.inDays} giorni fa';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1
          ? '1 settimana fa'
          : '$weeks settimane fa';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return months == 1
          ? '1 mese fa'
          : '$months mesi fa';
    } else {
      final years = (diff.inDays / 365).floor();
      return years == 1
          ? '1 anno fa'
          : '$years anni fa';
    }
  }

  Future<void> fetchSellerItems({bool reset = false}) async {
    if (reset) {
      page = 1;
      sellerItems = [];
      hasMore = true;
    }
    if (!hasMore) return;

    setState(() => isLoadingSellerItems = true);

    try {
      final token = await storage.read(key: 'session_token');
      if (token == null) {
        setState(() => isLoadingSellerItems = false);
        return;
      }

      String query = '';
      if (_selectedTab == 0) {
        final sellerEmail = widget.item['createdBy'];
        query = 'createdBy=$sellerEmail';
      } else {
        final subject = widget.item['materia'];
        query = 'subject=$subject';
      }

      final response = await http.get(
        Uri.parse(
          'https://cornaro-backend.onrender.com/get-books?$query&limit=$limit&page=$page',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final books = (data['books'] as List<dynamic>?) ?? [];

        final filtered =
            books
                .where(
                  (book) =>
                      _selectedTab == 1 || book?['_id'] != widget.item['_id'],
                )
                .map(
                  (book) => {
                    '_id': book['_id'] ?? '',
                    'title': book['title'] ?? 'Titolo non disponibile',
                    'price': (book['price'] as num?)?.toDouble() ?? 0.0,
                    'condition': book['condition'] ?? '',
                    'subject': book['subject'] ?? '',
                    'grade': book['grade'] ?? '',
                    'createdAt': book['createdAt'] ?? '',
                    "description": book["description"] ?? "",
                    "isbn": book["isbn"] ?? "",
                    'likedByMe': book['likedByMe'] ?? false,
                    'likes': book['likes'] ?? 0,
                    'images':
                        (book['images'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [],
                  },
                )
                .toList();

        setState(() {
          sellerItems.addAll(filtered);
          hasMore = page < (data['totalPages'] ?? 1);
          page++;
        });
      } else {
        sellerItems = [];
      }
    } catch (e) {
      sellerItems = [];
    }

    setState(() => isLoadingSellerItems = false);
  }

  Future<void> toggleLike(String bookId) async {
    final token = await storage.read(key: 'session_token');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://cornaro-backend.onrender.com/books/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'bookId': bookId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (widget.item['_id'] == bookId) {
            widget.item['likedByMe'] = data['likedByMe'];
            widget.item['likes'] = data['likes'];
          }

          final index = sellerItems.indexWhere((item) => item['_id'] == bookId);
          if (index != -1) {
            sellerItems[index]['likedByMe'] = data['likedByMe'];
            sellerItems[index]['likes'] = data['likes'];
          }
        });
      }
    } catch (e) {
      print('Errore like: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchSellerData().then((_) => fetchSellerItems(reset: true));
  }

  Future<void> fetchSellerData() async {
    setState(() => isLoading = true);
    try {
      final token = await storage.read(key: 'session_token');
      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      final sellerEmail = widget.item['createdBy'];
      final response = await http.get(
        Uri.parse('https://cornaro-backend.onrender.com/profile/$sellerEmail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          seller = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _scrollListener() {
    double offset = _scrollController.offset;
    double maxOffset = 350;
    double startTitleOffset = 300;

    double t = (offset / maxOffset).clamp(0.0, 1.0);
    double titleOpacity = ((offset - startTitleOffset) /
            (maxOffset - startTitleOffset))
        .clamp(0.0, 1.0);

    setState(() {
      _appBarColor = Color.lerp(Colors.transparent, AppColors.bgGrey, t)!;
      _lineOpacity = t;
      _titleOpacity = titleOpacity;
    });

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingSellerItems &&
        hasMore) {
      fetchSellerItems();
    }
  }

  void openImageFullscreen(BuildContext context, List<String> images, int initialIndex) {
    PageController pageController = PageController(initialPage: initialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) {
          return Scaffold(
            backgroundColor: AppColors.contrast,
            appBar: AppBar(
              backgroundColor: AppColors.contrast,
              elevation: 0,
              surfaceTintColor: AppColors.contrast,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: /* Container(
                    padding: const EdgeInsets.all(12),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/close.svg",
                      color: AppColors.text,
                    ),
                  ), */
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.text,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("Chiudi", style: TextStyle(color: AppColors.text)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      scaleEnabled: false,
                      panEnabled: true,
                      child: Transform.translate(
                        offset: const Offset(0, -40),
                        child: Center(
                          child: Image.network(
                            images[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: images.length,
                        effect: ExpandingDotsEffect(
                          dotColor: AppColors.text.withOpacity(0.5),
                          activeDotColor: AppColors.text,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasImages =
        item['immagine'].isNotEmpty && item['immagine'][0].isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _appBarColor,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Opacity(
            opacity: _lineOpacity,
            child: Container(color: AppColors.borderGrey, height: 1),
          ),
        ),
        title: Opacity(
          opacity: _titleOpacity,
          child: Text(
            item["titolo"],
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.text,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {},
            color: AppColors.contrast,
            itemBuilder: //TODO entrambi
                (context) => [
                  PopupMenuItem(
                    value: 'segnala',
                    child: Text(
                      'Segnala',
                      style: TextStyle(color: AppColors.red),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'condividi',
                    child: Text(
                      'Condividi',
                      style: TextStyle(color: AppColors.text),
                    ),
                  ),
                ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SvgPicture.asset(
                "assets/icons/dots.svg",
                width: 28,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.65,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      hasImages
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: item['immagine'].length,
                              itemBuilder: (context, index) {
                                if (item['immagine'][index].isEmpty) {
                                  return Container(
                                    color: AppColors.text.withOpacity(0.2),
                                    child: const Center(child: Text('Nessuna immagine disponibile')),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () => openImageFullscreen(context, List<String>.from(item['immagine']), index),
                                  child: Image.network(
                                    item['immagine'][index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                );
                              },
                            )

                          : Container(
                            color: AppColors.text.withOpacity(0.2),
                            child: const Center(
                              child: Text('Nessuna immagine disponibile'),
                            ),
                          ),
                      if (hasImages)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: item['immagine'].length,
                              effect: ExpandingDotsEffect(
                                expansionFactor: 3,
                                spacing: 8,
                                dotWidth: 8,
                                dotHeight: 8,
                                dotColor: Colors.white.withOpacity(0.5),
                                activeDotColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      if (hasImages)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => toggleLike(item['_id']),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.bgGrey,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: AppColors.borderGrey,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  item['likedByMe'] == true
                                    ? SvgPicture.asset(
                                        "assets/icons/heart_on.svg",
                                        color: Colors.red,
                                        width: 20,
                                      )
                                    : SvgPicture.asset(
                                        "assets/icons/heart_off.svg",
                                        color: AppColors.text.withOpacity(0.65),
                                        width: 20,
                                      ),
                                  if ((item['likes'] ?? 0) != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                        item['likes'].toString(),
                                        style: TextStyle(
                                          color: AppColors.text,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['titolo'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "${item['materia']}・${item['classe']}º anno",
                        style: TextStyle(
                          color: AppColors.text.withOpacity(0.65),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                         "${item['prezzo'].toStringAsFixed(2).replaceAll('.', ',')} €",
                        style: TextStyle(
                          color: AppColors.text.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "${(item['prezzo'] + (item['prezzo'] * 0.014) + 0.75).toStringAsFixed(2).replaceAll('.', ',')} € Include la Protezione acquisti",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
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
                Container(
                  decoration: BoxDecoration(color: AppColors.contrast),
                  width: double.infinity,
                  height: 28,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Descrizione",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: AppColors.text.withOpacity(0.65),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['description'] != ""
                                ? item['description']
                                : "Nessuna descrizione fornita.",
                            style: TextStyle(
                              color: AppColors.text.withOpacity(0.65),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Condizione",
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            item['condizione'],
                            style: TextStyle(
                              color: AppColors.text.withOpacity(0.65),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item['isbn'] != "")
                    Column(
                      children: [
                        Divider(color: AppColors.borderGrey),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "ISBN",
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                item['isbn'],
                                style: TextStyle(
                                  color: AppColors.text.withOpacity(0.65),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: AppColors.borderGrey),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Caricato",
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            timeAgo(item['createdAt']),
                            style: TextStyle(
                              color: AppColors.text.withOpacity(0.65),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8)
                  ],
                ),
                Container(
                  decoration: BoxDecoration(color: AppColors.contrast),
                  width: double.infinity,
                  height: 28,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => RecensioniPage(
                              sellerEmail: widget.item['createdBy'],
                              sellerName:
                                  seller != null
                                      ? "${seller!['firstName']} ${seller!['lastName']}"
                                      : null,
                            ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 16,
                              bottom: 16,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child:
                                  seller != null &&
                                          seller!['profileImage'] != ""
                                      ? Image.network(
                                        seller!['profileImage'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ) : 
                                      Container(
                                        width: 40,
                                        height: 40,
                                        color: AppColors.borderGrey,
                                        alignment: Alignment.center,
                                        child: Text(
                                          seller != null
                                              ? "${seller!['firstName'][0].toUpperCase()}"
                                              : "",
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isLoading
                                    ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 14,
                                          color: AppColors.borderGrey,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 120,
                                          height: 12,
                                          color: AppColors.borderGrey,
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${seller!['firstName']} ${seller!['lastName']}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/star_on.svg',
                                                width: 13,
                                                height: 13,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                      Color(0xFFe6a823),
                                                      BlendMode.srcIn,
                                                    ),
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                "${seller!['averageRating'].toStringAsFixed(1) ?? 0.0}",
                                                style: const TextStyle(
                                                  color: Color(0xFFe6a823),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "(${seller!['ratingsCount'] ?? 0})",
                                                style: TextStyle(
                                                  color: AppColors.text
                                                      .withOpacity(0.8),
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              SvgPicture.asset(
                                                "assets/icons/arrow-right.svg",
                                                height: 14,
                                                width: 14,
                                                colorFilter: ColorFilter.mode(
                                                  AppColors.text.withOpacity(
                                                    0.6,
                                                  ),
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: ClampingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      /* if (!isLoading &&
                                          seller!['isReliable'] == true)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                            bottom: 4,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/icons/handshake-svgrepo-com.svg",
                                                  width: 18,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  "Venditore affidabile",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                          bottom: 4,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/sell-svgrepo-com.svg",
                                                width: 14,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                "oltre 10 vendite concluse",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ), */

                                      if (seller == null)
                                        Text(
                                          "Caricamento stato...",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.text.withOpacity(0.65),
                                            fontWeight: FontWeight.w400,
                                            height: 1
                                          ),
                                        )
                                      else
                                        Text(
                                          seller!["isOnline"] == true
                                              ? "Online ora"
                                              : seller!["lastSeenAt"] != null
                                                  ? "Ultimo accesso ${timeAgo(seller!["lastSeenAt"])}"
                                                  : "Ultimo accesso non disponibile",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: seller!["isOnline"] == true
                                                ? const Color.fromARGB(255, 24, 139, 28)
                                                : AppColors.text.withOpacity(0.65),
                                            fontWeight: FontWeight.w400,
                                            height: 1
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: AppColors.contrast),
                  width: double.infinity,
                  height: 28,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Poppins",
                              height: 1.2,
                              color: AppColors.text,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "Commissione per la Protezione acquisti\n\n",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'Ad ogni acquisto effettuato attraverso il pulsante “Acquista” si aggiunge la commissione ',
                              ),
                              TextSpan(
                                text: 'Protezione acquisti',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. La Protezione acquisti include la nostra ',
                              ),
                              TextSpan(
                                text: 'Politica di rimborso',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: AppColors.contrast),
                  width: double.infinity,
                  height: 28,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _selectedTab = 0;
                                fetchSellerItems(reset: true);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 14,
                              ),
                              child: Text(
                                "Articoli dell'utente",
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
                                fetchSellerItems(reset: true);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 14,
                              ),
                              child: Text(
                                "Articoli simili",
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
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double itemWidth =
                              (constraints.maxWidth - 8) / 2;

                          return Wrap(
                            spacing: 8,
                            runSpacing: 12,
                            children:
                                sellerItems.map((item) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DettaglioItemPage(
                                              item: {
                                                '_id': item['_id'],
                                                'titolo': item['title'],
                                                'prezzo': item['price'],
                                                'condizione': item['condition'],
                                                'materia': item['subject'],
                                                'classe': item['grade'],
                                                'immagine': item['images'],
                                                'createdBy': widget.item['createdBy'],
                                                'likedByMe': item['likedByMe'],
                                                'likes': item['likes'],
                                                'description': item['description'] ?? '',
                                                'isbn': item['isbn'] ?? '',
                                                'createdAt': item['createdAt'],
                                              },
                                              tipo: _selectedTab == 0 ? 'utente' : 'simili',
                                            ),
                                          ),
                                        );

                                        //TODO al posto di fetchare fare un setState
                                        if (_selectedTab == 0) {
                                          fetchSellerItems(reset: true);
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: (item['images'] as List).isNotEmpty
                                                    ? Image.network(
                                                        item['images'][0],
                                                        width: itemWidth,
                                                        height: 290,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        width: itemWidth,
                                                        height: 290,
                                                        color: AppColors.text.withOpacity(0.1),
                                                        child: const Center(
                                                          child: Text('Nessuna immagine'),
                                                        ),
                                                      ),
                                              ),
                                              Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: GestureDetector(
                                                  onTap: () => toggleLike(item['_id']),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.bgGrey,
                                                      borderRadius: BorderRadius.circular(100),
                                                      border: Border.all(
                                                        color: AppColors.borderGrey,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        item['likedByMe'] == true
                                                            ? SvgPicture.asset(
                                                                "assets/icons/heart_on.svg",
                                                                color: Colors.red,
                                                                width: 20,
                                                              )
                                                            : SvgPicture.asset(
                                                                "assets/icons/heart_off.svg",
                                                                color: AppColors.text.withOpacity(0.65),
                                                                width: 20,
                                                              ),
                                                        if ((item['likes'] ?? 0) != 0)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 2),
                                                            child: Text(
                                                              item['likes'].toString(),
                                                              style: TextStyle(
                                                                color: AppColors.text,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item['title'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            item['subject'],
                                            style: TextStyle(
                                              color: AppColors.text.withOpacity(0.65),
                                              fontSize: 13,
                                              height: 1.2,
                                            ),
                                          ),
                                          Text(
                                            "${item['grade']}º anno",
                                            style: TextStyle(
                                              color: AppColors.text.withOpacity(0.65),
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            item['condition'],
                                            style: TextStyle(
                                              color: AppColors.text.withOpacity(
                                                0.65,
                                              ),
                                              fontSize: 13,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "${item['price'].toStringAsFixed(2).replaceAll('.', ',')} €",
                                            style: TextStyle(
                                              color: AppColors.text,
                                              fontSize: 16,
                                              height: 1.2,
                                            ),
                                          ),
                                          if (item['price'] != null)
                                            Row(
                                              children: [
                                                Text(
                                                  "${(item['price'] + (item['price'] * 0.014) + 0.75).toStringAsFixed(2).replaceAll('.', ',')} € incl.",
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                SvgPicture.asset(
                                                  "assets/icons/protection-secure-security-svgrepo-com.svg",
                                                  color: AppColors.primary,
                                                  width: 18,
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgGrey,
                border: Border(
                  top: BorderSide(color: AppColors.borderGrey, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    /* Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.bgGrey,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Fai un'offerta",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ), */
                    //TODO if isMe toglilo
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final token = await storage.read(key: 'session_token');
                              if (token == null) return;

                              final sellerResponse = await http.get(
                                Uri.parse('https://cornaro-backend.onrender.com/profile/${item['createdBy']}'),
                                headers: {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                },
                              );

                              Map<String, dynamic> seller;
                              if (sellerResponse.statusCode == 200) {
                                seller = jsonDecode(sellerResponse.body);
                              } else {
                                seller = {
                                  'firstName': item['createdBy'].split(".")[0],
                                  'lastName': "",
                                  'profileImage': "",
                                };
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    chatId: "",
                                    username: "${seller['firstName']} ${seller['lastName']}",
                                    avatar: seller['profileImage'],
                                    book: {
                                      '_id': item['_id'],
                                      'sellerEmail': item['createdBy'],
                                      'title': item['title'] ?? "",
                                      'price': item['price'] ?? 0,
                                      'image': item['image'] ?? "",
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              debugPrint('Errore apertura chat: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Inizia la conversazione",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DettaglioRipetizionePage extends StatelessWidget {
  final Map<String, dynamic> rep;

  const DettaglioRipetizionePage({super.key, required this.rep});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          rep['titolo'] ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: AppColors.bgGrey,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child:
                        rep['profilo'] != null
                            ? ClipPath(
                              clipper: ShapeBorderClipper(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: Image.asset(
                                rep['profilo'],
                                width: 57,
                                height: 57,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Padding(
                              padding: const EdgeInsets.all(6),
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

                  /* ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: AppColors.bgGrey,
                      child: rep['profilo'] != null
                          ? Image.asset(
                              rep['profilo'],
                              fit: BoxFit.cover,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(0),
                              child: SvgPicture.asset(
                                "assets/icons/user-3-svgrepo-com.svg",
                                colorFilter: ColorFilter.mode(
                                  AppColors.text,
                                  BlendMode.srcIn,
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                  ), */
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rep['prof'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: AppColors.text,
                              ),
                            ),

                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/star.svg',
                                  width: 15,
                                  height: 15,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFe6a823),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  rep['valutazione']!?.toStringAsFixed(1) ??
                                      '0.0',
                                  style: const TextStyle(
                                    color: Color(0xFFe6a823),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "(${rep['valutazioni']})",
                                  style: TextStyle(
                                    color: AppColors.text.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/map.svg",
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                AppColors.text.withOpacity(0.85),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rep['posizione'] ?? '',
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfbc877).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFe6a823),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/university-svgrepo-com.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            AppColors.text,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          rep['materia'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: Text(
                      "${rep['livello']}ª classe",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/dollar-sign-svgrepo-com.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "€${rep['prezzo']} / ora",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                rep['descrizione'] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //TODO: implement contact action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Contatta",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddBookPage extends StatefulWidget {
  final String token;
  const AddBookPage({super.key, required this.token});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String? condition;
  String? subject;
  String? grade;
  double? price;
  String? description;
  String? isbn;
  List<File> imageFiles = [];
List<Uint8List> webImages = [];
  List<String> uploadedImageUrls = [];
  List<bool> uploadingStatus = [];

  final List<String> conditions = ['Nuovo', 'Ottimo', 'Buono', 'Usato'];
  final List<String> subjects = [
    'Matematica',
    'Fisica',
    'Italiano',
    'Informatica',
    'Latino',
    'Inglese',
    'Scienze',
    'Arte',
    'Storia',
    'Filosofia',
  ];
  final List<String> grades = ['1', '2', '3', '4', '5'];

  Future<void> pickImagesOrCamera() async {
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
                  final picked = await picker.pickMultiImage();
                  if (picked.isNotEmpty) {
                    for (var pickedFile in picked) {
                      if (kIsWeb) {
                        final bytes = await pickedFile.readAsBytes();
                        setState(() {
                          webImages.add(bytes);
                          uploadingStatus.add(true);
                        });
                        await uploadSelectedImagesWeb(bytes);
                      } else {
                        final file = File(pickedFile.path);
                        setState(() {
                          imageFiles.add(file);
                          uploadingStatus.add(true);
                        });
                        await uploadSelectedImages([file]);
                      }
                    }
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
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    if (kIsWeb) {
                      final bytes = await picked.readAsBytes();
                      setState(() {
                        webImages.add(bytes);
                        uploadingStatus.add(true);
                      });
                      await uploadSelectedImagesWeb(bytes);
                    } else {
                      final file = File(picked.path);
                      setState(() {
                        imageFiles.add(file);
                        uploadingStatus.add(true);
                      });
                      await uploadSelectedImages([file]);
                    }
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

  Future<void> uploadSelectedImages(List<File> files) async {
    //! doesn't work on web bc it doesn't return a dart:io File
    const clientId = "3b4fd0382862345";

    for (final originalFile in files) {
      final index = imageFiles.indexOf(originalFile);

      try {
        final optimizedFile = kIsWeb ? originalFile : await optimizeImage(originalFile);

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.imgur.com/3/upload'),
        );

        request.headers['Authorization'] = 'Client-ID $clientId';

        request.files.add(
          await http.MultipartFile.fromPath('image', optimizedFile.path),
        );

        final response = await request.send();
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);

        if (response.statusCode == 200 && data["success"] == true) {
          setState(() {
            uploadedImageUrls.add(data["data"]["link"]);
            if (index != -1) uploadingStatus[index] = false;
          });
        } else {
          throw Exception("Imgur error");
        }
      } catch (e) {
        if (index != -1) uploadingStatus[index] = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Errore upload immagine: ${originalFile.path.split('/').last}",
            ),
          ),
        );
      }
    }
  }

  Future<void> uploadSelectedImagesWeb(Uint8List bytes) async {
    const clientId = "3b4fd0382862345";
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgur.com/3/upload'),
      );
      request.headers['Authorization'] = 'Client-ID $clientId';
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: 'upload.jpg'),
      );
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          uploadedImageUrls.add(data["data"]["link"]);
          int index = webImages.indexOf(bytes);
          if (index != -1) uploadingStatus[index] = false;
        });
      } else {
        throw Exception("Imgur error");
      }
    } catch (e) {
      int index = webImages.indexOf(bytes);
      if (index != -1) uploadingStatus[index] = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore upload immagine Web")),
      );
    }
  }

  Future<void> submitBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (uploadedImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona almeno un\'immagine')),
      );
      return;
    }
    try {
      final body = {
        'title': title,
        'condition': condition,
        'price': price,
        'subject': subject,
        'grade': grade,
        'images': uploadedImageUrls,
      };

      if (description != null && description!.trim().isNotEmpty) {
        body['description'] = description!.trim();
      }

      if (isbn != null && isbn!.trim().isNotEmpty) {
        body['isbn'] = isbn!.trim();
      }

      final response = await http.post(
        Uri.parse('https://cornaro-backend.onrender.com/add-books'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Libro aggiunto!')));


        Navigator.pop(context, true);
      } else {
        throw Exception(data['message'] ?? 'Errore aggiunta libro');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        title: Text("Aggiungi Libro"),
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: kIsWeb ? webImages.length + 1 : imageFiles.length + 1,
                  itemBuilder: (_, i) {
                    final isLast = kIsWeb ? i == webImages.length : i == imageFiles.length;

                    if (isLast) {
                      return GestureDetector( //TODO allargare questo in modo da essere più facile da tappare
                        onTap: pickImagesOrCamera,
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            radius: Radius.circular(8),
                            color: AppColors.primary.withOpacity(0.85),
                            strokeWidth: 2,
                            dashPattern: const [8, 4],
                          ),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/plus.svg',
                                color: AppColors.primary.withOpacity(0.85),
                                width: 26,
                                height: 26,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.memory(
                                      webImages[i],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      imageFiles[i],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            if (uploadingStatus[i])
                              Positioned.fill(
                                child: Container(
                                  color: AppColors.bgGrey.withOpacity(0.5),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    uploadedImageUrls.removeAt(i);
                                    uploadingStatus.removeAt(i);
                                    if (kIsWeb) {
                                      webImages.removeAt(i);
                                    } else {
                                      imageFiles.removeAt(i);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: modernInput("Titolo"),
                style: TextStyle(color: AppColors.text, fontSize: 16),
                onChanged: (v) => title = v,
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: modernInput("Descrizione (opzionale)").copyWith(
                  alignLabelWithHint: true,
                ),
                style: TextStyle(color: AppColors.text),
                maxLines: 4,
                textAlign: TextAlign.start,
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField(
                value: subject,
                style: TextStyle(
                  color: AppColors.text,
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
                dropdownColor: AppColors.contrast,
                items:
                    subjects
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                decoration: modernInput("Materia"),
                onChanged: (v) => setState(() => subject = v as String),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField(
                value: grade,
                style: TextStyle(
                  color: AppColors.text,
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
                dropdownColor: AppColors.contrast,
                items:
                    grades
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                decoration: modernInput("Classe"),
                onChanged: (v) => setState(() => grade = v as String),
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: modernInput("Prezzo (€)"),
                keyboardType: TextInputType.number,
                onChanged: (v) => price = double.tryParse(v),
                style: TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField(
                value: condition,
                style: TextStyle(
                  color: AppColors.text,
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
                dropdownColor: AppColors.contrast,
                items:
                    conditions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                decoration: modernInput("Condizione"),
                onChanged: (v) => setState(() => condition = v as String),
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: modernInput("ISBN (opzionale)"),
                style: TextStyle(color: AppColors.text),
                keyboardType: TextInputType.number,
                onChanged: (v) => isbn = v,
              ),
              const SizedBox(height: 24),
              modernButton("Aggiungi libro", false, submitBook),
            ],
          ),
        ),
      ),
    );
  }
}

class RecensioniPage extends StatefulWidget {
  final String sellerEmail;
  final String? sellerName;

  const RecensioniPage({Key? key, required this.sellerEmail, this.sellerName})
    : super(key: key);

  @override
  State<RecensioniPage> createState() => _RecensioniPageState();
}

class _RecensioniPageState extends State<RecensioniPage> {
  String selectedFilter = "Tutte";
  bool isLoading = true;
  List<Map<String, dynamic>> recensioni = [];

  @override
  void initState() {
    super.initState();
    fetchRecensioni();
  }

  Widget shimmerPage() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderGrey.withOpacity(0.85),
      highlightColor: AppColors.borderGrey.withOpacity(0.4),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 48,
                  color: AppColors.borderGrey.withOpacity(0.85),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: AppColors.borderGrey.withOpacity(0.85),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 16,
                  color: AppColors.borderGrey.withOpacity(0.85),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 90,
                height: 34,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.borderGrey.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(
            5,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.borderGrey.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 16,
                              color: AppColors.borderGrey.withOpacity(0.85),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.only(right: 2),
                                  color: AppColors.borderGrey.withOpacity(0.85),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 12,
                              color: AppColors.borderGrey.withOpacity(0.85),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 12,
                        color: AppColors.borderGrey.withOpacity(0.85),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: AppColors.borderGrey.withOpacity(0.85),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: AppColors.borderGrey.withOpacity(0.85),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.borderGrey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchRecensioni() async {
    setState(() => isLoading = true);
    try {
      final token = await storage.read(key: 'session_token');
      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://cornaro-backend.onrender.com/reviews/${widget.sellerEmail}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        List<Map<String, dynamic>> temp = [];

        for (var r in data) {
          Map<String, dynamic> reviewerProfile = {};
          if (r['reviewerEmail'] != null) {
            try {
              final profileResponse = await http.get(
                Uri.parse(
                  'https://cornaro-backend.onrender.com/profile/${r['reviewerEmail']}',
                ),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
              if (profileResponse.statusCode == 200) {
                reviewerProfile = jsonDecode(profileResponse.body);
              }
            } catch (_) {}
          }

          temp.add({
            'userName':
                reviewerProfile.isNotEmpty
                    ? "${reviewerProfile['firstName']} ${reviewerProfile['lastName']}"
                    : r['reviewer'] ?? "Utente",
            'userImage': reviewerProfile['profileImage'],
            'rating': r['rating'] ?? 0,
            'comment': r['comment'] ?? "",
            'daysAgo':
                r['createdAt'] != null
                    ? timeAgo(DateTime.parse(r['createdAt']))
                    : "",
            'isAutomatic': r['isAutomatic'] ?? false,
          });
        }

        recensioni = temp;
      } else {
        recensioni = [];
      }
    } catch (e) {
      recensioni = [];
    }
    setState(() => isLoading = false);
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inDays > 0) {
      final giorno = diff.inDays == 1 ? 'giorno' : 'giorni';
      return "${diff.inDays} $giorno fa";
    }

    if (diff.inHours > 0) {
      final ora = diff.inHours == 1 ? 'ora' : 'ore';
      return "${diff.inHours} $ora fa";
    }

    if (diff.inMinutes > 0) {
      final min = diff.inMinutes == 1 ? 'minuto' : 'minuti';
      return "${diff.inMinutes} $min fa";
    }

    return "Ora";
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered =
        recensioni.where((r) {
          if (selectedFilter == "Tutte") return true;
          if (selectedFilter == "Di utenti") return r['isAutomatic'] != true;
          if (selectedFilter == "Automatiche") return r['isAutomatic'] == true;
          return true;
        }).toList();

    double media =
        filtered.isEmpty
            ? 0
            : filtered.map((r) => r['rating'] as int).reduce((a, b) => a + b) /
                filtered.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgGrey,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        title:
          isLoading
            ? Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.borderGrey.withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
              ),
            )
            : Text(
              widget.sellerName ?? "Venditore",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: AppColors.text,
              ),
            ),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      body:
          isLoading
              ? shimmerPage()
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Column(
                    children: [
                      Text(
                        media.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              double rating = media;
                              String asset;
                              if (rating >= i + 1) {
                                asset = 'assets/icons/star_on.svg';
                              } else if (rating > i && rating < i + 1) {
                                asset = 'assets/icons/star_half.svg';
                              } else {
                                asset = 'assets/icons/star_off.svg';
                              }
                              return Row(
                                children: [
                                  SvgPicture.asset(
                                    asset,
                                    width: 14,
                                    height: 14,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFe6a823),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              );
                            }),
                          ),
                      const SizedBox(height: 8),
                      Text(
                        '(${filtered.length})',
                        style: TextStyle(
                          color: AppColors.text.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:
                        ['Tutte', 'Di utenti', 'Automatiche'].map((filter) {
                          bool selected = selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap:
                                  () => setState(() => selectedFilter = filter),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        selected
                                            ? AppColors.primary
                                            : AppColors.text.withOpacity(0.25),
                                    width: 2,
                                  ),
                                  color:
                                      selected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color:
                                        selected
                                            ? AppColors.primary
                                            : AppColors.text,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 28),
                  ...filtered.map((r) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    r['userImage'] != ""
                                        ? NetworkImage(r['userImage'])
                                        : null,
                                child:
                                    r['userImage'] == ""
                                        ? Container(
                                          width: 56,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                            color: AppColors.borderGrey,
                                          ),
                                          height: 56,
                                          child: Icon(
                                            Icons.person,
                                            size: 24,
                                            color: AppColors.text,
                                          ),
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          r['userName'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (r['isAutomatic']) ...[
                                          SvgPicture.asset(
                                            'assets/icons/verified.svg',
                                            width: 18,
                                            height: 18,
                                            colorFilter: ColorFilter.mode(
                                              AppColors.primary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Row(
                                          children: [
                                            SvgPicture.asset(
                                              i < (r['rating'] ?? 0)
                                                  ? 'assets/icons/star_on.svg'
                                                  : 'assets/icons/star_off.svg',
                                              width: 14,
                                              height: 14,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Color(0xFFe6a823),
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                            SizedBox(width: 2),
                                          ],
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                r['daysAgo'] ?? "",
                                style: TextStyle(
                                  color: AppColors.text.withOpacity(0.75),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if ((r['comment'] ?? "").isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                left: 52,
                                bottom: 8,
                              ),
                              child: Text(
                                r['comment'] ?? "",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          Divider(color: AppColors.borderGrey),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
    );
  }
}