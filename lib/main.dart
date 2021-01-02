import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gcg_expected_damage/scoreCalculator.dart';
import 'expectedDamage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        //AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ko', ''),
        const Locale('jp', ''),
        const Locale.fromSubtags(languageCode: 'zh'),
      ],
      title: '걸카페건 계산기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: Typography.blackMountainView,
      ),
      home: MyHomePage(title: '걸카페건 계산기'),
      routes: {
        '/expecteddamage': (context) => ExpectedDamage(),
        '/scorecalculator': (context) => ScoreCalculator(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: Text('잘못된 접근입니다'),
            ),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: RaisedButton(
                  color: Colors.blue,
                  //textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(30.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/scorecalculator');
                  },
                  child: Text(
                    "모의 점수 계산기",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: RaisedButton(
                  color: Colors.blue,
                  //textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(30.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/expecteddamage');
                  },
                  child: Text(
                    "대미지 기댓값",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
