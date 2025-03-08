import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'doa_detail_screen.dart';

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});

  @override
  _DoaScreenState createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
  List doaList = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDoa();
  }

  Future<void> fetchDoa() async {
    try {
      final response = await http.get(Uri.parse('https://open-api.my.id/api/doa'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          doaList = data.map((item) => {
            'judul': item['judul'] ?? "[Tidak tersedia]",
            'arab': item['arab'] ?? "[Tidak ada teks Arab]",
            'terjemah': item['terjemah'] ?? "[Tidak ada terjemahan]",
            'hadist': item['hadist'] ?? "[Tidak ada hadis]",
          }).toList();
        });
      } else {
        throw Exception('Gagal mengambil data doa');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kumpulan Doa", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
            : doaList.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: doaList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: const Icon(Icons.bookmark, color: Colors.green),
                          title: Text(
                            doaList[index]['judul'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            doaList[index]['terjemah'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoaDetailScreen(doa: doaList[index]),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
