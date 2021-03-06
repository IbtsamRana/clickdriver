import 'dart:convert';

import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Themes/colors.dart';
import 'package:driver/Themes/style.dart';
import 'package:driver/baseurl/baseurl.dart';
import 'package:driver/beanmodel/profilebean.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

//Verification page that sends otp to the phone number entered on phone number page
class VerificationPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          locale.verification,
          style: headingStyle,
        ),
      ),
      body: OtpVerify(),
    );
  }
}

//otp verification class
class OtpVerify extends StatefulWidget {

  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging firebaseMessaging;
  bool isDialogShowing = false;
  var deviceToken = '';
  var showDialogBox = false;
  var verificaitonPin = "";
  var firebaseAuth;
  var actualCode;
  AuthCredential _authCredential;

  bool firebaseOtp = false;

  @override
  void initState() {
    super.initState();
    hitAsyncInit();
  }

  void hitAsyncInit() async{
    try{
      Firebase.initializeApp();
    }catch(e){}
    firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((value) {
      deviceToken = value;
    });
    getFIrebaseStatus();
  }

  void getFIrebaseStatus() async{
    setState(() {
      showDialogBox = true;
    });
    var url = firebase;
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonData['data']['status'];
          if (tagObjsJson!=null && (tagObjsJson == '1' || tagObjsJson == 1)) {
            print('fd ${tagObjsJson}');
            setState(() {
              firebaseOtp = true;
            });
            initilizedFirebaseAuth();

          } else {
            setState(() {
              firebaseOtp = false;
              showDialogBox = false;
            });
          }
        } else {
          setState(() {
            firebaseOtp = false;
            showDialogBox = false;
          });
        }
      } else {
        setState(() {
          firebaseOtp = false;
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        firebaseOtp = false;
        showDialogBox = false;
      });
    });
  }


  initilizedFirebaseAuth() async{
    // print(firebaseOtp);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNumber = prefs.getString('delivery_boy_phone');
    firebaseAuth = await FirebaseAuth.instance;
    PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async {
      actualCode = verificationId;
      print('Code sent');
      if(showDialogBox!=null && showDialogBox){
        setState(() {
          showDialogBox = false;
        });
      }
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.actualCode = verificationId;
      print('Auto retrieval time out');

    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
          if(showDialogBox!=null && showDialogBox){
            setState(() {
              showDialogBox = false;
            });
          }
    };

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential auth) {
          if(showDialogBox!=null && showDialogBox){
            setState(() {
              showDialogBox = false;
            });
          }
    };

    firebaseAuth.verifyPhoneNumber(
        phoneNumber: userNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }


  void _signInWithPhoneNumber(String smsCode, BuildContext context) async {
    _authCredential = await PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);
    firebaseAuth.signInWithCredential(_authCredential).catchError((error) {
      print(error);
      if(showDialogBox!=null && showDialogBox){
        setState(() {
          showDialogBox = false;
        });
      }
    }).then((User user) async {
      print('${user.phoneNumber}\n${user.providerData.toList().toString()}');
      if(user!=null){
        hitFirebaseSuccessStatus('success',context);
      }
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: 10, bottom: 5, right: 80, left: 80),
                      child: Center(
                        child: Text(
                          locale.verifyYourPhoneNumber,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kMainTextColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        locale.enterYourMessageHere,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20.0, left: 20.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.0),
                          PinCodeTextField(
                            autofocus: true,
                            controller: _controller,
                            hideCharacter: false,
                            highlight: true,
                            highlightColor: kHintColor,
                            defaultBorderColor: kMainColor,
                            hasTextBorderColor: kMainColor,
                            maxLength: firebaseOtp?6:4,
                            pinBoxRadius: firebaseOtp?30:40,
                            onDone: (text) {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              verificaitonPin = text;
                            },
                            pinBoxWidth: firebaseOtp?45:60,
                            pinBoxHeight: firebaseOtp?45:60,
                            hasUnderline: false,
                            wrapAlignment: WrapAlignment.spaceAround,
                            pinBoxDecoration: ProvidedPinBoxDecoration
                                .roundedPinBoxDecoration,
                            pinTextStyle: TextStyle(fontSize: firebaseOtp?18.0:22.0),
                            pinTextAnimatedSwitcherTransition:
                            ProvidedPinBoxTextAnimation.scalingTransition,
                            pinTextAnimatedSwitcherDuration:
                            Duration(milliseconds: 300),
                            highlightAnimationBeginColor: Colors.black,
                            highlightAnimationEndColor: Colors.white12,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15.0),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              locale.didNotYouReceiveAnyCode,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              locale.resendNewCode,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kMainColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                )),
            Positioned(
              bottom: 12,
              left: 20,
              right: 20.0,
              child: InkWell(
                onTap: () {
                  if (!showDialogBox) {
                    setState(() {
                      showDialogBox = true;
                    });
                    if(firebaseOtp){
                      _signInWithPhoneNumber(verificaitonPin,context);
                    }else{
                      hitService(verificaitonPin, context);
                    }
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 52,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: kMainColor),
                  child: Text(
                    locale.verify,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: kWhiteColor,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: Visibility(
              visible: showDialogBox,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 100,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 120,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        color: kWhiteColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              locale.loadingPleaseWait,
                              style: TextStyle(
                                  color: kMainTextColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void hitService(String verificaitonPin, BuildContext context) async {
    if (deviceToken != null && deviceToken.length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = driverlogin;
      http.post(url, body: {
        'phone': prefs.getString('delivery_boy_phone'),
        'otp': verificaitonPin,
        'device_id': '${deviceToken}'
      }).then((response) {
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 1) {
            DriverProfile profile = DriverProfile.fromJson(jsonData['data']);
            prefs.setInt('duty', 0);
            var delivery_id = int.parse('${profile.delivery_boy_id}');
            prefs.setInt("delivery_boy_id", delivery_id);
            prefs.setString("delivery_boy_name", profile.delivery_boy_name);
            prefs.setString("delivery_boy_image", profile.delivery_boy_image);
            prefs.setString("delivery_boy_phone", profile.delivery_boy_phone);
            prefs.setString("delivery_boy_pass", profile.delivery_boy_pass);
            prefs.setString("device_id", profile.device_id);
            prefs.setString("delivery_boy_status", profile.delivery_boy_status);
            prefs.setString("is_confirmed", profile.is_confirmed);
            var cityadmin_id = int.parse(
                '${(profile.cityadmin_id != null) ? profile.cityadmin_id : 0}');
            prefs.setInt("cityadmin_id", cityadmin_id);
            var phone_verify = int.parse('${profile.phone_verify}');
            prefs.setInt("phoneverifed", phone_verify);
            prefs.setBool("islogin", true);
            if (jsonData['currency'] != null &&
                jsonData['currency'].toString().length > 2) {
              CurrencyData currencyData =
                  CurrencyData.fromJson(jsonData['currency']);
              prefs.setString("curency", '${currencyData.currency_sign}');
            }
            Toast.show(jsonData['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.accountPage, (route) => false);
          } else {
            prefs.setInt("phoneverifed", 0);
            prefs.setBool("islogin", false);
            Toast.show(jsonData['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            setState(() {
              showDialogBox = false;
            });
          }
        }
      });
    } else {
      firebaseMessaging.getToken().then((value) {
        deviceToken = value;
        hitService(verificaitonPin, context);
      });
    }
  }

  void hitFirebaseSuccessStatus(String status, BuildContext context) async {
    if (deviceToken != null && deviceToken.toString().length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = verifyotpfirebase;
      await http.post(url, body: {
        'user_phone': prefs.getString('user_phone'),
        'status': verificaitonPin,
        'device_id': '${deviceToken}'
      }).then((response) {
        print('Response Body: - ${response.body}');
        if (response.statusCode == 200) {
          print('Response Body: - ${response.body}');
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 1) {
            var userId = int.parse('${jsonData['data']['user_id']}');
            prefs.setInt("user_id", userId);
            prefs.setString("user_name", jsonData['data']['user_name']);
            prefs.setString("user_email", jsonData['data']['user_email']);
            prefs.setString("user_image", jsonData['data']['user_image']);
            prefs.setString("user_phone", jsonData['data']['user_phone']);
            prefs.setString("user_password", jsonData['data']['user_password']);
            prefs.setString(
                "wallet_credits", jsonData['data']['wallet_credits']);
            prefs.setString("first_recharge_coupon",
                jsonData['data']['first_recharge_coupon']);
            prefs.setBool("phoneverifed", true);
            prefs.setBool("islogin", true);
            prefs.setString("refferal_code", jsonData['data']['referral_code']);
            if (jsonData['currency'] != null) {
              CurrencyData currencyData =
              CurrencyData.fromJson(jsonData['currency']);
              print('${currencyData.toString()}');
              prefs.setString("curency", '${currencyData.currency_sign}');
            }
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.accountPage, (route) => false);
          } else {
            prefs.setBool("phoneverifed", false);
            prefs.setBool("islogin", false);
            setState(() {
              showDialogBox = false;
            });
          }
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      }).catchError((e) {
        print(e);
        setState(() {
          showDialogBox = false;
        });
      });
    } else {
      firebaseMessaging.getToken().then((value) {
        deviceToken = value;
        hitFirebaseSuccessStatus(status, context);
      });
    }
  }
}
