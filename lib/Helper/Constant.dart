import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const String appName = 'Admin App Zaitoon Pharmacy';
const String baseUrl = 'https://zaitoonpharmacy.com/admin/app/v1/api/';

const bool isDemoApp = true;
const int timeOut = 50;
const int perPage = 10;
String? countryCode = 'AE';
const String SIGNIN_LBL = "Sign in";
const String MOBILEHINT_LBL = 'Mobile number';
const String PASSHINT_LBL = 'Password';
const String SELECT_DATE_HINT_LBL = 'Select Date';
const String SELECT_TIME_HINT_LBL = 'Select Time';
const String FORGOT_PASSWORD_LBL = 'Forgot Password?';
const String CONTINUE_AGREE_LBL = "By continuing, you agree to our";
const String TERMS_SERVICE_LBL = "Terms of Service";
const String AND_LBL = "and";
const String PRIVACY_POLICY_LBL = "Privacy Policy";
const String TERM = 'Term & Conditions';
const String GET_PASSWORD = 'Get Password';
const String FORGOT_PASSWORDTITILE = 'Forgot Password';
const String RATE_US = 'Rate Us';
const String SHARE_APP = 'Share';
const String FAQS = 'Faqs';
const String ABOUT_LBL = 'About Us';
const String LOGOUT = 'Logout';
const String HOME_LBL = 'Home';
const String FAVORITE = 'Favorite';
const String NOTIFICATION = 'Notifications';
const String EDIT_PROFILE_LBL = "Edit Profile";
const String NAME_LBL = 'Name';
const String SAVE_LBL = "Save";
const String COLLECT_LBL = "Collect";
const String SEND_LBL = "Send";
const String CANCEL = "Cancel";
const String CHANGE_PASS_LBL = "Change Password";
const String CUR_PASS_LBL = "Current Password";
const String NEW_PASS_LBL = "New Password";
const String CON_PASS_REQUIRED_MSG = "Confirm Password is Required";
const String CON_PASS_NOT_MATCH_MSG = "Confirm Password not match";
const String CONFIRMPASSHINT_LBL = 'Confirm Password';
const String ADD_NAME_LBL = "Add Name";
const String LOGOUTTXT = 'Are you sure you want to logout?';
const String OTP_LBL = 'OTP Confirm';
const String LOGOUTYES = 'Yes';
const String LOGOUTNO = 'No';
const String WALLET = 'Wallet History';
const String ID_LBL = 'ID';
const String AMT_LBL = 'Amount';
const String OPNBL_LBL = 'Opening Balance';
const String CLBL_LBL = 'Closing Balance';
const String MSG_LBL = 'Message';
const String SEND_OTP_TITLE = "send otp";
const String FORGOT_PASS_TITLE = "forgot pass";
const String VERIFY_AND_PROCEED = 'Verify and proceed';
const String DIDNT_GET_THE_CODE = "Didn't get the code? ";
const String RESEND_OTP = 'Resend OTP';
const String SEND_OTP = 'Send OTP';
const String SET_PASSWORD = 'Set Password';
const String ORDER_DETAIL = 'Order Details';
const String ORDER_ID_LBL = 'Order ID';
const String ORDER_PROCESSED = 'Order Proccessed';
const String ORDER_SHIPPED = 'Order Shipped';
const String ORDER_DELIVERED = 'Order Delivered';
const String CANCEL_ORDER = 'Cancel Order';
const String RETURN_ORDER = 'Return Order';
const String PRICE_DETAIL = 'Price Detail';
const String PRICE_LBL = 'Price';
const String DELIVERY_CHARGE = 'Delivery Charge';
const String TAXPER = 'Tax';
const String PROMO_CODE_DIS_LBL = 'Promo Code Discount';
const String WALLET_BAL = 'Wallet Balance';
const String TOTAL_PRICE = 'Total Price';
const String SHIPPING_DETAIL = 'Shipping Details';
const String TRACKING_DETAIL = 'Tracking Details';
const String QUANTITY_LBL = 'Qty';
const String ORDER_DATE = 'Order Date';
const String PAYMENT_MTHD = 'Payment Method';
const String ORDER = 'Orders';
const String PRO_LBL = 'Products';
const String ORDER_TRACKING = 'Tracking';
const String CUST_LBL = 'Customer';
const String LOW_LBL = 'Low in stock';
const String SOLD_LBL = 'Sold out';
const String Del_LBL = 'Delivery Boy';
const String TICKET_LBL = 'Ticket';
const String RETURN_REQ_LBL = 'Return Requests';
const String CASH_COLLECTION = 'Cash Collection';
const String UPDATE_RETURN_REQ_LBL = 'Update Return Requests';
const String COLLECT_AMOUNT_LBL = 'Collect Amount';
const String AMOUNT_TO_BE_COLLECTED_HINT_LBL = 'Amount to be collected';
const String RECEIVED_LBL = 'Received';
const String PROCESSED_LBL = 'Processed';
const String SHIPED_LBL = 'Shipped';
const String DELIVERED_LBL = 'Delivered';
const String AWAITING_LBL = 'Awaiting';
const String CANCELLED_LBL = 'Cancelled';
const String RETURNED_LBL = 'Returned';
const String READY_TO_PICK_UP_LBL = 'Ready To PickUp';
const String CURBAL_LBL = 'Current Balance';
const String WITHDRAW_MONEY = 'Withdraw Balance';
const String SEND_REQUEST = 'Send Withrawal Request';
const String OTP_ENTER = 'Enter OTP';
const String WITHDRWAL_AMT = 'Withdrwal Amount';
const String BANK_DETAIL =
    'Bank Details:\nAccount No :123XXXXX\nIFSC Code: 123XXX \nName: Abc xyz';
