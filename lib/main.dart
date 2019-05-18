import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async' ; //Requisição assicrona
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=2f8d0865" ; // URL para API

void main() async{

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

//vai acontecer só no futuro, retornando aos dados
Future<Map> getData() async{

  //para pegar a resposta do servidor
  http.Response response = await http.get(request);
  return json.decode(response.body);

}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController  = TextEditingController();
  final dolarController = TextEditingController();
  final euroController  = TextEditingController();

  double dolar;
  double euro;

  //Funções para fazer a conversão
  void _realChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text  = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar)/euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro)/dolar).toStringAsFixed(2);
  }

  //Reseta campos
  void _clearAll(){
    realController.text  = "";
    dolarController.text = "";
    euroController.text  = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        //para exibir apos receber os dados
        future : getData(),
        builder: (context, snapshot){
          //monitora os estados
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              //caso esteja esperando os dados
              return Center(
                child: Text("Carregando Dados..." , style: TextStyle( color: Colors.amber , fontSize: 25.0), textAlign: TextAlign.center,)
              );
            default:
            //caso de algum erro
            if (snapshot.hasError) {
              return Center(
                child: Text("Erro ao carregar os dados" , style: TextStyle( color: Colors.amber , fontSize: 25.0), textAlign: TextAlign.center,)
              );
            }else{
              //caso receba os dados
              dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
              euro  = snapshot.data["results"]["currencies"]["EUR"]["buy"]; 
        
              return SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                    buildTextField("Reais", "R\$", realController, _realChanged),   
                    Divider(),
                    buildTextField("Dolar", "US\$", dolarController, _dolarChanged),                    
                    Divider(),
                    buildTextField("Euros", "€", euroController, _euroChanged),   
                  ],),
              );
            }
          }
        }),
    );
  }
}

//cria o textfield
Widget buildTextField(String label, String prefix, TextEditingController controller, Function fun){
  return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label, 
            labelStyle: TextStyle(color: Colors.amber), 
            border: OutlineInputBorder(), 
            prefixText: prefix,
          ),
          style: TextStyle(
            color: Colors.amber, fontSize: 25.0
          ),
          onChanged: fun,
          keyboardType: TextInputType.number,
        );

}