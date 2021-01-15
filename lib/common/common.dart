import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget manualLinkButton() {
  return FloatingActionButton(
    onPressed: _launchManual,
    tooltip: '설명서 링크',
    child: Icon(Icons.description),
  );
}

_launchManual() async {
  const url = 'https://github.com/Abalcon/gcg-expected-damage/blob/master/README.md';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw '현재 설명서를 열 수 없습니다. 나중에 다시 시도해주세요';
  }
}