const String FIELD_REQUIRED = 'This Field is Required';
const String SEND_VERIFY_CODE_LBL =
    "We will send a Verification Code to This Number";
const String SENT_VERIFY_CODE_TO_NO_LBL = "We have sent a verification code to";
const String COUNTRY_CODE_LBL = "Select country code";
const String PASS_SUCCESS_MSG = "Password Update Successfully! Please Login";
const String MOBILE_NUMBER_VARIFICATION = 'Enter Verification Code';
const String OTPWR = 'Request new OTP after 60 seconds';
const String OTPMSG = 'OTP verified successfully';
const String OTPERROR = 'Error validating OTP, try again';
const String ENTEROTP = 'Please Enter OTP!';
const String CREATE_ACC_LBL = "Create an account";
const String FILTER_BY = "Filter By";
const String SHOW_TRANS = 'Show Wallet Transactions';
const String SHOW_REQ = 'Show Wallet Requests';
const String PENDING = 'Pending';
const String ACCEPTED = 'Accepted';
const String REJECTED = 'Rejected';
const String PAYABLE = "Total Payable";
const String UPDATE_ORDER = 'Update Order';
const String PREFER_DATE_TIME = 'Preferred Delivery Date/Time';
const String PWD_REQUIRED = 'Password is Required';
const String PWD_LENGTH = 'password should be more then 6 char long';
const String USER_REQUIRED = 'Username is Required';
const String USER_LENGTH = 'Username should be 2 character long';
const String MOB_REQUIRED = 'Mobile number required';
const String VALID_MOB = 'Please enter valid mobile number';
const String NO_INTERNET = "No Internet";
const String NO_INTERNET_DISC =
    "Please check your connection again, or connect to Wi-Fi";
const String noItem = 'No Item Found..!!';
const String TRY_AGAIN_INT_LBL = "Try Again";
const String somethingMSg =
    'Something went wrong. Please try again after some time';
const String noNoti = 'No Notification Found..!!';
const String search = "Search";
const String OutofStock = "Out Of Stock";
const String NoitemsFound = "No Items Found";
const String OrderNo = "Order No.";
const String Quantity = "Quantity";
const String DiscountPrice = "Discount Price";
const String Subtotal = "Subtotal";
const String Remarks = "Remarks";
const String StockType = "Stock Type";
const String StockCount = "Stock Count";
const String SelectVarient = "Select Varient";
const String readProductText =
    "You have not authorized permission for read Product!!";
