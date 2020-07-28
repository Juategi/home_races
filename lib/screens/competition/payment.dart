import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homeraces/model/comment.dart';
import 'package:homeraces/model/competition.dart';
import 'package:homeraces/model/user.dart';
import 'package:homeraces/screens/competition/comments/comment_box.dart';
import 'package:homeraces/services/dbservice.dart';
import 'package:homeraces/shared/alert.dart';
import 'package:homeraces/shared/common_data.dart';
import 'package:homeraces/shared/functions.dart';
import 'package:homeraces/shared/loading.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String cardNumber, expiryDate, cardHolderName, cvvCode;
  bool isCvvFocused;
  Competition competition;

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
    );
  }
}
