import 'package:flutter/material.dart';
import 'common.dart';

class ScoreCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("모의전 점수 계산기"),
      ),
      body: ScoreCalculatorForm(),
    );
  }
}

class ScoreCalculatorForm extends StatefulWidget {
  @override
  ScoreCalculatorFormState createState() {
    return ScoreCalculatorFormState();
  }
}

class ScoreCalculatorFormState extends State<ScoreCalculatorForm> {
  final _formKey = GlobalKey<FormState>();

  final divider = Divider(
    color: Colors.grey,
    height: 20,
    thickness: 3,
    indent: 0,
    endIndent: 0,
  );

  // @override
  // void initState() {

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    TextEditingController _idController = new TextEditingController();
    TextEditingController _pwController = new TextEditingController();
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '모듈 치명타 확률',
                        hintText: '모듈 정보에 있는 "치명타" 값을 입력',
                        border: inputBorder,
                        focusedBorder: inputBorder,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return '모듈 치명타 확률을 입력하세요';
                        }
                        return null;
                      },
                    ),
                    Divider(color: Colors.white),
                    TextFormField(
                      controller: _pwController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '모듈 치명타 대미지',
                        hintText: '모듈 정보에 있는 "치명 대미지" 값을 입력',
                        border: inputBorder,
                        focusedBorder: inputBorder,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return '모듈 치명타 대미지를 입력하세요';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          disabledColor: Colors.grey,
                          disabledTextColor: Colors.black,
                          padding: EdgeInsets.all(8.0),
                          splashColor: Colors.blueAccent,
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {}
                          },
                          child: Text(
                            "계산하기",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
