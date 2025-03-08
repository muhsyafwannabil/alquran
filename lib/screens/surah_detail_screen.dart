import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SurahDetailScreen extends StatefulWidget {
  final Map surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<dynamic> ayatList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAyat();
  }

  Future<void> fetchAyat() async {
    try {
      final response = await http.get(
        Uri.parse('https://quran-api.santrikoding.com/api/surah/${widget.surah['nomor']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(json.encode(data));

        setState(() {
          ayatList = data['ayat'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data ayat');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah['nama'] ?? 'Surah'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Nama:', widget.surah['nama']),
                    _buildDetailRow('Arti:', widget.surah['arti']),
                    _buildDetailRow(
                      'Jumlah Ayat: ${widget.surah['jumlah_ayat'] ?? widget.surah['ayat'] ?? widget.surah['total_ayat'] ?? 'Tidak Diketahui'}',
                      null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Ayat:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
                      : ListView.builder(
                          itemCount: ayatList.length,
                          itemBuilder: (context, index) {
                            final ayat = ayatList[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      ayat['ar'] ?? ayat['arab'] ?? 'Ayat tidak tersedia',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${ayat['nomor'] ?? ''}. ${ayat['idn'] ?? 'Terjemahan tidak tersedia'}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(fontSize: 16),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
