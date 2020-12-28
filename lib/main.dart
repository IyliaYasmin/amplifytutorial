import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


import 'package:flutter/material.dart';


import 'amplifyconfiguration.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    routes: {},
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // gives our app awareness about whether we are succesfully connected to the cloud
  bool _amplifyConfigured = false;

  bool isSignUpComplete = false;
  bool isSignedIn = false;

  // Instantiate Amplify
  Amplify amplifyInstance = Amplify();

  @override
  void initState() {
    super.initState();

    // amplify is configured on startup
    _configureAmplify();
  }

  void _configureAmplify() async {
    if (!mounted) return;

    try {

      AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
      amplifyInstance.addPlugin(authPlugins: [authPlugin]);

      await amplifyInstance.configure(amplifyconfig);

      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> _registerUser(LoginData data) async {
   try{
     Map<String, dynamic> userAttributes = {
       "email": data.name,
     };

     SignUpResult res = await Amplify.Auth.signUp(
         username: data.name,
         password: data.password, options: CognitoSignUpOptions(userAttributes: userAttributes));

     setState(() {
        isSignUpComplete = res.isSignUpComplete;

        print("Sign up: " + (isSignUpComplete ? "Complete" : "Not Complete"));
     });

   } on AuthError catch(e) {
     print(e);
     return "Register Error: " + e.toString();
   }


  }

  Future<String> _signIn(LoginData data) async {

    try {

      SignInResult res = await Amplify.Auth.signIn(
          username: data.name,
          password: data.password);

      setState(() {
        isSignedIn = res.isSignedIn;

        Alert(context: context, type: AlertType.success, title: "Login Success", desc: "Good Job").show();
      });

    } on AuthError catch(e){

      Alert(context: context, type: AlertType.error, title: "Login Failed", desc: e.toString()).show();
      return e.toString();
    }

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FlutterLogin(
          logo: 'assets/vennify_media.png',
          onLogin: _signIn,
          onSignup: _registerUser,
          onRecoverPassword: (_) => null,
          title: 'Flutter Amplify'),
    );
  }
}