import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Formulario de Registro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegistroFormulario(),
    );
  }
}

class RegistroFormulario extends StatefulWidget {
  @override
  _RegistroFormularioState createState() => _RegistroFormularioState();
}

class _RegistroFormularioState extends State<RegistroFormulario> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  // Variables de género
  String _generoSeleccionado = 'M';

  // Variables para la fecha
  DateTime? _fechaSeleccionada;

  // Expresiones regulares para validación
  final RegExp nombreRegExp = RegExp(r'^[a-zA-Z\s]+$');
  final RegExp cedulaRegExp = RegExp(r'^\d{10}$');
  final RegExp telefonoRegExp = RegExp(r'^\d{7,10}$');
  final RegExp correoRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final RegExp contrasenaRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  // Función para mostrar el selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
        _fechaController.text = "${picked.toLocal()}".split(' ')[0]; // Formato YYYY-MM-DD
      });
    }
  }

  Future<void> postUser() async {
    final url = Uri.parse('http://localhost:8000/registrar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'cedula': _cedulaController.text,
        'telefono': _telefonoController.text,
        'fecha': _fechaController.text,
        'genero': _generoSeleccionado,
        'correo': _correoController.text,
        'contrasena': _contrasenaController.text,
      }),
    );

    if (response.statusCode == 200) {
      print('Usuario registrado exitosamente');
    } else {
      print('Error al registrar el usuario: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario de Registro'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  } else if (!nombreRegExp.hasMatch(value)) {
                    return 'El nombre solo puede contener letras';
                  }
                  return null;
                },
              ),

              // Campo Apellido
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El apellido es obligatorio';
                  } else if (!nombreRegExp.hasMatch(value)) {
                    return 'El apellido solo puede contener letras';
                  }
                  return null;
                },
              ),

              // Campo Cédula
              TextFormField(
                controller: _cedulaController,
                decoration: InputDecoration(labelText: 'Cédula'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La cédula es obligatoria';
                  } else if (!cedulaRegExp.hasMatch(value)) {
                    return 'La cédula debe tener 10 dígitos';
                  }
                  return null;
                },
              ),

              // Campo Teléfono
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El teléfono es obligatorio';
                  } else if (!telefonoRegExp.hasMatch(value)) {
                    return 'El teléfono debe tener entre 7 y 10 dígitos';
                  }
                  return null;
                },
              ),

              // Campo Fecha (con selector de fecha)
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _seleccionarFecha(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La fecha es obligatoria';
                  }
                  return null;
                },
              ),

              // Campo Género (Radio Buttons)
              Row(
                children: [
                  Text('Género:'),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'M',
                        groupValue: _generoSeleccionado,
                        onChanged: (value) {
                          setState(() {
                            _generoSeleccionado = value!;
                          });
                        },
                      ),
                      Text('Masculino'),
                      Radio<String>(
                        value: 'F',
                        groupValue: _generoSeleccionado,
                        onChanged: (value) {
                          setState(() {
                            _generoSeleccionado = value!;
                          });
                        },
                      ),
                      Text('Femenino'),
                    ],
                  ),
                ],
              ),

              // Campo Correo Electrónico
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo electrónico es obligatorio';
                  } else if (!correoRegExp.hasMatch(value)) {
                    return 'Ingrese un correo electrónico válido';
                  }
                  return null;
                },
              ),

              // Campo Contraseña
              TextFormField(
                controller: _contrasenaController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  } else if (!contrasenaRegExp.hasMatch(value)) {
                    return 'La contraseña debe tener al menos 8 caracteres, una letra mayúscula, una minúscula, un número y un carácter especial';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),
              // Botón de envío
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await postUser();
                  } else {
                    print('Errores en el formulario');
                  }
                },
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberar los controladores para evitar fugas de memoria
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}