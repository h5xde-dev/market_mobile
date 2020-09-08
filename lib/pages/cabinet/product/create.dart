import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/extesions/color.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/cabinet/product/list.dart';
import 'package:g2r_market/services/categories.dart';
import 'package:g2r_market/services/product.dart';
import 'package:g2r_market/widgets/custom__file_picker.dart';
import 'package:g2r_market/widgets/custom__multiple_file_picker.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:g2r_market/widgets/search_bar.dart';

// ignore: must_be_immutable
class ProductCreatePage extends StatefulWidget{
  

  final double padding = 10;
  final int profileId;
  final auth;

  ProductCreatePage({
    @required this.profileId,
    @required this.auth,
    Key key
  }) : super(key: key);

  @override
  _ProductCreatePageState createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController articulController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final TextEditingController availableValueController = TextEditingController();
  final TextEditingController minOrderValueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController seoKeywordsController = TextEditingController();
  final TextEditingController seoTitleController = TextEditingController();
  final TextEditingController seoDescriptionsController = TextEditingController();
  final TextEditingController weightValueController = TextEditingController();
  final TextEditingController widthValueController = TextEditingController();
  final TextEditingController heightValueController = TextEditingController();
  final TextEditingController lenghtValueController = TextEditingController();
  final TextEditingController sizeTypeController = TextEditingController();


  String countryProduct;

  Map selectedCategory;
  Map colorProduct = {'transparent': 'Не выбран'};
  Map weightType = {'gr': 'грамм'};
  Map sizeType = {'mm': 'мм'};
  Map minOrderType = {'pcs': 'шт'};
  Map availableType = {'pcs': 'шт'};

  File previewImage;
  List<FileImage> detailImages = [];
  List<FileImage> describleImages = [];

  Map<String, String> availableColors = {
    'transparent': 'не выбран',
    "#000000": 'Черный',
    "#808080": 'Серый',
    "#C0C0C0": 'Серебрянный',
    "#FFFFFF": 'Белый',
    "#FF00FF": 'Розовый',
    "#800080": 'Лиловый',
    "#FF0000": 'Красный',
    "#800000": 'Коричневый',
    "#FFFF00": 'Жёлтый',
    "#808000": 'Оливковый',
    "#00FF00": 'Лимонный',
    "#008000": 'Зеленый',
    "#00FFFF": 'Голубой',
    "#008080": 'Бирюзовый',
    "#0000FF": 'Синий',
    "#000080": 'Морской',
  };

  List<DropdownMenuItem> colors = [];
  List categoryList = [];

  bool _loaded = false;
      
