import 'dart:io';

import 'package:agora_demo/screens/demo_home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isFacebookLoginIn = false;
  String errorMessage = '';
  String successMessage = '';

  @override
  initState() {
    super.initState();
    facebookLoginout();
    signOutGoogle();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<bool> facebookLoginout() async {
    await auth.signOut();
    return true;
  }

  Widget button(title, onPressItem) {
    return ElevatedButton(
      child: Text(
        title,
        style: const TextStyle(fontSize: 20.0),
      ),
      onPressed: () {
        onPressItem();
      },
    );
  }

  Future<void> signOutGoogle() async {
    // GoogleSignIn googleSignIn;
    // if (Platform.) {
    GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "1016551248064-0h0h49fo3g9uqqgbujjjcj0p6efm0kqd.apps.googleusercontent.com");
    // } else {
    //   googleSignIn = GoogleSignIn();
    // }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    // GoogleSignIn googleSignIn;
    // if (Platform.isMacOS || Platform.isWindows) {
    GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "1016551248064-0h0h49fo3g9uqqgbujjjcj0p6efm0kqd.apps.googleusercontent.com");
    // } else {
    //   googleSignIn = GoogleSignIn();
    // }

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }
    if (user != null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const DemoHomePage()));
    }
  }

  Future signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential)
        .then((authResult) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const DemoHomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            button('Login with Google',
                () => {signInWithGoogle(context: context)}),
            button(
              'Login with facebook',
              () => signInWithFacebook(),
            )
          ],
        ),
      ),
    );
  }
}
