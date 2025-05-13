import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inicializado correctamente");
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
  runApp(const EcoRutasApp());
}

class EcoRutasApp extends StatelessWidget {
  const EcoRutasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRutas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Pantalla inicial: Iniciar sesión o registrarse
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenido',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 139, 25),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo_ecorutas.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('INICIAR SESIÓN'),
              ),
              const SizedBox(height: 30),
              const Text(
                'Si no tienes cuenta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('REGISTRARTE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de iniciar sesión
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    Future<void> login(BuildContext context) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("Error al iniciar sesión: ${e.toString()}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => login(context),
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de registro con funcionalidad de Firebase y campos adicionales
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores para los campos de entrada
    TextEditingController nameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Función de registro con campos adicionales
    Future<void> register(BuildContext context) async {
  try {
    // Crear usuario con Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Generar ID numérico único derivado del uid (usando hashCode)
    int idUsuarioGenerado = userCredential.user?.uid.hashCode ?? 0;

    // Guardar datos en Firestore
    await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user?.uid).set({
      'nombre': nameController.text.trim(),
      'apellido': lastNameController.text.trim(),
      'correo': emailController.text.trim(),
      'contrasena': passwordController.text.trim(),
      'direccion': 'Dirección no especificada', // Puedes reemplazar con un valor dinámico
      'id_Usuario': idUsuarioGenerado, // Generar ID único numérico
      'reportes_Realizados': 0, // Inicializar en 0
      'telefono': '', // Inicializar vacío si no se proporciona
    });

    // Mostrar confirmación de registro exitoso
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registro Exitoso"),
        content: const Text("Tu cuenta ha sido creada correctamente. Ahora puedes iniciar sesión."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  } catch (e) {
    // Manejo de errores específicos
    if (e.toString().contains('email-already-in-use')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Correo en uso"),
          content: const Text("El correo ingresado ya está registrado. Usa otro correo o inicia sesión."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("No se pudo registrar tu cuenta: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}


    // Interfaz de usuario para la pantalla de registro
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => register(context),
              child: const Text('Registrarte'),
            ),
          ],
        ),
      ),
    );
  }
}


///Pantalla principal 

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoRutas'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Cambiar para alinear hacia arriba
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20), // Espacio superior
              child: Text(
                'Selecciona de acuerdo a tu interés',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el título y los elementos siguientes

            // Imagen y botón para "Recolector"
            Image.asset(
              'assets/recolector.png', // Cambia por el nombre de tu imagen
              width: 200, // Ajusta el tamaño según necesites
              height: 200,
            ),
            const SizedBox(height: 10), // Espacio entre imagen y botón
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecolectorScreen()),
                );
              },
              child: const Text(
                'RECOLECTOR',
                style: TextStyle(fontSize: 25),
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el primer conjunto y el segundo

            // Imagen y botón para "Habitante"
            Image.asset(
              'assets/habitante.png', // Cambia por el nombre de tu imagen
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 10), // Espacio entre imagen y botón
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HabitanteScreen()),
                );
              },
              child: const Text(
                'HABITANTE',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//// Pantalla para "Recolector"
class RecolectorScreen extends StatelessWidget {
  const RecolectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recolector'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra elementos verticalmente
          children: [
            // Texto centrado en la parte superior
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Seleccione una opción",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 80), // Espaciado entre el texto y los botones

            // Botón "Ya Registrado"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade300,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecolectorSignInScreen()),
                );
              },
              child: const Text(
                'Ya Registrado',
                style: TextStyle(fontSize: 20),
              ),
            ),

            const SizedBox(height: 30), // Espaciado entre los botones

            // Botón "Registrar Nuevo Recolector"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecolectorRegisterScreen()),
                );
              },
              child: const Text(
                'Registrar Nuevo Recolector',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Pantalla de registro de recolector
class RecolectorRegisterScreen extends StatelessWidget {
  const RecolectorRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController marcaCarroController = TextEditingController();
    final TextEditingController placasController = TextEditingController();
    final TextEditingController telefonoController = TextEditingController();
    final TextEditingController licenciaController = TextEditingController();
    final TextEditingController coloniaViviendaController = TextEditingController();

    Future<void> registerRecolector(BuildContext context) async {
      try {
        String idConductor = DateTime.now().millisecondsSinceEpoch.toString();

        await FirebaseFirestore.instance.collection('conductores').doc(idConductor).set({
          'nombre': nameController.text.trim(),
          'apellido': lastNameController.text.trim(),
          'correo': emailController.text.trim(),
          'contraseña': passwordController.text.trim(),
          'marca_Carro': marcaCarroController.text.trim(),
          'placas': placasController.text.trim(),
          'telefono': telefonoController.text.trim(),
          'licencia': licenciaController.text.trim(),
          'colonia_Vivienda': coloniaViviendaController.text.trim(),
          'disponibilidad': 'Disponible',
          'id_Conductor': idConductor.hashCode,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReportesScreen()),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("Ocurrió un error al registrar tus datos: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Recolector'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
              TextField(controller: marcaCarroController, decoration: const InputDecoration(labelText: 'Marca del Vehículo')),
              TextField(controller: placasController, decoration: const InputDecoration(labelText: 'Placas')),
              TextField(controller: telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextField(controller: licenciaController, decoration: const InputDecoration(labelText: 'Licencia')),
              TextField(controller: coloniaViviendaController, decoration: const InputDecoration(labelText: 'Colonia de Vivienda')),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen.shade200, padding: const EdgeInsets.all(16)),
                onPressed: () => registerRecolector(context),
                child: const Text('Registrar', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de inicio de sesión
class RecolectorSignInScreen extends StatelessWidget {
  const RecolectorSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> signIn(BuildContext context) async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('conductores')
          .where('correo', isEqualTo: emailController.text.trim())
          .where('contraseña', isEqualTo: passwordController.text.trim())
          .get();

      if (snapshot.docs.isNotEmpty) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReportesScreen()));
      } else {
        showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Error"), content: const Text("Credenciales incorrectas."), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión - Recolector'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => signIn(context), child: const Text("Iniciar Sesión")),
        ]),
      ),
    );
  }
}


