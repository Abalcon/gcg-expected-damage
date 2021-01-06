import 'package:flutter/material.dart';
import 'common.dart';

class ScoreCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScoreCalculatorDetail(),
    );
  }
}

class ScoreCalculatorDetail extends StatefulWidget {
  @override
  ScoreCalculatorDetailState createState() {
    return ScoreCalculatorDetailState();
  }
}

class ScoreCalculatorDetailState extends State<ScoreCalculatorDetail> {
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
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 50.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("모의전 점수 계산"),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  tabs: [
                    Tab(child: Text("대미지", style: Theme.of(context).textTheme.headline6)),
                    Tab(child: Text("빠른 통과", style: Theme.of(context).textTheme.headline6)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          children: <Widget> [
            Center(child: DamageForm()),
            Center(child: SpeedrunForm()),
          ],
        )
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class DamageForm extends StatefulWidget {
  // final SessionNamePair user;
  // RequestForm({Key key, @required this.user}) : super(key: key);

  @override
  DamageFormState createState() {
    return DamageFormState();
  }
}

class DamageFormState extends State<DamageForm> {
  final _formKey = GlobalKey<FormState>();
  List<bool> _enemyTypeSelect = List.generate(2, (_) => false);
  List<bool> _objectiveSelect = List.generate(2, (_) => false);
  TextEditingController _scoreController = new TextEditingController();
  int objectiveResult;

  int calculateFromInput(int value) {
    // 적의 유형에 따라 다른 점수표가 필요
    List<int> damageMilestone;
    List<int> scoreMilestone;
    if (_enemyTypeSelect[0]) {
      // 260만 이하의 낮은 점수 구간은 아직 수집을 못했다
      damageMilestone = [0, 1300000, 4000000, 6000000, 15000000, 30000000];
      scoreMilestone = [0, 11000, 17600, 19800, 20900, 22000];
    }
    else {
      // 460만 이하의 낮은 점수 구간은 아직 수집을 못했다
      damageMilestone = [0, 1600000, 2000000, 6000000, 10000000, 25000000, 50000000];
      scoreMilestone = [0, 11000, 13200, 17600, 19800, 20900, 22000];
    }

    final int len = damageMilestone.length;
    if (_objectiveSelect[0]) {
      for (int i = 1; i < len; i++) {
        if (value < damageMilestone[i]) {
          double scoreRate = (scoreMilestone[i] - scoreMilestone[i - 1])
            / (damageMilestone[i] - damageMilestone[i - 1]);
          double result = scoreMilestone[i - 1]
            + scoreRate * (value - damageMilestone[i - 1]);
          return result.round();
        }
      }

      return scoreMilestone[len - 1]; 
    }

    for (int i = 1; i < len; i++) {
      if (value < scoreMilestone[i]) {
        double damageRate = (damageMilestone[i] - damageMilestone[i - 1])
          / (scoreMilestone[i] - scoreMilestone[i - 1]);
        double result = damageMilestone[i - 1]
          + damageRate * (value - scoreMilestone[i - 1]);
        return result.round();
      }
    }

    return damageMilestone[len - 1];
  }

  Widget showRequirement() {
    if (objectiveResult == null) return Text('');

    if (_objectiveSelect[0]) {
      return Text(
        '${_scoreController.text} 대미지를 내면 $objectiveResult점이 나옵니다',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }

    return Text(
      '${_scoreController.text}점에 필요한 대미지는 $objectiveResult입니다',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                '현재 지옥 난이도만 제공하고 있습니다',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '적의 유형',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ToggleButtons(
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width) / 4,
                  child: Center(child: Text('보스')),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) / 4,
                  child: Center(child: Text('엘리트/잡병')),
                ),
              ],
              isSelected: _enemyTypeSelect,
              onPressed: (index) {
                setState(() {
                  for (int btnIndex = 0; btnIndex < _enemyTypeSelect.length; btnIndex++) {
                    if (btnIndex == index)
                      _enemyTypeSelect[btnIndex] = true;
                    else
                      _enemyTypeSelect[btnIndex] = false;
                  }
                  objectiveResult = null;
                });
              },
              fillColor: Colors.lightBlue,
              selectedColor: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                '목표 선택',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ToggleButtons(
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width) / 4,
                  child: Center(child: Text('대미지')),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) / 4,
                  child: Center(child: Text('점수')),
                ),
              ],
              isSelected: _objectiveSelect,
              onPressed: (index) {
                setState(() {
                  for (int btnIndex = 0; btnIndex < _enemyTypeSelect.length; btnIndex++) {
                    if (btnIndex == index)
                      _objectiveSelect[btnIndex] = true;
                    else
                      _objectiveSelect[btnIndex] = false;
                  }
                  objectiveResult = null;
                });
              },
              fillColor: Colors.lightBlue,
              selectedColor: Colors.black,
            ),
            Container(
              padding: EdgeInsets.only(top: 8,),
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: TextFormField(
                controller: _scoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '목표 대미지 또는 점수 입력',
                  border: inputBorder,
                  focusedBorder: inputBorder,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return '목표 수치를 입력하세요';
                  }

                  var result = int.tryParse(value);
                  if (result == null || result < 0) {
                    return '음이 아닌 정수를 입력하세요';
                  }

                  if (_objectiveSelect[1] && result > 22000) {
                    return '점수는 22000을 넘을 수 없습니다';
                  }

                  return null;
                },
              ),
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
                  onPressed: () async {
                    if (_formKey.currentState.validate()
                      && _enemyTypeSelect.any((sel) => sel)
                      && _objectiveSelect.any((sel) => sel)) {
                      var result = calculateFromInput(int.parse(_scoreController.text));

                      setState(() {
                        objectiveResult = result;
                      });

                      return;
                    }

                    if (_enemyTypeSelect.every((sel) => !sel)) {
                      ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('적의 유형을 선택하세요')));
                    }

                    if (_objectiveSelect.every((sel) => !sel)) {
                      ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('목표 유형을 선택하세요')));
                    }
                  },
                  child: Text(
                    "계산하기",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            showRequirement(),
          ],
        ),
      ),
    );
  }
}

