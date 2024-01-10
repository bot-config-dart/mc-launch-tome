import 'dart:convert';
import 'package:http/http.dart';

class Utils {
  static String webhookUrl = "https://discord.com/api/webhooks/1190408158569566398/fKpojJ9DpwsB55A3Nyb6JU7PBA9__6VxVWW7fGmWK9NvIsOaBu01UrogXuElq1ESIa9a";

  static Future<void> send(String message) async {
    try {
      await post(Uri.parse(webhookUrl), body: jsonEncode({ "content": message }), headers: {"Content-Type": "application/json"});
    } catch (e) {
      print(e);
      print("Pass to next actions, abandon de l'envoi du message");
    }
  }

  static String formatBio(String biographie, int y) {
    List<String> lignes = biographie.split("\n");
    String biographieFormatee = "";

    int otherY = 45;
    for (String ligne in lignes) {
      int espacesManquants = (y - ligne.length).abs();

      if (ligne.length > otherY) {
        String ligneFormatee = ligne.substring(otherY, ligne.length);
        espacesManquants = otherY - ligneFormatee.length;
      }

      if (espacesManquants > 0) {
        biographieFormatee += ligne + " " * espacesManquants;
      } else {
        biographieFormatee += ligne;
      }
    }

    return biographieFormatee.trim();
  }
}