import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double result;

  int percent = 0;
  double num = 0;
  List<TimeData> class_zero = <TimeData>[];

  List<TimeData> class_one = <TimeData>[];
  int curclass=0;
  int conecount=0;
  int c2count = 0;




  var options = ["Class 1","Class 2"] ;
  bool timed = false;

  void changePercent(double a) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      if (a<.5){
        curclass=0;
        c2count++;
      }
      else {
        curclass = 1;
        conecount++;
      }
      percent =(a*255).toInt();

      chartRangeSeries.add(new _ChartData(class_one.length.toString(), a, 1-a));
      num = a*100;
    });
  }

  Future<void>  addData (int a) async {
    double f = await fetchAPIResult(a.toString());
    changePercent(f);
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      class_zero.add(TimeData(a,(f)));
      class_one.add(TimeData(a,(1-f)));
    });
  }

  void startDataFlow() {
    timed=!timed;
    if(timed)
    new Timer.periodic(Duration(milliseconds: 250), (Timer t) {
      if(!timed)
        t.cancel();
      addData(class_one.length);
      print("hi");
    });
  }

  List<PieSeries<_PieData, String>> getPieSeries() {
    final List<_PieData> pieData = <_PieData>[
      _PieData('Class1', conecount, 'Class 1 '),
      _PieData('Class2', c2count, 'Class 2'),
    ];
    return <PieSeries<_PieData, String>>[
      PieSeries<_PieData, String>(
          explode: true,
          explodeIndex: 0,
          explodeOffset: '10%',
          dataSource: pieData,
          xValueMapper: (_PieData data, _) => data.xData,
          yValueMapper: (_PieData data, _) => data.yData,
          dataLabelMapper: (_PieData data, _) => data.text,
          startAngle: 90,
          endAngle: 90,
          dataLabelSettings: DataLabelSettings(isVisible: true)),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(
                children: <Widget>[
                  new SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(percent,200, 5, 5)
                      ),
                      padding: const EdgeInsets.all(10),
                      child: new Text(
                          options[curclass]+'       '+'$num',
                          style: Theme.of(context).textTheme.display1,
                      ),
                    ),
                  ),
                  new SizedBox(
                    width: double.infinity,
                    height: 100,
                    child:Container(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(percent,200, 5, 5)
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                      new RaisedButton(
                        child:Text('Fast'),
                      onPressed: (){
                        //debugPrint(fetchAPIResult().toString());
                        startDataFlow();
                        print("TAPPED");
                         },
                      ), new RaisedButton(
                            child:Text('Next'),
                            onPressed: (){
                              //debugPrint(fetchAPIResult().toString());
                              addData(class_one.length);
                              print("TAPPED");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Column(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        height:300,
                        child: SfCartesianChart(
                            title: ChartTitle(
                                text: 'Surf vs Down Probs '),
                          // Initialize category axis
                            primaryXAxis: CategoryAxis(),

                            series: <LineSeries<TimeData, String>>[
                              LineSeries<TimeData, String>(
                                // Bind data source
                                  dataSource:  class_zero,
                                  xValueMapper: (TimeData time, _) => time.seconds.toString(),
                                  yValueMapper: (TimeData time, _) => time.time
                              ),
                              LineSeries<TimeData, String>(
                                // Bind data source
                                  dataSource:  class_one,
                                  xValueMapper: (TimeData time, _) => time.seconds.toString(),
                                  yValueMapper: (TimeData time, _) => time.time
                              )
                            ]
                        ),
                      ),
                      SizedBox(
                        child: SfCircularChart(
                          title: ChartTitle(text: 'Surf vs Down Occur'),
                          legend: Legend(isVisible: true),
                          series: getPieSeries(),
                        ),
                        width: double.infinity,
                        height: 300,
                      ),
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          title: ChartTitle(
                              text: 'Surf/Down Difference'),
                          primaryXAxis: CategoryAxis(
                            majorGridLines: MajorGridLines(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                              axisLine: AxisLine(width: 0),
                              interval: 2,
                              labelFormat: '{value}',
                              majorTickLines: MajorTickLines(size: 0)),
                          series: getRangeColumnSeries(),
                          tooltipBehavior:
                          TooltipBehavior(enable: true, header: '', canShowMarker: false),
                        ),
                      )



                    ],
                  )
                ],
            )
        )
    );
  }

}

List<_ChartData> chartRangeSeries= <_ChartData>[];


List<RangeColumnSeries<_ChartData, String>> getRangeColumnSeries() {
  final List<_ChartData> chartData = chartRangeSeries ;
  return <RangeColumnSeries<_ChartData, String>>[
    RangeColumnSeries<_ChartData, String>(
      enableTooltip: true,
      dataSource: chartData,
      xValueMapper: (_ChartData sales, _) => sales.x,
      lowValueMapper: (_ChartData sales, _) => sales.low,
      highValueMapper: (_ChartData sales, _) => sales.high,
      dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.top,
          textStyle: ChartTextStyle(fontSize: 10)),
    )
  ];
}

class _ChartData {
  _ChartData(this.x, this.low, this.high);
  final String x;
  final double low;
  final double high;
}


class _PieData {
  _PieData(this.xData, this.yData, [this.text]);
  final String xData;
  final num yData;
  final String text;
}

Future<double> fetchAPIResult(String num) async {

  var uri =  new Uri.https("conocochallengetamu.appspot.com", "api/",{"model_input":num});
  var response = await http.get(
    uri,
  );
  final responseJson = json.decode(response.body);
  print(responseJson['result']);

  return responseJson['result'];
}

class APIResult {
  final double result;

  APIResult({this.result});

  factory APIResult.fromJson(Map<String, dynamic> json) {
    return APIResult(
      result: json['result'],
    );
  }

  double getResult(){
    return result;
  }

  @override
  String toString() {
    // TODO: implement toString
    return result.toString();
  }
}


class TimeData {
  TimeData(this.seconds, this.time);
  final int seconds;
  final double time;
}