
import 'package:asset_yug_debugging/features/Auth/data/repository/auth_repo_impl.dart';
import 'package:asset_yug_debugging/features/Auth/data/repository/auth_token_repository_impl.dart';
import 'package:asset_yug_debugging/features/Auth/data/repository/firebase_authentication.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/features/Main/presentation/pages/MainPage.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //HIVE REMEMBER ME LOGIN
  late Box box;

  @override
  void initState() {
    super.initState();
    createBox();
  }

  void createBox() async {
    box = await Hive.openBox('auth_data');
    getData();
  }

  void getData() async {
    if (box.get('email') != null && box.get('password') != null) {
      setState(() {
        _emailController.text = box.get('email');
        _passwordController.text = box.get('password');
        isRememberMe = true;
      });
    }
  }
  //HIVE ENDS

  bool isLoading = false;

  bool isSignUpScreen = false;
  bool isRememberMe = false;

//!OLD METHOD TO SIGN IN USING FIREBASE
  void signInUser() async {
  if (!isLoading) {
    setState(() => isLoading = true);
    
    try {
      String res = await AuthServices().loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (res == "success") {
        await getUserToken();

        if (isRememberMe) {
          box.put('email', _emailController.text);
          box.put('password', _passwordController.text);
          print("Email: ${box.get('email')}");
          print("Password: ${box.get('password')}");
        } else {
          box.clear();
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } else {
        _showErrorSnackBar("Please enter the correct credentials");
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}

Future<void> getUserToken() async {
  try {
    final authRepository = AuthRepositoryImpl(httpClient: Client());
    final userData = await authRepository.login(_emailController.text);
    
    if (userData != null) {
      box.put('auth_token', userData["token"]);
      box.put('role', userData["role"]);
      print("Token: ${box.get('auth_token')}");
      print("Role: ${box.get('role')}");
      fetchUserCompanyDetails(_emailController.text);
    } else {
      _showErrorSnackBar('Login failed');
    }
  } catch (e) {
    _showErrorSnackBar(e.toString());
  }
}

Future<void> fetchUserCompanyDetails(String email) async{
  final userRepo = AuthTokenRepositoryImpl(httpClient: Client());
  final companyDetails = await userRepo.getCompanyId(email);
  box.put('companyId', companyDetails['id']);
  box.put('companyName', companyDetails['companyName']);
  //!TEMPORARY PRINT STATEMENTS
  if(mounted){
    dSnackBar(context, "recieved companyId: ${companyDetails['id']}", TypeSnackbar.success);
  }
  print("recieved companyId: ${companyDetails['id']}" );
  print("recieved companyName: ${companyDetails['companyName']}" );
} 

void _showErrorSnackBar(String message) {
  if (mounted) {
    dSnackBar(context, message, TypeSnackbar.error);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tBlack,
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          //Background Card (Welcome to AssetYug)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              height: MediaQuery.sizeOf(context).height/2.5,
              decoration: const BoxDecoration(
                color: tPrimary,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.bitbucket,
                    size: 40,
                    color: tYellow,
                  ),
                  SizedBox(
                    width: dPadding * 2,
                  ),
                  Text("AssetYug",
                      style: TextStyle(
                          color: tWhite,
                          fontSize: 48,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),

          //Main Login Signup Card
          Positioned(
            top: MediaQuery.sizeOf(context).height/3.2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeIn,

              padding: const EdgeInsets.all(dPadding * 3),
              height: isSignUpScreen ? 500 : 400,
              width: MediaQuery.sizeOf(context).width - 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  color: tWhite,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5),
                  ]),

              //Login Signup Card
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //Login Signup selection row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //LOGIN TAB
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignUpScreen = false;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              "LOGIN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: dTextSize,
                                color:
                                    isSignUpScreen ? disabledText : textColor1,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            if (!isSignUpScreen)
                              Container(
                                height: 3,
                                width: 55,
                                decoration: BoxDecoration(
                                    color: tPrimary,
                                    borderRadius: BorderRadius.circular(1)),
                              )
                          ],
                        ),
                      ),

                      //SIGNUP Tab
                      GestureDetector(
                        onTap: () {
                          // setState(() {
                          //   isSignUpScreen = true;
                          // });
                        },
                        child: Column(
                          children: [
                            Text(
                              "SIGNUP",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: dTextSize,
                                color:
                                    isSignUpScreen ? textColor1 : disabledText,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            if (isSignUpScreen)
                              Container(
                                height: 3,
                                width: 55,
                                decoration: BoxDecoration(
                                    color: tYellow,
                                    borderRadius: BorderRadius.circular(1)),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),

                  //Signup Form
                  if (isSignUpScreen) buildSignupSection(),

                  if (!isSignUpScreen) buildSignInSection(),

                  //Submit Button
                  SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: tPrimary,
                            foregroundColor: tWhite, // Background color
                            padding: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(dBorderRadius))),
                        onPressed: () {
                          signInUser();
                        },
                        child: !isLoading
                            ? const Text(
                                "Login",
                                style: TextStyle(fontSize: 16),
                              )
                            : const SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child: CircularProgressIndicator(color: tWhite),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column buildSignInSection() {
    return Column(
      children: [
        buildTextField(Icons.mail, "E-mail", false, true, _emailController),
        buildTextField(
            Icons.password, "Password", true, false, _passwordController),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => const BorderSide(width: 1.0, color: tPrimary),
                    ),
                    value: isRememberMe,
                    activeColor: tPrimary,
                    checkColor: tWhite,
                    onChanged: (value) {
                      setState(() {
                        isRememberMe = !isRememberMe;
                      });
                    }),
                const Text(
                  "Remember me",
                  style: TextStyle(fontSize: 14, color: lighterGrey),
                )
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 14,
                  color: tPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Container buildSignupSection() {
    return Container(
      // padding: EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: dPadding * 2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextField(
                Icons.person, "Company Name", false, false, _emailController),
            buildTextField(Icons.mail, "E-Mail", false, true, _emailController),
            buildTextField(
                Icons.password, "Password", true, false, _passwordController),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 250,
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                    text: "By pressing 'Submit' you agree to out ",
                    style: TextStyle(color: lighterGrey),
                    children: [
                      TextSpan(
                        text: "terms & conditions",
                        style:
                            TextStyle(color: Colors.deepOrange, fontSize: 14),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextButton buildTextButton(
      IconData icon, Color bgColor, Color fgColor, String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
          side: const BorderSide(width: 1, color: lighterGrey),
          minimumSize: const Size(125, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          backgroundColor: bgColor),
      child: Row(children: [
        FaIcon(
          icon,
          color: fgColor,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: TextStyle(color: fgColor, fontWeight: FontWeight.w700),
        )
      ]),
    );
  }

//Text Form Field Builder Method
  Widget buildTextField(IconData icon, String hintText, bool isPassword,
      bool isEmail, TextEditingController fieldController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        style: const TextStyle(color: tBlack),
        controller: fieldController,
        cursorColor: tBlack,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(

            // border: OutlineInputBorder(borderRadius: BorderRadius.circular(dBorderRadius),),
            prefixIcon: Icon(
              icon,
              color: tBlack,
            ),
            contentPadding: const EdgeInsets.all(dPadding * 2),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: textColor1),
              borderRadius: BorderRadius.circular(dBorderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: tPrimary),
              borderRadius: BorderRadius.circular(dBorderRadius),
            ),
            hintText: hintText),
      ),
    );
  }
}
