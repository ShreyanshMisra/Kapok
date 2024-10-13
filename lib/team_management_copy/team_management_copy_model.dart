import '/components/hamburger_menu_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'team_management_copy_widget.dart' show TeamManagementCopyWidget;
import 'package:flutter/material.dart';

class TeamManagementCopyModel
    extends FlutterFlowModel<TeamManagementCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for hamburgerMenu component.
  late HamburgerMenuModel hamburgerMenuModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    hamburgerMenuModel = createModel(context, () => HamburgerMenuModel());
  }

  @override
  void dispose() {
    hamburgerMenuModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
