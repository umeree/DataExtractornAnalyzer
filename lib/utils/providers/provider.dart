import 'package:dataextractor_analyzer/view-model/edit-text-view-model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => EditTextViewModel()),
];