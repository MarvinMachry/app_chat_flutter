import 'dart:io';

import 'package:projclient/screens/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projclient/screens/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      ///dados da autenticação - tokens
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final AuthResult authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      print("User: " + user.displayName);
      return user;
    } catch (erro) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();
    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Não foi possível fazer login!'),
          backgroundColor: Colors.red));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now()
    };
    if (imgFile != null) {
      setState(() {
        _isLoading = true;
      });
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child("imgs")
          .child(user.uid + DateTime.now().microsecondsSinceEpoch.toString())
          .putFile(imgFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _isLoading = true;
      });
      print(url);
      data['url'] = url;
    }
    if (text != null) data['text'] = text;
    Firestore.instance.collection("message").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_currentUser != null
              ? 'Olá, ${_currentUser.displayName}'
              : 'Chat App'),
          elevation: 0,
          actions: <Widget>[
            _currentUser != null
                ? IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  googleSignIn.signOut();
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text("Logout"),
                  ));
                })
                : Container()
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("message")
                      .orderBy("time")
                      .snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                        return ListView.builder(
                            itemCount: documents.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              return ChatMessage(
                                  documents[index].data,
                                  documents[index].data['uid'] ==
                                      _currentUser?.uid);
                            });
                    }
                  },
                )),
            _isLoading ? LinearProgressIndicator() : Container(),
            TextComposer(_sendMessage)
          ],
        ));
  }
}
