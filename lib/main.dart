import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firebase_options.dart';

const String openaiApiKey = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    ),
  );
}

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '.apps.googleusercontent.com',
  );
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyChatApp()),
      );
    } catch (e) {
      // Handle sign-in errors
      print('Error signing in: $e');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in. Please try again.'),
        ),
      );
    }
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;
        
        // Navigate to the chat page upon successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyChatApp()),
        );
      }
    } catch (e) {
      // Handle sign-in errors
      print('Error signing in with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in with Google. Please try again.'),
        ),
      );
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } catch (e) {
      print('Error sending password reset email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending password reset email. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              // SVG Image
              Container(
                width: 870,
                height: 520.139,
                child: SvgPicture.asset(
                  'undraw_login_re_4vu2.svg',
                  fit: BoxFit.contain,
                ),
              ),
              // Rest of your login page UI
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    // TextFields for email and password
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromRGBO(143, 148, 251, 1),
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email or Phone number",
                          hintStyle: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    // Login Button
                    GestureDetector(
                      onTap: () {
                        signInWithEmailAndPassword(
                          emailController.text,
                          passwordController.text,
                          context,
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Sign up text
                    GestureDetector(
                      onTap: () {
                        signUpWithGoogle(context);
                      },
                      child: Text(
                        "Don't have an account? Sign up with Google",
                        style: TextStyle(
                          color: Color.fromRGBO(143, 148, 251, 1),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Go to chat page text
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyChatApp()),
                        );
                      },
                      child: Text(
                        "Go to the chat page",
                        style: TextStyle(
                          color: Color.fromRGBO(143, 148, 251, 1),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Open the dialog to reset password
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String email = '';
                            return AlertDialog(
                              title: Text("Reset Password"),
                              content: TextField(
                                decoration: InputDecoration(
                                  hintText: "Enter your email",
                                ),
                                onChanged: (value) {
                                  email = value;
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    resetPassword(email, context);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Reset"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color.fromRGBO(143, 148, 251, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyChatApp extends StatefulWidget {
  const MyChatApp({Key? key}) : super(key: key);

  @override
  _MyChatAppState createState() => _MyChatAppState();
}

class _MyChatAppState extends State<MyChatApp> {
  List<ChatMessage> messages = [];
  late ScrollController _scrollController;

  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText(); // Initialize speech_to_text instance
  final FlutterTts flutterTts = FlutterTts(); // Initialize flutter_tts instance
  bool _isListening = false;
  String _text = '';
  double _confidence = 0.7; // Define _confidence variable

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _scrollController = ScrollController();
  }

  void _initializeSpeech() {
    _speech.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            setState(() {
              _text = '';
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            });

            // Speak out the recognized text
            await flutterTts.speak(_text);

            // Add the recognized text to the sender's message side
            sendMessage(_text);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> sendMessage(String messageContent) async {
    setState(() {
      messages.add(
          ChatMessage(messageContent: messageContent, messageType: "sender"));
    });

    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openaiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': messageContent}
        ],
        'model': 'gpt-3.5-turbo',
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var generatedText = data['choices'][0]['message']['content'];
      setState(() {
        messages.add(
            ChatMessage(messageContent: generatedText, messageType: "receiver"));
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }

    _textController.clear(); // Clear text field after sending message
  }

  void _speakGeneratedText(String generatedText) async {
    // Speak out the generated text
    await flutterTts.speak(generatedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 2),
                
                const SizedBox(width: 12),
                Expanded(
                  child: Center(
                    child: Text(
                      " App",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.settings, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                child: Align(
                  alignment: (messages[index].messageType == "receiver"
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].messageType == "receiver"
                          ? Colors.grey.shade200
                          : Color.fromRGBO(143, 148, 251, 1)), // Change sender color
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messages[index].messageContent,
                          style: TextStyle(
                            fontSize: 15,
                            color: (messages[index].messageType == "receiver"
                                ? Colors.black // Change color for receiver's messages
                                : Colors.white), // Change color for sender's messages
                          ),
                        ),
                        if (messages[index].messageType == "receiver") // Add button for text-to-speech in receiver's message
                          IconButton(
                            icon: Icon(Icons.volume_up),
                            onPressed: () => _speakGeneratedText(messages[index].messageContent),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: _listen, // Start listening to voice input
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color:Color.fromRGBO(143, 148, 251, 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.white, size: 20), // Microphone icon
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _text = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  FloatingActionButton(
                    onPressed: () {
                      if (_text.isNotEmpty) {
                        sendMessage(_text);
                      }
                    },
                    backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                    elevation: 0,
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String messageContent;
  final String messageType;

  ChatMessage({
    required this.messageContent,
    required this.messageType,
  });
}
