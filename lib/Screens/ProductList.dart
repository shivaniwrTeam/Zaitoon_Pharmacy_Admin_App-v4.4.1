import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:admin_eshop/Screens/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'AddProduct.dart';
import 'EditProduct.dart';
import 'Search.dart';

class ProductList extends StatefulWidget {
  final String? flag;
  const ProductList({Key? key, this.flag}) : super(key: key);
  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true;
  final bool _isProgress = false;
  bool _isButtonExtended = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String? sortBy = 'p.id';
  String? orderBy = "DESC";
  String? flag = '';
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  List<dynamic>? filterList = [];
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  String? filter = "";
  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  final List<TextEditingController> _controller = [];
  var items;
  bool isFilterClear = false;
  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    flag = widget.flag;
    getProduct("0");
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

  @override
  void dispose() {
    buttonController!.dispose();
    controller.removeListener(
      () {},
    );
    for (int i = 0; i < _controller.length; i++) {
      _controller[i].dispose();
    }
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightWhite,
      appBar: getAppbar(),
      floatingActionButton: floatingBtn(),
      key: _scaffoldKey,
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : productList.isEmpty
                  ? getNoItem()
                  : Stack(
                      children: <Widget>[
                        _showForm(),
                        showCircularProgress(_isProgress, primary),
                      ],
                    )
          : noInternet(context),
    );
  }

  Column floatingBtn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          isExtended: _isButtonExtended,
          backgroundColor: white,
          label: Text(
            getTranslated(context, 'ADD NEW PRODUCT')!,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: fontColor, fontSize: 15),
          ),
          icon: const Icon(
            Icons.add,
            size: 32,
            color: fontColor,
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute<String>(
                builder: (context) => const AddProduct(),
              ),
            );
            print("result: $result");
            if (result == 'refresh') {
              setState(
                () {
                  _isLoading = true;
                  isLoadingmore = true;
                  offset = 0;
                  total = 0;
                  productList.clear();
                },
              );
              getProduct("0");
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
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
              title: getTranslated(context, NO_INTERNET),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();
                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      offset = 0;
                      total = 0;
                      flag = '';
                      getProduct("0");
                    } else {
                      await buttonController!.reverse();
                      if (mounted) {
                        setState(
                          () {},
                        );
                      }
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

  Container noIntBtn(BuildContext context) {
    final double width = deviceWidth;
    return Container(
      padding: const EdgeInsetsDirectional.only(
        bottom: 10.0,
        top: 50.0,
      ),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80.0),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => super.widget,
              ),
            );
          },
          child: Ink(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: width / 1.2,
                minHeight: 45,
              ),
              alignment: Alignment.center,
              child: Text(
                getTranslated(context, NO_INTERNET)!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: white,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget listItem(int index) {
    if (index < productList.length) {
      final Product model = productList[index];
      totalProduct = model.total;
      String stockType = "";
      if (model.stockType == "") {
        stockType = "Not enabled";
      } else if (model.stockType == "1" || model.stockType == "0") {
        stockType = "Global";
      } else if (model.stockType == "2") {
        stockType = "Varient wise";
      }
      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }
      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;
      items = List<String>.generate(
        model.totalAllow != "" ? int.parse(model.totalAllow!) : 10,
        (i) => (i + 1).toString(),
      );
      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }
      return Card(
        elevation: 0,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  model: model,
                ),
              ),
            ).then(
              (value) => () {
                setState(
                  () {
                    _isLoading = true;
                    isLoadingmore = true;
                    offset = 0;
                    total = 0;
                    productList.clear();
                  },
                );
                return getProduct("0");
              }(),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: "$index${model.id}",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: FadeInImage(
                          image: NetworkImage(model.image!),
                          height: 80.0,
                          width: 80.0,
                          placeholder: placeHolder(80),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return erroWidget(
                              80,
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              model.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: lightBlack),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "${CUR_CURRENCY!} $price ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  double.parse(
                                            model
                                                .prVarientList![
                                                    model.selVarient!]
                                                .disPrice!,
                                          ) !=
                                          0
                                      ? "${CUR_CURRENCY!}${model.prVarientList![model.selVarient!].price!}"
                                      : "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        letterSpacing: 0,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              '${getTranslated(context, StockType)!}: $stockType',
                            ),
                            if (model.prVarientList![model.selVarient!].stock !=
                                "")
                              Text(
                                '${getTranslated(context, StockCount)!}: ${model.prVarientList![model.selVarient!].stock}',
                                style: const TextStyle(
                                  color: fontColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Container(),
                            InkWell(
                              onTap: () {
                                productDeletDialog(
                                  model.name!,
                                  model.id!,
                                );
                              },
                              child: const Icon(
                                Icons.delete,
                                color: red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (model.availability == "0")
                Text(
                  getTranslated(context, OutofStock)!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                )
              else
                Container(),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  productDeletDialog(String productName, String id) async {
    final String pName = productName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Text(
                '${getTranslated(context, SURE_LBL)!} "  $pName " ${getTranslated(context, "PRODUCT")!}',
                style: Theme.of(this.context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, "No")!,
                    style:
                        Theme.of(this.context).textTheme.titleSmall!.copyWith(
                              color: lightBlack,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, "Yes")!,
                    style:
                        Theme.of(this.context).textTheme.titleSmall!.copyWith(
                              color: fontColor,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    delProductApi(id);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> delProductApi(String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      final parameter = {
        "product_id": id,
      };
      apiBaseHelper.postAPICall(getDeleteProductApi, parameter).then(
        (getdata) {
          final bool error = getdata["error"];
          final String? msg = getdata["message"];
          if (!error) {
            setsnackbar(msg!, context);
            _isLoading = true;
            isLoadingmore = true;
            offset = 0;
            total = 0;
            productList.clear();
            getProduct("0");
          } else {
            setsnackbar(msg!, context);
            _isLoading = true;
            isLoadingmore = true;
            offset = 0;
            total = 0;
            productList.clear();
            getProduct("0");
          }
        },
        onError: (error) {},
      );
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            _isLoading = false;
          },
        );
      }
    }
    return;
  }

  updateProductList() {
    if (mounted) {
      setState(
        () {},
      );
    }
  }

  Future<void> getProduct(String top) async {
    if (readProduct) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          final parameter = {
            SORT: sortBy,
            "order": orderBy,
            LIMIT: perPage.toString(),
            OFFSET: offset.toString(),
            TOP_RETAED: top,
            FLAG: flag,
          };
          if (selId != "") {
            parameter[ATTRIBUTE_VALUE_ID] = selId;
          }
          print("parameter : $parameter");
          final Response response =
              await post(getProductApi, headers: headers, body: parameter)
                  .timeout(const Duration(seconds: timeOut));
          log("API is $getProductApi \n para are $parameter \n response : ${response.body}");
          if (response.statusCode == 200) {
            final getdata = json.decode(response.body);
            final bool error = getdata["error"];
            final String? msg = getdata["message"];
            if (!error) {
              total = int.parse(getdata["total"]);
              if (_isFirstLoad) {
                filterList = getdata["filters"];
                _isFirstLoad = false;
              }
              if (offset < total) {
                tempList.clear();
                final data = getdata["data"];
                tempList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                getAvailVarient();
                offset = offset + perPage;
              }
            } else {
              if (msg != "Products Not Found !") setsnackbar(msg!, context);
              isLoadingmore = false;
            }
            if (mounted) {
              setState(
                () {
                  _isLoading = false;
                  isFilterClear = false;
                },
              );
            }
          }
        } on TimeoutException catch (_) {
          setsnackbar(somethingMSg, context);
          if (mounted) {
            setState(
              () {
                _isLoading = false;
                isLoadingmore = false;
              },
            );
          }
        }
      } else {
        if (mounted) {
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isLoading = false;
          },
        );
      }
      Future.delayed(const Duration(microseconds: 500)).then(
        (_) async {
          setsnackbar(getTranslated(context, readProductText)!, context);
        },
      );
    }
    return;
  }

  void getAvailVarient() {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;
            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  AppBar getAppbar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: lightWhite,
      iconTheme: const IconThemeData(color: primary),
      title: Text(
        getTranslated(context, PRO_LBL)!,
        style: const TextStyle(
          color: primary,
        ),
      ),
      elevation: 5,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(end: 4.0),
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                stockFilter();
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.filter_alt_outlined,
                  color: primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const Search(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.search,
                  color: primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    listType ? Icons.grid_view : Icons.list,
                    color: primary,
                    size: 22,
                  ),
                ),
                onTap: () {
                  productList.isNotEmpty
                      ? setState(
                          () {
                            listType = !listType;
                          },
                        )
                      : setState(
                          () {},
                        );
                },
              ),
            ),
          ),
        ),
        Container(
          width: 40,
          margin: const EdgeInsetsDirectional.only(top: 10, bottom: 10, end: 5),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton(
                padding: EdgeInsets.zero,
                onSelected: (dynamic value) {
                  switch (value) {
                    case 0:
                      return filterDialog();
                    case 1:
                      return sortDialog();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 0,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsetsDirectional.zero,
                      leading: const Icon(
                        Icons.tune,
                        color: fontColor,
                        size: 20,
                      ),
                      title: Text(
                        getTranslated(context, FilterText)!,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsetsDirectional.zero,
                      leading:
                          const Icon(Icons.sort, color: fontColor, size: 20),
                      title: Text(
                        getTranslated(context, Sort)!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget productItem(int index, bool pad) {
    if (index < productList.length) {
      final Product model = productList[index];
      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }
      if (_controller.length < index + 1) {
        _controller.add(
          TextEditingController(),
        );
      }
      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;
      items = List<String>.generate(
        model.totalAllow != "" ? int.parse(model.totalAllow!) : 10,
        (i) => (i + 1).toString(),
      );
      String stockType = "";
      if (model.stockType == "") {
        stockType = "Not enabled";
      } else if (model.stockType == "1" || model.stockType == "0") {
        stockType = "Global";
      } else if (model.stockType == "2") {
        stockType = "Varient wise";
      }
      final double width = deviceWidth * 0.5;
      return Card(
        elevation: 0.2,
        margin: EdgeInsetsDirectional.only(bottom: 5, end: pad ? 5 : 0),
        child: InkWell(
          onTap: () async {
            print("------HELOO");
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  model: model,
                ),
              ),
            ).then(
              (value) => () {
                setState(() {
                  _isLoading = true;
                  isLoadingmore = true;
                  offset = 0;
                  total = 0;
                  productList.clear();
                });
                return getProduct("0");
              }(),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                      child: Hero(
                        tag: "$index${model.id}",
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: NetworkImage(model.image!),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return erroWidget(
                              width,
                            );
                          },
                          placeholder: placeHolder(width),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: model.availability == "0"
                          ? Text(
                              getTranslated(context, OutofStock)!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5.0,
                  top: 5,
                  bottom: 5,
                ),
                child: Text(
                  model.name!,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    " ${CUR_CURRENCY!} $price ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (double.parse(
                        model.prVarientList![model.selVarient!].disPrice!,
                      ) !=
                      0)
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              double.parse(
                                        model.prVarientList![model.selVarient!]
                                            .disPrice!,
                                      ) !=
                                      0
                                  ? "${CUR_CURRENCY!}${model.prVarientList![model.selVarient!].price!}"
                                  : "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  '${getTranslated(context, StockType)!}: $stockType',
                ),
              ),
              if (model.prVarientList![model.selVarient!].stock != "")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    '${getTranslated(context, StockCount)!}: ${model.prVarientList![model.selVarient!].stock ?? ''}',
                    style: const TextStyle(
                      color: fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(),
              InkWell(
                onTap: () {
                  productDeletDialog(
                    model.name!,
                    model.id!,
                  );
                },
                child: const Icon(
                  Icons.delete,
                  color: red,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void stockFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 2.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 19.0,
                    bottom: 16.0,
                  ),
                  child: Text(
                    getTranslated(context, StockFilter)!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(color: lightBlack),
                OverflowBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Center(
                        child: Text(
                          getTranslated(context, All)!,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: lightBlack,
                                  ),
                        ),
                      ),
                      onPressed: () {
                        flag = '';
                        if (mounted) {
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 1');
                      },
                    ),
                    const Divider(color: lightBlack),
                    TextButton(
                      child: Center(
                        child: Text(
                          getTranslated(context, SOLD_LBL)!,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: lightBlack,
                                  ),
                        ),
                      ),
                      onPressed: () {
                        flag = 'sold';
                        if (mounted) {
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 1');
                      },
                    ),
                    const Divider(color: lightBlack),
                    TextButton(
                      child: Center(
                        child: Text(
                          getTranslated(context, LOW_LBL)!,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: lightBlack,
                                  ),
                        ),
                      ),
                      onPressed: () {
                        flag = 'low';
                        if (mounted) {
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 2');
                      },
                    ),
                    const Divider(color: white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void sortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 2.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                5.0,
              ),
            ),
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 19.0,
                    bottom: 16.0,
                  ),
                  child: Text(
                    getTranslated(context, soartBy)!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(color: lightBlack),
                OverflowBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Center(
                        child: Text(
                          getTranslated(context, topRated)!,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: lightBlack,
                                  ),
                        ),
                      ),
                      onPressed: () {
                        sortBy = '';
                        orderBy = 'DESC';
                        flag = '';
                        if (mounted) {
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        }
                        getProduct("1");
                        Navigator.pop(context, 'option 1');
                      },
                    ),
                    const Divider(color: lightBlack),
                    TextButton(
                      child: Center(
                        child: Text(
                          getTranslated(context, newestFirst)!,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: lightBlack,
                                  ),
                        ),
                      ),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'DESC';
                        flag = '';
                        if (mounted) {
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 1');
                      },
                    ),
                    const Divider(color: lightBlack),
                    TextButton(
                      child: Center(
                        child: Text(
                          getTranslated(context, oldestFirst)!,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: lightBlack,
                                  ),
                        ),
                      ),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'ASC';
                        flag = '';
                        if (mounted) {
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 2');
                      },
                    ),
                    const Divider(color: lightBlack),
                    TextButton(
                      child: Center(
                        child: Text(
                          getTranslated(context, pricelowtoHigh)!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: lightBlack),
                        ),
                      ),
                      onPressed: () {
                        sortBy = 'pv.price';
                        orderBy = 'ASC';
                        flag = '';
                        if (mounted) {
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 3');
                      },
                    ),
                    const Divider(color: lightBlack),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                      child: TextButton(
                        child: Center(
                          child: Text(
                            getTranslated(context, pricehightolow)!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: lightBlack),
                          ),
                        ),
                        onPressed: () {
                          sortBy = 'pv.price';
                          orderBy = 'DESC';
                          flag = '';
                          if (mounted) {
                            setState(
                              () {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              },
                            );
                          }
                          getProduct("0");
                          Navigator.pop(context, 'option 4');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _scrollListener() {
    setState(() {
      _isButtonExtended =
          controller.position.userScrollDirection == ScrollDirection.forward;
    });
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              isLoadingmore = true;
              if (offset < total) getProduct("0");
            },
          );
        }
      }
    }
  }

  Future<void> _refresh() {
    if (mounted) {
      setState(
        () {
          _isLoading = true;
          isLoadingmore = true;
          offset = 0;
          total = 0;
          productList.clear();
        },
      );
    }
    return getProduct("0");
  }

  RefreshIndicator _showForm() {
    print("productList****${productList.length}");
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: listType
          ? ListView.builder(
              controller: controller,
              itemCount: (offset < total)
                  ? productList.length + 1
                  : productList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (index == productList.length && isLoadingmore)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : listItem(index);
              },
            )
          : GridView.count(
              padding: const EdgeInsetsDirectional.only(top: 5),
              crossAxisCount: 2,
              controller: controller,
              childAspectRatio: 0.8,
              physics: const AlwaysScrollableScrollPhysics(),
              children: List.generate(
                (offset < total) ? productList.length + 1 : productList.length,
                (index) {
                  return (index == productList.length && isLoadingmore)
                      ? shimmer2()
                      : productItem(index, index % 2 == 0 ? true : false);
                },
              ),
            ),
    );
  }

  void filterDialog() {
    if (filterList!.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (builder) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 30.0),
                    child: AppBar(
                      backgroundColor: lightWhite,
                      title: Text(
                        getTranslated(context, FilterText)!,
                        style: const TextStyle(
                          color: fontColor,
                        ),
                      ),
                      elevation: 5,
                      leading: Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.all(10),
                            decoration: shadow(),
                            child: Card(
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () => Navigator.of(context).pop(),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.only(end: 4.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_outlined,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsetsDirectional.only(end: 10.0),
                          alignment: Alignment.center,
                          child: InkWell(
                            child: Text(
                              getTranslated(context, clearFilters)!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: fontColor,
                                  ),
                            ),
                            onTap: () {
                              if (mounted) {
                                setState(
                                  () {
                                    selectedId.clear();
                                    isFilterClear = true;
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: lightWhite,
                      padding: const EdgeInsetsDirectional.only(
                        start: 7.0,
                        end: 7.0,
                        top: 7.0,
                      ),
                      child: Card(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                color: lightWhite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsetsDirectional.only(
                                    top: 10.0,
                                  ),
                                  itemCount: filterList!.length,
                                  itemBuilder: (context, index) {
                                    attsubList = filterList![index]
                                            ['attribute_values']
                                        .split(',');
                                    attListId = filterList![index]
                                            ['attribute_values_id']
                                        .split(',');
                                    if (filter == "") {
                                      filter = filterList![0]["name"];
                                    }
                                    return InkWell(
                                      onTap: () {
                                        if (mounted) {
                                          setState(
                                            () {
                                              filter =
                                                  filterList![index]['name'];
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          start: 20,
                                          top: 10.0,
                                          bottom: 10.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: filter ==
                                                  filterList![index]['name']
                                              ? white
                                              : lightWhite,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            bottomLeft: Radius.circular(7),
                                          ),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          filterList![index]['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: filter ==
                                                        filterList![index]
                                                            ['name']
                                                    ? fontColor
                                                    : lightBlack,
                                                fontWeight: FontWeight.normal,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsetsDirectional.only(top: 10.0),
                                itemCount: filterList!.length,
                                itemBuilder: (context, index) {
                                  if (filter == filterList![index]["name"]) {
                                    attsubList = filterList![index]
                                            ['attribute_values']
                                        .split(',');
                                    attListId = filterList![index]
                                            ['attribute_values_id']
                                        .split(',');
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: attListId!.length,
                                      itemBuilder: (context, i) {
                                        return CheckboxListTile(
                                          dense: true,
                                          title: Text(
                                            attsubList![i],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  color: lightBlack,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                          ),
                                          value: selectedId
                                              .contains(attListId![i]),
                                          activeColor: primary,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          onChanged: (bool? val) {
                                            if (mounted) {
                                              setState(
                                                () {
                                                  if (val == true) {
                                                    selectedId
                                                        .add(attListId![i]);
                                                  } else {
                                                    selectedId
                                                        .remove(attListId![i]);
                                                  }
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: white,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(total.toString()),
                              Text(
                                getTranslated(context, productsFound)!,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SimBtn(
                          size: 0.4,
                          title: getTranslated(context, apply),
                          onBtnSelected: () {
                            if (!isFilterClear) {
                              if (selectedId.isEmpty) {
                                selId = '';
                              } else {
                                selId = selectedId.join(',');
                              }
                              if (mounted) {
                                setState(() {
                                  _isLoading = true;
                                  total = 0;
                                  offset = 0;
                                  isLoadingmore = true;
                                  productList.clear();
                                });
                              }
                              getProduct("0");
                            } else {
                              if (mounted) {
                                setState(
                                  () {
                                    selId = "";
                                    _isLoading = true;
                                    total = 0;
                                    offset = 0;
                                    isLoadingmore = true;
                                    productList.clear();
                                  },
                                );
                              }
                              getProduct("0");
                            }
                            Navigator.pop(context, 'Product Filter');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }
}
