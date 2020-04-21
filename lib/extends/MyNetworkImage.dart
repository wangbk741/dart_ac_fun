// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui show Codec;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//  class NetworkImage extends ImageProvider<NetworkImage> {
//   /// Creates an object that fetches the image at the given URL.
//   ///
//   /// The arguments [url] and [scale] must not be null.
//   const NetworkImage(String url, { double scale, Map<String, String> headers })
//     :assert(url!=null),
//     assert(scale!=null);

//   /// The URL from which the image will be fetched.
//   String get url;

//   /// The scale to place in the [ImageInfo] object of the image.
//   double get scale;


//   Map<String, String> get headers;

//   @override
//   ImageStreamCompleter load(NetworkImage key, DecoderCallback decode);
// }


// class FileImage extends ImageProvider<FileImage> {

//   const FileImage(this.file, this.sdCache, { this.scale = 1.0 })
//     : assert(file != null),
//       assert(scale != null);

//   /// The file to decode into an image.
//   final File file;

//   /// The scale to place in the [ImageInfo] object of the image.
//   final double scale;
//   //是否需要缓存到sd卡
//   final bool sdCache;

//   @override
//   Future<FileImage> obtainKey(ImageConfiguration configuration) {
//     return SynchronousFuture<FileImage>(this);
//   }

//   @override
//   ImageStreamCompleter load(NetworkImage key, DecoderCallback decode) {
//     return MultiFrameImageStreamCompleter(
//       ////这个就是主要的图片网络加载方法
//       codec: _loadAsync(key),
//       scale: key.scale,
//       informationCollector: () sync* {
//         yield ErrorDescription('Path: ${file?.path}');
//       },
//     );
//   }

//   Future<ui.Codec> _loadAsync(NetworkImage key) async {
//     assert(key == this);

// /// 新增代码块start
// /// 从缓存目录中查找图片是否存在
//     final Uint8List cacheBytes = await _cacheFileImage.getFileBytes(key.url);
//     if(cacheBytes != null) {
//       return PaintingBinding.instance.instantiateImageCodec(cacheBytes);
//     }
// /// 新增代码块end

//     final Uri resolved = Uri.base.resolve(key.url);
//     final HttpClientRequest request = await _httpClient.getUrl(resolved);
//     headers?.forEach((String name, String value) {
//       request.headers.add(name, value);
//     });
//     final HttpClientResponse response = await request.close();
//     if (response.statusCode != HttpStatus.ok)
//       throw Exception('HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

// /// 新增代码块start
// /// 将下载的图片数据保存到指定缓存文件中
//     await _cacheFileImage.saveBytesToFile(key.url, bytes);
// /// 新增代码块end

//     return PaintingBinding.instance.instantiateImageCodec(bytes);
//   }


//   @override
//   bool operator ==(dynamic other) {
//     if (other.runtimeType != runtimeType)
//       return false;
//     final FileImage typedOther = other;
//     return file?.path == typedOther.file?.path
//         && scale == typedOther.scale;
//   }

//   @override
//   int get hashCode => hashValues(file?.path, scale);

//   @override
//   String toString() => '$runtimeType("${file?.path}", scale: $scale)';


// }