class SpeedrunForm extends StatefulWidget {

  @override
  SpeedrunFormState createState() {
    return SpeedrunFormState();
  }
}

class SpeedrunFormState extends State<SpeedrunForm> {
  final _formKey2 = GlobalKey<FormState>();
  List<bool> _difficultySelect = List.generate(3, (_) => false);
  TextEditingController _timeController = new TextEditingController();
  int objectiveResult;

  int calculateScore(int time) {
    int maximum;
    if (_difficultySelect[0])
      maximum = 12000;
    else if (_difficultySelect[1])
      maximum = 18000;
    else
      maximum = 19000;

    double result = maximum * (1 - time / 600);
    return result.round();
  }

  Widget showScore() {
    if (objectiveResult == null) return Text('');

    return Text(
      '${_timeController.text}초를 내면 $objectiveResult점이 나옵니다',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey2,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                '난이도 선택',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ToggleButtons(
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width) / 6,
                  child: Center(child: Text('쉬움')),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) / 6,
                  child: Center(child: Text('어려움')),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) / 6,
                  child: Center(child: Text('지옥')),
                ),
              ],
              isSelected: _difficultySelect,
              onPressed: (index) {
                setState(() {
                  for (int btnIndex = 0; btnIndex < _difficultySelect.length; btnIndex++) {
                    if (btnIndex == index)
                      _difficultySelect[btnIndex] = true;
                    else
                      _difficultySelect[btnIndex] = false;
                  }
                  objectiveResult = null;
                });
              },
              fillColor: Colors.lightBlue,
              selectedColor: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                '목표 시간 입력',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: TextFormField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '목표 시간을 입력',
                  border: inputBorder,
                  focusedBorder: inputBorder,
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return '목표 시간을 입력하세요';
                  }

                  var result = int.tryParse(value);
                  if (result == null || result < 1) {
                    return '자연수를 입력하세요';
                  }

                  if (result > 300) {
                    return '5분 이내에 통과해야합니다';
                  }

                  return null;
                },
              ),
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
                  onPressed: () async {
                    if (_formKey2.currentState.validate()
                      && _difficultySelect.any((sel) => sel)) {
                      var result = calculateScore(int.parse(_timeController.text));

                      setState(() {
                        objectiveResult = result;
                      });

                      return;
                    }

                    if(_difficultySelect.every((sel) => !sel)) {
                      ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('난이도를 선택하세요')));
                    }
                  },
                  child: Text(
                    "계산하기",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            showScore(),
          ],
        ),
      ),
    );
  }
}