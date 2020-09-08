import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/manager/list_companies.dart';
import 'package:g2r_market/services/manager.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';

// ignore: must_be_immutable
class CompanyCreatePage extends StatefulWidget{
  

  final double padding = 10;
  final auth;

  CompanyCreatePage({
    @required this.auth,
    Key key
  }) : super(key: key);

  @override
  _CompanyCreatePageState createState() => _CompanyCreatePageState();
}

class _CompanyCreatePageState extends State<CompanyCreatePage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
      
  @override
  Widget build(BuildContext context) {

    return __content(context);
  }

  __content(context)
  {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height * .25,
            decoration: BoxDecoration(
              color: Color.fromRGBO(247,247,247, 100)
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height:20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Icon(Icons.arrow_back_ios),
                        onTap: () => Navigator.pop(context, true),
                      ),
                      Center()
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        Form(
                          key: _formKey,
                          child: __accountEdit(context),
                        )
                      ]
                    )
                  )
                ],
              ),
            )
          ),
        ]
      ),
    );
  }

  Widget __accountEdit(context)
  {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Информация о компании', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Название компании',
          placeholder: companyNameController.text,
          controller: companyNameController,
          type: TextInputType.text,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          },  
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'E-mail',
          placeholder: emailController.text,
          controller: emailController,
          type: TextInputType.emailAddress,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          }
        ),
        SizedBox(height: widget.padding),
        Center(
          child: CustomRaisedButton(
            onPressed: () async => await createCompany(context),
            color: Colors.white,
            child: Text('Сохранить'),
          )
        )
      ]
    );
  }

  Future createCompany(context) async
  {
    if (_formKey.currentState.validate())
    {

      Map<String, String> _data = {};

      _data = {
        'name': companyNameController.text.toString(),
        'email': emailController.text.toString(),
      };

      var result = await Manager.createCompany(widget.auth, _data);

      if(result == true)
      {
        Navigator.pushReplacement(context, AnimatedScaleRoute(
          builder: (context) => CompanyListPage(
              auth: widget.auth,
            )
          )
        );
      }
    }
  }
}