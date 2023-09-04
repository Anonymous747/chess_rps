import 'package:flutter/material.dart';

final routerKey = GlobalKey<NavigatorState>();

void pushNamed(String routeName) {
  routerKey.currentState!.pushNamed(routeName);
}

void pop() {
  routerKey.currentState!.pop();
}