const String FilterText = "Filter";
const String Sort = "Sort";
const String pleaseSelect = "Please Select";
const String variantdoestexist = "This varient doesn't available.";
const String StockFilter = "Stock Filter";
const String All = "All";
const String soartBy = "Sort By";
const String topRated = "Top Rated";
const String newestFirst = "Newest First";
const String oldestFirst = "Oldest First";
const String pricelowtoHigh = "Price - Low to High";
const String pricehightolow = "Price - High to Low";
const String clearFilters = "Clear Filters";
const String productsFound = "Products found";
const String apply = "Apply";
const String payableText = "Payable";
const String addTracking = "Add Tracking";
const String orderonText = "Order on";
const String authorizePermission =
    "You have not authorized permission for read order!!";
const String startDateText = "Start Date";
const String endDateText = "End Date";
const String courierAgencyText = "Courier Agency";
const String trackingIDText = "Tracking ID";
const String URLText = "URL";
const String couldnotlaunch = "Could not launch";
const String hello = "Hello";
const String yourOrderWithId = "Your order with id";
const String isText = "is";
const String thankyouText =
    "If you have further query feel free to contact us.Thank you.";
const String noteText = "NOTE";
const String updateStatus = "Update Status";
const String selectDeliveryBoy = "Select Delivery Boy";
const String authoritypermissionText =
    "You have not authorized permission for update order!!";
const String attachmentText = "Attachment";
const String checkFolderText = "Check Your Download Folder";
const String ViewLbl = "VIEW";
const String MediaText = "Media";
const String UploadFromGelleryText = "Upload media from Gellery";
const String SelectFileText = "Select File";
const String UploadText = "Upload";
const String videoUploadError = "Error in video uploading please try again...!";
const String doneText = "Done";
const String SubDirectory = "Sub Directory";
const String sizeText = "Size";
const String extension = "extension";
const String DayText = "Day";
const String productSalesText = "Product Sales";
const String Week = "Week";
const String Month = "Month";
const String categoryProductCountText = "Category wise product's count";
const String AddProductText = "Add Product";
const String ProductNameText = "Product Name";
const String AddnewProductText = "Add new product name! ...";
const String shortDescriptionText = "Short Description";
const String addSortDescText = "Add Sort Detail of Product ...!";
const String TagsHelpText = "(These tags help you in search result)";
const String TagsHelpText2 =
    "Type in some tags for example AC, Cooler, Flagship Smartphones, Mobiles, Sport etc..";
const String SelectTax = "Select Tax";
const String None = "None";
const String Veg = "Veg";
const String nonVeg = "Non-Veg";
const String SelectIndicator = "Select Indicator";
const String Tags = "Tags";
const String SelectAttribute = "Select Attribute";
const String alredyInserted = "Already inserted..";
const String TotalAllowedQuantityText = "Total Allowed Quantity";
const String MinimumOrderQuantityText = "Minimum Order Quantity";
const String QuantityStepSizeText = "Quantity Step Size";
const String MadeInText = "Made In";
const String WarrantyPeriodText = "Warranty Period";
const String GuaranteePeriodText = "Guarantee Period";
const String DeliverableTypeText = "Deliverable Type";
const String IncludeText = "Include";
const String ExcludeText = "Exclude";
const String SelectDeliverableTypeText = "Select Deliverable Type";
const String SelectZipCodeText = "Select ZipCode";
const String selectCity = "Select City";
const String selectedcategoryText = "selected category";
const String OkText = "Ok";
const String NotSelectedText = "Not Selected Yet ...";
const String nosubcatText = "no sub cat";
const String IsReturnableText = "Is Returnable ?";
const String IsCODallowedText = "Is COD allowed ?";
const String TaxincludedinpricesText = "Tax included in prices ?";
const String IsCancelableText = "Is Cancelable ?";
const String TillwhichstatusText = "Till which status ?";
const String MainImageText = "Main Image";
const String OtherImagesText = "Other Images";
const String Video = "Video";
const String Vimeo = "Vimeo";
const String Youtube = "Youtube";
const String SelectVideoTypeText = "Select Video Type";
const String SelfHostedText = "Self Hosted";
const String PasteVimeoText = "Paste Vimeo Video link / url ...!";
const String PasteYoutubeText = "Paste Youtube Video link / url...!";
const String GeneralInformationText = "General Information";
const String AttributesText = "Attributes";
const String VariationsText = "Variations";
const String TypeOfProduct = "Type Of Product";
const String EnableStockManagementText = "Enable Stock Management";
const String SaveSettingsText = "Save Settings";
const String PleaseenterproductpriceText = "Please enter product price";
const String PleaseenterproductspecialpriceText =
    "Please enter product special price";
