import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Update {
  Future<void> update(List<String> arguments) async {
    print("Updating...");
    final repoUrl = 'https://api.github.com/repos/nom_utilisateur/nom_du_depot/contents/lib';
    final destinationDirectory = 'destination_local';

    try {
      final response = await http.get(Uri.parse(repoUrl));

      if (response.statusCode == 200) {
        final List<dynamic> contents = jsonDecode(response.body);

        for (var content in contents) {
          if (content['type'] == 'file') {
            final contentUrl = content['download_url'];
            final fileName = content['name'];
            final fileResponse = await http.get(Uri.parse(contentUrl));

            // Vous pouvez maintenant faire ce que vous voulez avec le contenu du fichier,
            // par exemple, le sauvegarder localement.
            File('$destinationDirectory/$fileName').writeAsBytesSync(fileResponse.bodyBytes);
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
}