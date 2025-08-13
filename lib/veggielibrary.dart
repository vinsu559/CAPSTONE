import 'package:flutter/material.dart';

class Veggie {
  final String name;
  final String description;
  final String imagePath;
  final String soilMoisture;

  Veggie({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.soilMoisture,
  });
}

class VeggieLibraryScreen extends StatefulWidget {
  const VeggieLibraryScreen({super.key});

  @override
  State<VeggieLibraryScreen> createState() => _VeggieLibraryScreenState();
}

class _VeggieLibraryScreenState extends State<VeggieLibraryScreen> {
  final List<Veggie> _allVeggies = [
    Veggie(
      name: 'Lettuce',
      description:
          'Lettuce is a leafy green vegetable commonly used in salads. It grows best in cool weather and needs consistent watering. It prefers well-drained soil rich in organic matter and partial sunlight.',
      imagePath: 'assets/images/lettuce.jpg',
      soilMoisture: '50% - 70%',
    ),
    Veggie(
      name: 'Tomato',
      description:
          'Tomatoes are rich in vitamins and require lots of sunlight. They thrive in well-drained, fertile soil with a pH between 6.0 and 6.8. Regular watering is crucial to prevent fruit cracking.',
      imagePath: 'assets/images/tomato.jpg',
      soilMoisture: '60% - 80%',
    ),
    Veggie(
      name: 'Spinach',
      description:
          'Spinach grows quickly and can be harvested multiple times. It prefers cool temperatures and moist, nutrient-rich soil. High nitrogen content promotes lush leaf growth.',
      imagePath: 'assets/images/spinach.jpg',
      soilMoisture: '40% - 60%',
    ),
  ];

  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    List<Veggie> filteredVeggies =
        _allVeggies
            .where(
              (veggie) => veggie.name.toLowerCase().startsWith(
                _searchText.toLowerCase(),
              ),
            )
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Veggie Library'), centerTitle: true),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search vegetable...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          // Grid list
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredVeggies.length,
              itemBuilder: (context, index) {
                final veggie = filteredVeggies[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => VeggieDetailScreen(veggie: veggie),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Centered image
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            veggie.imagePath,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          veggie.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Soil Moisture: ${veggie.soilMoisture}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VeggieDetailScreen extends StatelessWidget {
  final Veggie veggie;

  const VeggieDetailScreen({super.key, required this.veggie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(veggie.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image centered
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                veggie.imagePath,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    veggie.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Predefined Soil Moisture: ${veggie.soilMoisture}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
