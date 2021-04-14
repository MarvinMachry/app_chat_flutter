import 'package:projclient/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:async';


Future<void> main() async {
  runApp(MyApp());
  //Firestore.instance.collection("mensagem").document("W6YoCq8sMULZOqoiKhYH").setData({"texto" : "boa noite", "lido" : false });

  //Firestore.instance.collection("mensagem").add({"texto" : "mais uma", "lido" : true });

  //Firestore.instance.collection("mensagem").document("W6YoCq8sMULZOqoiKhYH").updateData({"lido" : true });
  // Firestore.instance.collection("mensagem").document("W6YoCq8sMULZOqoiKhYH").delete();
/*
   QuerySnapshot snapshot = await  Firestore.instance.collection("mensagem").getDocuments();
   snapshot.documents.forEach((d) {
     print(d.data);
     print(d.documentID);
   });



  Firestore.instance.collection("mensagem").snapshots().listen((dado) {
    dado.documents.forEach((d) {
        print(d.data);
    });
  });

 */

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:  ChatScreen(),
    );
  }
}