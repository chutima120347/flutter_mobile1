import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Stack(
        children: [
          Container(
            width: 120, 
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(20)),
            ), 
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 80, 
              height: 80,
              decoration: 
                  BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              ),
          ),
          Positioned(
            top: 110,
            left: 20,
            child: Container(
              width: 80, 
              height: 80,
              decoration: 
                  BoxDecoration(shape: BoxShape.circle, color: Colors.yellow),
              ),
          ),
          Positioned(
            top: 200,
            left: 20,
            child: Container(
              width: 80, 
              height: 80,
              decoration: 
                  BoxDecoration(shape: BoxShape.circle, color: Colors.green),
              ),),
        ],
        ))); 
  }
}