import 'package:flutter/material.dart';
import 'common.dart';

class ExpectedDamage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("대미지 배율 기댓값 계산"),
      ),
      body: ExpectedDamageForm(),
    );
  }
}

// TODO: 무기의 스킬을 수치화
// 브레이버: Damage * 5 + 67
// 오로라: Damage * (1 + 0.9 + 0.8 + 0.7)
// 로튼: Damage * 0.85 + 72.4 * 0.15
// 아쿠아: 45 * (Rate * 0.05)
// 물총: jspEffect + 1.275
// class Weapon {
//   enum weaponType;
//   double baseDamage;
//   double baseRate;
//   double baseCrit;
//   double baseBreak;
// }

class ExpectedRate {
  double weaponDPS;
  double skill;

  ExpectedRate(
    this.weaponDPS,
    this.skill,
  );
}

class ExpectedDamageForm extends StatefulWidget {
  @override
  ExpectedDamageFormState createState() {
    return ExpectedDamageFormState();
  }
}

class ExpectedDamageFormState extends State<ExpectedDamageForm> {
  final _formKey = GlobalKey<FormState>();
  //TextEditingController _baseController = new TextEditingController();
  // 무기 기초 속성 수치
  TextEditingController _bdamController = new TextEditingController();
  TextEditingController _brateController = new TextEditingController();
  TextEditingController _bcritController = new TextEditingController();
  TextEditingController _bbreakController = new TextEditingController();
  // 무기 속성 증가 수치
  TextEditingController _damageController = new TextEditingController();
  TextEditingController _rateController = new TextEditingController();
  TextEditingController _critController = new TextEditingController();
  TextEditingController _breakController = new TextEditingController();
  // 무기 성능 수치
  TextEditingController _jspController = new TextEditingController(text: '0');
  TextEditingController _pwbController = new TextEditingController(text: '0');
  TextEditingController _wprController = new TextEditingController(text: '0');
  var specValueList = new List<String>.generate(21, (i) => i.toString());
  // 모듈 수치
  TextEditingController _mcdController = new TextEditingController();
  TextEditingController _mcpController = new TextEditingController();
  TextEditingController _mprController = new TextEditingController();
  // 소대 버프
  TextEditingController _shootController = new TextEditingController(text: '0');
  TextEditingController _skillController = new TextEditingController(text: '0');
  TextEditingController _tcritController = new TextEditingController(text: '0');
  // 스킬에 의한 공격 버프, 피격 디버프
  // TextEditingController _buffController = new TextEditingController();
  // TextEditingController _debuffController = new TextEditingController();
  List<bool> _attributeSelect = List.generate(4, (_) => false);
  ExpectedRate objectiveResult;

