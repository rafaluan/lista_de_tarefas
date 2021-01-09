import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  List _toDoList = [];
  List _toDoList2 = [];
  List _toDoList3 = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  int _currentIndex = 0;
  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
    _readData("0").then((data) {
      setState(
        () {
          _toDoList = json.decode(data);
        },
      );
    });
    _readData("1").then((data1) {
      setState(
        () {
          _toDoList2 = json.decode(data1);
        },
      );
    });
    _readData("2").then((data2) {
      setState(
        () {
          _toDoList3 = json.decode(data2);
        },
      );
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      if (_currentIndex == 0) {
        _toDoList.add(newToDo);
        _saveData(_toDoList);
      }
      if (_currentIndex == 1) {
        _toDoList2.add(newToDo);
        _saveData(_toDoList2);
      }
      if (_currentIndex == 2) {
        _toDoList3.add(newToDo);
        _saveData(_toDoList3);
      }
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    List lista;
    if (_currentIndex == 0) lista = _toDoList;
    if (_currentIndex == 1) lista = _toDoList2;
    if (_currentIndex == 2) lista = _toDoList3;
    setState(() {
      lista.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData(lista);
    });

    return null;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List lista;
    if (_currentIndex == 0) lista = _toDoList;
    if (_currentIndex == 1) lista = _toDoList2;
    if (_currentIndex == 2) lista = _toDoList3;
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _toDoController,
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                )),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: lista.length,
                  itemBuilder: buildItem),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.school),
            title: Text('Acadêmicas'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.sports_esports),
            title: new Text('Lazer'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), title: new Text('Saúde'))
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    List lista;
    if (_currentIndex == 0) lista = _toDoList;
    if (_currentIndex == 1) lista = _toDoList2;
    if (_currentIndex == 2) lista = _toDoList3;
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(lista[index]["title"]),
        value: lista[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(lista[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            lista[index]["ok"] = c;
            _saveData(lista);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(lista[index]);
          _lastRemovedPos = index;
          lista.removeAt(index);

          _saveData(lista);

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    lista.insert(_lastRemovedPos, _lastRemoved);
                    _saveData(lista);
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile(String a) async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data$a.json");
  }

  Future<File> _saveData(List a) async {
    String b;
    String data = json.encode(a);
    if (a == _toDoList) {
      b = "0";
    } else if (a == _toDoList2) {
      b = "1";
    } else if (a == _toDoList3) {
      b = "2";
    }
    final file = await _getFile(b);
    return file.writeAsString(data);
  }

  Future<String> _readData(String a) async {
    try {
      final file = await _getFile(a);

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
