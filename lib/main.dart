import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

void main(){
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePage();
  }
}

class HomePage extends State<MyApp> {
  double subtotal;
  double restaurantPrice = 0.0;
  static String _locale = "en-FR";
  static String currencySymbol = "\$";
  TextEditingController moneyFormatter;
  var satisfactionFlex = [3, 4, 3, 3];

  Geolocator geolocator = Geolocator();
  Position position;

  Future<Position> getPosition() async {
    try {
      return await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      return null;
    }
  }
  @override
  void initState() {
    super.initState();
    getPosition().then((p) {
      position = p;
      getLocale().then((l) {
        _locale = l;
        currencySymbol = NumberFormat.simpleCurrency(locale: _locale).currencySymbol;
        moneyFormatter = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator:',', leftSymbol: currencySymbol);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getPosition().then((p) {
      position = p;
      getLocale().then((l) {
        _locale = l;
        currencySymbol = NumberFormat.simpleCurrency(locale: _locale).currencySymbol;
        moneyFormatter = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator:',', leftSymbol: currencySymbol);
      });
    });
    print(position);
    return MaterialApp(
      title: 'Flutter',
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Center(
            child: Column (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  controller: moneyFormatter,
                  decoration: new InputDecoration(
                    labelText: "Enter Subtotal",
                    fillColor: Colors.white,
                  ),
                ),
                Row (
                    children: [
                      Text (
                          currencySymbol
                      ),
                      Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: Colors.teal,
                            min: 0.0,
                            max: 10.0,
                            value: restaurantPrice,
                            onChanged: (double value) {
                              setState(() {
                                restaurantPrice = value;
                              });
                            },
                          )
                      ),
                      Text (
                          currencySymbol + currencySymbol + currencySymbol
                      ),
                    ]
                ),
                Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: satisfactionFlex[0],
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            satisfactionFlex = [4, 3, 3, 3];
                            vibrate();
                          });
                        },
                        child: Image.asset("graphics/unhappy.png")
                      )
                    ),
                    Flexible(flex: 1, child: Container()),
                    Flexible(
                        flex: satisfactionFlex[1],
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                satisfactionFlex = [3, 4, 3, 3];
                                vibrate();
                              });
                            },
                            child: Image.asset("graphics/confused.png")
                        )
                    ),
                    Flexible(flex: 1, child: Container()),
                    Flexible(
                        flex: satisfactionFlex[2],
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                satisfactionFlex = [3, 3, 4, 3];
                                vibrate();
                              });
                            },
                            child: Image.asset("graphics/smiling.png")
                        )
                    ),
                    Flexible(flex: 1, child: Container()),
                    Flexible(
                        flex: satisfactionFlex[3],
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                satisfactionFlex = [3, 3, 3, 4];
                                vibrate();
                              });
                            },
                            child: Image.asset("graphics/in-love.png")
                        )
                    )
                  ]
                ),
                Text(
                  "HELLO"
                )
              ],
            ),
          ),
        ),
      ),
      theme: ThemeData(
          primarySwatch: Colors.teal
      ),
    );
  }

  void vibrate() {
    HapticFeedback.vibrate();
    HapticFeedback.heavyImpact();
  }

  Future<String> getLocale() async{
    if (position == null) {
      return "en-FR";
    }
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark[0].isoCountryCode);
    return "en-FR";
  }
}