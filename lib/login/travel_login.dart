import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_hotel/api/travel_api.dart';
import 'package:flutter_application_hotel/layout/travel_index.dart';
import 'package:flutter_application_hotel/model/travel_user.dart';
import 'travel_signup.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_hotel/user/user_pref.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  String id = "";
  String pw = "";
  bool? yes;
  final formKey = GlobalKey<FormState>();

  String? validatePassword(String value) {
    String pattern =
        r'^(?=.*[a-zA-z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,15}$';
    RegExp regExp = RegExp(pattern);

    if (value.isEmpty) {
      return '비밀번호를 입력하세요';
    } else if (value.length < 8) {
      return '비밀번호는 8자리 이상이어야 합니다';
    } else if (!regExp.hasMatch(value)) {
      return '특수문자, 문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.';
    } else {
      return null; //null을 반환하면 정상
    }
  }

  String? validatePasswordConfirm(String password, String passwordConfirm) {
    if (passwordConfirm.isEmpty) {
      return '비밀번호 확인칸을 입력하세요';
    } else if (password != passwordConfirm) {
      return '입력한 비밀번호가 서로 다릅니다.';
    } else {
      return null; //null을 반환하면 정상
    }
  }

  userLogin() async {
    try {
      var res = await http.post(Uri.parse(TravelApi.login), body: {
        'travel_email': emailController.text.trim(),
        'travel_pw': passwordController.text.trim(),
      });

      if (res.statusCode == 200) {
        var resLogin = jsonDecode(res.body);

        if (resLogin['success'] == true) {
          TravelUser travelInfo = TravelUser.fromJson(resLogin['travelData']);
          print(travelInfo.toJson());
          await RememberTravel.saveRememberTravelInfo(travelInfo);

          setState(() {
            emailController.clear();
            passwordController.clear();
          });

          complete();
        } else {
          failed();
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  complete() {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const travel_index()));
  }

  failed() {
    return ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('로그인 실패')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 120,
          title: const Text(
            '로그인',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black54,
              ),
              label: const Text(
                '뒤로가기',
                style: TextStyle(color: Colors.black54),
              ),
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.grey.withOpacity(0.04);
                  }
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.grey.withOpacity(0.12);
                  }
                  return Colors.black;
                }),
              ),
            ),
          ),
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
        ),
        body: Center(
          child: Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('여행사 로그인'),
                      ],
                    ),
                    const SizedBox(
                        width: 120,
                        child: Divider(color: Colors.black, thickness: 2.0)),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        width: 350,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => id = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "이메일을 입력하세요.";
                            } else if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return "올바른 이메일 주소를 입력하세요.";
                            }
                            return null;
                          },
                          controller: emailController,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.perm_identity),
                              hintText: '이메일을 입력하세요.'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (value) => pw = value,
                        validator: (value) => validatePassword(value!),
                        controller: passwordController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: '비밀번호를 입력하세요.'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const travelSignUp()));
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                children: [
                                  Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Text(
                              ' | ',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const travelSignUp()));
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                children: [
                                  Text(
                                    '아이디 찾기',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Text(
                              ' | ',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const travelSignUp()));
                            },
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                children: [
                                  Text(
                                    '비밀번호 찾기',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: 350,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          userLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ));
  }
}