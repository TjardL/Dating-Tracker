import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linus_dating_life/view/graph_page.dart';

class ListOverviewPage extends StatefulWidget {
  ListOverviewPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListOverviewPageState createState() => _ListOverviewPageState();
}

class _ListOverviewPageState extends State<ListOverviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _counter = 0;

  Map teilnehmer = Map<String, Map<String, String>>();
  final databaseReference = Firestore.instance;
  Future dataFuture;
  DateTime selectedDate = DateTime.now();
  List<String> achievments = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //dataFuture = getData("linus");
  }

  void callback() {
    setState(() {});
  }

  getData(String id) async {
    teilnehmer = {};
    await databaseReference
        .collection('User')
        .document('$id')
        .collection('achievment')
        .document('achievment')
        .get()
        .then((value) => {
              achievments = value.data.keys.toList(),
            });
    await databaseReference
        .collection('User')
        .document('$id')
        .collection('Candidates')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) async {
        //achievments[i],
        Map temp = {};
        for (int i = 0; i < achievments.length; i++) {
          if (f[achievments[i]] != null) {
            temp.putIfAbsent(
                achievments[i], () => DateTime.parse(f[achievments[i]]));
          }
        }

        teilnehmer.putIfAbsent(f.documentID, () => temp);
        print(teilnehmer);
      });
    });
    return teilnehmer;
  }

  @override
  Widget build(BuildContext context) {
    //selectedDate = widget.se;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
           IconButton(
              icon: Icon(Icons.show_chart),
              color: Colors.white,
              onPressed: () {
              Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => GraphPage()),
  );
              }),
          IconButton(
              icon: Icon(Icons.edit),
              color: Colors.white,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(

                          content: Container(
                            width: double.maxFinite,
                            child: Column(
                              
                              children: <Widget>[
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: achievments.length,
                                  itemBuilder: (context, i) {
                                    return ListTile(
                                            title: Text(
                                                achievments[i]),
                                          );
                                        
                                  },
                                ),
                                Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration:
                                          InputDecoration(labelText: "Neue Stufe"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      child: Text("Submit"),
                                      onPressed: () {
                                        //TODO: linus hardgecoded
                                        setState(() {
                                          databaseReference
                                              .collection('User')
                                              .document('linus')
                                              .collection('achievment')
                                              .document(
                                                  'achievment')
                                              .updateData({
                                            '${_nameController.text}': true,
                                          });
                                        });

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                              ],
                            ),
                          ));
                    });
              }),
          IconButton(
              icon: Icon(Icons.add),
              color: Colors.white,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              right: -40.0,
                              top: -40.0,
                              child: InkResponse(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: CircleAvatar(
                                  child: Icon(Icons.close),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration:
                                          InputDecoration(labelText: "Name"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton(
                                      child: Text("Submit"),
                                      onPressed: () {
                                        //TODO: linus hardgecoded
                                        setState(() {
                                          databaseReference
                                              .collection('User')
                                              .document('linus')
                                              .collection('Candidates')
                                              .document(
                                                  '${_nameController.text}')
                                              .setData({
                                            'name': '${_nameController.text}',
                                          });
                                        });

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              })
        ],
      ),
      body: FutureBuilder(
        future: getData("linus"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) {
                String key = snapshot.data.keys.elementAt(i);
                return ExpansionTile(
                  title: new Text(
                    key,
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                  children: <Widget>[
                    new Column(
                      children:
                          _buildExpandableContent(snapshot.data[key], key),
                    ),
                  ],
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  _buildExpandableContent(Map list, String name) {
    List<Widget> columnContent = [];

    for (int i = 0; i < list.length; i++) {
      columnContent.add(
        new ListTile(
          title: new Text(
            list.keys.elementAt(i),
            style: new TextStyle(fontSize: 18.0),
          ),
          leading: Text(
            DateFormat('dd.MM.yyyy').format(list[list.keys.elementAt(i)]),
            style: new TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
    /*
                              columnContent.add(
                                new ListTile(
                                  title: new Text(
                                    "Kuss",
                                    style: new TextStyle(fontSize: 18.0),
                                  ),
                                  leading: teilnehmer.kuss == null
                                      ? Text(
                                          "kek",
                                          style: new TextStyle(fontSize: 18.0),
                                        )
                                      : Text(
                                          DateFormat('dd.MM.yyyy').format(teilnehmer.kuss),
                                          style: new TextStyle(fontSize: 18.0),
                                        ),
                                ),
                              );
                          */
    print(name);
    print("${selectedDate.toLocal()}".split(' ')[0]);
    columnContent.add(
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: InkResponse(
          onTap: () {
            showDialog(
                context: context,
                child: new DialogCreateAction(
                  onValueChange: _onValueChange,
                  initialValue: selectedDate,
                  name: name,
                  achievment: this.achievments,
                  callbackfunc: callback,
                ));
          },
          child: CircleAvatar(
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );

    return columnContent;
  }

  void _onValueChange(DateTime value) {
    setState(() {
      selectedDate = value;
    });
  }

  _buildAchievments() {
    List<Widget> list = [];
    for (int i = 0; i < achievments.length; i++) {
      list.add(ListTile(
        title: Text(achievments[i]),
      ));
    }
    return list;
  }
/*
  List<Teilnehmer> teilnehmer = [
    Teilnehmer("Lena", DateTime(2020, 10, 20), null, null, null),
    Teilnehmer("Maja", DateTime(2020, 10, 20), DateTime(2020, 10, 22),
        DateTime(2020, 10, 27), null),
    Teilnehmer("Franck Ribery", null, DateTime(2020, 10, 28),
        DateTime(2020, 10, 30), DateTime(2000, 01, 01)),
  ];
  */
}

class DialogCreateAction extends StatefulWidget {
  const DialogCreateAction(
      {this.onValueChange,
      this.initialValue,
      this.name,
      this.achievment,
      this.callbackfunc});
  final name;
  final DateTime initialValue;
  final void Function(DateTime) onValueChange;
  final List<String> achievment;
  final VoidCallback callbackfunc;

  @override
  State createState() => new DialogCreateActionState();
}

class DialogCreateActionState extends State<DialogCreateAction> {
  DateTime _selectedDate;
  final databaseReference = Firestore.instance;

  var pickerData;

  var aktionsname = "Wähle Ereignis";
  @override
  void initState() {
    super.initState();
    widget.achievment.forEach((element) {
      element = "'" + element + "'";
    });

    var joined = widget.achievment.map((part) => "\"$part\"");
    pickerData = '[${joined.toList()}]';

    _selectedDate = widget.initialValue;
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      width: 100,
                      child: RaisedButton(
                        onPressed: () {
                          showPickerArray(context);
                        },
                        child: Text("$aktionsname"),
                      ),
                    ),
                  ),
                  Text(
                    "${_selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        _selectDate(context);
                      }),

                  //DATEPCIKER
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text("Submit"),
                  onPressed: () {
                    //TODO: linus hardgecoded
                    widget.callbackfunc();
                    databaseReference
                        .collection('User')
                        .document('linus')
                        .collection('Candidates')
                        .document('${widget.name}')
                        .setData({
                      '$aktionsname': '${_selectedDate}',
                    }, merge: true).then((value) => widget.callbackfunc());

                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  showPickerArray(BuildContext context) {
    new Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: new JsonDecoder().convert(pickerData), isArray: true),
        hideHeader: true,
        title: new Text("Please Select"),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
          setState(() {
            aktionsname = picker.getSelectedValues()[0];
          });
        }).showDialog(context);
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        print(_selectedDate);
      });
  }
}
