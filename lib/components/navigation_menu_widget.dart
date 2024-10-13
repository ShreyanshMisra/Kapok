import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_menu_model.dart';
export 'navigation_menu_model.dart';

class NavigationMenuWidget extends StatefulWidget {
  const NavigationMenuWidget({super.key});

  @override
  State<NavigationMenuWidget> createState() => _NavigationMenuWidgetState();
}

class _NavigationMenuWidgetState extends State<NavigationMenuWidget> {
  late NavigationMenuModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavigationMenuModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container();
  }
}
