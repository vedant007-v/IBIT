import 'package:flutter/material.dart';

class LearnMore extends StatefulWidget {
  @override
  _LearnMoreState createState() => _LearnMoreState();
}

class _LearnMoreState extends State<LearnMore> {
  final List<Map<String, dynamic>> items = [
    {
      'image': 'assets/outline_fractures_relief.png',
      'title': 'Angular outline,conchoidal fractures,arcuate(f),relief',
      'description': 'The surface micro textures of quartz grains a: angular outline, high relief; b: subangular outline, high relief; c: subangular outline, low relief; d: rounded outline, medium relief; e: large conchoidal fractures, high relief; f: medium conchoidal fractures (1), arcuate steps (2) and straight steps (3); g: arcuate steps (1), straight steps (2) and flat cleavage ',
      'height': 250.0,
      'width': 320.0,
    },
    {
      'image': 'assets/outline_fractures_re.png',
      'title': 'Angular outline,conchoidal fractures,arcuate(f),relief',
      'description': 'SEM images of detrital sand grains (a) Sand grain showing angular to sub- angular outline, high relief and large Vs. (b) Sand grain showing small pits, straight scratches and rounded outline. (c) Well rounded grain exhibits small Vs, small pits and arcuate steps. (d) Sand grains showing smooth surface, large Vs and fracture planes. (e) Sub-angular grain showing large fracture planes and low to medium relief. (f) Sand grain with sub-rounded outline and quartz precipitation. ',
      'height': 400.0,
    },
    {
      'image': 'assets/traight_arcuatesteps.png',
      'title': 'traight and arcuate steps (J);',
      'description': 'Explanatory images of quartz surface microtextures observed under SEM. A, bulbous edges; B, solution pits; C, adhering particles; D, intense precipitation; E, dulled surface; F, crescentic marks; G, V-shaped percussion marks; H, oriented etch pits; I, conchoidal features; J, straight and arcuate steps; K, parallel striations; L, low grain relief. ',
      'height': 480.0,
    },
    {
      'image': 'assets/Mediring_img.png',
      'title': 'Meandering ridges (A)',
      'description': 'Explanatory images of quartz surface microtextures. (A) breakage blocks on the most concave part of grains and meandering ridges; (B) straight grooves; (C) crescentic marks; (D) chattermark; (E) very intense silica precipitation covering all grain surface including depressions; (F) solution pits and solution crevasses. ',
      'height': 480.0,
    },
    {
      'image': 'assets/Graded_arcs.png',
      'title': 'Graded arcs (E)',
      'description': 'SEM micrographs of quartz specimens of the investigated cryoconites: (A-B) A-type fresh grains; (C) details of conchoidal feature; (D) subparallel steps; (E) surface with graded arcs (arrows); (F-G) B-type weathered grains; (H) details of grain edge with holes and caverns (arrow); (I-J) mechanically abraded bulbous edges; (K) surface of C-type grain with scaly-grained encrustation; (L-M) E-type cracked grains (arrows show cracked surfaces); (N) D-type grain with bulbous encrustation; (O) details of bulbous encrustation. ',
      'height': 480.0,
    },
    {
      'image': 'assets/upturned_plates.png',
      'title': 'Upturned plates',
      'description': 'Mechanically cleaved grain showing upturned plates',
      'height': 250.0,
    },
    {
      'image': 'assets/Percussion marks.png',
      'title': 'Percussion marks',
      'description': 'Different types of percussion marks ',
      'height': 280.0,
    },
    {
      'image': 'assets/Abrasionfatigue.png',
      'title': 'Abrasion fatigue',
      'description': 'SEM morphology of adhesive wear surface of spool shoulder',
      'height': 480.0,
    },
    {
      'image': 'assets/Imbricatedgrinding.png',
      'title': 'Imbricated grinding features (F)',
      'description': 'Quartz grains microtextural characteristics of the hard clay, Yangtze River sediment (YR), Yellow River sediment (HR), and Chinese Loess Plateau (CLP) loess. (A-H) Hard clay quartz grains: (A) Very angular grain with high relief and the presence of a conchoidal fracture (a). (B) Angular grain with medium relief showing an arcuate (a) and straight (b) step. (C) Angular grain with low relief and the presence of a series of flat cleavage surfaces (arrows). (D) Angular grain and the presence of a dish pit (a). (E) V-shaped percussion cracks covering a surface. (1) Enlarged image showing the detail of V-shaped percussion cracks (arrows). (F) Very angular grain with high relief showing imbricated grinding features. (G) Detail of triangular etch pits. The orientation of the etch triangles is extremely regular. (H) Circular solution pits on a fracture plane.',
      'height': 460.0,
    },
    {
      'image': 'assets/Orientedetchpits.png',
      'title': 'Oriented etch pits',
      'description': 'Oriented etch pits features',
      'height': 280.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text('Learn about features'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.asset(
                      item['image']!,
                      height: item['height'],
                      width: item['width'],
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    item['title']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item['description']!,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
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

void main() {
  runApp(MaterialApp(home: LearnMore()));
}