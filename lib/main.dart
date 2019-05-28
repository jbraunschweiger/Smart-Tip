import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePage();
  }
}

class HomePage extends State<MyApp> {
  double subtotal = 0.0;
  double restaurantPrice = 0.0;
  static String countryCode = "US";
  static String _locale = "en-US";
  static List<String> countryData;
  static String currencySymbol = "\$";
  MoneyMaskedTextController moneyFormatter;
  NumberFormat textMoneyFormatter;
  var satisfactionFlex = [3, 4, 3, 3];
  static int happiness = 2;

  Geolocator geolocator = Geolocator();
  Position position;

  Future<Position> getPosition() async {
    try {
      return await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    Helper.loadCountries();
    Helper.loadLocales();
    getPosition().then((p) {
      position = p;
      getCountryCode().then((cc) {
        countryCode = cc;
        countryData = Helper.getCountryData(countryCode);
        _locale = Helper.getLocale(countryCode);
        textMoneyFormatter = NumberFormat.simpleCurrency(locale: _locale);
        currencySymbol = textMoneyFormatter.currencySymbol;
        moneyFormatter = MoneyMaskedTextController(
            decimalSeparator: '.',
            thousandSeparator: ',',
            leftSymbol: currencySymbol);
        moneyFormatter.addListener(() {
          this.setState(() {
            subtotal = moneyFormatter.numberValue;
          });
        });
        this.setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Colors.white;
    Color accent = Colors.blue;
    double defaultFontSize = 28;
    return MaterialApp(
        title: 'Flutter',
        home: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 210, 220, 230)),
              child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: moneyFormatter,
                        cursorWidth: 0,

                        style: TextStyle(fontSize: defaultFontSize),
                        decoration: InputDecoration(
                          labelText: "Enter Subtotal",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                            ),
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                                flex: satisfactionFlex[0],
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        satisfactionFlex = [4, 3, 3, 3];
                                        happiness = -2;
                                        vibrate();
                                      });
                                    },
                                    child:
                                        Image.asset("graphics/unhappy.png"))),
                            Flexible(flex: 1, child: Container()),
                            Flexible(
                                flex: satisfactionFlex[1],
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        satisfactionFlex = [3, 4, 3, 3];
                                        happiness = -1;
                                        vibrate();
                                      });
                                    },
                                    child:
                                        Image.asset("graphics/confused.png"))),
                            Flexible(flex: 1, child: Container()),
                            Flexible(
                                flex: satisfactionFlex[2],
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        satisfactionFlex = [3, 3, 4, 3];
                                        happiness = 1;
                                        vibrate();
                                      });
                                    },
                                    child:
                                        Image.asset("graphics/smiling.png"))),
                            Flexible(flex: 1, child: Container()),
                            Flexible(
                                flex: satisfactionFlex[3],
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        satisfactionFlex = [3, 3, 3, 4];
                                        happiness = 2;
                                        vibrate();
                                      });
                                    },
                                    child: Image.asset("graphics/in-love.png")))
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tip', style: TextStyle(color: accent, fontSize: defaultFontSize)),
                                  Text(getTip(), style: TextStyle(color: primary, fontSize: defaultFontSize)),
                                ]),
                            Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total', style: TextStyle(color: accent, fontSize: defaultFontSize)),
                                  Text(getTotal(), style: TextStyle(color: primary, fontSize: defaultFontSize)),
                                ]),
                          ])
                    ],
                  ),
                ),
              )),
        ),
        theme: ThemeData(
            // Define the default Brightness and Colors
            brightness: Brightness.dark,
            primaryColor: Colors.white,
            accentColor: Colors.blue,

            // Define the default Font Family
            fontFamily: 'Montserrat'));
  }

  void vibrate() {
    HapticFeedback.vibrate();
    HapticFeedback.heavyImpact();
  }

  void addToDatabase() async {
    await Firestore.instance
    .collection("Tips")
    .add({
      "Country Code": "XX",
      "Location": 4,
      "Subtotal": 5,
      "Time": 5,
      "Tip Amount": 5,
    });
  }

  double getTipNumber() {
    if (countryData != null) {
      double tipPercent = Helper.getTip(happiness, countryData) / 100;
      return subtotal * tipPercent;
    }
    return subtotal * .15;
  }

  String getTip() {
    if (textMoneyFormatter != null) {
      return textMoneyFormatter.format(getTipNumber());
    }
    return getTipNumber().toString();
  }

  double getTotalNumber() {
    return getTipNumber() + subtotal;
  }

  String getTotal() {
    if (textMoneyFormatter != null) {
      return textMoneyFormatter.format(getTotalNumber());
    }
    return getTotalNumber().toString();
  }

  Future<String> getCountryCode() async {
    if (position == null) {
      return "US";
    }
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    return placemark[0].isoCountryCode;
  }
}
