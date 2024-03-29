import 'package:flutter/material.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/widgets/fade_slide_transition.dart';

class SelectSlotOnboardPage extends StatefulWidget {
  SelectSlotOnboardPage({Key? key}) : super(key: key);

  @override
  State<SelectSlotOnboardPage> createState() => _SelectSlotOnboardPageState();
}

class _SelectSlotOnboardPageState extends State<SelectSlotOnboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Duration kLoginAnimationDuration = Duration(milliseconds: 500);

  late final Animation<double> _formElementAnimation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kLoginAnimationDuration,
    );
    final fadeSlideTween = Tween<double>(begin: 0.0, end: 1.0);
    _formElementAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.7,
        1.0,
        curve: Curves.easeInOut,
      ),
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideTransition(
        animation: _formElementAnimation,
        additionalOffset: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SizeConfig.kverticalMargin32,
            Flexible(
              child: Image.asset(
                'assets/images/onboarding/slot/dates.png',
                scale: 2,
              ),
            ),
            Flexible(
              child: Image.asset(
                'assets/images/onboarding/slot/slots.png',
                scale: 2,
              ),
            ),
          ],
        ));
  }
}
