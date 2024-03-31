import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrpt;
import 'package:file_picker/file_picker.dart';

void main ()
{
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeWidget(),
    )
  );
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

String fileType="jpg";
class _HomeWidgetState extends State<HomeWidget> {
  File? file;
  bool storageStatus=false;
  @override
  initState()
  {
    super.initState();
  
  }
  requestStoragePermission() async
  {
    try 
    {
      var status = await Permission.storage.status;
      if(!status.isGranted)
      {
        await Permission.storage.request();
      }
    }catch(e)
    {
      log(e.toString());
    }
  }
  Future<void> pickImage() async
  {
    try 
    {
      await requestStoragePermission();
    FilePickerResult? filePicked = await FilePicker.platform.pickFiles();
    if(filePicked!=null)
    {
      String? path = filePicked.files.first.path;
      file= File(path.toString());
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar("File Picked"));
      });
    }
    }catch(e)
    {
      log(e.toString());
    }
  }
  mySnackBar(String message)
  {
    return SnackBar(
      content: Text(message),
      duration:const Duration(seconds: 1),
      padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:const Text("Encryption",style: TextStyle(fontWeight: FontWeight.w900),),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color:const Color.fromARGB(205, 223, 228, 227),
                      child: DropdownButton(
                        borderRadius: BorderRadius.circular(10),
                        underline: Container(),
                        value: fileType,
                        items: const [
                          DropdownMenuItem(
                            value: "jpg",
                            child: Text("JPG",style: TextStyle(fontWeight: FontWeight.w900),),
                          ),
                          DropdownMenuItem(
                            value: "png",
                            child: Text("PNG",style: TextStyle(fontWeight: FontWeight.w900),),
                          ),
                          DropdownMenuItem(
                            value: "mp4",
                            child: Text("MP4",style: TextStyle(fontWeight: FontWeight.w900),),
                          ),
                          DropdownMenuItem(
                            value: "pdf",
                            child: Text("PDF",style: TextStyle(fontWeight: FontWeight.w900),),
                          ),
                          DropdownMenuItem(
                            value: "doc",
                            child: Text("DOC",style: TextStyle(fontWeight: FontWeight.w900),),
                          ),
                        ], 
                      onChanged: (value){
                        setState(() {
                        fileType=value.toString();
                        });
                      }),
                    ),
                  ),
                 const SizedBox(height: 10,),
                  const Text(
                    "Pick the right format to Encrypt or Decrypt",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin:const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color.fromARGB(255, 226, 226, 226),
                    child: file==null?
                    IconButton(
                      onPressed: () async{
                        await pickImage();
                      },
                      icon:const Icon(Icons.file_open,size: 70,)):
                    IconButton(
                    onPressed: ()async{
                      await pickImage();
                    },
                    icon: const Icon(Icons.check,size: 70,color: Colors.green,),
                    )
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child:const Text("Encrypt and Save",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.white),),
                    onPressed: () async{
                      if(file!=null)
                      {
                          final plaintext = await file!.readAsBytes();
                          Encryption().encrypt(plaintext);
                      }
                    },
                  ),
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child:const Text("Decrypt and Save",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.white),),
                    onPressed: () async{
                      if(file!=null)
                      {
                          Uint8List plaintext = await file!.readAsBytes();
                          Encryption().decrypt(plaintext);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Encryption 
{
  static final mykey = encrpt.Key.fromUtf8("1245714587458888");
  static final myiv = encrpt.IV.fromUtf8("e16ce888a20dadb8");
  static final encryptor = encrpt.Encrypter(encrpt.AES(mykey));
  encrypt(plaintext)
  {
    final encrypted = encryptor.encryptBytes(plaintext,iv: myiv);
    saveEncryptedFile(encrypted.bytes);
  }
  saveEncryptedFile(encFile) async
  {
    try 
    {
    File newEncfile = File("/storage/emulated/0/Download/encrypted.aes");
    await newEncfile.writeAsBytes(encFile).then((value) {
      log("Encrypted successful");
    });
    }catch(e)
    {
      log(e.toString());
    }
  }
  decrypt(plaintext)
  {
    try 
    {
    Encrypted obj = Encrypted(plaintext);
    final decrypted = encryptor.decryptBytes(obj,iv: myiv);
    saveDecryptFile(decrypted);
    log("Decrypted successfuly");
    }catch(e)
    {
      log(e.toString());
    }
  }
  saveDecryptFile(decFile) async
  {
    try 
    {
    File newEncfile = File("/storage/emulated/0/Download/decrypted.$fileType");
    await newEncfile.writeAsBytes(decFile).then((value) {
      log("mission successful");
    });
    }catch(e)
    {
      log(e.toString());
    }
  }
}
