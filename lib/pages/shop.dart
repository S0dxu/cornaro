import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cornaro/theme.dart';

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
          // TODO
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: SvgPicture.asset(
          'assets/icons/plus.svg',
          color: AppColors.contrast,
          width: 26,
          height: 26,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class RipetizioniPage extends StatelessWidget {
  const RipetizioniPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> ripetizioni = [
      {
        'titolo': 'Ripetizioni di Matematica',
        'materia': 'Matematica',
        'livello': 'Superiori / Università',
        'descrizione': 'Lezioni private di algebra, geometria e analisi 1.',
        'docente': 'Elena Moretti',
        'numero': '+39 333 112 2233',
        'prezzo': '€20/h',
      },
      {
        'titolo': 'Ripetizioni di Inglese',
        'materia': 'Inglese',
        'livello': 'Tutti i livelli',
        'descrizione':
            'Conversazione, grammatica e preparazione esami Cambridge.',
        'docente': 'Marco Bianchi',
        'numero': '+39 339 998 1122',
        'prezzo': '€18/h',
      },
      {
        'titolo': 'Ripetizioni di Fisica',
        'materia': 'Fisica',
        'livello': 'Liceo scientifico',
        'descrizione': 'Spiegazioni personalizzate con esempi pratici.',
        'docente': 'Giulia Rossi',
        'numero': '+39 340 776 3344',
        'prezzo': '€22/h',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        title: const Text(
          'Ripetizioni',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgGrey,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ripetizioni.length,
        itemBuilder: (context, index) {
          final ripetizione = ripetizioni[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => DettaglioItemPage(
                        item: ripetizione,
                        tipo: "Ripetizione",
                      ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ripetizione['titolo'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ripetizione['materia'],
                    style: TextStyle(color: AppColors.text.withOpacity(0.65)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Prezzo: ${ripetizione['prezzo']}",
                    style: TextStyle(color: AppColors.text.withOpacity(0.8)),
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

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['Appunti', 'Libri Usati', 'Ripetizioni'];

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

  final List<Map<String, dynamic>> libri = [
    {
      'titolo': 'La fisica di Cutnell e Johnson Vol. 1',
      'condizione': 'Buono',
      'prezzo': '15,00',
      'materia': 'Fisica',
      'classe': '3',
      'immagine': 'assets/icons/libri/l1.png',
      'likes': 2,
      'liked': false,
    },
    {
      'titolo':
          'Invito alle scienze naturali (organica, biochimica, biotecnologie)',
      'condizione': 'Ottimo',
      'prezzo': '20,00',
      'materia': 'Scienze',
      'classe': '5',
      'immagine': 'assets/icons/libri/l2.png',
      'likes': 5,
      'liked': false,
    },
    {
      'titolo': 'Letteratura Visione del Mondo 3B',
      'condizione': 'Nuovo',
      'prezzo': '25,00',
      'materia': 'Italiano',
      'classe': '5',
      'immagine': 'assets/icons/libri/l3.png',
      'likes': 1,
      'liked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLibri =
        libri.where((libro) {
          final prezzo = double.tryParse(libro['prezzo'].toString()) ?? 0;
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
              libro['titolo'].toString().toLowerCase().contains(
                searchText.toLowerCase(),
              ) ||
              libro['materia'].toString().toLowerCase().contains(
                searchText.toLowerCase(),
              );
          return condizioneMatch &&
              prezzoMatch &&
              materiaMatch &&
              classeMatch &&
              searchMatch;
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () {
            Navigator.pop(context);
          },
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
                  onChanged: (value) => setState(() => searchText = value),
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
                List<String> condizioni = [
                  'Tutte',
                  'Nuovo',
                  'Ottimo',
                  'Buono',
                  'Usato',
                ];
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
                List<String> classi = ['Tutte', '1ª', '2ª', '3ª', '4ª', '5ª'];
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
                                            color: const Color(0xffcccccc),
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
                                            fontSize: 20,
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
                                                final bool isSelected =
                                                    selectedCondizione ==
                                                    condizione;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setModalState(
                                                      () =>
                                                          selectedCondizione =
                                                              condizione,
                                                    );
                                                    setState(() {});
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
                                                final bool isSelected =
                                                    selectedMateria == materia;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setModalState(
                                                      () =>
                                                          selectedMateria =
                                                              materia,
                                                    );
                                                    setState(() {});
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
                                                final bool isSelected =
                                                    selectedClasse == classe;
                                                return GestureDetector(
                                                  onTap: () {
                                                    setModalState(
                                                      () =>
                                                          selectedClasse =
                                                              classe,
                                                    );
                                                    setState(() {});
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
                                            setState(() {});
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

            return GridView.builder(
              itemCount: filteredLibri.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: itemWidth / itemHeight,
              ),
              itemBuilder: (context, index) {
                final libro = filteredLibri[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                DettaglioItemPage(item: libro, tipo: "Libro"),
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
                              libro['immagine'],
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
                                  libro['liked'] = !libro['liked'];
                                  libro['likes'] += libro['liked'] ? 1 : -1;
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
                                      libro['liked']
                                          ? 'assets/icons/heart_on.svg'
                                          : 'assets/icons/heart_off.svg',
                                      color:
                                          libro['liked']
                                              ? AppColors.primary
                                              : AppColors.text.withOpacity(
                                                0.65,
                                              ),
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${libro['likes']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color:
                                            libro['liked']
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
                              libro['titolo'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              libro['materia'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              libro['classe'] + "ª classe",
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              libro['condizione'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${libro['prezzo']} €",
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
        onPressed: () {},
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: SvgPicture.asset(
          'assets/icons/plus.svg',
          color: AppColors.contrast,
          width: 26,
          height: 26,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.item['liked'] ?? false;
    likeCount = widget.item['likes'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final String? imagePath = widget.item['immagine'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.contrast,
      ),
      body: Column(
        children: [
          if (imagePath != null)
            Flexible(
              flex: 60,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(color: AppColors.text.withOpacity(0.2)),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isLiked = !isLiked;
                          likeCount += isLiked ? 1 : -1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
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
                              isLiked
                                  ? 'assets/icons/heart_on.svg'
                                  : 'assets/icons/heart_off.svg',
                              color:
                                  isLiked
                                      ? AppColors.primary
                                      : AppColors.text.withOpacity(0.65),
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$likeCount',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color:
                                    isLiked
                                        ? AppColors.primary
                                        : AppColors.text.withOpacity(0.65),
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
          Expanded(
            flex: 40,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item['titolo'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.item['materia'] ?? '',
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                              ),
                            ),
                            Text(
                              widget.item['classe'] + "ª classe" ?? '',
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                              ),
                            ),
                            Text(
                              widget.item['condizione'] ?? widget.item['prof'],
                              style: TextStyle(
                                color: AppColors.text.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.item['prezzo'] ?? ''} €",
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Acquista",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.contrast,
                        ),
                      ),
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
