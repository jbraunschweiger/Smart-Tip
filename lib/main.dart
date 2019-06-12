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
  double alternative = 0.0;
  double restaurantPrice = 0.0;
  static String countryCode = "US";
  static String _locale = "en-US";
  static List<String> countryData;
  static String currencySymbol = "\$";
  MoneyMaskedTextController moneyFormatter;
  NumberFormat textMoneyFormatter;

  MoneyMaskedTextController alternateMoneyFormatter;
  var satisfactionFlex = [3, 4, 3, 3];
  static int happiness = -1;

  Geolocator geolocator = Geolocator();
  Position position;

  bool feedbackInteracted = false;
  bool feedbackRequired = true;

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
        alternateMoneyFormatter = MoneyMaskedTextController(
            decimalSeparator: '.',
            thousandSeparator: ',',
            leftSymbol: currencySymbol);
        alternateMoneyFormatter.addListener(() {
          this.setState(() {
            alternative = alternateMoneyFormatter.numberValue;
          });
        });
        this.setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Colors.black45;
    Color accent = Color.fromARGB(255, 165, 205, 196);
    double defaultFontSize = 28;
    return MaterialApp(
        title: 'Flutter',
        home: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
              decoration: BoxDecoration(color: accent),
              child: Container(
                margin: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 10),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 40, bottom: 40),
                          margin: const EdgeInsets.only(top: 50, bottom: 10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: moneyFormatter,
                            cursorWidth: 0,
                            style: TextStyle(
                                fontSize: defaultFontSize, color: primary),
                            decoration: InputDecoration(
                              labelText: "Enter Subtotal",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              ),
                            ),
                          )),
                      Container(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 40, bottom: 40),
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          child: Row(
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
                                        child: Image.asset(
                                            "graphics/unhappy.png"))),
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
                                        child: Image.asset(
                                            "graphics/confused.png"))),
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
                                        child: Image.asset(
                                            "graphics/smiling.png"))),
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
                                        child: Image.asset(
                                            "graphics/in-love.png")))
                              ])),
                      Container(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20, bottom: 20),
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Percent',
                                          style: TextStyle(
                                              color: accent,
                                              fontSize: defaultFontSize)),
                                      Text(getTipPercent(),
                                          style: TextStyle(
                                              color: primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: defaultFontSize)),
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tip',
                                          style: TextStyle(
                                              color: accent,
                                              fontSize: defaultFontSize)),
                                      Text(getTip(),
                                          style: TextStyle(
                                              color: primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: defaultFontSize)),
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total',
                                          style: TextStyle(
                                              color: accent,
                                              fontSize: defaultFontSize)),
                                      Text(getTotal(),
                                          style: TextStyle(
                                              color: primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: defaultFontSize)),
                                    ]),
                              ])),
                      getContainer(primary, accent, defaultFontSize)
                    ],
                  ),
                ),
              )),
        ),
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: accent,
            accentColor: Colors.transparent,

            // Define the default Font Family
            fontFamily: 'Montserrat'));
  }

  void vibrate() {
    HapticFeedback.vibrate();
    HapticFeedback.heavyImpact();
  }

  void addToDatabase(Placemark pos) async {
    print("submitting");
    DateTime now = DateTime.now();
    double time = now.hour * 60.0 + now.minute;
    print(countryCode);
    print(pos.postalCode);
    print(subtotal);
    print(time);
    print(getTipPercentNumber());
    await Firestore.instance.collection("Tips").add({
      "Country Code": countryCode,
      "Location": pos.postalCode,
      "Latitude": pos.position.latitude,
      "Longitude": pos.position.longitude,
      "Subtotal": subtotal,
      "Time": time,
      "Tip Amount": getTipPercentNumber(),
      "Type": "restaurant",
    });
  }

  Widget getContainer(Color primary, Color accent, double defaultFontSize) {
    if (feedbackInteracted && !feedbackRequired) {
      return Container();
    }
    return Container(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
        ),
        child: getFeedbackButton(primary, accent, defaultFontSize));
  }

  Widget getFeedbackButton(
      Color primary, Color accent, double defaultFontSize) {
    if (!feedbackInteracted) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Do You Agree?",
                style: TextStyle(
                    fontSize: defaultFontSize - 5,
                    fontWeight: FontWeight.bold,
                    color: primary)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              MaterialButton(
                child: Text('Yes'),
                color: accent,
                colorBrightness: Brightness.dark,
                onPressed: () {
                  feedbackInteracted = true;
                  feedbackRequired = false;
                  this.setState(() {});
                },
              ),
              MaterialButton(
                child: Text('No'),
                color: accent,
                colorBrightness: Brightness.dark,
                onPressed: () {
                  alternative = getTipPercentNumber();
                  feedbackInteracted = true;
                  feedbackRequired = true;
                  this.setState(() {});
                },
              )
            ])
          ]);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Text("How much did you tip?",
          style: TextStyle(
              fontSize: defaultFontSize - 5,
              fontWeight: FontWeight.bold,
              color: primary)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        MaterialButton(
          child: Text('-'),
          color: accent,
          colorBrightness: Brightness.dark,
          onPressed: () {
            alternative -= 0.005;
            if (alternative < 0) {
              alternative = 0;
            }
            this.setState(() {});
          },
        ),
        MaterialButton(
          child: Text('+'),
          color: accent,
          colorBrightness: Brightness.dark,
          onPressed: () {
            alternative += 0.005;
            this.setState(() {});
          },
        ),
        MaterialButton(
          child: Text('Submit'),
          color: accent,
          colorBrightness: Brightness.dark,
          onPressed: () {
            getPlacemark().then((pos) {
              addToDatabase(pos);
            });
            feedbackInteracted = true;
            feedbackRequired = false;
            this.setState(() {});
          },
        )
      ])
    ]);
  }

  double getTipPercentNumber() {
    if (feedbackInteracted) {
      return alternative;
    }
    if (countryData != null) {
      double tipPercent = Helper.getTip(happiness, countryData) / 100;
      return tipPercent;
    }
    return .15;
  }

  String getTipPercent() {
    var f = NumberFormat("##.0#", "en-US");
    return f.format(getTipPercentNumber() * 100) + "%";
  }

  double getTipNumber() {
    return subtotal * getTipPercentNumber();
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

  Future<Placemark> getPlacemark() async {
    if (position == null) {
      return null;
    }
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    return placemark[0];
  }
}
