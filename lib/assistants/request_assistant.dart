import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant
{
  static Future<dynamic> reciveRequest(String url) async{
    http.Response httpResponse = await http.get(Uri.parse(url));

    try
    {
      if(httpResponse.statusCode == 200) //successful http.Response
      {
        String responseData = httpResponse.body; //json format

        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      }
      else
      {
        return "Si è verificato un errore. Nessuna risposta.";
      }
    }catch(exp)
    {
      return "Si è verificato un errore. Nessuna risposta."; //NON CAMBIARE MAI
      // VIENE RICHIAMATA ALL'INTERNO DI assistant_methods.dart
    }

  }
}