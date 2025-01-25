import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import 'Media.dart';
import 'package:http/http.dart' as http;

class AddBrand extends StatefulWidget {
  const AddBrand({Key? key}) : super(key: key);
  @override
  _AddBrandState createState() => _AddBrandState();
}

late String brandImage;
late String brandImageUrl;

class _AddBrandState extends State<AddBrand> with TickerProviderStateMixin {
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController brandNameControlller = TextEditingController();
  String? brandName;
  @override
  void initState() {
    brandImage = '';
    brandImageUrl = '';
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
    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: getAppBar(
        getTranslated(context, ADD_NEW_BRAND_LBL)!,
        context,
      ),
      body: _isNetworkAvail ? getBodyPart() : noInternet(context),
    );
  }

  SingleChildScrollView getBodyPart() {
    return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Form(
            key: _formkey,
            child: Column(children: [
              addBrandName(),
              brandImageWidget(),
              selectedBrandImageShow(),
              AppBtn(
                title: getTranslated(context, ADD_BRAND_LBL),
                btnAnim: buttonSqueezeanimation,
                btnCntrl: buttonController,
                onBtnSelected: () async {
                  validateAndSubmit();
                },
              ),
              resetProButton(),
              const SizedBox(
                width: 20,
                height: 30,
              ),
            ],),),);
  }

  Row resetProButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<String>(
                builder: (context) => const AddBrand(),
              ),
            );
            setsnackbar("Reset Successfully", context);
          },
          child: Container(
            height: 50,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: lightBlack2,
            ),
            child: Center(
              child: Text(
                getTranslated(context, ResetAllText)!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column addBrandName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        brandText(),
        brandTextField(),
      ],
    );
  }

  Padding brandText() {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
        top: 15,
      ),
      child: Text(
        getTranslated(context, BRAND_NAME_LBL)!,
        style: const TextStyle(
          fontSize: 16,
          color: fontColor,
        ),
      ),
    );
  }

  Container brandTextField() {
    return Container(
      width: deviceWidth,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: brandNameControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onChanged: (value) {
          brandName = value;
        },
        validator: (val) => validateBrand(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, ADD_NEW_BRAND_NAME_LBL),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
        ),
      ),
    );
  }

  Padding brandImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, BRAND_IMAGE_LBL)!,
          ),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(5),
              ),
              width: 90,
              height: 40,
              child: Center(
                child: Text(
                  getTranslated(context, UploadText)!,
                  style: const TextStyle(
                    color: white,
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Media(
                    from: "main",
                    type: "addBrand",
                  ),
                ),
              ).then(
                (value) => setState(
                  () {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget selectedBrandImageShow() {
    return brandImage == ''
        ? Container()
        : Image.network(
            brandImageUrl,
            width: 100,
            height: 100,
          );
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      addBrand();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      if (brandName == '' && brandName == null) {
        setsnackbar(getTranslated(context, PLZ_ADD_BRAND_NAME_LBL)!, context);
        return false;
      } else if (brandImage == '') {
        setsnackbar(getTranslated(context, PLZ_ADD_BRAND_IMAGE_LBL)!, context);
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> addBrand() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        final request = http.MultipartRequest("POST", addBrandApi);
        request.headers.addAll(headers);
        request.fields['brand_input_name'] = brandName!;
        request.fields['brand_input_image'] = brandImage;
        print("response : ${request.fields}");
        print("response : ${request.files}");
        final response = await request.send();
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final getdata = json.decode(responseString);
        print("getdata : $getdata");
        final bool error = getdata["error"];
        final String msg = getdata['message'];
        if (!error) {
          await buttonController!.reverse();
          setsnackbar(msg, context);
        } else {
          await buttonController!.reverse();
          setsnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, somethingMSg)!,
          context,
        );
      }
    } else if (mounted) {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        },
      );
    }
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
                          builder: (BuildContext context) => super.widget,
                        ),
                      );
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
}
