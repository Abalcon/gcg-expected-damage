import 'package:flutter/material.dart';
import 'common.dart';

class BatteryCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("팬텀 전력 계산기"),
      ),
      body: BatteryCalculatorForm(),
    );
  }
}

class BatteryCalculatorForm extends StatefulWidget {
  @override
  BatteryCalculatorFormState createState() {
    return BatteryCalculatorFormState();
  }
}

class BatteryCalculatorFormState extends State<BatteryCalculatorForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phantomNumber = new TextEditingController();
  TextEditingController _crystalNumber = new TextEditingController();
  TextEditingController _crystalDifficulty = TextEditingController(text: '극악');
  TextEditingController _unitNumber = new TextEditingController();
  TextEditingController _unitDifficulty = TextEditingController(text: '극악');
  TextEditingController _weaponNumber = new TextEditingController();
  TextEditingController _weaponDifficulty = TextEditingController(text: '극악');
  TextEditingController _limitNumber = new TextEditingController();
  TextEditingController _limitDifficulty = TextEditingController(text: '극악');
  TextEditingController _coopNumber = new TextEditingController();
  TextEditingController _coopDifficulty = TextEditingController(text: '지옥');
  TextEditingController _eventController = new TextEditingController();

  final divider = Divider(
    color: Colors.transparent,
    height: 20,
    thickness: 2,
    indent: 100,
    endIndent: 100,
  );

  // 기본 사용 가능 전력: 240 + 30 + 30 + 20 + 60
  final int basicCharge = 380;
  final int monthlyDailyCharge = 30;
  bool haveMonthlyPass = true;
  // 팬텀은 보스까지만 잡고 철수를 가정
  final int seasonLength = 14;
  final int phantomEasy = 18;
  final int phantomNormal = 24;
  final int phantomHard = 36;
  // 하루에 필요한 충전량 (렙업은 반영하지 않았음)
  double dailyRequiredCharge;

  Widget showDailyRequiredCharge() {
    if (dailyRequiredCharge == null) return Text('');

    if (dailyRequiredCharge > 0) {
      String additionalNote = '';
      if (dailyRequiredCharge > 2100)
        additionalNote = '20충으로도 채울 수 없는 엄청난 양입니다! 전지 괜찮아요?';
      else if (dailyRequiredCharge > 900) {
        var offset = dailyRequiredCharge - 900;
        var requiredTwentyChargeDays = (offset * seasonLength / 1200).ceil();
        additionalNote =
            '20충은 총 $requiredTwentyChargeDays일 필요하며, 나머지는 10충 이내로 하면 됩니다';
      } else if (dailyRequiredCharge > 120 && dailyRequiredCharge < 900) {
        var offset = dailyRequiredCharge - 120;
        var requiredTenChargeDays = (offset * seasonLength / 780).ceil();
        additionalNote = '10충은 총 $requiredTenChargeDays일 필요하며, 나머지는 2충하면 됩니다';
      } else
        additionalNote = '하루 2충으로 충분합니다';

      return Column(
        children: [
          Text(
            '하루에 필요한 충전량은 ${dailyRequiredCharge.ceil()} 입니다',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            additionalNote,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      );
    }

    return Text(
      '충전할 필요가 없습니다',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  int getTotalRequiredCharge() {
    int requiredConsumption;
    final int phantomNumber = int.parse(_phantomNumber.text);
    switch (phantomNumber) {
      case 0:
        requiredConsumption = 0;
        break;
      case 1:
        requiredConsumption = phantomEasy;
        break;
      case 2:
        requiredConsumption = phantomEasy + phantomNormal;
        break;
      default:
        requiredConsumption =
            phantomHard * (phantomNumber - 2) + phantomEasy + phantomNormal;
    }

    final int naturalCharge =
        haveMonthlyPass ? basicCharge + monthlyDailyCharge : basicCharge;

    int crystalRequire = getRequiredbyDifficulty(_crystalDifficulty.text);
    int crystalConsumption = (crystalRequire > 0)
        ? crystalRequire * int.parse(_crystalNumber.text)
        : int.parse(_crystalNumber.text);
    int unitRequire = getRequiredbyDifficulty(_unitDifficulty.text);
    int unitConsumption = (unitRequire > 0)
        ? unitRequire * int.parse(_unitNumber.text)
        : int.parse(_unitNumber.text);
    int weaponRequire = getRequiredbyDifficulty(_weaponDifficulty.text);
    int weaponConsumption = (weaponRequire > 0)
        ? weaponRequire * int.parse(_weaponNumber.text)
        : int.parse(_weaponNumber.text);
    int limitRequire = getRequiredbyDifficulty(_limitDifficulty.text);
    int limitConsumption = (limitRequire > 0)
        ? limitRequire * int.parse(_limitNumber.text)
        : int.parse(_limitNumber.text);
    int coopRequire = getRequiredbyDifficulty(_coopDifficulty.text);
    int coopConsumption = (coopRequire > 0)
        ? coopRequire * int.parse(_coopNumber.text)
        : int.parse(_coopNumber.text);
    int eventConsumption = int.parse(_eventController.text);
    final int otherConsumption = crystalConsumption +
        unitConsumption +
        weaponConsumption +
        limitConsumption +
        coopConsumption +
        eventConsumption;

    final int requiredCharge =
        requiredConsumption + (otherConsumption - naturalCharge) * seasonLength;
    return requiredCharge;
  }

  int getRequiredbyDifficulty(String difficulty) {
    switch (difficulty) {
      case '극악':
      case '지옥':
        return 30;
      case '악몽':
        return 25;
      case '어려움':
        return 20;
      case '보통':
        return 15;
      case '쉬움':
        return 10;
      default:
        return 0;
    }
  }

  Widget bountySetting(String name, TextEditingController difficulty,
      TextEditingController ctrl) {
    var textList = (name == '협동 출격')
        ? ['쉬움', '보통', '어려움', '악몽', '지옥', '직접 입력']
        : ['쉬움', '보통', '어려움', '악몽', '지옥', '극악', '직접 입력'];
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          VerticalDivider(),
          Container(
            width: 100,
            child: DropdownButtonFormField<String>(
              isExpanded: false,
              value: difficulty.text,
              icon: Icon(
                Icons.arrow_downward,
                color: Colors.lightBlue,
              ),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.blue),
              decoration: InputDecoration(
                fillColor: Colors.blueAccent,
                border: inputBorder,
                focusedBorder: inputBorder,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 5.0,
                ),
              ),
              onChanged: (String newValue) {
                setState(() {
                  difficulty.text = newValue;
                });
              },
              items: textList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          VerticalDivider(),
          Container(
            width: 100,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '횟수 입력',
                border: inputBorder,
                focusedBorder: inputBorder,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 5.0,
                ),
                errorStyle: TextStyle(
                  fontSize: 10,
                ),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return '$name 횟수를 입력하세요';
                }

                var result = int.tryParse(value);
                if (result == null || result < 0) {
                  return '음이 아닌 정수를 입력하세요';
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '한 시즌의 기간은 14일입니다',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '시즌내 목표 보스 격파 횟수',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        VerticalDivider(),
                        Container(
                          width: 100,
                          child: TextFormField(
                            controller: _phantomNumber,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '횟수 입력',
                              border: inputBorder,
                              focusedBorder: inputBorder,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 5.0,
                              ),
                              errorStyle: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return '보스 격파 횟수를 입력하세요';
                              }

                              var result = int.tryParse(value);
                              if (result == null || result < 0) {
                                return '음이 아닌 정수를 입력하세요';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    divider,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '월정액 여부',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Switch(
                          value: haveMonthlyPass,
                          onChanged: (value) {
                            setState(() {
                              haveMonthlyPass = value;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blueAccent,
                        ),
                      ],
                    ),
                    divider,
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '일일 바운티 미션',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    bountySetting('크리스탈 ', _crystalDifficulty, _crystalNumber),
                    bountySetting('팀원 단련', _unitDifficulty, _unitNumber),
                    bountySetting('부품 수집', _weaponDifficulty, _weaponNumber),
                    bountySetting('한계 돌파', _limitDifficulty, _limitNumber),
                    bountySetting('협동 출격', _coopDifficulty, _coopNumber),
                    divider,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '일일 이벤트 소모 전력',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        VerticalDivider(),
                        Container(
                          width: 100,
                          child: TextFormField(
                            controller: _eventController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '소모 전력',
                              border: inputBorder,
                              focusedBorder: inputBorder,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 5.0,
                              ),
                              errorStyle: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return '이벤트 소모 전력을 입력하세요';
                              }

                              var result = int.tryParse(value);
                              if (result == null || result < 0) {
                                return '음이 아닌 정수를 입력하세요';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          disabledColor: Colors.grey,
                          disabledTextColor: Colors.black,
                          padding: EdgeInsets.all(20.0),
                          splashColor: Colors.blueAccent,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              final int requiredCharge =
                                  getTotalRequiredCharge();

                              setState(() {
                                dailyRequiredCharge =
                                    requiredCharge / seasonLength;
                              });

                              // ScaffoldMessenger.of(context)
                              //   .showSnackBar(SnackBar(content: Text('필요 전력 구현 예정입니다')));
                            }
                          },
                          child: Text(
                            "필요 전력 계산하기",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ),
                    showDailyRequiredCharge(),
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
