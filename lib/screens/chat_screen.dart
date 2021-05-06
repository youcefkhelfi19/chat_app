import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
final _firestore= FirebaseFirestore.instance;
User loggedUser;
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen> {
  final textEditingController=TextEditingController();
  String messageSent;
  final _auth = FirebaseAuth.instance;


   @override
 void initState() {

    super.initState();
    getCurrentUser();
  }

  void getCurrentUser()async {
   try{
     final user = _auth.currentUser;
     if(user != null){
      loggedUser = user;
      print(loggedUser.email);
     }else{
       print('null');
     }
   }catch(e){
   print(e);
   }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        messageSent=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(

                    onPressed: () {
                      textEditingController.clear();
                     try{
                       _firestore.collection('messages').add({
                         'text':messageSent,
                         'sender':loggedUser.email,
                       });

                     }catch(e){

                     }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class TextBubble extends StatelessWidget {
  final String message ;
  final String sender;
  final bool isCurrentUser;
  TextBubble({this.message,this.sender,this.isCurrentUser});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end: CrossAxisAlignment.start,
          children: [
            Text(sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black45,
            ),
            ),
            Material(
              borderRadius:isCurrentUser ? BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ): BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              elevation: 5.0,
              color: isCurrentUser ? Colors.lightBlueAccent:Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                child: Text(
                  message,
                  style: TextStyle(
                     color: isCurrentUser? Colors.white:Colors.lightBlueAccent,
                    fontSize: 15.0
                  ),
                ),
              ),
            )
          ],
        ),
    );
  }
}
class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return  Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }else{
            final messages = snapshot.data.docs.reversed;
            List<TextBubble> messageWidgets = [];
            for(var message in messages){

              final  messageText = message['text'];
              final  messageSender = message['sender'];
              final currentUser = loggedUser.email;
              final messageWidget = TextBubble(
                  message: messageText,
                  sender: messageSender,
                  isCurrentUser:currentUser == messageSender);
              messageWidgets.add(messageWidget);
            }
            return Expanded(

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                child: ListView(
                  reverse: true,
                  children:messageWidgets,
                ),
              ),
            );
          }

        }
    );
  }
}
