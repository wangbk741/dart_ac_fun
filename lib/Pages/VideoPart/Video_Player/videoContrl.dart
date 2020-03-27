import 'dart:async';
import 'package:ac_fun/Pages/VideoPart/Video_Player/video_player_full.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

class ControlView extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback moveEnd;
  final VoidCallback moveStart;
  final ValueChanged<String> changedPlayUrl;
  final bool isFull;
  final List streams;
  const ControlView({Key key, @required this.controller,@required this.moveEnd,@required this.moveStart,@required this.isFull,@required this.streams, this.changedPlayUrl}) : super(key: key);
  @override
  _ControlViewState createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  double progressValue; //进度
  String labelProgress; //tip内容
  bool isPlayDone = false;
  Timer timer;
  
  @override
  initState() {
    progressValue = 0.0; //进度
    labelProgress = '00:00'; //tip内容
    widget.controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    pauseTimer();
    super.dispose();
  }
  void handleEnd(){
    // 延时1s执行返回
      widget.moveEnd();
  }
  void handleStart(){
    widget.moveStart();
  }
  void startTimer(){
    const period = const Duration(seconds: 1);
    timer = Timer.periodic(period, (timer) {
      int position = widget.controller.value.position.inMilliseconds;
      int duration = widget.controller.value.duration.inMilliseconds;
      //Buffering缓冲 
      // print("1"+widget.controller.value.isPlaying.toString());
      // print('2'+widget.controller.value.isBuffering.toString());
      // print('3'+widget.controller.value.isLooping.toString());
      if (position >= duration) {
       //播放结束
        pauseTimer();
        _onChanged(0.0);
        isPlayDone = true;
        widget.controller.pause();
        handleEnd();
        return;
      }
      setState(() {
        progressValue = position / duration * 100;
        labelProgress = DateUtil.formatDateMs(
          position.toInt(),
          format: 'mm:ss',
        );
      });
    });
  }
  void pauseTimer(){
    if (timer!=null) {
      timer.cancel();
      timer = null;
    }
  }
  @override
  void didUpdateWidget(ControlView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerLeft,
            child: FlatButton(
                onPressed: () {
                  handleEnd();
                  setState(() {
                      widget.controller.value.isPlaying
                        ? widget.controller.pause()
                        : widget.controller.play();
                  });
                  if (widget.controller.value.isPlaying) {
                    startTimer();
                  }else{
                    pauseTimer();
                  }
                },
                color: Colors.transparent,
                child: isPlayDone?Icon(Icons.replay)
                      :Icon(
                        widget.controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      )
                )
        )),
        Expanded(
          flex: 6,
            child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                      child: Text(
                        '$labelProgress'+'/'+DateUtil.formatDateMs(
                        widget.controller.value.duration.inMilliseconds.toInt(),
                        format: 'mm:ss',
                      ),style: TextStyle(fontSize: 8),textAlign: TextAlign.right,),
                    )),
                    Expanded(
                      flex: 4,
                      child: Slider(
                      value: progressValue,
                      // label: labelProgress,
                      divisions: 100,
                      onChangeStart: _onChangeStart,
                      onChangeEnd: _onChangeEnd,
                      onChanged: _onChanged,
                      min: 0,
                      max: 100,
                    ))
                  ],
                )
            )
        ),
        Container(child: widget.isFull?Expanded(
          flex: 1,
          child:Container(
            child: ShowMenu(streams: widget.streams, onCanceled: () {
              print('onCanceled');
              widget.moveEnd();
            }, onSelected: (String value) {
              int index = int.parse(value);
              // print(index);
              widget.changedPlayUrl(widget.streams[index]["playUrls"][0]);
            }, touchStart: () {
              widget.moveStart();
            }, )
            ),
        ):Container(child: Text(widget.streams[0]["qualityLabel"]))),
        Expanded(
          flex: 1,
          child: Container(
            child: FlatButton(
            onPressed: () {
              // handle = false;
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return VideoFullPage(widget.controller,widget.streams);
              }));
          },
          child: Icon(Icons.fullscreen,color: Colors.white,),
        )))
      ],
    );
  }

  void _onChangeEnd(_) {
    // 关闭手动操作标识
    // handle = false;
    handleEnd();
    // 跳转到滑动时间
    int duration = widget.controller.value.duration.inMilliseconds;
    widget.controller.seekTo(
      Duration(milliseconds: (progressValue / 100 * duration).toInt()),
    );
  }

  void _onChangeStart(_) {
    // 开始手动操作标识
    // handle = true;
    handleStart();
  }

  void _onChanged(double value) {
    int duration = widget.controller.value.duration.inMilliseconds;
    setState(() {
      progressValue = value;
      labelProgress = DateUtil.formatDateMs(
        (value / 100 * duration).toInt(),
        format: 'mm:ss',
      );
    });
  }
}

class ShowMenu extends StatefulWidget {
  final List streams;
  final ValueChanged<String> onSelected;
  final VoidCallback onCanceled;
  final VoidCallback touchStart;
  const ShowMenu({Key key,@required this.streams,@required this.onSelected,@required this.onCanceled,@required this.touchStart}) : super(key: key);
  @override
  _ShowMenuState createState() => _ShowMenuState();
}

class _ShowMenuState extends State<ShowMenu> {
  int defIndex = 0;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
              child: Text(widget.streams[defIndex]["qualityLabel"]),
              onPressed:(){ 
                widget.touchStart();
                final RenderBox button = context.findRenderObject();
                // print(button.size);

                final RenderBox overlay = Overlay.of(context).context.findRenderObject();
                // print(overlay.size);
    
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero),
                        ancestor: overlay),
                ),
                Offset.zero & overlay.size,
              );
                showMenu(context: context, position: position, 
                items: _createPopupMenuItem(widget.streams)
                ).then<void>((newValue) {
                  if (!mounted)
                    return null;
                  if (newValue == null) {
                    if (widget.onCanceled != null)
                      widget.onCanceled();
                    return null;
                  }
                  if (widget.onSelected != null)
                    setState(() {
                      defIndex = int.parse(newValue);
                    });
                    widget.onSelected(newValue);
                });
              }
          );
  }
   List<PopupMenuItem<String>> _createPopupMenuItem(List arr){
    List <PopupMenuItem<String>> list = [];
    for (var i = arr.length-1; i >=0; i--) {
      list.add(
        PopupMenuItem(value: i.toString(), 
        child: Text(arr[i]["qualityLabel"]),
      ));
    }
    return list;
  }
}