// Nueva pantalla para ver los reportes
class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Basura'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Lista de reportes disponibles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Mostrar reportes normales
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('reportes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error al cargar los reportes.");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  final reportes = snapshot.data?.docs ?? [];
                  if (reportes.isEmpty) return const Text("No hay reportes normales disponibles.");

                  return ListView.builder(
                    itemCount: reportes.length,
                    itemBuilder: (context, index) {
                      final reporte = reportes[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text("Domicilio: ${reporte['domicilio']}"),
                          subtitle: Text("Contenedor: ${reporte['contenedor']}"),
                          trailing: Text("Fecha: ${reporte['fecha_Reporte'] ?? 'Sin fecha'}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text("Lista de reportes especiales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Mostrar reportes especiales
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('reportes_Especiales').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error al cargar los reportes especiales.");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  final reportesEspeciales = snapshot.data?.docs ?? [];
                  if (reportesEspeciales.isEmpty) return const Text("No hay reportes especiales disponibles.");

                  return ListView.builder(
                    itemCount: reportesEspeciales.length,
                    itemBuilder: (context, index) {
                      final reporte = reportesEspeciales[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text("Domicilio: ${reporte['domicilio']}"),
                          subtitle: Text("Colonia: ${reporte['colonia']}"),
                          trailing: Text("Fecha: ${reporte['fecha_Reporte'] ?? 'Sin fecha'}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




///pantalla de habiatante 
class HabitanteScreen extends StatefulWidget {
  const HabitanteScreen({super.key});

  @override
  _HabitanteScreenState createState() => _HabitanteScreenState();
}

class _HabitanteScreenState extends State<HabitanteScreen> {
  final TextEditingController domicilioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController coloniaController = TextEditingController();
  String? contenedorSeleccionado;
  DateTime? fechaSeleccionada;

  final List<String> contenedores = [
    "Contenedor 1",
    "Contenedor 2",
    "Contenedor 3",
    "Contenedor 4",
    "Contenedor 5",
    "Contenedor 6",
    "Contenedor 7",
  ];

  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (nuevaFecha != null) {
      setState(() {
        fechaSeleccionada = nuevaFecha;
      });
    }
  }

  Future<void> enviarReporte(BuildContext context) async {
    if (fechaSeleccionada == null || domicilioController.text.trim().isEmpty || descripcionController.text.trim().isEmpty || coloniaController.text.trim().isEmpty || contenedorSeleccionado == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Datos incompletos"),
          content: const Text("Por favor, completa todos los campos antes de enviar el reporte."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reportes').add({
        'fecha_Reporte': fechaSeleccionada!.toIso8601String(), // Se registrará correctamente la fecha
        'domicilio': domicilioController.text.trim(),
        'colonia': coloniaController.text.trim(),
        'contenedor': contenedorSeleccionado,
        'descripcion': descripcionController.text.trim(),
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Reporte Enviado"),
          content: const Text("Su reporte ha sido registrado correctamente."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("No se pudo registrar el reporte: $e"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Levantar Reporte'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Seleccione el contenedor más cercano:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ZoomImageScreen()));
                },
                child: Hero(
                  tag: 'zoomImagen',
                  child: Image.asset('assets/contenedores.png', width: 250, height: 200, fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 20),

              TextField(controller: domicilioController, decoration: const InputDecoration(labelText: 'Domicilio')),
              const SizedBox(height: 15),

              TextField(controller: coloniaController, decoration: const InputDecoration(labelText: 'Colonia')), // Se agregó colonia
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Contenedor Cercano'),
                value: contenedorSeleccionado,
                items: contenedores.map((contenedor) {
                  return DropdownMenuItem<String>(value: contenedor, child: Text(contenedor));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    contenedorSeleccionado = value;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextField(controller: descripcionController, decoration: const InputDecoration(labelText: 'Descripción de su hogar')),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Fecha del reporte:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    fechaSeleccionada != null
                        ? "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}"
                        : "No seleccionada",
                    style: const TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(onPressed: () => seleccionarFecha(context), child: const Text("Seleccionar Fecha")),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: () => enviarReporte(context), child: const Text("Enviar Reporte", style: TextStyle(fontSize: 20))),
              const SizedBox(height: 20),

              const Text("Si ningún contenedor te queda cerca, presiona el siguiente botón", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RecoleccionEspecialScreen()));
                },
                child: const Text("Solicitar recolección en domicilio", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// Pantalla de zoom en la imagen
class ZoomImageScreen extends StatelessWidget {
  const ZoomImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro para mejor visualización
      body: Center(
        child: Hero(
          tag: 'zoomImagen',
          child: InteractiveViewer( // Permite hacer zoom con gestos
            child: Image.asset('assets/contenedores.png'),
          ),
        ),
      ),
    );
  }
}


// Pantalla para recolección especial de basura
class RecoleccionEspecialScreen extends StatefulWidget {
  const RecoleccionEspecialScreen({super.key});

  @override
  _RecoleccionEspecialScreenState createState() => _RecoleccionEspecialScreenState();
}

class _RecoleccionEspecialScreenState extends State<RecoleccionEspecialScreen> {
  final TextEditingController domicilioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController coloniaController = TextEditingController();
  DateTime? fechaSeleccionada;

  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (nuevaFecha != null) {
      setState(() {
        fechaSeleccionada = nuevaFecha;
      });
    }
  }

  Future<void> enviarReporteEspecial(BuildContext context) async {
    if (fechaSeleccionada == null || domicilioController.text.trim().isEmpty || descripcionController.text.trim().isEmpty || coloniaController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Datos incompletos"),
          content: const Text("Por favor, completa todos los campos antes de enviar el reporte."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reportes_Especiales').add({
        'fecha_Reporte': fechaSeleccionada!.toIso8601String(),
        'domicilio': domicilioController.text.trim(),
        'colonia': coloniaController.text.trim(),
        'descripcion': descripcionController.text.trim(),
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Reporte Enviado"),
          content: const Text("Su solicitud de recolección especial ha sido registrada correctamente."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("No se pudo registrar el reporte: $e"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recolección Especial'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: domicilioController, decoration: const InputDecoration(labelText: 'Domicilio')),
            const SizedBox(height: 15),

            TextField(controller: coloniaController, decoration: const InputDecoration(labelText: 'Colonia')),
            const SizedBox(height: 15),

            TextField(controller: descripcionController, decoration: const InputDecoration(labelText: 'Descripción de su hogar')),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Fecha del reporte:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  fechaSeleccionada != null
                      ? "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}"
                      : "No seleccionada",
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(onPressed: () => seleccionarFecha(context), child: const Text("Seleccionar Fecha")),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(onPressed: () => enviarReporteEspecial(context), child: const Text("Enviar Solicitud")),
          ],
        ),
      ),
    );
  }
}