const String SettingsavedsuccessfullyText = "Setting saved successfully";
const String SpecialpricemustbelessText =
    "Special price must be less than original price";
const String StockStatusText = "Stock Status";
const String PleaseenteralldetailsText = "Please enter all details";
const String filltheboxthenaddanotherText = "fill the box then add another";
const String AddAttributeText = "Add Attribute";
const String AttributessavedsuccessfullyText = "Attributes saved successfully";
const String SaveAttributeText = "Save Attribute";
const String selectcheckboxText =
    "Note : select checkbox if the attribute is to be used for variation";
const String SpecialPriceText = "Special Price";
const String SelectStockStatusText = "Select Stock Status";
const String InStockText = "In Stock";
const String AddattributevalueText = "Add attribute value";
const String SelectTypeText = "Select Type";
const String TotalStockText = "Total Stock";
const String SKUText = "SKU";
const String SimpleProductText = "Simple Product";
const String VariableProductText = "Variable Product";
const String YoucantChangeText = "You can't Change Product Type";
const String ChooseStockManagementTypeType = "Choose Stock Management Type";
const String ProductLevelStockText =
    "Product Level (Stock Will Be Managed Generally)";
const String VariantLevelStockText =
    "Variable Level (Stock Will Be Managed Variant Wise)";
const String SelectStockTypeText = "Select Stock Type";
const String DescriptionText = "Description";
const String AddDescriptionText = "Add Description";
const String EditText = "Edit";
const String ResetAllText = "Reset All";
const String UpdateProductText = "Update Product";
const String PleaseselectproducttypeText = "Please select product type";
const String PleaseaddproductimageText = "Please Add product image";
const String PleaseselectcategoryText = "Please select category";
const String PleaseentervideourlText = "Please enter video url";
const String SpecialpriceText = "Special price can not greater than price";
const String PleaseenterstockdetailsText = "Please enter stock details";
const String PleaseenterpricedetailsText = "Please enter price details";
const String EditProductText = "Edit Product";
const String CollectedCashText = "Collected Cash";
const String ResetText = "Reset";
const String ActiveText = "Active";
const String DeactiveText = "Deactive";
const String permissiontext = "You have not authorized permission for read.!!";
const String CustomerSupportText = "Customer Support";
const String PleaseSelectTypeorstatusText = "Please Select Type or status";
const String EmailText = "Email";
const String SubjectText = "Subject";
const String TypeText = "Type";
const String DateText = "Date";
const String CHATText = "CHAT";
const String WritemessageText = "Write message...";
const String DownloadingText = "Downloading...";
const String AddNewProduct = "Add New Product";
const String ProductNameRequired = "Product Name Required";
const String PleaseEnterValidProductName = "Please Enter Valid Product Name";
const String SortDescriptionisrequired = "Sort Description is required";
const String minimamcharacterText = "minimam 5 character is required";
const String FieldRequiredText = "This Field is Required!";
const String ProductDescriptionText = "Product Description";
const String ClearText = "Clear";
const String EnterProductDescriptionText =
    "Please Enter Product Description here...!";
