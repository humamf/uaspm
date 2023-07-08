import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pahlawan Indonesia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(name: 'Pahlawan Indonesia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Hero> listHero = [];
  List<Hero> filteredHeroes = [];

  Future<List<Hero>> fetchData() async {
    final response = await http.get(
        Uri.parse('https://indonesia-public-static-api.vercel.app/api/heroes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Hero.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    fetchData().then((heroes) {
      setState(() {
        listHero = heroes;
        filteredHeroes = heroes;
      });
    }).catchError((error) {
      print('Error: $error');
      // Handle error state here
    });
    super.initState();
  }

  void filterHeroes(String query) {
    List<Hero> filteredList = listHero.where((hero) {
      final nameLower = hero.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredHeroes = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterHeroes,
              decoration: InputDecoration(
                labelText: 'Cari Nama Pahlawan',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final hero = filteredHeroes[index];
                return ListTile(
                  title: Text(hero.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${hero.name}'),
                      Text('Birth Year: ${hero.birthYear.toString()}'),
                      Text('Death Year: ${hero.deathYear.toString()}'),
                      Text('Description: ${hero.description}'),
                      Text('Ascension Year: ${hero.ascensionYear.toString()}'),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: filteredHeroes.length,
            ),
          ),
        ],
      ),
    );
  }
}

class Hero {
  final String name;
  final birthYear;
  final deathYear;
  final String description;
  final ascensionYear;

  Hero({
    required this.name,
    required this.birthYear,
    required this.deathYear,
    required this.description,
    required this.ascensionYear,
  });

  factory Hero.fromJson(Map<String, dynamic> json) {
    return Hero(
      name: json['name'],
      birthYear: json['birth_year'],
      deathYear: json['death_year'],
      description: json['description'],
      ascensionYear: json['ascension_year'],
    );
  }
}
