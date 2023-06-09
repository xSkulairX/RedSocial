import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/auth/register_page.dart';
import 'package:chatapp_firebase/pages/home_page.dart';
import 'package:chatapp_firebase/service/auth_service.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Inicia sesión",
                          style: TextStyle(color: Colors.black,
                              fontSize: 35, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text("¡Interactua ahora con comunidades y amigos!",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF999999))),
                        Image.asset("assets/login.png"),
                        TextFormField(
                          cursorColor: Color(0xFFF28500),
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              labelText: "Correo",
                              labelStyle: TextStyle(
                                color: Color(0xFF999999),
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xFFF28500),
                              ),
                              focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Color(0xFFF28500))),
                              enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Color(0xFFF28500)),),
                              ),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          // check tha validation
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Por favor ingresa un correo válido";
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          cursorColor: Color(0xFFF28500),
                          style: TextStyle(color: Colors.black),
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "Contraseña",
                              labelStyle: TextStyle(
                                color: Color(0xFF999999)),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Color(0xFFF28500),
                              ),
                              focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Color(0xFFF28500))),
                              enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2, color: Color(0xFFF28500))),
                              ),
                          validator: (val) {
                            if (val!.length < 6) {
                              return "La contraseña debe tener al menos 6 carácteres";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text(
                              "Iniciar sesión",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: () {
                              login();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                          text: "¿No tienes cuenta? ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "¡Regístrate ahora!",
                                style: TextStyle(
                                    color: Color(0xFFF28500),
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  }),
                          ],
                        )),
                      ],
                    )),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUserNameandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          // saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.white, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
