import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const request = "https://api.hgbrasil.com/finance?key=d0058575";

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  double? real;
  double? dolar;
  double? euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      dolarController.text = '';
      euroController.text = '';
    }
    real = double.parse(text);
    dolarController.text = (real! / dolar!).toStringAsFixed(2);
    euroController.text = (real! / euro!).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      realController.text = '';
      euroController.text = '';
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      realController.text = '';
      dolarController.text = '';
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro!).toStringAsFixed(2);
    dolarController.text = (euro * this.euro! / dolar!).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados \n verifique sua conexão com a internet',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextFild(
                            'R\$', 'R\$ ', realController, _realChanged),
                        Divider(),
                        buildTextFild(
                            'US\$', 'US\$ ', dolarController, _dolarChanged),
                        Divider(),
                        buildTextFild('€', '€ ', euroController, _euroChanged)
                      ]),
                );
              }
          }
        },
        future: getData(),
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

Widget buildTextFild(String label, String prefix, TextEditingController c,
    Function(String text) f) {
  return Container(
    margin: EdgeInsets.only(left: 10, right: 10),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: f,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          prefix: Text(
            prefix,
            style: TextStyle(color: Colors.amber),
          )),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
    ),
  );
}