  @override
  Widget build(BuildContext context) {

    final spinkit = Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SpinKitRing(color: Colors.blue[900], size: 175),
          SvgPicture.asset('resources/svg/main/spinner.svg', alignment: Alignment.center, width: 150),
        ],
      )
    );
    
    return _loaded ? __content(context, categoryList, null) : FutureBuilder(
      future: getList(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError)
              return __content(context, null, spinkit);
            else {
              return __content(context, snapshot.data, null);
            }
        }
      },
    );
  }

  __content(context, categoryList, spinkit)
  {
    for (var color in availableColors.entries)
    {
      colors.add(
        DropdownMenuItem(
          child: Text('${color.value}'),
          value: color
        )
      );
    }

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
                    child: (spinkit != null) ? spinkit : ListView(
                      children: [
                        Form(
                          key: _formKey,
                          child: __accountEdit(context, categoryList),
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

  Widget __accountEdit(context, categoryList)
  {

    List categoryListNames = new List<String>.unmodifiable(
      categoryList.map((e) => 
        e['name'].toString()
      ).toList()
    );
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SearchBar(
          hint: "Выберите категорию",
          items: categoryListNames,
          selectedItem: selectedCategory,
          onChanged: (item) {

            int index = categoryListNames.indexWhere((element) => item == element);

            setState(() {
              selectedCategory = categoryList[index];
            });
          },
        ),
        SizedBox(height: widget.padding),
        Text('Основные характеристики', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Артикул',
          placeholder: articulController.text,
          controller: articulController,
          type: TextInputType.number,
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
          label: 'Название',
          controller: nameController,
          placeholder: nameController.text,
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
        CountryCodePicker(
          onChanged: (CountryCode item){
            setState(() {
              countryProduct = item.code.toLowerCase();
            });
          },
          initialSelection: 'RU',
          showCountryOnly: true,
          showOnlyCountryWhenClosed: true,
          alignLeft: false,
        ),
        SizedBox(height: widget.padding),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInput(
              label: 'Минимальная цена (\$)',
              placeholder: minPriceController.text,
              controller: minPriceController,
              type: TextInputType.number,
              validator: (value) {
                if(value.isEmpty)
                {
                  return 'Поле не заполнено';
                }

                return null;
              }
            ),
            SizedBox(height: 10),
            CustomInput(
              label: 'Максимальная цена (\$)',
              placeholder: maxPriceController.text,
              controller: maxPriceController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
          ],
        ),
        SizedBox(height: widget.padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomInput(
              label: 'Минимальная партия',
              width: 200,
              placeholder: minOrderValueController.text,
              controller: minOrderValueController,
              type: TextInputType.number,
              validator: (value) {
                if(value.isEmpty)
                {
                  return 'Поле не заполнено';
                }

                return null;
              }
            ),
            SizedBox(width: 10),
            DropdownButton(
              hint: SizedBox(
                width: 100,
                child: Text(minOrderType[minOrderType.keys.first])
              ),
              items: [
                DropdownMenuItem(
                  child: Text('шт'),
                  value: {'pcs': 'шт'}
                ),
                DropdownMenuItem(
                  child: Text('коробок'),
                  value: {'bags': 'коробок'}
                ),
                DropdownMenuItem(
                  child: Text('килограмм'),
                  value: {'kg': 'килограмм'}
                ),
              ],
              onChanged: (item)
              {
                setState(() {
                  minOrderType = item;
                });
              }
            ),
          ],
        ),
        SizedBox(height: widget.padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomInput(
              label: 'Доступное количество',
              width: 200,
              placeholder: availableValueController.text,
              controller: availableValueController,
              type: TextInputType.number,
              validator: (value) {
                if(value.isEmpty)
                {
                  return 'Поле не заполнено';
                }

                return null;
              }
            ),
            SizedBox(width: 10),
            DropdownButton(
              hint: SizedBox(
                width: 100,
                child: Text(availableType[availableType.keys.first])
              ),
              items: [
                DropdownMenuItem(
                  child: Text('шт'),
                  value: {'pcs': 'шт'}
                ),
                DropdownMenuItem(
                  child: Text('коробок'),
                  value: {'bags': 'коробок'}
                ),
                DropdownMenuItem(
                  child: Text('килограмм'),
                  value: {'kg': 'килограмм'}
                ),
              ],
              onChanged: (item)
              {
                setState(() {
                  availableType = item;
                });
              }
            ),
          ],
        ),
        SizedBox(height: widget.padding),
        DropdownButton(
          hint: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (colorProduct.keys.first == 'transparent')
              ? Text("Цвет ")
              : Container(
                  height: 20,
                  width: 20,
                  color: HexColor.fromHex(colorProduct.keys.first ),
                ),
              Text(colorProduct[colorProduct.keys.first])
            ],
          ),
          items: colors,
          onChanged: (item)
          {
            setState(() {
              colorProduct = Map.fromEntries([item]);
            });
          }
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          height: 200,
          label: 'Описание товара',
          placeholder: descriptionController.text,
          controller: descriptionController,
          type: TextInputType.text,
          validator: (value) {
            return null;
          }, 
        ),
        SizedBox(height: widget.padding),
        CustomFilePicker(
          text: "Изображение для списка карточек товаров",
          choosenImage: previewImage,
          onPressed: () async {
            previewImage = await FilePicker.getFile(
              type: FileType.image,
              allowCompression: true
            );

            setState(() {
              previewImage = previewImage;
            });
          },
          afterRemove: (){
            setState(() {
              previewImage = null;
            });
          },
        ),
        SizedBox(height: widget.padding),
        CustomMultipleFilePicker(
          choosenImages: detailImages,
          text: "Изображения для просмотра карточек товаров",
          onPressed: () async {

            List<FileImage> _detailImages = [];

            List<File> _images = await FilePicker.getMultiFile(
              type: FileType.image,
              allowCompression: true
            );

            if( _detailImages.isNotEmpty)
            {
              for (var _banner in _images)
              {
                _detailImages.add(FileImage(_banner));
              }

              setState((){
                detailImages = _detailImages;
              });
            }
          },
          afterRemove: () {
            setState((){
              detailImages = detailImages;
            });
          }
        ),
        SizedBox(height: widget.padding),
        CustomMultipleFilePicker(
          choosenImages: describleImages,
          text: "Изображения для блока описание",
          onPressed: () async {

            List<FileImage> _describleImages = [];

            List<File> _images = await FilePicker.getMultiFile(
              type: FileType.image,
              allowCompression: true
            );

            if( _describleImages.isNotEmpty)
            {
              for (var _banner in _images)
              {
                _describleImages.add(FileImage(_banner));
              }

              setState((){
                describleImages = _describleImages;
              });
            }
          },
          afterRemove: () {
            setState((){
              describleImages = describleImages;
            });
          }
        ),
        SizedBox(height: widget.padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomInput(
              label: 'Вес',
              width: 190,
              placeholder: weightValueController.text,
              controller: weightValueController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
            SizedBox(width: 10),
            DropdownButton(
              hint: SizedBox(
                width: 120,
                child: Text(weightType[weightType.keys.first])
              ),
              items: [
                DropdownMenuItem(
                  child: Text('грамм'),
                  value: {'gr': 'грамм'}
                ),
                DropdownMenuItem(
                  child: Text('килограмм'),
                  value: {'kg': 'килограмм'}
                ),
                DropdownMenuItem(
                  child: Text('тонн'),
                  value: {'ton': 'тонн'}
                ),
              ],
              onChanged: (item)
              {
                setState(() {
                  weightType = item;
                });
              }
            ),
          ],
        ),
        SizedBox(height: widget.padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomInput(
              label: 'Длина',
              width: 50,
              placeholder: lenghtValueController.text,
              controller: lenghtValueController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
            SizedBox(width: 5),
            CustomInput(
              label: 'Высота',
              width: 50,
              placeholder: heightValueController.text,
              controller: heightValueController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
            SizedBox(width: 5),
            CustomInput(
              label: 'Ширина',
              width: 50,
              placeholder: widthValueController.text,
              controller: widthValueController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
            SizedBox(width: 5),
            DropdownButton(
              hint: SizedBox(
                width: 120,
                child: Text(sizeType[sizeType.keys.first])
              ),
              items: [
                DropdownMenuItem(
                  child: Text('мм'),
                  value: {'mm': 'мм'}
                ),
                DropdownMenuItem(
                  child: Text('см'),
                  value: {'cm': 'см'}
                ),
                DropdownMenuItem(
                  child: Text('м'),
                  value: {'m': 'м'}
                ),
              ],
              onChanged: (item)
              {
                setState(() {
                  sizeType = item;
                });
              }
            ),
          ],
        ),
        SizedBox(height: widget.padding),
        Center(
          child: CustomRaisedButton(
            onPressed: () async => await createProduct(context),
            color: Colors.white,
            child: Text('Сохранить'),
          )
        )
      ]
    );
  }

  Future getList() async
  {
    if(categoryList != null && _loaded == false)
    {
      setState(() {
        _loaded = true;
        categoryList = categoryList;
      });
    }
    
    List categories;

    categories = await Category.getAllList();

    return categories;
  }

  Future createProduct(context) async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return null;
    }

    if(countryProduct == null)
    {
      countryProduct = "ru";
    }

    if (_formKey.currentState.validate())
    {

      Map<String, dynamic> _data = {};
      Map _files = {};

      _data = {
        'category_id': selectedCategory['id'].toString(),
        'articul': articulController.text.toString(),
        'name': nameController.text.toString(),
        'country': countryProduct.toString().toUpperCase(),
        'min_price': minPriceController.text.toString(),
        'max_price':maxPriceController.text.toString(),
        'available': {
          'value': availableValueController.text.toString(),
          'type': availableType.keys.first.toString(),
        },
        'min_order': {
          'value': minOrderValueController.text.toString(),
          'type': minOrderType.keys.first.toString(),
        },
        'color': colorProduct.keys.first.toString(),
        'description': descriptionController.text.toString(),
        'seo_keywords': seoKeywordsController.text.toString(),
        'seo_title': seoTitleController.text.toString(),
        'seo_descriptions': seoDescriptionsController.text.toString(),
        'weight': {
          'value': weightValueController.text.toString(),
          'type': weightType.keys.first.toString(),
        },
        'lenght': {
          'value': lenghtValueController.text.toString(),
          'type': sizeType.keys.first.toString()
        },
        'width': {
          'value': widthValueController.text.toString(),
          'type': sizeType.keys.first.toString()
        },
        'height': {
          'value': heightValueController.text.toString(),
          'type': sizeType.keys.first.toString()
        }
      };

      _files.addEntries([
        MapEntry('preview_image', previewImage.path)
      ]);

      if(describleImages.isNotEmpty)
      {
        _files.addEntries([MapEntry('describle_images', [])]);

        for (var item in describleImages)
        {
          _files['describle_images'].add(item.file.path);
        }
      }

      if(detailImages.isNotEmpty)
      {
        _files.addEntries([MapEntry('detail_images', [])]);

        for (var item in detailImages)
        {
          _files['detail_images'].add(item.file.path);
        }
      }

      var result = await Product.create(auth, _data, _files, widget.profileId);

      if(result == true)
      {
        Navigator.pushReplacement(context, AnimatedScaleRoute(
          builder: (context) => ProductListPage(
              auth: auth,
              profileId: widget.profileId,
            )
          )
        );
      }
    }
  }
}