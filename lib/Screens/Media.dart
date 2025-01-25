import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:admin_eshop/Helper/String.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../../Model/MediaModel/MediaModel.dart';
import 'package:http_parser/http_parser.dart';
import 'AddProduct.dart' as add;
import 'EditProduct.dart' as edit;
import 'AddBrand.dart' as addBrand;
import 'EditBrand.dart' as editBrand;
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import 'EmailSend.dart' as email;

class Media extends StatefulWidget {
  final from;
  final pos;
  final type;
  const Media({Key? key, this.from, this.pos, this.type}) : super(key: key);
  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool scrollLoadmore = true;
  bool scrollGettingData = false;
  bool scrollNodata = false;
  int scrollOffset = 0;
  List<MediaModel> mediaList = [];
  List<MediaModel> tempList = [];
  List<MediaModel> selectedList = [];
  ScrollController? scrollController;
  late List<String> variantImgList = [];
  late List<String> variantImgUrlList = [];
  late List<String> variantImgRelativePath = [];
  late List<String> otherImgList = [];
  late List<String> otherImgUrlList = [];
  var selectedImageFromGellery;
  File? videoFromGellery;
  File? documentFromGellery;
  String? uploadedVideoName;
  String? uploadedDocumentName;
  @override
  void initState() {
    super.initState();
    scrollOffset = 0;
    getMedia();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this,);
    scrollController = ScrollController();
    scrollController!.addListener(_transactionscrollListener);
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

  _transactionscrollListener() {
    if (scrollController!.offset >=
            scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            scrollLoadmore = true;
            getMedia();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, MediaText)!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }

