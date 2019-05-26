import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
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
  String currencySymbol = "#";
  TextEditingController moneyFormatter;


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter',
      builder: (context, navigator) {
        Locale locale= Localizations.localeOf(context);
        currencySymbol = NumberFormat.simpleCurrency(locale: locale.toString()).currencySymbol;
        moneyFormatter = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator:',', leftSymbol: currencySymbol);
        return new Container(
          child: navigator
        );
      },
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
                            activeColor: Colors.indigoAccent,
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
}