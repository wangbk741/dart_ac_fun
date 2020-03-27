import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:async';

/*
 * 封装 restful 请求
 *
 * GET、POST、DELETE、PATCH
 * 主要作用为统一处理相关事务：
 *  - 统一处理请求前缀；
 *  - 统一打印请求信息；
 *  - 统一打印响应信息；
 *  - 统一打印报错信息；
 */
class DioUtils {
  /// global dio object
  static Dio dio;

  /// default options
  static const String API_PREFIX = 'https://novel.dkvirus.com/api/v1';
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 3000;

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  ///Get请求测试
  static void getHttp() async {
    try {
      Response response = await Dio().get("http://www.google.cn");
      print("response$response");
    } catch (e) {
      print(e);
    }
  }

  ///Post请求测试
  static void postHttp<T>(
    String url, {
    parameters,
    Function(T t) onSuccess,
    Function(String error) onError,
  }) async {

    ///定义请求参数
    parameters = parameters ?? {};
    //参数处理
    parameters.forEach((key, value) {
      if (url.indexOf(key) != -1) {
        url = url.replaceAll(':$key', value.toString());
      }
    });

    try {
      Response response;
      Dio dio = createInstance();
      response = await dio.post(url, data: parameters);
      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess(response.data);
        }
      } else {
        throw Exception('statusCode:${response.statusCode}');
      }
      print('响应数据：' + response.toString());
    } catch (e) {
      print('请求出错：' + e.toString());
      onError(e.toString());
    }
  }

  /// request method
  //url 请求链接
  //parameters 请求参数
  //metthod 请求方式
  //onSuccess 成功回调
  //onError 失败回调
  static Future<Map> request<T>(String url,
      {parameters,
      method,
      Function(Map t) onSuccess,
      Function(String error) onError}) async {
    parameters = parameters ?? {};
    method = method ?? 'GET';

    /// 请求处理
    parameters.forEach((key, value) {
      if (url.indexOf(key) != -1) {
        url = url.replaceAll(':$key', value.toString());
      }
    });

    /// 打印:请求地址-请求方式-请求参数
    print('请求地址：【' + method + '  ' + url + '】');
    print('请求参数：' + parameters.toString());

    Dio dio = createInstance();
    //请求结果
    var result;
    Map<String, dynamic> map;
    try {
      Response response = await dio.request(url,
          data: parameters, options: new Options(method: method));
      // result = jsonDecode(response.data);
      // result = new Map< dynamic>.from(response.data);

      map = json.decode(response.data);
      // print(map);
      if (response.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess(map);
        }
      } else {
        throw Exception('statusCode:${response.statusCode}');
      }
      // print('响应数据：' + response.data);
    } on DioError catch (e) {
      print('请求出错：' + e.toString());
      onError(e.toString());
    }

    return map;
  }

  /// 创建 dio 实例对象
  static Dio createInstance() {
    if (dio == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      var options = BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 15000,
        responseType: ResponseType.plain,
        validateStatus: (status) {
          // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
          return true;
        },
        baseUrl: "http://poetry.huhustory.com/",
        headers: {
          'random':'20F86997-DFD5-4B2B-972B-0CD1F94FB5FB',
                'deviceType':'0',
                'market':'appstore',
                'appVersion':'6.0.0.272',
                'resolution':'750x1334',
                'acPlatform':'IPHONE',
                'udid':'21358CB0-D01A-46C8-ACEB-932BF4E653FB',
                'sign':'2155593998ce1f807fc411b343eefe2f50b2d9c474',
                'net':'%E4%B8%AD%E5%9B%BD%E7%A7%BB%E5%8A%A8_5',
                'mod':'iPhone9,1',
                'productId':'2000',
                'Accept':'application/json',
                'Accept-Encoding':'br, gzip, deflate',
                'idfa':'21358CB0-D01A-46C8-ACEB-932BF4E653FB',
                'Content-Type':'application/x-www-form-urlencoded',
                'Content-Length':'0',
        }
      );

      dio = new Dio(options);
    }

    return dio;
  }

  /// 清空 dio 对象
  static clear() {
    dio = null;
  }
}