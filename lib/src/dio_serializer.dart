

import 'package:dio/dio.dart';

abstract class DioSerializer {
  dynamic convertRequest(RequestOptions options);
  ReturnType convertResponse<ReturnType,SingleItemType>(Response response);
}
