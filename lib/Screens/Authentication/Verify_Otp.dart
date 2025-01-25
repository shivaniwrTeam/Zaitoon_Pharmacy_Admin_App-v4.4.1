import 'dart:async';
import 'package:admin_eshop/Screens/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../Helper/AppBtn.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/Session.dart';
import '../../Helper/String.dart';
import 'Set_Password.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber;
  final String? countryCode;
  final String? title;
  const VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
      this.title,})
      : super(key: key);
  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = GlobalKey();
  String? password;
  String? mobile;
  String? countrycode;
  String? otp;
  bool isCodeSent = false;
  late String _verificationId;
  String signature = "";
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  @override
  void initState() {
    super.initState();
    getUserDetails();
    getSingature();
    _onVerifyCode();
    Future.delayed(const Duration(seconds: 60)).then(
      (_) {
        _isClickable = true;
      },
    );
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    buttonSqueezeanimation = Tween(
      begin: deviceWidth * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    mobile = await getPrefrence(MOBILE);
    countrycode = await getPrefrence(COUNTRY_CODE);
    setState(
      () {},
    );
  }

  Future<void> checkNetworkOtp() async {
    final bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setsnackbar(OTPWR, context);
      }
    } else {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );
      Future.delayed(const Duration(seconds: 60)).then(
        (_) async {
          final bool avail = await isNetworkAvailable();
          if (avail) {
            if (_isClickable) {
              _onVerifyCode();
            } else {
              setsnackbar(OTPWR, context);
            }
          } else {
            await buttonController!.reverse();
            setsnackbar(getTranslated(context, somethingMSg)!, context);
          }
        },
      );
    }
  }

  AppBtn verifyBtn() {
    return AppBtn(
      title: VERIFY_AND_PROCEED,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        _onFormSubmitted();
      },
    );
  }

  Future<void> _onVerifyCode() async {
    setState(
      () {
        isCodeSent = true;
      },
    );
    verificationCompleted(AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential).then(
        (UserCredential value) {
          if (value.user != null) {
            setsnackbar(OTPMSG, context);
            setPrefrence(MOBILE, mobile!);
            setPrefrence(COUNTRY_CODE, countrycode!);
            if (widget.title == FORGOT_PASS_TITLE) {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => SetPass(mobileNumber: mobile!),
                ),
              );
            }
          } else {
            setsnackbar(OTPERROR, context);
          }
        },
      ).catchError(
        (error) {
          setsnackbar(error.toString(), context);
        },
      );
    }

    verificationFailed(FirebaseAuthException authException) {
      setsnackbar(authException.message!, context);
      setState(
        () {
          isCodeSent = false;
        },
      );
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;
      setState(
        () {
          _verificationId = verificationId;
        },
      );
    }

    codeAutoRetrievalTimeout(String verificationId) {
      _verificationId = verificationId;
      setState(
        () {
          _isClickable = true;
          _verificationId = verificationId;
        },
      );
    }

    if (isFirebaseAuth) {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
          timeout: const Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,);
    }
  }

  Future<void> _onFormSubmitted() async {
    final String code = otp!.trim();
    if (code.length == 6) {
      _playAnimation();
      if (isFirebaseAuth) {
        final AuthCredential authCredential = PhoneAuthProvider.credential(
            verificationId: _verificationId, smsCode: code,);
        _firebaseAuth.signInWithCredential(authCredential).then(
          (UserCredential value) async {
            if (value.user != null) {
              await buttonController!.reverse();
              setsnackbar(getTranslated(context, OTPMSG)!, context);
              setPrefrence(MOBILE, mobile!);
              setPrefrence(COUNTRY_CODE, countrycode!);
              if (widget.title == SEND_OTP_TITLE) {
              } else if (widget.title == FORGOT_PASS_TITLE) {
                Future.delayed(const Duration(seconds: 2)).then(
                  (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SetPass(
                          mobileNumber: mobile!,
                        ),
                      ),
                    );
                  },
                );
              }
            } else {
              setsnackbar(getTranslated(context, OTPERROR)!, context);
              await buttonController!.reverse();
            }
          },
        ).catchError(
          (error) async {
            setsnackbar(error.toString(), context);
            await buttonController!.reverse();
          },
        );
      } else {
        final response = await apiBaseHelper
            .postAPICall(verifyOtp, {"mobile": mobile, "otp": otp});
        if (response['error']) {
          setsnackbar(response['message'], context);
          await buttonController!.reverse();
        } else {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => SetPass(
                mobileNumber: mobile!,
              ),
            ),
          );
        }
      }
    } else {
      setsnackbar(getTranslated(context, ENTEROTP)!, context);
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Expanded getImage() {
    return Expanded(
      flex: 4,
      child: Center(
        child: SvgPicture.asset(
          'assets/images/homelogo.svg',
          colorFilter: const ColorFilter.mode(
            primary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Padding monoVarifyText() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: Center(
        child: Text(
          getTranslated(context, MOBILE_NUMBER_VARIFICATION)!,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Padding otpText() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child: Center(
        child: Text(
          getTranslated(context, SENT_VERIFY_CODE_TO_NO_LBL)!,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Padding mobText() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10.0,
        left: 20.0,
        right: 20.0,
        top: 10.0,
      ),
      child: Center(
        child: Text(
          "+$countrycode-$mobile",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Padding otpLayout() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 50.0,
        right: 50.0,
      ),
      child: Center(
        child: PinFieldAutoFill(
          decoration: UnderlineDecoration(
            textStyle: const TextStyle(fontSize: 20, color: fontColor),
            colorBuilder: const FixedColorBuilder(lightWhite),
          ),
          currentCode: otp,
          onCodeChanged: (String? code) {
            otp = code;
          },
          onCodeSubmitted: (String code) {
            otp = code;
          },
        ),
      ),
    );
  }

  Padding resendText() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 30.0, left: 25.0, right: 25.0, top: 10.0,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslated(context, DIDNT_GET_THE_CODE)!,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: fontColor,
                  fontWeight: FontWeight.normal,
                ),
          ),
          InkWell(
            onTap: () async {
              await buttonController!.reverse();
              checkNetworkOtp();
            },
            child: Text(
              getTranslated(context, RESEND_OTP)!,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded expandedBottomView() {
    return Expanded(
      flex: 6,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Card(
            elevation: 0.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                monoVarifyText(),
                otpText(),
                mobText(),
                otpLayout(),
                verifyBtn(),
                resendText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: lightWhite,
        padding: const EdgeInsets.only(
          bottom: 20.0,
        ),
        child: Column(
          children: <Widget>[
            getImage(),
            expandedBottomView(),
          ],
        ),
      ),
    );
  }
}
