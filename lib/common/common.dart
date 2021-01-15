import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

OutlineInputBorder inputBorder = new OutlineInputBorder(
  borderRadius: const BorderRadius.all(
    const Radius.circular(0.0),
  ),
  borderSide: new BorderSide(
    color: Colors.black,
    width: 1.0,
  ),
);

Widget manualLinkButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () => _launchManual(context),
    tooltip: '설명서 링크',
    child: Icon(Icons.description),
  );
}

_launchManual(BuildContext context) async {
  const url = 'https://github.com/Abalcon/gcg-expected-damage/blob/master/README.md';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('현재 설명서를 열 수 없습니다. 나중에 다시 시도해주세요')));
  }
}