import '/flutter_flow/flutter_flow_util.dart';
import 'teams_widget.dart' show TeamsWidget;
import 'package:flutter/material.dart';

class TeamsModel extends FlutterFlowModel<TeamsWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TeamName widget.
  FocusNode? teamNameFocusNode;
  TextEditingController? teamNameController;
  String? Function(BuildContext, String?)? teamNameControllerValidator;
  // State field(s) for Location widget.
  FocusNode? locationFocusNode;
  TextEditingController? locationController;
  String? Function(BuildContext, String?)? locationControllerValidator;
  // State field(s) for Enter_TeamNum widget.
  FocusNode? enterTeamNumFocusNode;
  TextEditingController? enterTeamNumController;
  String? Function(BuildContext, String?)? enterTeamNumControllerValidator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    teamNameFocusNode?.dispose();
    teamNameController?.dispose();

    locationFocusNode?.dispose();
    locationController?.dispose();

    enterTeamNumFocusNode?.dispose();
    enterTeamNumController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
