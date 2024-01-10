import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Update {
  Future<void> update(List<String> arguments) async {
    print("Updating...");
    final repoUrl = 'https://api.github.com/repos/bot-config-dart/mc-launch-tome/contents/lib';
    final destinationDirectory = Directory.current.path + '/lib';
    print('Téléchargement du dossier "lib" dans $destinationDirectory...');

    try {
      final response = await http.get(Uri.parse(repoUrl));

      if (response.statusCode == 200) {
        final List<dynamic> contents = jsonDecode(response.body);

        for (var content in contents) {
          if (content['type'] == 'file') {
            await download(content['download_url'], '$destinationDirectory/${content['name']}');
          } else if (content['type'] == 'dir') {
            await downloadFolder(content['url'], '$destinationDirectory/${content['name']}');
          }
        }

        print('Téléchargement du dossier "lib" terminé avec succès.');
      } else {
        print('Erreur lors de la requête : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors du téléchargement : $e');
    }
  }
  
  Future<void> download(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));

    print('Téléchargement de $fileName...');
    if (response.statusCode == 200) {
      File(fileName).writeAsBytesSync(response.bodyBytes);
    } else {
      print('Erreur lors de la requête : ${response.statusCode}');
    }
  }
  
  Future<void> downloadFolder(String url, String folderName) async {
    final response = await http.get(Uri.parse(url));

    print('Téléchargement du dossier $folderName...');
    if (response.statusCode == 200) {
      final List<dynamic> contents = jsonDecode(response.body);

      for (var content in contents) {
        if (content['type'] == 'file') {
          await download(content['download_url'], '$folderName/${content['name']}');
        } else if (content['type'] == 'dir') {
          await downloadFolder(content['url'], '$folderName/${content['name']}');
        }
      }
    } else {
      print('Erreur lors de la requête : ${response.statusCode}');
    }
  }

}