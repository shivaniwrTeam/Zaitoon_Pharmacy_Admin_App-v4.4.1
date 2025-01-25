import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../Helper/AppBtn.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/Session.dart';
import '../../Helper/String.dart';
import '../Privacy_Policy.dart';
import 'Verify_Otp.dart';

class SendOtp extends StatefulWidget {
  String? title;
  SendOtp({Key? key, this.title}) : super(key: key);
  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile;
  String? id;
  String? countrycode;
  String? mobileno;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    final bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
          await buttonController!.reverse();
        },
      );
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, TRY_AGAIN_INT_LBL),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();
                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (BuildContext context) => super.widget,),);
                    } else {
                      await buttonController!.reverse();
                      setState(
                        () {},
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getVerifyUser() async {
    try {
      final data = {MOBILE: mobile};
      final Response response =
          await post(getVerifyUserApi, body: data, headers: headers)
              .timeout(const Duration(seconds: timeOut));
      final getdata = json.decode(response.body);
      final bool? error = getdata["error"];
      final String? msg = getdata["message"];
      await buttonController!.reverse();
      if (widget.title == SEND_OTP_TITLE) {
        if (!error!) {
          setsnackbar(msg!, context);
          setPrefrence(MOBILE, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          Future.delayed(const Duration(seconds: 1)).then((_) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => VerifyOtp(
                  mobileNumber: mobile!,
                  countryCode: countrycode,
                  title: SEND_OTP_TITLE,
                ),
              ),
            );
          });
        } else {
          setsnackbar(msg!, context);
        }
      }
      if (widget.title == FORGOT_PASS_TITLE) {
        if (!error!) {
          setPrefrence(MOBILE, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) => VerifyOtp(
                        mobileNumber: mobile!,
                        countryCode: countrycode,
                        title: FORGOT_PASS_TITLE,
                      ),),);
        } else {
          setsnackbar(msg!, context);
        }
      }
    } on TimeoutException catch (_) {
      setsnackbar(somethingMSg, context);
      await buttonController!.reverse();
    }
  }

  Expanded subLogo() {
    return Expanded(
      flex: widget.title == SEND_OTP_TITLE ? 4 : 5,
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

  Padding createAccTxt() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: Align(
        child: Text(
          widget.title == SEND_OTP_TITLE
              ? getTranslated(context, CREATE_ACC_LBL)!
              : getTranslated(context, FORGOT_PASSWORDTITILE)!,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Padding verifyCodeTxt() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 40.0, left: 40.0, right: 40.0, bottom: 20.0,),
      child: Align(
        child: Text(
          getTranslated(context, SEND_VERIFY_CODE_LBL)!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  SizedBox setCodeWithMono() {
    return SizedBox(
      width: deviceWidth * 0.7,
      child: IntlPhoneField(
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: fontColor, fontWeight: FontWeight.normal),
        controller: mobileController,
        decoration: InputDecoration(
          hintStyle: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: fontColor, fontWeight: FontWeight.normal),
          hintText: getTranslated(context, MOBILEHINT_LBL),
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(7),),
          fillColor: lightWhite,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        initialCountryCode: countryCode,
        onTap: () {},
        onSaved: (phoneNumber) {
          setState(() {
            countrycode =
                phoneNumber!.countryCode.replaceFirst('+', '');
            mobile = phoneNumber.number;
          });
        },
        onCountryChanged: (country) {
          setState(() {
            countrycode = country.dialCode;
          });
        },
        showDropdownIcon: false,
        invalidNumberMessage: getTranslated(context, 'VALID_MOB'),
        keyboardType: TextInputType.number,
        flagsButtonMargin: const EdgeInsets.only(left: 20, right: 20),
        pickerDialogStyle: PickerDialogStyle(
          padding: const EdgeInsets.only(left: 10, right: 10),
        ),
      ),
    );
  }

  AppBtn verifyBtn() {
    return AppBtn(
      title: widget.title == SEND_OTP_TITLE
          ? getTranslated(context, SEND_OTP)!
          : getTranslated(context, GET_PASSWORD)!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  Widget termAndPolicyTxt() {
    return widget.title == SEND_OTP_TITLE
        ? Padding(
            padding: const EdgeInsets.only(
                bottom: 30.0, left: 25.0, right: 25.0, top: 10.0,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  getTranslated(context, CONTINUE_AGREE_LBL)!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: fontColor,
                        fontWeight: FontWeight.normal,
                      ),
                ),
                const SizedBox(
                  height: 3.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const PrivacyPolicy(
                              title: TERM,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        getTranslated(context, TERMS_SERVICE_LBL)!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: fontColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      getTranslated(context, AND_LBL)!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: fontColor,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const PrivacyPolicy(
                              title: PRIVACY_POLICY_LBL,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        getTranslated(context, PRIVACY_POLICY_LBL)!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: fontColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container();
  }

  StatelessWidget backBtn() {
    return Platform.isIOS
        ? InkWell(
            onTap: () {
              print("clicked");
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsetsDirectional.only(top: 50.0, start: 20.0),
              alignment: AlignmentDirectional.topStart,
              child: const Card(
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: InkWell(
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this,);
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

  Expanded expandedBottomView() {
    return Expanded(
      flex: widget.title == SEND_OTP_TITLE ? 6 : 5,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formkey,
            child: Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  createAccTxt(),
                  verifyCodeTxt(),
                  setCodeWithMono(),
                  verifyBtn(),
                  termAndPolicyTxt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: _isNetworkAvail
          ? Container(
              color: lightWhite,
              padding: const EdgeInsets.only(
                bottom: 20.0,
              ),
              child: Column(
                children: <Widget>[
                  backBtn(),
                  subLogo(),
                  expandedBottomView(),
                ],
              ),
            )
          : noInternet(context),
    );
  }
}
