import 'package:flutter/material.dart';
import 'package:foster_logger/pages/add-urination.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:foster_logger/store/index.dart';
import 'dart:convert';

class AddDevelopment extends StatefulWidget {
  @override
  _AddDevelopment createState() => new _AddDevelopment();
}

class _AddDevelopment extends State<AddDevelopment> {
  AppState state;
  String error = '';
  bool status = false;

  TextEditingController date;
  TextEditingController response = new TextEditingController();

  void initState() {
    super.initState();
    state = Provider.of<AppState>(context, listen: false);
    date = new TextEditingController(text: state.formatDate(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        title: new Text('DEVELOPMENT ' + state.foster['name']),
        backgroundColor: Colors.purpleAccent,
      ),
      body: new SafeArea(
          child: new SingleChildScrollView(
        child: new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: EdgeInsets.only(top: 10),
                child: new GestureDetector(
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.all(18),
                      labelStyle: new TextStyle(color: Colors.grey),
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.date_range,
                          color: Colors.grey.withOpacity(0.7)),
                      enabledBorder: new OutlineInputBorder(
                        borderSide:
                            new BorderSide(color: Colors.grey.withOpacity(0.4)),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderSide:
                            new BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    style: new TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    controller: date,
                    readOnly: true,
                    onTap: () {
                      showDate();
                    },
                  ),
                ),
              ),
              new Container(
                margin: EdgeInsets.only(top: 10),
                child: new TextFormField(
                  maxLines: 5,
                  decoration: new InputDecoration(
                      enabledBorder: new OutlineInputBorder(
                          borderSide: new BorderSide(
                              color: Colors.grey.withOpacity(0.4))),
                      focusedBorder: new OutlineInputBorder(
                          borderSide: new BorderSide(
                        color: Colors.grey.withOpacity(0.4),
                      )),
                      labelText: 'Add a note ',
                      labelStyle:
                          new TextStyle(color: Colors.grey, fontSize: 15),
                      alignLabelWithHint: true),
                  controller: response,
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20),
                child: new MaterialButton(
                  onPressed: () {
                    submit();
                  },
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  color: Colors.purpleAccent,
                  shape: StadiumBorder(),
                  child: status
                      ? new CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                          strokeWidth: 2)
                      : new Text('SUBMIT',
                          style: new TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  void showDate() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(1900, 1, 1),
        maxTime: DateTime(new DateTime.now().year, 12, 31), onConfirm: (date) {
      this.date.text = state.formatDate(date);
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  void submit() {
    setState(() {
      status = true;
    });

    state.postAuth(
        context, 'create-foster-development/' + state.foster['id'].toString(), {
      'date': date.text,
      'note': response.text,
    }).then((data) {
      var body = jsonDecode(data.body);
//      print(body);
      if (data.statusCode == 200 && body['status']) {
        state.notifyToastSuccess(
            context: context,
            message: 'Development notes was updated successful');
        Navigator.pop(context);
      } else if (data.statusCode != 422) {
        state.notifyToastDanger(
            context: context, message: "Error occured while creating account");
      }
      setState(() {
        status = false;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        status = false;
      });
    });
  }
}
