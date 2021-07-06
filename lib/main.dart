import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=716657a7";
void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.green))),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;

  final reaisController = TextEditingController();
  final dolaresController = TextEditingController();
  final eurosController = TextEditingController();

  void realChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double real = double.parse(text);
    dolaresController.text = (real / dolar).toStringAsPrecision(2);
    eurosController.text = (real / euro).toStringAsPrecision(2);
  }

  void dolarChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double dolar = double.parse(text);
    reaisController.text = (dolar * this.dolar).toStringAsPrecision(2);
    eurosController.text = (dolar * this.dolar / euro).toStringAsPrecision(2);
  }

  void euroChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double euro = double.parse(text);
    reaisController.text = (euro * this.euro).toStringAsPrecision(2);
    dolaresController.text = (euro * this.euro / dolar).toStringAsPrecision(2);
  }

  void _clearFields() {
    reaisController.text = "";
    dolaresController.text = "";
    eurosController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "\$ Conversor de Moedas \$",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center));

              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Erro ao carregar dados...",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$", reaisController, realChanged),
                        Divider(),
                        buildTextField(
                            "Dolares", "US\$", dolaresController, dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "\$", eurosController, euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController textController, Function update) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    controller: textController,
    onChanged: update,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
