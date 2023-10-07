import 'package:flutter/material.dart';
import 'package:studyingx/routes/routes.dart';

// default push transition
void push(BuildContext context, String routeName) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return routes[routeName]!(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      var opacityAnimation = animation.drive(Tween(begin: 0.5, end: 1.0));
      return SlideTransition(
        position: offsetAnimation,
        child: Opacity(opacity: opacityAnimation.value, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  ));
}
