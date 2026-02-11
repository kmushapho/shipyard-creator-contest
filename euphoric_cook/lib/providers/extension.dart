import 'package:pocketbase/pocketbase.dart';

extension AuthRecordHelpers on RecordModel {
  String get email => getStringValue('email');
  bool get isVerified => getBoolValue('verified');
}