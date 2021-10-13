import 'package:flutter/material.dart';

import 'calendar.dart';

class CalendarView extends StatelessWidget {
  CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[for (var i = 0; i <= 24; i++) SizedOverflowBox(
          size: Size(50, 0),
          alignment: Alignment(1, 0),
          child: Text(TimeOfDay(hour: i, minute: 0).format(context))
        )],
      ),
      Expanded(child: CalendarSelect()),
    ]);
  }
}

class CalendarSelect extends StatelessWidget {
  CalendarSelect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TimeOfDay getTime(Offset global) {
      RenderBox self = context.findRenderObject() as RenderBox;
      double height = self.globalToLocal(global).dy;

      int mins = height * (60*24) ~/ self.size.height;
      mins = mins < 0 ? 0 : (mins > 1439 ? 1439 : mins);
      return TimeOfDay(hour: (mins / 60).floor(), minute: mins % 60);
    }

    return LayoutBuilder(builder: (context, constraints) {
      Widget position(double pos, Widget child) {
        return Transform.translate(
          offset: Offset(0, constraints.biggest.height * pos - 100/2),
          child: SizedOverflowBox(
            size: Size(constraints.biggest.width, 100),
            alignment: Alignment(-1, 0),
            child: child
          )
        );
      }
      return Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[for (var i = 0; i <= 24; i++) SizedOverflowBox(
              size: Size(constraints.biggest.width, 0),
              child: Divider(indent: 5, endIndent: 30),
            )],
          ),
          CalendarTransition(activity: "foo", getTime: getTime, position: position),
        ],
      );
    });
  }
}

class CalendarTransition extends StatefulWidget {
  CalendarTransition({Key? key, required this.activity, required this.getTime, required this.position}): super(key: key);

  final Function getTime;
  final Function position;
  final String activity;

  @override
  State<CalendarTransition> createState() => _CalendarTransitionState();
}

class _CalendarTransitionState extends State<CalendarTransition> {
  TimeOfDay time = TimeOfDay(hour: 12, minute: 0);

  @override
  Widget build(BuildContext context) {
    double pos = (time.hour * 60 + time.minute) / (60*24);
    return widget.position(pos, Row(children: <Widget>[
      Expanded(child: Divider(color: Colors.white)),
      Draggable(
        child: RotatedBox(
          quarterTurns: 1,
          child: Icon(Icons.location_pin, color: Colors.blue, size: 30.0),
        ),
        axis: Axis.vertical,
        feedback: Container(width: 1),
        onDragUpdate: (details) {
          setState(() { time = widget.getTime(details.globalPosition); });
        }
      ),
    ]));
  }
}
