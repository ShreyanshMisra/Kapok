import '/components/task_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'new_task_widget.dart' show NewTaskWidget;
import 'package:flutter/material.dart';

class NewTaskModel extends FlutterFlowModel<NewTaskWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for task component.
  late TaskModel taskModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    taskModel = createModel(context, () => TaskModel());
  }

  @override
  void dispose() {
    taskModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
