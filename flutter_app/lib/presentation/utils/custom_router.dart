import 'package:flutter/material.dart';

final routerKey = GlobalKey<NavigatorState>();

void pushNamed(String routeName, {Object? arguments}) {
  routerKey.currentState!.pushNamed(routeName, arguments: arguments);
}

void pop() {
  routerKey.currentState!.pop();
}
