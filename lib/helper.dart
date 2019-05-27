
import 'package:flutter/services.dart';

class Helper {
  static String _countryDataSet = "";
  static String _localeData = "";

  static Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  static void loadCountries() {
    print("starting");
    loadAsset('assets/res/countries.csv').then((dynamic output) {
      _countryDataSet = output;
    });
  }

  static void loadLocales() {
    print("starting");
    loadAsset('assets/res/fucking_locales.csv').then((dynamic output) {
      _localeData = output;
    });
  }

  static List<String> getCountryData(String countryCode){
    List<String> toReturn = new List();
    RegExp exp = new RegExp("($countryCode.{1,})");
    Iterable<Match> matches = exp.allMatches(_countryDataSet);
    String substring = "";
    for(Match s in matches){
      substring = _countryDataSet.substring(s.start,s.end);
    }
    exp = new RegExp("([^,]{1,})");
    matches = exp.allMatches(substring);
    for(Match s in matches){
      toReturn.add(substring.substring(s.start,s.end));
    }
    return toReturn;
  }

  static String getLocale(String countryCode){
    String toReturn = "";
    RegExp exp = new RegExp("($countryCode.{1,})");
    Iterable<Match> matches = exp.allMatches(_localeData);
    String substring = "";
    print("Data: " + _localeData);
    for(Match s in matches){
      substring = _localeData.substring(s.start,s.end);
    }
    exp = new RegExp("([^,]{1,})");
    matches = exp.allMatches(substring);
    for(Match s in matches){
      toReturn=substring.substring(s.start,s.end);
    }
    return toReturn;
  }

  static double getTip(int happiness, List<String> data){
    double tipRate = double.parse(data[2]);
    int hasData = int.parse(data[3]);
    int expected = int.parse(data[1]);
    if(hasData == 0){
      //TODO add popup for no data
      return 0.0;
    }
    if(tipRate == 0 && hasData == 1){
      return 0.0;
    }
    if(tipRate<=7.5&&happiness<0&&expected==0){
      return 0.0;
    }
    double variance = tipRate/7;
    tipRate += variance * happiness;
    return tipRate;
  }
}