const String PleaseaddattributesText = "Please add attributes";
const String SearchAttributeText = "Search Attribute";
const String ChangeLanguageText = "Change Language";
const String ChooseLanguageText = "Choose Language";
const String IdentificationofProductText = "Identification of Product";
const String ProductIdentificationNumberText = "Product Identification Number";
const String BRAND_NAME_REQ_LBL = "Brand Name Required";
const String BRAND_VALID_LBL = "Please Enter Valid Brand Name";
const String ADD_NEW_BRAND_LBL = "Add New Brand";
const String BRAND_NAME_LBL = "Brand Name";
const String ADD_NEW_BRAND_NAME_LBL = "Add new brand name...";
const String ADD_BRAND_LBL = "Add Brand";
const String BRAND_IMAGE_LBL = "Brand Image";
const String SEL_BRAND_LBL = "Select Brand";
const String BRAND_LBL = "Brand";
const String BRANDS_LBL = "Brands";
const String PLZ_ADD_BRAND_NAME_LBL = "Please add brand name";
const String PLZ_ADD_BRAND_IMAGE_LBL = "Please add your brand image";
const String UPDATE_BRAND_LBL = "Update Brand";
const String English = "English";
const String Hindi = "Hindi";
const String Chinese = "Chinese";
const String Spanish = "Spanish";
const String Arabic = "Arabic";
const String Russian = "Russian";
const String Japanese = "Japanese";
const String Deutch = "Deutch";
const String SURE_LBL = "Are you sure you want to delete";
const String PhysicalProductText = "Physical Product";
const String DigitalProductText = "Digital Product";
const String ProductTypeLbl = "Product Type";
const String IsDownloadAllowedText = "Is Download Allowed";
const String DownloadLinkTypeText = "Download Link Type";
const String AddLinkText = "Add Link";
const String DigitalProLinkText = "Digital Product Link";
const String DigitalProLinkHintText = "Paste Digital Product Link or Url";
const String SelDownloadLinkTypeText = "Please select download link type";
const String AddDigitalProductFileText = "Please add digital product file";
const String AddDigitalProductlinkText = "Please add digital product link";
const String AddValidDigitalProductlinkText =
    "Please add valid digital product link";
const String SendMailText = "Send Mail";
const String StockManagementText = "Stock Management";
const String SimpleText = "Simple";
const String DigitalText = "Digital";
const String DigitalOrderMailDetailsText = "Digital Order Mail Details";
const String OrderItemIdText = "Order Item Id";
const String FileUrlText = "File Url";
const String AttachMentForDownloadProText = "Attachment for Download Product";
const String EnterEmailIdText = "Enter Email Id";
const String EditMessageIdText = "Edit Message";
const String CurrentStockText = "Current Stock";
const String AddText = "Add";
const String SubtractText = "Subtract";
const String NoteSelectTypeText = "Note : Please Select Type...!";
const String SubmitText = "Submit";
const String QtySubtractWarningText =
    "Quantity can’t be subtracted, please check current stock !!!";
const String AttachMentForDownloadText =
    "Hello Dear, You have purchase our digital product and we are happy to share the product with you, you can get product with this mail attachment. Thank You ...!";
bool cityWiseDelivery = false;
bool isFirebaseAuth = true;
printServerError(
  String url, {
  required int statusCode,
  required Map parameter,
  required String response,
}) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/log($statusCode).html')
    ..writeAsStringSync('''
          $url,<br><br>
          $parameter,<br></br>
          Response:<br></br>
          $response
          ''');
  if (statusCode == 500) {
    await OpenFilex.open(file.path);
  }
}

Future<bool> hasStoragePermissionGiven() async {
  if (Platform.isIOS) {
    bool permissionGiven = await Permission.storage.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.storage.request()).isGranted;
      return permissionGiven;
    }
    return permissionGiven;
  }
  final deviceInfoPlugin = DeviceInfoPlugin();
  final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
  if (androidDeviceInfo.version.sdkInt < 33) {
    bool permissionGiven = await Permission.storage.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.storage.request()).isGranted;
      return permissionGiven;
    }
    return permissionGiven;
  } else {
    bool permissionGiven = await Permission.photos.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.photos.request()).isGranted;
      return permissionGiven;
    }
    return permissionGiven;
  }
}
