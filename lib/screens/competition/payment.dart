import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:homeraces/shared/loading.dart';
import 'dart:convert';
import 'package:tripledes/tripledes.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String cardNumber, expiryDate, cardHolderName, cvvCode, order, merchant;
  bool isCvvFocused;
  Competition competition;
  var response;
  Map<String,String> headers;
  WebViewController _controller;

  Future _loadWeb() async{
    response = await http.post("https://sis-t.redsys.es:25443/sis/realizarPago", headers: headers);
  }

  void _timer() {
    if(response == null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          print("Loading...");
        });
        _timer();
      });
    }
  }

  _loadHtml() async {
    _controller.loadUrl( Uri.dataFromString(
        response.body,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  @override
  void initState() {
    cardHolderName = "";
    cardNumber = "";
    expiryDate = "";
    cvvCode = "";
    isCvvFocused = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    competition = ModalRoute.of(context).settings.arguments;
    order = "1446068581";  // Calcular
    merchant = "b221d9dbb083a7f33428d7c2a3c3198ae925614d70210e28716ccaa7cd4ddb79"; //BAnco
    Map Ds_MerchantParameters = {
      "DS_MERCHANT_AMOUNT": competition.price.toString(),
      "DS_MERCHANT_CURRENCY": "978", //€
      "DS_MERCHANT_MERCHANTCODE": "999008881", //Banco
      "DS_MERCHANT_ORDER": order,
      "DS_MERCHANT_TERMINAL": "1", //Banco
      "DS_MERCHANT_TRANSACTIONTYPE": "0", //Banco
    };
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String Ds_MerchantParameters_coded = stringToBase64.encode(Ds_MerchantParameters.toString());
    String Ds_SignatureVersion = "HMAC_SHA256_V1";
    String merchantKey = stringToBase64.encode(merchant);
    var blockCipher = new BlockCipher(new DESEngine(), order);
    var tripledes = blockCipher.encode(merchantKey);
    var hmacSha256 = new Hmac(sha256, utf8.encode(tripledes));
    var digest = hmacSha256.convert(utf8.encode(Ds_MerchantParameters_coded));
    var Ds_Signature = stringToBase64.encode(digest.toString());
    headers = {
      "Ds_SignatureVersion": Ds_SignatureVersion,
      "Ds_MerchantParameters": Ds_MerchantParameters_coded,
      "Ds_Signature": Ds_Signature
    };
    if(response == null) {
      _loadWeb();
      _timer();
    }
    ScreenUtil.init(context, height: CommonData.screenHeight, width: CommonData.screenWidth, allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
              onPressed: () => Navigator.pop(context),
            ),
        ),
      body: response == null? Center(child: CircularLoading(),):
      WebView(
        initialUrl: 'about:blank',
        javascriptMode: JavascriptMode.unrestricted,
        gestureNavigationEnabled: true,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _loadHtml();
        },
      ),
    );
    /*return WebviewScaffold(
        url: "https://sis-t.redsys.es:25443/sis/realizarPago",

        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
            onPressed: () => Navigator.pop(context),
          ),
        ),
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 30.h,),
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            height: 175.h,
            textStyle: TextStyle(color: Colors.yellowAccent),
            width: MediaQuery.of(context).size.width,
            animationDuration: Duration(milliseconds: 1000),
            cardBgColor: Colors.black,
          ),
          SizedBox(height: 30.h,),
          CreditCardForm(
            themeColor: Colors.red,
            onCreditCardModelChange: (CreditCardModel creditCardModel) {
              setState(() {
                cardNumber = creditCardModel.cardNumber;
                expiryDate = creditCardModel.expiryDate;
                cardHolderName = creditCardModel.cardHolderName;
                cvvCode = creditCardModel.cvvCode;
                isCvvFocused = creditCardModel.isCvvFocused;
              });
            },
          ),
        ],
      ),
    );*/
  }
}