  Widget _showContent() {
    return scrollNodata
        ? Column(
            children: [
              uploadImage(),
              Center(
                child: Text(
                  getTranslated(context, noItem)!,
                ),
              ),
            ],
          )
        : NotificationListener<ScrollNotification>(
            child: Column(
              children: [
                uploadImage(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsetsDirectional.only(
                        bottom: 5, start: 10, end: 10,),
                    itemCount: mediaList.length,
                    itemBuilder: (context, index) {
                      MediaModel? item;
                      item = mediaList.isEmpty ? null : mediaList[index];
                      return item == null ? Container() : getMediaItem(index);
                    },
                  ),
                ),
                if (scrollGettingData) const Padding(
                        padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
                        child: CircularProgressIndicator(),
                      ) else Container(),
              ],
            ),
          );
  }

  Future<void> uploadMediaAPI() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        final request = http.MultipartRequest("POST", uploadMediaApi);
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID!;
        if (selectedImageFromGellery != null) {
          http.MultipartFile image;
          final mainImagepPath = lookupMimeType(selectedImageFromGellery.path);
          final extension = mainImagepPath!.split("/");
          image = await http.MultipartFile.fromPath(
            "documents[]",
            selectedImageFromGellery.path,
            contentType: MediaType('image', extension[1]),
          );
          request.files.add(image);
        }
        if (videoFromGellery != null) {
          final mainImagepPath = lookupMimeType(videoFromGellery!.path);
          final extension = mainImagepPath!.split("/");
          final video = await http.MultipartFile.fromPath(
            "documents[]",
            videoFromGellery!.path,
            contentType: MediaType('video', extension[1]),
          );
          request.files.add(video);
        }
        if (uploadedDocumentName != null) {
          final mainImagepPath = lookupMimeType(documentFromGellery!.path);
          final extension = mainImagepPath!.split("/");
          final video = await http.MultipartFile.fromPath(
            "documents[]",
            documentFromGellery!.path,
            contentType: MediaType(
              'application',
              extension[1],
            ),
          );
          request.files.add(video);
        }
        final response = await request.send();
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final getdata = json.decode(responseString);
        final bool error = getdata["error"];
        final String msg = getdata['message'];
        if (!error) {
          setsnackbar(msg, context);
          selectedImageFromGellery = null;
          documentFromGellery = null;
          setState(
            () {
              scrollOffset = 0;
              getMedia();
            },
          );
        } else {
          setsnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setsnackbar(getTranslated(context, somethingMSg)!, context);
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

  Padding uploadImage() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10,
        bottom: 5,
        start: 10,
        end: 10,
      ),
      child: Card(
        child: InkWell(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getTranslated(context, UploadFromGelleryText)!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              InkWell(
                onTap: () {
                  if (widget.from == "file") {
                    digitalProductGallery();
                  }
                  if (widget.from == "video") {
                    videoFromGallery();
                  } else {
                    imageFromGallery();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: 120,
                  height: 40,
                  child: Center(
                    child: Text(
                      getTranslated(context, SelectFileText)!,
                      style: const TextStyle(
                        color: white,
                      ),
                    ),
                  ),
                ),
              ),
              if (documentFromGellery == null) Container() else Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.file_open,
                              color: primary,
                            ),
                          ),
                          Expanded(
                            child: Text(documentFromGellery!.path),
                          ),
                        ],
                      ),
                    ),
              if (selectedImageFromGellery == null) Container() else const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              if (uploadedVideoName == null) Container() else const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              if (selectedImageFromGellery == null) Container() else Image.file(
                selectedImageFromGellery!,
                height: 200,
                width: 200,
              ),
              if (uploadedVideoName == null) Container() else Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(uploadedVideoName!),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              if (selectedImageFromGellery == null) Container() else const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              if (uploadedVideoName == null) Container() else const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              if (selectedImageFromGellery == null) Container() else InkWell(
                      onTap: () {
                        uploadMediaAPI();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 120,
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
                    ),
              if (uploadedVideoName == null) Container() else InkWell(
                      onTap: () {
                        uploadMediaAPI();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 120,
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
                    ),
              if (documentFromGellery == null) Container() else InkWell(
                      onTap: () {
                        uploadMediaAPI();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 120,
                        height: 40,
                        child: Center(
                          child: Text(
                            getTranslated(context, "Upload")!,
                            style: const TextStyle(
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  digitalProductGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'doc',
        'docx',
        'txt',
        'pdf',
        'ppt',
        'pptx',
      ],
    );
    if (result != null) {
      final File document = File(result.files.single.path!);
      setState(
        () {
          documentFromGellery = document;
          result.names[0] == null
              ? setsnackbar(
                  "Error in video uploading please try again...!",
                  context,
                )
              : () {
                  uploadedDocumentName = result.names[0];
                }();
        },
      );
      if (mounted) setState(() {});
    } else {}
  }

  videoFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4',
        '3gp',
        'avchd',
        'avi',
        'flv',
        'mkv',
        'mov',
        'webm',
        'wmv',
        'mpg',
        'mpeg',
        'ogg',
      ],
    );
    if (result != null) {
      final File video = File(result.files.single.path!);
      setState(
        () {
          videoFromGellery = video;
          result.names[0] == null
              ? setsnackbar(getTranslated(context, videoUploadError)!, context)
              : () {
                  uploadedVideoName = result.names[0];
                }();
        },
      );
      if (mounted) {
        setState(
          () {},
        );
      }
    } else {}
  }

  imageFromGallery() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'],
    );
    if (result != null) {
      final File image = File(result.files.single.path!);
      setState(
        () {
          selectedImageFromGellery = image;
        },
      );
    } else {}
  }

  AppBar getAppBar(String title, BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: white,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: shadow(),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  color: primary,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: primary,
        ),
      ),
      actions: [
        if (widget.from == "other" || widget.from == 'variant') TextButton(
                onPressed: () {
                  if (widget.from == "other") {
                    if (widget.type == "add") {
                      add.otherPhotos.addAll(otherImgList);
                      add.otherImageUrl.addAll(otherImgUrlList);
                    }
                    if (widget.type == "edit") {
                      edit.otherPhotos.addAll(otherImgList);
                      if (edit.showOtherImages.isNotEmpty) {
                        if (otherImgList.isNotEmpty) {
                          for (int i = 0; i < otherImgList.length; i++) {
                            edit.showOtherImages.removeLast();
                          }
                        }
                      }
                      edit.showOtherImages.addAll(otherImgUrlList);
                    }
                  } else if (widget.from == 'variant') {
                    if (widget.type == "add") {
                      add.variationList[widget.pos].images = variantImgList;
                      add.variationList[widget.pos].imagesUrl =
                          variantImgUrlList;
                      add.variationList[widget.pos].imageRelativePath =
                          variantImgRelativePath;
                    }
                    if (widget.type == "edit") {
                      edit.variationList[widget.pos].images = variantImgList;
                      edit.variationList[widget.pos].imagesUrl =
                          variantImgUrlList;
                      edit.variationList[widget.pos].imageRelativePath =
                          variantImgRelativePath;
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  getTranslated(context, doneText)!,
                ),
              ) else Container(),
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
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  super.widget,),).then(
                        (value) {
                          setState(
                            () {},
                          );
                        },
                      );
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

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> getMedia() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (scrollLoadmore) {
        if (mounted) {
          setState(
            () {
              scrollLoadmore = false;
              scrollGettingData = true;
              if (scrollOffset == 0) {
                mediaList = [];
              }
            },
          );
        }
        try {
          final parameter = {
            LIMIT: perPage.toString(),
            OFFSET: scrollOffset.toString(),
          };
          if (widget.from == "video") {
            parameter["type"] = "video";
          }
          if (widget.from == "file") {
            parameter["type"] = "archive,document";
          }
          final http.Response response = await http
              .post(getMediaApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));
          final getdata = json.decode(response.body);
          final bool error = getdata["error"];
          final String? msg = getdata["message"];
          scrollGettingData = false;
          if (scrollOffset == 0) scrollNodata = error;
          if (!error) {
            tempList.clear();
            final data = getdata["data"];
            if (data.length != 0) {
              tempList = (data as List)
                  .map((data) => MediaModel.fromJson(data))
                  .toList();
              mediaList.addAll(tempList);
              scrollLoadmore = true;
              scrollOffset = scrollOffset + perPage;
            } else {
              scrollLoadmore = false;
            }
          } else {
            scrollLoadmore = false;
            setsnackbar(msg!, context);
          }
          if (mounted) {
            setState(() {
              scrollLoadmore = false;
            });
          }
        } on TimeoutException catch (_) {
          setsnackbar(getTranslated(context, somethingMSg)!, context);
          setState(
            () {
              scrollLoadmore = false;
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            scrollLoadmore = false;
          },
        );
      }
    }
  }

  Card getMediaItem(int index) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(
            () {
              mediaList[index].isSelected = !mediaList[index].isSelected;
              if (widget.from == "main") {
                if (widget.type == "add") {
                  add.productImage =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                  add.productImageUrl = mediaList[index].image!;
                }
                if (widget.type == "edit") {
                  edit.productImage =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                  edit.productImageUrl = mediaList[index].image!;
                  edit.productImageRelativePath = mediaList[index].path!;
                }
                if (widget.type == "addBrand") {
                  addBrand.brandImage =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                  addBrand.brandImageUrl = mediaList[index].image!;
                }
                if (widget.type == "editBrand") {
                  editBrand.brandImage =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                  editBrand.brandImageUrl = mediaList[index].image!;
                  editBrand.brandImageRelativePath = mediaList[index].path!;
                }
                Navigator.pop(context);
              } else if (widget.from == "video") {
                if (widget.type == "add") {
                  add.uploadedVideoName =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                }
                if (widget.type == "edit") {
                  edit.uploadedVideoName =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                }
                Navigator.pop(context);
              } else if (widget.from == "other") {
                if (mediaList[index].isSelected) {
                  otherImgList.add(mediaList[index].path!);
                  otherImgUrlList.add(mediaList[index].image!);
                } else {
                  otherImgList.add(mediaList[index].path!);
                  otherImgUrlList.remove(mediaList[index].image);
                }
              } else if (widget.from == 'variant') {
                if (mediaList[index].isSelected) {
                  variantImgList.add(
                      "${mediaList[index].subDic!}${mediaList[index].name!}",);
                  variantImgUrlList.add(mediaList[index].image!);
                  variantImgRelativePath.add(mediaList[index].path!);
                } else {
                  variantImgList.remove(
                      "${mediaList[index].subDic!}${mediaList[index].name!}",);
                  variantImgUrlList.remove(mediaList[index].image);
                  variantImgRelativePath.remove(mediaList[index].path);
                }
              } else if (widget.from == "file") {
                if (widget.type == "add") {
                  add.uploadFileName =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                }
                if (widget.type == "edit") {
                  edit.uploadFileName =
                      "${mediaList[index].subDic!}${mediaList[index].name!}";
                }
                if (widget.type == 'email') {
                  email.selectedUploadFileSubDic =
                      mediaList[index].subDic! + mediaList[index].name!;
                }
                Navigator.pop(context);
              }
            },
          );
        },
        child: Stack(
          children: [
            Row(
              children: [
                Image.network(
                  mediaList[index].image!,
                  height: 200,
                  width: 200,
                  errorBuilder: (context, error, stackTrace) => erroWidget(
                    200,
                  ),
                  color: fontColor
                      .withOpacity(mediaList[index].isSelected ? 1 : 0),
                  colorBlendMode: BlendMode.color,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${getTranslated(context, NAME_LBL)!} : ${mediaList[index].name!}',
                        ),
                        Text(
                          '${getTranslated(context, SubDirectory)!} : ${mediaList[index].subDic!}',
                        ),
                        Text(
                          '${getTranslated(context, sizeText)!} : ${mediaList[index].size!}',
                        ),
                        Text(
                          '${getTranslated(context, extension)!} : ${mediaList[index].extention!}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color:
                  fontColor.withOpacity(mediaList[index].isSelected ? 0.1 : 0),
            ),
            if (mediaList[index].isSelected) const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.check_circle,
                        color: primary,
                      ),
                    ),
                  ) else Container(),
          ],
        ),
      ),
    );
  }
}
