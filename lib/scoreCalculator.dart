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

  Future<void> _showEnterPhoneModal(String session) async {
    TextEditingController _phoneController = new TextEditingController();

    return showModalBottomSheet<void>(
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: Column(children: [
                Icon(Icons.verified, size: 100, color: Colors.black),
                Text('Revault에 오신 것을 환영합니다!\n',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(
                    '기본 배송지에 들어갈 전화번호를 입력하시기 바랍니다\n나중에 환경설정에서 입력하거나 변경할 수 있습니다',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Divider(
                  indent: 50,
                  endIndent: 50,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '전화번호 입력',
                    border: inputBorder,
                    focusedBorder: inputBorder,
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.black)),
                      color: Colors.black,
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.transparent,
                      onPressed: () async {
                        //Navigator.pushReplacementNamed(context, '/auctionList');
                        Navigator.pop(context);
                      },
                      child: Text('건너뛰기', style: TextStyle(fontSize: 16.0)),
                    ),
                    VerticalDivider(),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.black)),
                      color: Colors.black,
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.transparent,
                      onPressed: () async {
                        if (_phoneController.text != '') {}
                      },
                      child: Text('등록하기', style: TextStyle(fontSize: 16.0)),
                    ),
                  ],
                ),
              ]),
            ),
          );
        });
  }

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
              child: Column(children: <Widget>[
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
                    )),
              ])),
        ],
      ),
    )));
  }
}
