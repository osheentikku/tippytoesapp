import 'package:flutter/material.dart';
import 'package:tippytoesapp/components/login_signup_button.dart';
import 'package:tippytoesapp/components/login_signup_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //text editting controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //user login method
  void userLogin() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFECD08),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //pre logo padding
              SizedBox(height: 30),

              //logo
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 150,
                backgroundImage: AssetImage('lib/images/tippytoeslogo'),
              ),

              //padding
              SizedBox(height: 50),

              //email
              LoginSignUpTextField(
                controller: usernameController,
                hintText: "email",
                obscure: false,
                preIcon: Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.black,
                  size: 35,
                ),
              ),

              //padding
              SizedBox(
                height: 30,
              ),

              //password
              LoginSignUpTextField(
                controller: passwordController,
                hintText: "password",
                obscure: true,
                preIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.black,
                  size: 35,
                ),
              ),

              //padding
              SizedBox(
                height: 8,
              ),

              //forgot password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              //pading
              SizedBox(height: 40),

              //login
              LoginSignupButton(
                text: 'LOGIN',
                onTap: userLogin,
              ),

              //padding
              SizedBox(
                height: 30,
              ),

              //or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Color.fromARGB(255, 116, 97, 97),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: Color.fromARGB(255, 87, 73, 73),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Color.fromARGB(255, 116, 97, 97),
                      ),
                    ),
                  ],
                ),
              ),

              //apple/google logo
              Row(
                children: [
                
                //google logo

                //apple logo
                
                ],
              ),

              //dont have an account?
            ],
          ),
        ),
      ),
    );
  }
}