  // 대미지 배율 기댓값 계산
  Widget showExpectedDamage() {
    if (objectiveResult == null) return Text('');

    return Padding(
      padding: EdgeInsets.only(
        bottom: 20.0,
      ),
      child: Text(
        '무기 사격 대미지 DPS 배율 기댓값은 ${objectiveResult.weaponDPS}입니다' +
            '\n스킬 대미지 배율 기댓값은 ${objectiveResult.skill}입니다',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  ExpectedRate calculateExpectedDamage() {
    // 배율 기댓값 = 속성 보정 * 크리 기대치 * 딜 증가치
    // 속성 보정: 기본 보정 + 모듈 억제 + 부품 공격전술
    double attributeRate;
    int attr = _attributeSelect.indexOf(true);
    switch (attr) {
      case 0:
        attributeRate = 2.0;
        break;
      case 1:
        attributeRate = 1.5;
        break;
      case 2:
        attributeRate = 1.0;
        break;
      case 3:
        attributeRate = 0.5;
        break;
      default:
        throw Exception('올바르지 않은 값이 들어왔습니다');
    }
    if (attributeRate > 1.1) {
      double weaponPressureEffect = 0;
      int pressureLevel = int.parse(_wprController.text);
      if (pressureLevel >= 20)
        weaponPressureEffect = 0.297;
      else if (pressureLevel >= 12)
        weaponPressureEffect = 0.222;
      else if (pressureLevel >= 7)
        weaponPressureEffect = 0.148;
      else if (pressureLevel >= 3) weaponPressureEffect = 0.074;

      attributeRate += (attributeRate - 1) * weaponPressureEffect;
      attributeRate += double.parse(_mprController.text);
    }

    // 크리 기대치: 1 + 치명 확률 * 치명 추댐
    // - 치명 확률: 무기 치확 + 강화탄 + 모듈 치명타 + 소대 치확 + (스킬 치확)
    // - 치명 추댐: 0.5 + 모듈 치명 대미지
    double criticalProbability = double.parse(_bcritController.text) *
        (1 + int.parse(_critController.text) / 100);
    double enhancedBulletEffect = 0;
    int eBulletLevel = int.parse(_pwbController.text);
    if (eBulletLevel >= 20)
      enhancedBulletEffect = 13.5;
    else if (eBulletLevel >= 12)
      enhancedBulletEffect = 10.1;
    else if (eBulletLevel >= 7)
      enhancedBulletEffect = 6.7;
    else if (eBulletLevel >= 3) enhancedBulletEffect = 3.3;

    criticalProbability += enhancedBulletEffect;
    criticalProbability += double.parse(_mcpController.text);
    criticalProbability += int.parse(_tcritController.text);
    if (criticalProbability > 100) criticalProbability = 100;

    double criticalDamageRate = 0.5 + double.parse(_mcdController.text) / 100;
    double expectedCriticalDamage =
        1 + criticalProbability * criticalDamageRate / 100;

    // 딜 증가치 - 6.1 / 12.1 / 18.2 / 24.3
    // 여러 버프가 겹치면 곱연산? 합연산?
    double jspBulletEffect = 1;
    int jBulletLevel = int.parse(_jspController.text);
    if (jBulletLevel >= 20)
      jspBulletEffect = 1.243;
    else if (jBulletLevel >= 12)
      jspBulletEffect = 1.182;
    else if (jBulletLevel >= 7)
      jspBulletEffect = 1.121;
    else if (jBulletLevel >= 3) jspBulletEffect = 1.061;

    // 사격속도
    double fireRate = double.parse(_brateController.text) *
        (1 + int.parse(_rateController.text) / 100);
    // 무기 사격 대미지 비율
    double baseDamage = (double.parse(_bdamController.text) / 100) *
        (1 + int.parse(_damageController.text) / 100) *
        (1 + int.parse(_shootController.text) / 100);
    // TODO: 샷건의 경우 기본적으로 5를 곱해야한다
    double expRate = attributeRate * expectedCriticalDamage * jspBulletEffect;
    double weaponDPS = baseDamage * fireRate * expRate;
    print('기초 대미지: $baseDamage');
    print('사격 속도: $fireRate per second');
    print('속성 보정: $attributeRate');
    print('치명 기댓값: $expectedCriticalDamage');
    print('대미지 증가: $jspBulletEffect');
    return ExpectedRate(
        weaponDPS, expRate * (1 + int.parse(_skillController.text) / 100));
  }

  Widget makeDropDownInput(
      String name, TextEditingController inputVal, List<String> valueList) {
    return Container(
      width: (MediaQuery.of(context).size.width) / 8,
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          DropdownButtonFormField<String>(
            isExpanded: false,
            value: inputVal.text,
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
                inputVal.text = newValue;
              });
            },
            items: valueList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
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
      padding: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       '기초 공격력',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //     VerticalDivider(),
                  //     Container(
                  //       width: 100,
                  //       child: TextFormField(
                  //         controller: _baseController,
                  //         keyboardType: TextInputType.number,
                  //         decoration: InputDecoration(
                  //           hintText: '편성에 있는 공격력 수치',
                  //           border: inputBorder,
                  //           focusedBorder: inputBorder,
                  //           contentPadding: EdgeInsets.symmetric(
                  //             vertical: 5.0,
                  //             horizontal: 5.0,
                  //           ),
                  //           errorStyle: TextStyle(
                  //             fontSize: 10,
                  //           ),
                  //         ),
                  //         validator: (value) {
                  //           if (value.isEmpty) {
                  //             return '공격력 수치를 입력하세요';
                  //           }

                  //           var result = int.tryParse(value);
                  //           if (result == null || result < 0) {
                  //             return '음이 아닌 정수를 입력하세요';
                  //           }

                  //           return null;
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      '속성 보정 선택',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ToggleButtons(
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Center(child: Text('유리(모의전)')),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Center(child: Text('유리(일반)')),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Center(child: Text('대등')),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Center(child: Text('불리')),
                      ),
                    ],
                    isSelected: _attributeSelect,
                    onPressed: (index) {
                      setState(() {
                        for (int btnIndex = 0;
                            btnIndex < _attributeSelect.length;
                            btnIndex++) {
                          if (btnIndex == index)
                            _attributeSelect[btnIndex] = true;
                          else
                            _attributeSelect[btnIndex] = false;
                        }
                        objectiveResult = null;
                      });
                    },
                    fillColor: Colors.lightBlue,
                    selectedColor: Colors.black,
                  ),
                  // TODO: 무기 종류 선택할 수 있도록 변경
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      '무기 기본 속성 수치',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '대미지',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _bdamController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '대미지',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = double.tryParse(value);
                                if (result == null || result < 0) {
                                  return '음이 아닌 값을 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '사격속도',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _brateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '사격속도',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = double.tryParse(value);
                                if (result == null || result < 0) {
                                  return '음이 아닌 값을 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '치명타',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _bcritController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '치명타',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = double.tryParse(value);
                                if (result == null || result < 0) {
                                  return '음이 아닌 값을 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(children: [
                          Text(
                            '실신치',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextFormField(
                            controller: _bbreakController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '실신치',
                              border: inputBorder,
                              focusedBorder: inputBorder,
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return '필수 항목';
                              }

                              var result = double.tryParse(value);
                              if (result == null || result < 0) {
                                return '음이 아닌 값을 입력하세요';
                              }

                              return null;
                            },
                          ),
                        ]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      '무기 속성 가산 수치',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '대미지',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _damageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '대미지',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = int.tryParse(value);
                                if (result == null) {
                                  return '정수를 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '사격속도',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _rateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '사격속도',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = int.tryParse(value);
                                if (result == null) {
                                  return '정수를 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '치명타',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _critController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '치명타',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = int.tryParse(value);
                                if (result == null) {
                                  return '정수를 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(children: [
                          Text(
                            '실신치',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextFormField(
                            controller: _breakController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '실신치',
                              border: inputBorder,
                              focusedBorder: inputBorder,
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return '필수 항목';
                              }

                              var result = int.tryParse(value);
                              if (result == null) {
                                return '정수를 입력하세요';
                              }

                              return null;
                            },
                          ),
                        ]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      '무기 성능 수치',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      makeDropDownInput('JSP탄', _jspController, specValueList),
                      makeDropDownInput('강화탄', _pwbController, specValueList),
                      makeDropDownInput('공격전술', _wprController, specValueList),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      '모듈 수치',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '치명 대미지',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _mcdController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '치명 대미지',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = double.tryParse(value);
                                if (result == null || result < 0) {
                                  return '음이 아닌 값을 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '치명타',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _mcpController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '치명타',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = double.tryParse(value);
                                if (result == null || result < 0) {
                                  return '음이 아닌 값을 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width) / 8,
                        child: Column(
                          children: [
                            Text(
                              '억제',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextFormField(
                              controller: _mprController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '억제',
                                border: inputBorder,
                                focusedBorder: inputBorder,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return '필수 항목';
                                }

                                var result = double.tryParse(value);
                                if (result == null || result < 0) {
                                  return '음이 아닌 값을 입력하세요';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      '소대 버프',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      makeDropDownInput(
                          '사격 대미지', _shootController, ['0', '1', '3', '5']),
                      makeDropDownInput(
                          '스킬 대미지', _skillController, ['0', '2', '5', '8']),
                      makeDropDownInput(
                          '치명타율', _tcritController, ['0', '1', '3', '5']),
                    ],
                  ),
                  Divider(color: Colors.transparent),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       '공격 버프',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //     VerticalDivider(),
                  //     Container(
                  //       width: 100,
                  //       padding: EdgeInsets.only(right: 20.0,),
                  //       child: TextFormField(
                  //         controller: _buffController,
                  //         keyboardType: TextInputType.number,
                  //         decoration: InputDecoration(
                  //           hintText: '스킬에 의한 부여 대미지 증가',
                  //           border: inputBorder,
                  //           focusedBorder: inputBorder,
                  //           contentPadding: EdgeInsets.symmetric(
                  //             vertical: 5.0,
                  //             horizontal: 5.0,
                  //           ),
                  //           errorStyle: TextStyle(
                  //             fontSize: 10,
                  //           ),
                  //         ),
                  //         validator: (value) {
                  //           if (value.isEmpty) {
                  //             return '부여 대미지 증가 수치를 입력하세요';
                  //           }

                  //           return null;
                  //         },
                  //       ),
                  //     ),
                  //     Text(
                  //       '상대 피격 디버프',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //     VerticalDivider(),
                  //     Container(
                  //       width: 100,
                  //       child: TextFormField(
                  //         controller: _debuffController,
                  //         keyboardType: TextInputType.number,
                  //         decoration: InputDecoration(
                  //           hintText: '스킬에 의한 받는 대미지 증가',
                  //           border: inputBorder,
                  //           focusedBorder: inputBorder,
                  //           contentPadding: EdgeInsets.symmetric(
                  //             vertical: 5.0,
                  //             horizontal: 5.0,
                  //           ),
                  //           errorStyle: TextStyle(
                  //             fontSize: 10,
                  //           ),
                  //         ),
                  //         validator: (value) {
                  //           if (value.isEmpty) {
                  //             return '받는 대미지 증가 수치를 입력하세요';
                  //           }

                  //           return null;
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
                        onPressed: () async {
                          if (_formKey.currentState.validate() &&
                              _attributeSelect.any((sel) => sel)) {
                            var result = calculateExpectedDamage();

                            setState(() {
                              objectiveResult = result;
                            });

                            return;
                            // ScaffoldMessenger.of(context)
                            //   .showSnackBar(SnackBar(content: Text('대미지 계산 구현중')));
                          }
                        },
                        child: Text(
                          "계산하기",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),
                  showExpectedDamage(),
                  Divider(
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )));
  }
}
